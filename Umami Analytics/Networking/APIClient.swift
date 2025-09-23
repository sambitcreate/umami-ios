//
//  APIClient.swift
//  Umami Analytics
//
//  Created by Augment on 4/17/25.
//

import Foundation
import Combine

class APIClient {
    private var baseURL: URL
    private var authToken: String?
    private var apiKey: String?
    private var isCloud: Bool = false
    private let jsonDecoder: JSONDecoder
    private let jsonEncoder: JSONEncoder
    private var apiVersion: APIVersion = .unknown

    enum APIVersion {
        case v1
        case v2
        case unknown
    }

    init(serverURL: String) throws {
        guard let url = URL(string: serverURL) else {
            throw AuthError.invalidURL
        }
        self.baseURL = url

        self.jsonDecoder = JSONDecoder()
        self.jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase

        self.jsonEncoder = JSONEncoder()
        self.jsonEncoder.keyEncodingStrategy = .convertToSnakeCase

        // We'll detect the API version when we first authenticate
    }

    func setBaseURL(_ urlString: String) throws {
        guard let url = URL(string: urlString) else {
            throw AuthError.invalidURL
        }
        self.baseURL = url
    }

    func setAuthToken(_ token: String) {
        self.authToken = token
    }

    func clearAuthToken() {
        self.authToken = nil
    }

    // MARK: - Cloud Configuration

    func configureForCloud(apiKey: String) {
        self.isCloud = true
        self.apiKey = apiKey
        // In Cloud mode, base should be api.umami.is (without /v1); paths will be normalized.
        if baseURL.host?.contains("api.umami.is") == false {
            if let url = URL(string: "https://api.umami.is") {
                self.baseURL = url
            }
        }
    }

    func setAPIKey(_ key: String?) {
        self.apiKey = key
    }

    // MARK: - Helper Methods

    private func createRequest(path: String, method: String, body: Encodable? = nil) -> URLRequest {
        // Normalize path for Cloud vs self-hosted
        let effectivePath: String
        if isCloud {
            effectivePath = normalizeCloudPath(path)
        } else {
            effectivePath = path
        }

        // IMPORTANT: Do NOT use appendingPathComponent when `effectivePath` may include a query string.
        // Using appendingPathComponent would percent-encode '?' into '%3F', breaking endpoints like
        // /api/websites/{id}/metrics?startAt=... (seen in logs).
        let apiURL: URL
        if let url = URL(string: effectivePath, relativeTo: baseURL) {
            // `URL(string:relativeTo:)` preserves query components in `effectivePath` correctly.
            apiURL = url
        } else {
            // Fallback for strictly path-only inputs (no query). This mirrors previous behavior.
            apiURL = baseURL.appendingPathComponent(effectivePath)
        }

        var request = URLRequest(url: apiURL)
        request.httpMethod = method
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        // Prefer Cloud API key header when configured
        if isCloud, let apiKey = apiKey, !apiKey.isEmpty {
            request.addValue(apiKey, forHTTPHeaderField: "x-umami-api-key")
        } else if let token = authToken {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        if let body = body {
            do {
                request.httpBody = try jsonEncoder.encode(body)
            } catch {
                print("Error encoding request body: \(error)")
            }
        }

        return request
    }

    private func normalizeCloudPath(_ path: String) -> String {
        // Convert self-hosted style paths to Cloud v1 paths.
        // Rules:
        //  - "/api/v1/..." -> "/v1/..."
        //  - "/api/..."     -> "/v1/..."
        //  - "/v1/..."      -> unchanged
        //  - otherwise, prefix with "/v1" if it starts with "/"
        if path.hasPrefix("/api/v1/") {
            let remainder = String(path.dropFirst("/api/v1".count)) // keeps leading '/'
            return "/v1" + remainder
        } else if path.hasPrefix("/api/") {
            let remainder = String(path.dropFirst("/api".count)) // keeps leading '/'
            return "/v1" + remainder
        } else if path.hasPrefix("/v1/") {
            return path
        } else if path.hasPrefix("/") {
            return "/v1" + path
        } else {
            return "/v1/\(path)"
        }
    }

    private func performRequest<T: Decodable>(request: URLRequest) -> AnyPublisher<T, Error> {
        print("🌐 API Request: \(request.httpMethod ?? "GET") \(request.url?.absoluteString ?? "unknown URL")")

        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse else {
                    print("❌ Unknown response type")
                    throw APIError.unknown
                }

                print("📡 Response: \(httpResponse.statusCode) for \(request.url?.path ?? "unknown path")")

                // Try to log response data for debugging
                if let responseString = String(data: data, encoding: .utf8) {
                    if responseString.count > 500 {
                        print("📦 Response data (truncated): \(String(responseString.prefix(500)))...")
                    } else {
                        print("📦 Response data: \(responseString)")
                    }
                }

                if httpResponse.statusCode == 401 {
                    print("🔒 Unauthorized access")
                    throw APIError.unauthorized
                }

                if httpResponse.statusCode == 404 {
                    // Special handling for 404 errors - might be API version incompatibility
                    print("⚠️ 404 Not Found: This might indicate an API version incompatibility")

                    // Try to detect if this is a v1 vs v2 API issue
                    if request.url?.path.contains("/api/websites") == true {
                        // Check if we need to try alternative endpoint formats
                        if self.apiVersion == .unknown {
                            print("🔄 API version unknown, will try alternative endpoints on next request")
                            self.detectAPIVersion()
                        }
                        throw APIError.endpointNotFound(request.url?.path ?? "unknown")
                    } else {
                        throw APIError.serverError("Endpoint not found (404): \(request.url?.path ?? "unknown")")
                    }
                }

                if httpResponse.statusCode != 200 {
                    // Try to parse error message from response
                    if let errorResponse = try? JSONDecoder().decode([String: String].self, from: data),
                       let errorMessage = errorResponse["error"] {
                        print("❌ Server error: \(errorMessage)")
                        throw APIError.serverError(errorMessage)
                    } else {
                        print("❌ HTTP error: \(httpResponse.statusCode)")
                        throw APIError.serverError("Status code: \(httpResponse.statusCode)")
                    }
                }

                return data
            }
            .flatMap { data -> AnyPublisher<T, Error> in
                // Special handling for RealtimeData to support different API versions
                if T.self == RealtimeData.self {
                    return self.decodeRealtimeData(data: data, request: request)
                        .map { $0 as! T }
                        .eraseToAnyPublisher()
                } else {
                    // Standard decoding for other types
                    return Just(data)
                        .decode(type: T.self, decoder: self.jsonDecoder)
                        .mapError { error in
                            if let decodingError = error as? DecodingError {
                                print("❌ Decoding error: \(decodingError)")
                                // Log more details about the decoding error
                                switch decodingError {
                                case let .typeMismatch(type, context):
                                    print("   Type mismatch: Expected \(type) at \(context.codingPath)")
                                case let .valueNotFound(type, context):
                                    print("   Value not found: Expected \(type) at \(context.codingPath)")
                                case let .keyNotFound(key, context):
                                    print("   Key not found: \(key) at \(context.codingPath)")
                                case let .dataCorrupted(context):
                                    print("   Data corrupted: \(context)")
                                @unknown default:
                                    print("   Unknown decoding error")
                                }
                                return APIError.decodingError
                            } else {
                                return error
                            }
                        }
                        .eraseToAnyPublisher()
                }
            }
            .mapError { error in
                if let apiError = error as? APIError {
                    return apiError
                } else {
                    print("❌ Network error: \(error.localizedDescription)")
                    return APIError.networkError(error)
                }
            }
            .eraseToAnyPublisher()
    }

    // Helper method to extract website ID from URL path
    private func extractWebsiteId(from path: String) -> String? {
        // Common path formats:
        // /api/websites/{id}/realtime
        // /api/website/{id}/realtime
        // /api/realtime/{id}
        // /api/v1/websites/{id}/realtime
        // /api/v1/website/{id}/realtime

        let pathComponents = path.split(separator: "/")

        // For /api/realtime/{id} format
        if pathComponents.count >= 3 && pathComponents[1] == "api" && pathComponents[2] == "realtime" {
            if pathComponents.count >= 4 {
                return String(pathComponents[3])
            }
        }

        // For other formats like /api/websites/{id}/realtime or /api/website/{id}/realtime
        if pathComponents.count >= 4 && pathComponents[1] == "api" {
            if pathComponents[2] == "websites" || pathComponents[2] == "website" {
                if pathComponents.count >= 5 {
                    return String(pathComponents[3])
                }
            }

            // For /api/v1/websites/{id}/realtime or /api/v1/website/{id}/realtime
            if pathComponents[2] == "v1" && pathComponents.count >= 5 {
                if pathComponents[3] == "websites" || pathComponents[3] == "website" {
                    if pathComponents.count >= 6 {
                        return String(pathComponents[4])
                    }
                }
            }
        }

        print("⚠️ Could not extract website ID from path: \(path)")
        return nil
    }

    // Special decoder for RealtimeData to handle different API formats
    private func decodeRealtimeData(data: Data, request: URLRequest) -> AnyPublisher<RealtimeData, Error> {
        // First try standard decoding
        return Just(data)
            .decode(type: RealtimeData.self, decoder: jsonDecoder)
            .catch { error -> AnyPublisher<RealtimeData, Error> in
                if let decodingError = error as? DecodingError {
                    print("⚠️ Standard RealtimeData decoding failed: \(decodingError)")

                    // Extract websiteId from the URL path
                    let websiteId = self.extractWebsiteId(from: request.url?.path ?? "")

                    // Try to decode as the newer format (without websiteId)
                    do {
                        // First, try to decode the JSON to see what fields are available
                        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                            print("🔍 Examining JSON structure: \(json.keys)")

                            // Check if this is the newer format with countries, urls, etc. but no websiteId
                            if json["websiteId"] == nil &&
                               (json["countries"] != nil || json["urls"] != nil || json["timestamp"] != nil) {

                                // Create a new RealtimeData with the extracted websiteId
                                var realtimeData = try self.jsonDecoder.decode(RealtimeData.self, from: data)

                                // Set the websiteId from the URL
                                if let id = websiteId {
                                    print("✅ Successfully decoded newer RealtimeData format, adding websiteId: \(id)")
                                    realtimeData = RealtimeData(
                                        websiteId: id,
                                        timestamp: realtimeData.timestamp,
                                        pageviews: realtimeData.pageviews,
                                        sessions: realtimeData.sessions,
                                        events: realtimeData.events,
                                        countries: realtimeData.countries,
                                        urls: realtimeData.urls,
                                        referrers: realtimeData.referrers,
                                        series: realtimeData.series,
                                        totals: realtimeData.totals
                                    )
                                }

                                return Just(realtimeData)
                                    .setFailureType(to: Error.self)
                                    .eraseToAnyPublisher()
                            }
                        }
                    } catch {
                        print("❌ Failed to decode alternative RealtimeData format: \(error)")
                    }
                }

                // If all decoding attempts fail, return the original error
                return Fail(error: error).eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    private func detectAPIVersion() {
        // This method will be called when we encounter a 404 error
        // We'll try to determine if we're dealing with a v1 or v2 API
        print("🔍 Attempting to detect Umami API version...")

        // Make a request to a common endpoint that exists in both v1 and v2
        let request = createRequest(path: "/api/me", method: "GET")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    // This endpoint exists in v2
                    self.apiVersion = .v2
                    print("✅ Detected Umami API v2")

                    // Check if this is a newer version of v2 that uses different realtime endpoint
                    self.checkRealtimeEndpointFormat()
                } else if httpResponse.statusCode == 404 {
                    // Try a v1 specific endpoint
                    let v1Request = self.createRequest(path: "/api/account", method: "GET")

                    URLSession.shared.dataTask(with: v1Request) { data, response, error in
                        if let httpResponse = response as? HTTPURLResponse {
                            if httpResponse.statusCode == 200 {
                                self.apiVersion = .v1
                                print("✅ Detected Umami API v1")

                                // Check if this is a newer version of v1 that uses different realtime endpoint
                                self.checkRealtimeEndpointFormat()
                            } else {
                                print("❓ Unable to determine API version, defaulting to v2")
                                self.apiVersion = .v2
                                self.checkRealtimeEndpointFormat()
                            }
                        }
                    }.resume()
                } else {
                    print("❓ Unable to determine API version, defaulting to v2")
                    self.apiVersion = .v2
                    self.checkRealtimeEndpointFormat()
                }
            } else {
                print("❓ Unable to determine API version, defaulting to v2")
                self.apiVersion = .v2
                self.checkRealtimeEndpointFormat()
            }
        }.resume()
    }

    private func checkRealtimeEndpointFormat() {
        // Some Umami versions use different realtime endpoint formats
        // Let's check a few common patterns

        // First, try the standard v2 format with a test website ID
        let testWebsiteId = "test-website-id"
        let v2RealtimeRequest = createRequest(path: "/api/websites/\(testWebsiteId)/realtime", method: "GET")

        print("🔍 Checking realtime endpoint format...")

        URLSession.shared.dataTask(with: v2RealtimeRequest) { data, response, error in
            if let httpResponse = response as? HTTPURLResponse {
                // If we get a 401 or 403, that's actually good - it means the endpoint exists but we're not authorized
                // A 404 means the endpoint format is wrong
                if httpResponse.statusCode == 401 || httpResponse.statusCode == 403 {
                    print("✅ Confirmed standard realtime endpoint format: /api/websites/{id}/realtime")
                } else if httpResponse.statusCode == 404 {
                    // Try alternative format: /api/realtime/{id}
                    let altRealtimeRequest = self.createRequest(path: "/api/realtime/\(testWebsiteId)", method: "GET")

                    URLSession.shared.dataTask(with: altRealtimeRequest) { data, response, error in
                        if let httpResponse = response as? HTTPURLResponse {
                            if httpResponse.statusCode == 401 || httpResponse.statusCode == 403 {
                                print("✅ Confirmed alternative realtime endpoint format: /api/realtime/{id}")
                                // Store this information for future use
                                UserDefaults.standard.set("alt_realtime", forKey: "umami_realtime_format")
                            } else {
                                // Try one more format: /api/website/{id}/realtime (singular 'website')
                                let singularRealtimeRequest = self.createRequest(path: "/api/website/\(testWebsiteId)/realtime", method: "GET")

                                URLSession.shared.dataTask(with: singularRealtimeRequest) { data, response, error in
                                    if let httpResponse = response as? HTTPURLResponse {
                                        if httpResponse.statusCode == 401 || httpResponse.statusCode == 403 {
                                            print("✅ Confirmed singular realtime endpoint format: /api/website/{id}/realtime")
                                            // Store this information for future use
                                            UserDefaults.standard.set("singular_realtime", forKey: "umami_realtime_format")
                                        } else {
                                            print("⚠️ Could not determine realtime endpoint format, will try multiple formats")
                                            // We'll try all formats when making actual requests
                                            UserDefaults.standard.set("try_all", forKey: "umami_realtime_format")
                                        }
                                    }
                                }.resume()
                            }
                        }
                    }.resume()
                }
            }
        }.resume()
    }

    // Helper method to try alternative API endpoints when a 404 is encountered
    private func tryAlternativeEndpoint<T: Decodable>(originalPath: String) -> AnyPublisher<T, Error>? {
        // Based on the detected API version, try alternative endpoint formats

        // If we're dealing with website stats endpoints, they might have different formats in v1 vs v2
        if originalPath.contains("/api/websites") && originalPath.contains("/stats") {
            if apiVersion == .v1 {
                // Try v1 format
                if let websiteId = extractWebsiteId(from: originalPath) {
                    let v1Path = "/api/website/\(websiteId)/stats"
                    print("🔄 Trying alternative v1 endpoint: \(v1Path)")
                    let request = createRequest(path: v1Path, method: "GET")
                    return performRequest(request: request)
                }
            } else if apiVersion == .v2 || apiVersion == .unknown {
                // Try v2 format if we're not sure
                if let websiteId = extractWebsiteId(from: originalPath) {
                    let v2Path = "/api/websites/\(websiteId)/stats"
                    print("🔄 Trying alternative v2 endpoint: \(v2Path)")
                    let request = createRequest(path: v2Path, method: "GET")
                    return performRequest(request: request)
                }
            }
        }

        // Similar logic for metrics endpoints
        if originalPath.contains("/api/websites") && originalPath.contains("/metrics") {
            if let websiteId = extractWebsiteId(from: originalPath) {
                // Check if we've already determined the metrics endpoint format
                let metricsFormat = UserDefaults.standard.string(forKey: "umami_metrics_format")

                if metricsFormat == "alt_metrics" {
                    // Use the alternative format: /api/metrics/{id}
                    let altPath = "/api/metrics/\(websiteId)"
                    print("🔄 Trying alternative metrics endpoint: \(altPath)")
                    let request = createRequest(path: altPath, method: "GET")
                    return performRequest(request: request)
                } else if metricsFormat == "singular_metrics" || apiVersion == .v1 {
                    // Use the singular format: /api/website/{id}/metrics
                    let singularPath = "/api/website/\(websiteId)/metrics"
                    print("🔄 Trying singular metrics endpoint: \(singularPath)")
                    let request = createRequest(path: singularPath, method: "GET")
                    return performRequest(request: request)
                } else if metricsFormat == "snake_case_params" {
                    // Try with snake_case parameter names
                    // We need to modify the query parameters
                    if var urlComponents = URLComponents(string: originalPath) {
                        var newQueryItems: [URLQueryItem] = []

                        // Convert camelCase to snake_case for parameter names
                        if let queryItems = urlComponents.queryItems {
                            for item in queryItems {
                                if item.name == "startAt" {
                                    newQueryItems.append(URLQueryItem(name: "start_at", value: item.value))
                                } else if item.name == "endAt" {
                                    newQueryItems.append(URLQueryItem(name: "end_at", value: item.value))
                                } else {
                                    newQueryItems.append(item)
                                }
                            }
                            urlComponents.queryItems = newQueryItems
                        }

                        if let newPath = urlComponents.string {
                            print("🔄 Trying metrics endpoint with snake_case params: \(newPath)")
                            let request = createRequest(path: newPath, method: "GET")
                            return performRequest(request: request)
                        }
                    }
                } else if metricsFormat == "try_all" || metricsFormat == nil {
                    // Try multiple formats in sequence
                    // First try the v1 format
                    let v1Path = "/api/website/\(websiteId)/metrics"
                    print("🔄 Trying v1 metrics endpoint: \(v1Path)")
                    let v1Request = createRequest(path: v1Path, method: "GET")

                    return performRequest(request: v1Request)
                        .handleEvents(receiveOutput: { _ in
                            print("✅ Found working endpoint: singular_metrics")
                            UserDefaults.standard.set("singular_metrics", forKey: "umami_metrics_format")
                        })
                        .catch { error -> AnyPublisher<T, Error> in
                            if case APIError.endpointNotFound = error {
                                // Try the alternative format
                                let altPath = "/api/metrics/\(websiteId)"
                                print("🔄 Trying alternative metrics endpoint: \(altPath)")
                                let altRequest = self.createRequest(path: altPath, method: "GET")

                                return self.performRequest(request: altRequest)
                                    .handleEvents(receiveOutput: { _ in
                                        print("✅ Found working endpoint: alt_metrics")
                                        UserDefaults.standard.set("alt_metrics", forKey: "umami_metrics_format")
                                    })
                                    .catch { error -> AnyPublisher<T, Error> in
                                        // If all else fails, use original request
                                        print("❌ All metrics endpoint formats failed")
                                        return Fail(error: error).eraseToAnyPublisher()
                                    }
                                    .eraseToAnyPublisher()
                            }
                            return Fail(error: error).eraseToAnyPublisher()
                        }
                        .eraseToAnyPublisher()
                }
            }
        }

        // For pageviews
        if originalPath.contains("/api/websites") && originalPath.contains("/pageviews") {
            if apiVersion == .v1 {
                if let websiteId = extractWebsiteId(from: originalPath) {
                    let v1Path = "/api/website/\(websiteId)/pageviews"
                    print("🔄 Trying alternative v1 endpoint: \(v1Path)")
                    let request = createRequest(path: v1Path, method: "GET")
                    return performRequest(request: request)
                }
            }
        }

        // For realtime data
        if originalPath.contains("/api/websites") && originalPath.contains("/realtime") {
            if let websiteId = extractWebsiteId(from: originalPath) {
                // Check if we've already determined the realtime endpoint format
                let realtimeFormat = UserDefaults.standard.string(forKey: "umami_realtime_format")

                if realtimeFormat == "alt_realtime" {
                    // Use the alternative format: /api/realtime/{id}
                    let altPath = "/api/realtime/\(websiteId)"
                    print("🔄 Trying alternative realtime endpoint: \(altPath)")
                    let request = createRequest(path: altPath, method: "GET")
                    return performRequest(request: request)
                } else if realtimeFormat == "singular_realtime" || apiVersion == .v1 {
                    // Use the singular format: /api/website/{id}/realtime
                    let singularPath = "/api/website/\(websiteId)/realtime"
                    print("🔄 Trying singular realtime endpoint: \(singularPath)")
                    let request = createRequest(path: singularPath, method: "GET")
                    return performRequest(request: request)
                } else if realtimeFormat == "try_all" || realtimeFormat == nil {
                    // Try multiple formats in sequence
                    // First try the v1 format
                    let v1Path = "/api/website/\(websiteId)/realtime"
                    print("🔄 Trying v1 realtime endpoint: \(v1Path)")
                    let v1Request = createRequest(path: v1Path, method: "GET")

                    return performRequest(request: v1Request)
                        .catch { error -> AnyPublisher<T, Error> in
                            if case APIError.endpointNotFound = error {
                                // Try the alternative format
                                let altPath = "/api/realtime/\(websiteId)"
                                print("🔄 Trying alternative realtime endpoint: \(altPath)")
                                let altRequest = self.createRequest(path: altPath, method: "GET")

                                return self.performRequest(request: altRequest)
                                    .catch { error -> AnyPublisher<T, Error> in
                                        // If all else fails, use mock data
                                        print("❌ All realtime endpoint formats failed")
                                        return Fail(error: error).eraseToAnyPublisher()
                                    }
                                    .eraseToAnyPublisher()
                            }
                            return Fail(error: error).eraseToAnyPublisher()
                        }
                        .eraseToAnyPublisher()
                }
            }
        }

        return nil
    }

    // This method has been replaced by the more comprehensive version above

    // MARK: - Authentication

    func login(username: String, password: String) -> AnyPublisher<AuthResponse, Error> {
        let credentials = AuthCredentials(username: username, password: password)
        let request = createRequest(path: "/api/auth/login", method: "POST", body: credentials)

        return performRequest(request: request)
            .handleEvents(receiveOutput: { [weak self] _ in
                // After successful login, detect the API version
                self?.detectAPIVersion()
            })
            .eraseToAnyPublisher()
    }

    func verifyToken() -> AnyPublisher<User, Error> {
        // Cloud flow: validate API key by calling /v1/me
        if isCloud {
            guard apiKey != nil else {
                return Fail(error: APIError.unauthorized).eraseToAnyPublisher()
            }

            let meReq = createRequest(path: "/api/me", method: "GET") // will normalize to /v1/me

            // Try to decode directly to User
            let meAsUser: AnyPublisher<User, Error> = performRequest(request: meReq)
                .eraseToAnyPublisher()

            // Or wrapped { user: User }
            struct MeResponse: Codable { let user: User }
            let meWrappedPublisher: AnyPublisher<MeResponse, Error> = performRequest(request: meReq)
            let meAsWrappedUser: AnyPublisher<User, Error> = meWrappedPublisher
                .map { $0.user }
                .eraseToAnyPublisher()

            return meAsUser
                .catch { _ in meAsWrappedUser }
                .eraseToAnyPublisher()
        }

        // Self-hosted flow: must have bearer token
        guard authToken != nil else {
            return Fail(error: APIError.unauthorized).eraseToAnyPublisher()
        }

        // Some Umami deployments expect POST for /api/auth/verify or expose /api/me instead.
        // Strategy:
        // 1) Try GET /api/auth/verify
        // 2) On 405/404, try POST /api/auth/verify
        // 3) If that fails, try GET /api/me decoding either User or { user: User }

        // Step 1: GET /api/auth/verify
        let getVerify = createRequest(path: "/api/auth/verify", method: "GET")
        let publisher: AnyPublisher<User, Error> = performRequest(request: getVerify)
            .handleEvents(receiveOutput: { [weak self] _ in
                if self?.apiVersion == .unknown { self?.detectAPIVersion() }
            })
            .eraseToAnyPublisher()

        return publisher.catch { [weak self] error -> AnyPublisher<User, Error> in
            guard let self = self else { return Fail(error: error).eraseToAnyPublisher() }

            // Only fall back on method/endpoint issues
            if case APIError.serverError(let message) = error, message.contains("405") || message.contains("404") {
                print("🔄 auth/verify fallback: trying POST /api/auth/verify due to \(message)")
                // Step 2: POST /api/auth/verify
                let postVerify = self.createRequest(path: "/api/auth/verify", method: "POST")
                return self.performRequest(request: postVerify)
                    .handleEvents(receiveOutput: { [weak self] _ in
                        if self?.apiVersion == .unknown { self?.detectAPIVersion() }
                    })
                    .catch { postError -> AnyPublisher<User, Error> in
                        print("⚠️ POST /api/auth/verify failed: \(postError)")
                        // Step 3: GET /api/me (v2) – try decoding User first, then { user: User }
                        let meReq = self.createRequest(path: "/api/me", method: "GET")

                        // Try to decode directly to User
                        let meAsUser: AnyPublisher<User, Error> = self.performRequest(request: meReq)
                            .eraseToAnyPublisher()

                        // If that fails, try decoding { user: User }
                        struct MeResponse: Codable { let user: User }
                        let meWrappedPublisher: AnyPublisher<MeResponse, Error> = self.performRequest(request: meReq)
                        let meAsWrappedUser: AnyPublisher<User, Error> = meWrappedPublisher
                            .map { $0.user }
                            .eraseToAnyPublisher()

                        return meAsUser
                            .catch { _ in meAsWrappedUser }
                            .eraseToAnyPublisher()
                    }
                    .eraseToAnyPublisher()
            }

            return Fail(error: error).eraseToAnyPublisher()
        }
        .eraseToAnyPublisher()
    }

    func getServerInfo() -> AnyPublisher<ServerInfo, Error> {
        // This endpoint might not exist in all Umami versions, but we'll try it
        let request = createRequest(path: "/api/status", method: "GET")

        return performRequest(request: request)
            .catch { error -> AnyPublisher<ServerInfo, Error> in
                // If the status endpoint doesn't exist, create a basic server info
                if case APIError.endpointNotFound = error {
                    let basicInfo = ServerInfo(
                        url: self.baseURL.absoluteString,
                        name: "Umami Server"
                    )
                    return Just(basicInfo)
                        .setFailureType(to: Error.self)
                        .eraseToAnyPublisher()
                }

                return Fail(error: error).eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    func logout() -> AnyPublisher<EmptyResponse, Error> {
        guard authToken != nil else {
            return Just(EmptyResponse()).setFailureType(to: Error.self).eraseToAnyPublisher()
        }

        let request = createRequest(path: "/api/auth/logout", method: "POST")
        return performRequest(request: request)
    }

    // MARK: - Websites

    func getWebsites(page: Int = 1, pageSize: Int = 1000) -> AnyPublisher<WebsiteListResponse, Error> {
        // Many Umami deployments paginate /api/websites. Default page size can hide items.
        // Request a large page to show all sites in the app's list view.
        var components = URLComponents(string: "/api/websites")
        components?.queryItems = [
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "pageSize", value: String(pageSize))
        ]

        guard let path = components?.string else {
            return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
        }

        let request = createRequest(path: path, method: "GET")
        return performRequest(request: request)
    }

    func getWebsite(id: String) -> AnyPublisher<WebsiteModel, Error> {
        let request = createRequest(path: "/api/websites/\(id)", method: "GET")
        return performRequest(request: request)
    }

    func getWebsiteStats(id: String, dateRange: DateRange) -> AnyPublisher<WebsiteStatsResponse, Error> {
        // Track persistent failures but don't use mock data
        let persistentFailureCount = UserDefaults.standard.integer(forKey: "umami_stats_failure_count")
        if persistentFailureCount > 5 {
            print("⚠️ Note: Multiple persistent failures with stats data")
        }

        // Format the date parameters carefully to avoid NaN errors
        let startAtStr = String(format: "%.0f", Double(dateRange.startAt))
        let endAtStr = String(format: "%.0f", Double(dateRange.endAt))

        print("📊 Stats request with dates: start=\(startAtStr), end=\(endAtStr)")

        var components = URLComponents(string: "/api/websites/\(id)/stats")
        components?.queryItems = [
            URLQueryItem(name: "startAt", value: startAtStr),
            URLQueryItem(name: "endAt", value: endAtStr)
        ]

        if let timezone = dateRange.timezone {
            components?.queryItems?.append(URLQueryItem(name: "timezone", value: timezone))
        }

        guard let path = components?.string else {
            return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
        }

        let request = createRequest(path: path, method: "GET")

        return performRequest(request: request)
            .catch { error -> AnyPublisher<WebsiteStatsResponse, Error> in
                // If we get a 404 error or other server error, try alternative endpoints
                if case APIError.endpointNotFound = error {
                    print("⚠️ Primary stats endpoint failed (404), trying alternatives")
                    return self.tryAlternativeStatsEndpoints(id: id, dateRange: dateRange, startAtStr: startAtStr, endAtStr: endAtStr)
                } else if case APIError.serverError = error {
                    print("⚠️ Primary stats endpoint failed (server error), trying alternatives")
                    return self.tryAlternativeStatsEndpoints(id: id, dateRange: dateRange, startAtStr: startAtStr, endAtStr: endAtStr)
                } else if case APIError.decodingError = error {
                    // If we get a decoding error, the API might be returning a different format
                    print("⚠️ Decoding error for stats data: \(error.localizedDescription)")

                    // Increment the failure counter for tracking purposes
                    let currentCount = UserDefaults.standard.integer(forKey: "umami_stats_failure_count")
                    UserDefaults.standard.set(currentCount + 1, forKey: "umami_stats_failure_count")

                    // Return the error
                    return Fail(error: APIError.decodingError)
                        .eraseToAnyPublisher()
                }

                // If we can't handle the error, just pass it through
                return Fail(error: error).eraseToAnyPublisher()
            }
            .handleEvents(receiveOutput: { _ in
                // On success, reset the failure counter
                UserDefaults.standard.set(0, forKey: "umami_stats_failure_count")
            })
            .eraseToAnyPublisher()
    }

    func getWebsiteMetrics(id: String, dateRange: DateRange) -> AnyPublisher<WebsiteMetricsResponse, APIError> {
        // Track persistent failures but don't use mock data
        let persistentFailureCount = UserDefaults.standard.integer(forKey: "umami_metrics_failure_count")
        if persistentFailureCount > 5 {
            print("⚠️ Note: Multiple persistent failures with metrics data")
        }

        let startAtStr = String(format: "%.0f", Double(dateRange.startAt))
        let endAtStr = String(format: "%.0f", Double(dateRange.endAt))
        let unit = dateRange.unit
        let tz = dateRange.timezone

        print("📊 Metrics request with dates (ms): start=\(startAtStr), end=\(endAtStr), unit=\(unit)")

        // Helper to build a metrics request with required 'type' param
        func metricsRequest(type: String) -> URLRequest? {
            var c = URLComponents(string: "/api/websites/\(id)/metrics")
            var items = [
                URLQueryItem(name: "type", value: type),
                URLQueryItem(name: "startAt", value: startAtStr),
                URLQueryItem(name: "endAt", value: endAtStr)
            ]
            items.append(URLQueryItem(name: "unit", value: unit))
            if let tz = tz { items.append(URLQueryItem(name: "timezone", value: tz)) }
            c?.queryItems = items
            guard let path = c?.string else { return nil }
            return createRequest(path: path, method: "GET")
        }

        // Generic shapes from Umami metrics APIs
        struct XY: Codable { let x: String?; let y: Int?; let value: Int?; let url: String?; let referrer: String?; let name: String?; let device: String?; let os: String?; let country: String?; let title: String? }
        struct XYEnvelope: Codable { let data: [XY]?; let metrics: [XY]? }
        func decodeXY(_ data: Data) throws -> [XY] {
            if let env = try? self.jsonDecoder.decode(XYEnvelope.self, from: data) {
                if let list = env.data { return list }
                if let list = env.metrics { return list }
            }
            if let list = try? self.jsonDecoder.decode([XY].self, from: data) { return list }
            // Fallback: try to coerce dynamically
            if let arr = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] {
                return arr.map { dict in
                    let x = dict["x"] as? String ?? dict["name"] as? String ?? dict["url"] as? String ?? dict["referrer"] as? String
                    let y = dict["y"] as? Int ?? dict["value"] as? Int
                    return XY(x: x, y: y, value: nil, url: nil, referrer: nil, name: nil, device: nil, os: nil, country: nil, title: nil)
                }
            }
            throw APIError.decodingError
        }

        // Pageviews + sessions series endpoint
        struct SeriesPoint: Codable { let date: String?; let value: Int?; let x: String?; let y: Int? }
        struct PageviewsResp: Codable { let pageviews: [SeriesPoint]?; let sessions: [SeriesPoint]? }
        func decodeSeries(_ data: Data) throws -> ([PageviewMetric], [SessionMetric]) {
            if let env = try? self.jsonDecoder.decode(PageviewsResp.self, from: data) {
                let p = (env.pageviews ?? []).compactMap { pt in
                    let d = pt.date ?? pt.x
                    let v = pt.value ?? pt.y
                    if let d = d, let v = v { return PageviewMetric(date: d, value: v) }
                    return nil
                }
                let s = (env.sessions ?? []).compactMap { pt in
                    let d = pt.date ?? pt.x
                    let v = pt.value ?? pt.y
                    if let d = d, let v = v { return SessionMetric(date: d, value: v) }
                    return nil
                }
                return (p, s)
            }
            // Fallback: top-level array to pageviews only
            if let arr = try? self.jsonDecoder.decode([SeriesPoint].self, from: data) {
                let p = arr.compactMap { pt -> PageviewMetric? in
                    let d = pt.date ?? pt.x
                    let v = pt.value ?? pt.y
                    if let d = d, let v = v { return PageviewMetric(date: d, value: v) }
                    return nil
                }
                return (p, [])
            }
            throw APIError.decodingError
        }

        // Build requests
        guard let urlsReq = metricsRequest(type: "url"),
              let refsReq = metricsRequest(type: "referrer"),
              let browsersReq = metricsRequest(type: "browser"),
              let osReq = metricsRequest(type: "os"),
              let devicesReq = metricsRequest(type: "device"),
              let countriesReq = metricsRequest(type: "country") else {
            return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
        }

        var pvComponents = URLComponents(string: "/api/websites/\(id)/pageviews")
        var pvItems = [
            URLQueryItem(name: "startAt", value: startAtStr),
            URLQueryItem(name: "endAt", value: endAtStr),
            URLQueryItem(name: "unit", value: unit)
        ]
        if let tz = tz { pvItems.append(URLQueryItem(name: "timezone", value: tz)) }
        pvComponents?.queryItems = pvItems
        guard let pvPath = pvComponents?.string else {
            return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
        }
        let pvReq = createRequest(path: pvPath, method: "GET")

        // Fetch each metric category
        let urlsP: AnyPublisher<[PageMetric], Error> = performRequest(request: urlsReq)
            .tryMap { data -> [PageMetric] in
                let list = try decodeXY(data)
                return list.compactMap { xy in
                    let url = xy.url ?? xy.x
                    guard let url = url else { return nil }
                    let val = xy.y ?? xy.value ?? 0
                    return PageMetric(url: url, title: xy.title, value: val)
                }
            }
            .mapError { $0 }
            .eraseToAnyPublisher()

        let refsP: AnyPublisher<[ReferrerMetric], Error> = performRequest(request: refsReq)
            .tryMap { data -> [ReferrerMetric] in
                let list = try decodeXY(data)
                return list.compactMap { xy in
                    let ref = xy.referrer ?? xy.x ?? xy.name
                    guard let ref = ref else { return nil }
                    let val = xy.y ?? xy.value ?? 0
                    return ReferrerMetric(referrer: ref, value: val)
                }
            }
            .mapError { $0 }
            .eraseToAnyPublisher()

        let browsersP: AnyPublisher<[BrowserMetric], Error> = performRequest(request: browsersReq)
            .tryMap { data -> [BrowserMetric] in
                let list = try decodeXY(data)
                return list.compactMap { xy in
                    let name = xy.name ?? xy.x
                    guard let name = name else { return nil }
                    let val = xy.y ?? xy.value ?? 0
                    return BrowserMetric(name: name, value: val)
                }
            }
            .mapError { $0 }
            .eraseToAnyPublisher()

        let osP: AnyPublisher<[OSMetric], Error> = performRequest(request: osReq)
            .tryMap { data -> [OSMetric] in
                let list = try decodeXY(data)
                return list.compactMap { xy in
                    let name = xy.os ?? xy.name ?? xy.x
                    guard let name = name else { return nil }
                    let val = xy.y ?? xy.value ?? 0
                    return OSMetric(name: name, value: val)
                }
            }
            .mapError { $0 }
            .eraseToAnyPublisher()

        let devicesP: AnyPublisher<[DeviceMetric], Error> = performRequest(request: devicesReq)
            .tryMap { data -> [DeviceMetric] in
                let list = try decodeXY(data)
                return list.compactMap { xy in
                    let name = xy.device ?? xy.name ?? xy.x
                    guard let name = name else { return nil }
                    let val = xy.y ?? xy.value ?? 0
                    return DeviceMetric(device: name, value: val)
                }
            }
            .mapError { $0 }
            .eraseToAnyPublisher()

        let countriesP: AnyPublisher<[CountryMetric], Error> = performRequest(request: countriesReq)
            .tryMap { data -> [CountryMetric] in
                let list = try decodeXY(data)
                return list.compactMap { xy in
                    let codeOrName = xy.country ?? xy.name ?? xy.x
                    guard let label = codeOrName else { return nil }
                    let val = xy.y ?? xy.value ?? 0
                    return CountryMetric(code: label.uppercased(), name: label, value: val)
                }
            }
            .mapError { $0 }
            .eraseToAnyPublisher()

        let pageviewsP: AnyPublisher<(pageviews: [PageviewMetric], sessions: [SessionMetric]), Error> = performRequest(request: pvReq)
            .tryMap { data in
                try decodeSeries(data)
            }
            .mapError { $0 }
            .eraseToAnyPublisher()

        // Combine results
        let combined = Publishers.Zip3(Publishers.Zip(urlsP, refsP), Publishers.Zip(browsersP, osP), Publishers.Zip(devicesP, countriesP))
            .zip(pageviewsP)
            .map { (grouped, series) -> WebsiteMetricsResponse in
                let ((pages, refs), (browsers, oss), (devices, countries)) = grouped
                let pageviews = series.pageviews
                let sessions = series.sessions

                let metrics = WebsiteMetrics(
                    pageviews: pageviews,
                    sessions: sessions,
                    events: [],
                    countries: countries,
                    browsers: browsers,
                    os: oss,
                    devices: devices,
                    referrers: refs,
                    pages: pages
                )

                let startISO = ISO8601DateFormatter().string(from: Date(timeIntervalSince1970: Double(dateRange.startAt) / 1000))
                let endISO = ISO8601DateFormatter().string(from: Date(timeIntervalSince1970: Double(dateRange.endAt) / 1000))
                return WebsiteMetricsResponse(websiteId: id, startDate: startISO, endDate: endISO, metrics: metrics)
            }
            .mapError { error in
                if let apiError = error as? APIError { return apiError }
                return APIError.networkError(error)
            }
            .handleEvents(receiveOutput: { _ in
                UserDefaults.standard.set(0, forKey: "umami_metrics_failure_count")
            })
            .eraseToAnyPublisher()

        return combined
    }

    func getWebsitePageviews(id: String, dateRange: DateRange) -> AnyPublisher<[PageviewMetric], Error> {
        var components = URLComponents(string: "/api/websites/\(id)/pageviews")
        components?.queryItems = [
            URLQueryItem(name: "startAt", value: "\(dateRange.startAt)"),
            URLQueryItem(name: "endAt", value: "\(dateRange.endAt)"),
            URLQueryItem(name: "unit", value: dateRange.unit)
        ]

        if let timezone = dateRange.timezone {
            components?.queryItems?.append(URLQueryItem(name: "timezone", value: timezone))
        }

        guard let path = components?.string else {
            return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
        }

        let request = createRequest(path: path, method: "GET")

        return performRequest(request: request)
            .catch { error -> AnyPublisher<[PageviewMetric], Error> in
                // If we get a 404 error, try alternative endpoints based on API version
                if case APIError.endpointNotFound = error,
                   let alternativePublisher: AnyPublisher<[PageviewMetric], Error> = self.tryAlternativeEndpoint(originalPath: path) {
                    return alternativePublisher
                }

                // If we can't handle the error, just pass it through
                return Fail(error: error).eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    // Helper method for trying alternative stats endpoints
    private func tryAlternativeStatsEndpoints(id: String, dateRange: DateRange, startAtStr: String, endAtStr: String) -> AnyPublisher<WebsiteStatsResponse, Error> {
        print("⚠️ Primary stats endpoint failed, trying alternatives")

        // Try all possible endpoint formats in sequence

        // 1. Try v1 format: /api/website/{id}/stats
        let v1Path = "/api/website/\(id)/stats"
        var v1Components = URLComponents(string: v1Path)
        v1Components?.queryItems = [
            URLQueryItem(name: "startAt", value: startAtStr),
            URLQueryItem(name: "endAt", value: endAtStr)
        ]

        if let timezone = dateRange.timezone {
            v1Components?.queryItems?.append(URLQueryItem(name: "timezone", value: timezone))
        }

        guard let v1FullPath = v1Components?.string else {
            return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
        }

        print("🔄 Trying v1 stats endpoint: \(v1FullPath)")
        let v1Request = self.createRequest(path: v1FullPath, method: "GET")

        return self.performRequest(request: v1Request)
            .catch { _ -> AnyPublisher<WebsiteStatsResponse, Error> in
                // 2. Try alternative format with different parameter names
                let altPath = "/api/websites/\(id)/stats"
                var altComponents = URLComponents(string: altPath)
                altComponents?.queryItems = [
                    URLQueryItem(name: "start_at", value: startAtStr),
                    URLQueryItem(name: "end_at", value: endAtStr)
                ]

                if let timezone = dateRange.timezone {
                    altComponents?.queryItems?.append(URLQueryItem(name: "timezone", value: timezone))
                }

                guard let altFullPath = altComponents?.string else {
                    return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
                }

                print("🔄 Trying alternative stats endpoint with snake_case params: \(altFullPath)")
                let altRequest = self.createRequest(path: altFullPath, method: "GET")

                return self.performRequest(request: altRequest)
                    .catch { _ -> AnyPublisher<WebsiteStatsResponse, Error> in
                        // 3. Try another common format: /api/v1/websites/{id}/stats
                        let v1ApiPath = "/api/v1/websites/\(id)/stats"
                        var v1ApiComponents = URLComponents(string: v1ApiPath)
                        v1ApiComponents?.queryItems = [
                            URLQueryItem(name: "startAt", value: startAtStr),
                            URLQueryItem(name: "endAt", value: endAtStr)
                        ]

                        if let timezone = dateRange.timezone {
                            v1ApiComponents?.queryItems?.append(URLQueryItem(name: "timezone", value: timezone))
                        }

                        guard let v1ApiFullPath = v1ApiComponents?.string else {
                            return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
                        }

                        print("🔄 Trying v1 API stats endpoint: \(v1ApiFullPath)")
                        let v1ApiRequest = self.createRequest(path: v1ApiFullPath, method: "GET")

                        return self.performRequest(request: v1ApiRequest)
                            .catch { error -> AnyPublisher<WebsiteStatsResponse, Error> in
                                // If all else fails, pass the error through
                                print("⚠️ All stats endpoints failed: \(error.localizedDescription)")

                                // Increment the failure counter for tracking purposes
                                let currentCount = UserDefaults.standard.integer(forKey: "umami_stats_failure_count")
                                UserDefaults.standard.set(currentCount + 1, forKey: "umami_stats_failure_count")

                                // Return the error
                                return Fail(error: APIError.endpointNotFound("All stats endpoints failed"))
                                    .eraseToAnyPublisher()
                            }
                            .eraseToAnyPublisher()
                    }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    // MARK: - Realtime

    // Helper method for trying alternative metrics endpoints
    private func tryAlternativeMetricsEndpoints(id: String, dateRange: DateRange, startAtStr: String, endAtStr: String) -> AnyPublisher<WebsiteMetricsResponse, Error> {
        print("⚠️ Primary metrics endpoint failed, trying alternatives")

        // Try all possible endpoint formats in sequence

        // Convert timestamps to seconds format (some Umami versions expect seconds instead of milliseconds)
        let startAtSecondsStr = String(format: "%.0f", Double(dateRange.startAt) / 1000)
        let endAtSecondsStr = String(format: "%.0f", Double(dateRange.endAt) / 1000)

        // Convert timestamps to ISO date strings (some Umami versions expect ISO strings)
        let startAtISOStr = ISO8601DateFormatter().string(from: Date(timeIntervalSince1970: Double(dateRange.startAt) / 1000))
        let endAtISOStr = ISO8601DateFormatter().string(from: Date(timeIntervalSince1970: Double(dateRange.endAt) / 1000))

        print("🔍 Trying with multiple date formats:")
        print("  - Milliseconds: start=\(startAtStr), end=\(endAtStr)")
        print("  - Seconds: start=\(startAtSecondsStr), end=\(endAtSecondsStr)")
        print("  - ISO: start=\(startAtISOStr), end=\(endAtISOStr)")

        // 1. Try v1 format: /api/website/{id}/metrics
        let v1Path = "/api/website/\(id)/metrics"
        var v1Components = URLComponents(string: v1Path)
        v1Components?.queryItems = [
            URLQueryItem(name: "startAt", value: startAtStr),
            URLQueryItem(name: "endAt", value: endAtStr),
            URLQueryItem(name: "unit", value: dateRange.unit)
        ]

        if let timezone = dateRange.timezone {
            v1Components?.queryItems?.append(URLQueryItem(name: "timezone", value: timezone))
        }

        guard let v1FullPath = v1Components?.string else {
            return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
        }

        print("🔄 Trying v1 metrics endpoint: \(v1FullPath)")
        let v1Request = self.createRequest(path: v1FullPath, method: "GET")

        return self.performRequest(request: v1Request)
            .handleEvents(receiveOutput: { _ in
                // Store the successful format for future use
                print("✅ Found working endpoint: singular_metrics")
                UserDefaults.standard.set("singular_metrics", forKey: "umami_metrics_format")
                UserDefaults.standard.set(0, forKey: "umami_metrics_failure_count")
            })
            .catch { _ -> AnyPublisher<WebsiteMetricsResponse, Error> in
                // 2. Try alternative format: /api/metrics/{id}
                let altPath = "/api/metrics/\(id)"
                var altComponents = URLComponents(string: altPath)
                altComponents?.queryItems = [
                    URLQueryItem(name: "startAt", value: startAtStr),
                    URLQueryItem(name: "endAt", value: endAtStr),
                    URLQueryItem(name: "unit", value: dateRange.unit)
                ]

                if let timezone = dateRange.timezone {
                    altComponents?.queryItems?.append(URLQueryItem(name: "timezone", value: timezone))
                }

                guard let altFullPath = altComponents?.string else {
                    return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
                }

                print("🔄 Trying alternative metrics endpoint: \(altFullPath)")
                let altRequest = self.createRequest(path: altFullPath, method: "GET")

                return self.performRequest(request: altRequest)
                    .handleEvents(receiveOutput: { _ in
                        // Store the successful format for future use
                        print("✅ Found working endpoint: alt_metrics")
                        UserDefaults.standard.set("alt_metrics", forKey: "umami_metrics_format")
                        UserDefaults.standard.set(0, forKey: "umami_metrics_failure_count")
                    })
                    .catch { _ -> AnyPublisher<WebsiteMetricsResponse, Error> in
                        // 3. Try standard format with snake_case parameter names
                        let snakeCasePath = "/api/websites/\(id)/metrics"
                        var snakeCaseComponents = URLComponents(string: snakeCasePath)
                        snakeCaseComponents?.queryItems = [
                            URLQueryItem(name: "start_at", value: startAtStr),
                            URLQueryItem(name: "end_at", value: endAtStr),
                            URLQueryItem(name: "unit", value: dateRange.unit)
                        ]

                        if let timezone = dateRange.timezone {
                            snakeCaseComponents?.queryItems?.append(URLQueryItem(name: "timezone", value: timezone))
                        }

                        guard let snakeCaseFullPath = snakeCaseComponents?.string else {
                            return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
                        }

                        print("🔄 Trying metrics endpoint with snake_case params: \(snakeCaseFullPath)")
                        let snakeCaseRequest = self.createRequest(path: snakeCaseFullPath, method: "GET")

                        return self.performRequest(request: snakeCaseRequest)
                            .handleEvents(receiveOutput: { _ in
                                // Store the successful format for future use
                                print("✅ Found working endpoint: snake_case_params")
                                UserDefaults.standard.set("snake_case_params", forKey: "umami_metrics_format")
                                UserDefaults.standard.set(0, forKey: "umami_metrics_failure_count")
                            })
                            .catch { _ -> AnyPublisher<WebsiteMetricsResponse, Error> in
                                // 4. Try v1 plural format: /api/v1/websites/{id}/metrics
                                let v1ApiPath = "/api/v1/websites/\(id)/metrics"
                                var v1ApiComponents = URLComponents(string: v1ApiPath)
                                v1ApiComponents?.queryItems = [
                                    URLQueryItem(name: "startAt", value: startAtStr),
                                    URLQueryItem(name: "endAt", value: endAtStr),
                                    URLQueryItem(name: "unit", value: dateRange.unit)
                                ]

                                if let timezone = dateRange.timezone {
                                    v1ApiComponents?.queryItems?.append(URLQueryItem(name: "timezone", value: timezone))
                                }

                                guard let v1ApiFullPath = v1ApiComponents?.string else {
                                    return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
                                }

                                print("🔄 Trying v1 API plural metrics endpoint: \(v1ApiFullPath)")
                                let v1ApiRequest = self.createRequest(path: v1ApiFullPath, method: "GET")

                                return self.performRequest(request: v1ApiRequest)
                                    .handleEvents(receiveOutput: { _ in
                                        // Store the successful format for future use
                                        print("✅ Found working endpoint: v1_plural_metrics")
                                        UserDefaults.standard.set("v1_plural_metrics", forKey: "umami_metrics_format")
                                        UserDefaults.standard.set(0, forKey: "umami_metrics_failure_count")
                                    })
                                    .catch { _ -> AnyPublisher<WebsiteMetricsResponse, Error> in
                                        // 5. Try v1 singular format: /api/v1/website/{id}/metrics
                                        let v1ApiSingularPath = "/api/v1/website/\(id)/metrics"
                                        var v1ApiSingularComponents = URLComponents(string: v1ApiSingularPath)
                                        v1ApiSingularComponents?.queryItems = [
                                            URLQueryItem(name: "startAt", value: startAtStr),
                                            URLQueryItem(name: "endAt", value: endAtStr),
                                            URLQueryItem(name: "unit", value: dateRange.unit)
                                        ]

                                        if let timezone = dateRange.timezone {
                                            v1ApiSingularComponents?.queryItems?.append(URLQueryItem(name: "timezone", value: timezone))
                                        }

                                        guard let v1ApiSingularFullPath = v1ApiSingularComponents?.string else {
                                            return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
                                        }

                                        print("🔄 Trying v1 API singular metrics endpoint: \(v1ApiSingularFullPath)")
                                        let v1ApiSingularRequest = self.createRequest(path: v1ApiSingularFullPath, method: "GET")

                                        return self.performRequest(request: v1ApiSingularRequest)
                                            .handleEvents(receiveOutput: { _ in
                                                // Store the successful format for future use
                                                print("✅ Found working endpoint: v1_singular_metrics")
                                                UserDefaults.standard.set("v1_singular_metrics", forKey: "umami_metrics_format")
                                                UserDefaults.standard.set(0, forKey: "umami_metrics_failure_count")
                                            })
                                            .catch { _ -> AnyPublisher<WebsiteMetricsResponse, Error> in
                                                // 6. Try v2 format: /api/v2/websites/{id}/metrics
                                                let v2Path = "/api/v2/websites/\(id)/metrics"
                                                var v2Components = URLComponents(string: v2Path)
                                                v2Components?.queryItems = [
                                                    URLQueryItem(name: "startAt", value: startAtStr),
                                                    URLQueryItem(name: "endAt", value: endAtStr),
                                                    URLQueryItem(name: "unit", value: dateRange.unit)
                                                ]

                                                if let timezone = dateRange.timezone {
                                                    v2Components?.queryItems?.append(URLQueryItem(name: "timezone", value: timezone))
                                                }

                                                guard let v2FullPath = v2Components?.string else {
                                                    return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
                                                }

                                                print("🔄 Trying v2 API metrics endpoint: \(v2FullPath)")
                                                let v2Request = self.createRequest(path: v2FullPath, method: "GET")

                                                return self.performRequest(request: v2Request)
                                                    .handleEvents(receiveOutput: { _ in
                                                        // Store the successful format for future use
                                                        print("✅ Found working endpoint: v2_metrics")
                                                        UserDefaults.standard.set("v2_metrics", forKey: "umami_metrics_format")
                                                        UserDefaults.standard.set(0, forKey: "umami_metrics_failure_count")
                                                    })
                                                    .catch { _ -> AnyPublisher<WebsiteMetricsResponse, Error> in
                                                        // 7. Try with seconds instead of milliseconds
                                                        let secondsPath = "/api/websites/\(id)/metrics"
                                                        var secondsComponents = URLComponents(string: secondsPath)
                                                        secondsComponents?.queryItems = [
                                                            URLQueryItem(name: "startAt", value: startAtSecondsStr),
                                                            URLQueryItem(name: "endAt", value: endAtSecondsStr),
                                                            URLQueryItem(name: "unit", value: dateRange.unit)
                                                        ]

                                                        if let timezone = dateRange.timezone {
                                                            secondsComponents?.queryItems?.append(URLQueryItem(name: "timezone", value: timezone))
                                                        }

                                                        guard let secondsFullPath = secondsComponents?.string else {
                                                            return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
                                                        }

                                                        print("🔄 Trying metrics endpoint with seconds timestamps: \(secondsFullPath)")
                                                        let secondsRequest = self.createRequest(path: secondsFullPath, method: "GET")

                                                        return self.performRequest(request: secondsRequest)
                                                            .handleEvents(receiveOutput: { _ in
                                                                // Store the successful format for future use
                                                                print("✅ Found working endpoint: seconds_timestamps")
                                                                UserDefaults.standard.set("seconds_timestamps", forKey: "umami_metrics_format")
                                                                UserDefaults.standard.set(0, forKey: "umami_metrics_failure_count")
                                                            })
                                                            .catch { _ -> AnyPublisher<WebsiteMetricsResponse, Error> in
                                                                // 8. Try with ISO date strings
                                                                let isoPath = "/api/websites/\(id)/metrics"
                                                                var isoComponents = URLComponents(string: isoPath)
                                                                isoComponents?.queryItems = [
                                                                    URLQueryItem(name: "startAt", value: startAtISOStr),
                                                                    URLQueryItem(name: "endAt", value: endAtISOStr),
                                                                    URLQueryItem(name: "unit", value: dateRange.unit)
                                                                ]

                                                                if let timezone = dateRange.timezone {
                                                                    isoComponents?.queryItems?.append(URLQueryItem(name: "timezone", value: timezone))
                                                                }

                                                                guard let isoFullPath = isoComponents?.string else {
                                                                    return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
                                                                }

                                                                print("🔄 Trying metrics endpoint with ISO date strings: \(isoFullPath)")
                                                                let isoRequest = self.createRequest(path: isoFullPath, method: "GET")

                                                                return self.performRequest(request: isoRequest)
                                                                    .handleEvents(receiveOutput: { _ in
                                                                        // Store the successful format for future use
                                                                        print("✅ Found working endpoint: iso_dates")
                                                                        UserDefaults.standard.set("iso_dates", forKey: "umami_metrics_format")
                                                                        UserDefaults.standard.set(0, forKey: "umami_metrics_failure_count")
                                                                    })
                                                                    .catch { _ -> AnyPublisher<WebsiteMetricsResponse, Error> in
                                                                        // 9. Try without unit parameter
                                                                        let noUnitPath = "/api/websites/\(id)/metrics"
                                                                        var noUnitComponents = URLComponents(string: noUnitPath)
                                                                        noUnitComponents?.queryItems = [
                                                                            URLQueryItem(name: "startAt", value: startAtStr),
                                                                            URLQueryItem(name: "endAt", value: endAtStr)
                                                                        ]

                                                                        if let timezone = dateRange.timezone {
                                                                            noUnitComponents?.queryItems?.append(URLQueryItem(name: "timezone", value: timezone))
                                                                        }

                                                                        guard let noUnitFullPath = noUnitComponents?.string else {
                                                                            return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
                                                                        }

                                                                        print("🔄 Trying metrics endpoint without unit parameter: \(noUnitFullPath)")
                                                                        let noUnitRequest = self.createRequest(path: noUnitFullPath, method: "GET")

                                                                        return self.performRequest(request: noUnitRequest)
                                                                            .handleEvents(receiveOutput: { _ in
                                                                                // Store the successful format for future use
                                                                                print("✅ Found working endpoint: no_unit")
                                                                                UserDefaults.standard.set("no_unit", forKey: "umami_metrics_format")
                                                                                UserDefaults.standard.set(0, forKey: "umami_metrics_failure_count")
                                                                            })
                                                                            .catch { error -> AnyPublisher<WebsiteMetricsResponse, Error> in
                                                                                // If all else fails, pass the error through
                                                                                print("⚠️ All metrics endpoints failed: \(error.localizedDescription)")

                                                                                // Increment the failure counter for tracking purposes
                                                                                let currentCount = UserDefaults.standard.integer(forKey: "umami_metrics_failure_count")
                                                                                UserDefaults.standard.set(currentCount + 1, forKey: "umami_metrics_failure_count")

                                                                                // Return the error
                                                                                return Fail(error: APIError.endpointNotFound("All metrics endpoints failed"))
                                                                                    .eraseToAnyPublisher()
                                                                            }
                                                                            .eraseToAnyPublisher()
                                                                    }
                                                                    .eraseToAnyPublisher()
                                                            }
                                                            .eraseToAnyPublisher()
                                                    }
                                                    .eraseToAnyPublisher()
                                            }
                                            .eraseToAnyPublisher()
                                    }
                                    .eraseToAnyPublisher()
                            }
                            .eraseToAnyPublisher()
                    }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    // Helper method for trying alternative realtime endpoints
    private func tryAlternativeRealtimeEndpoints(websiteId: String) -> AnyPublisher<RealtimeData, Error> {
        print("⚠️ Primary realtime endpoint failed, trying alternatives")

        // Try all possible endpoint formats in sequence

        // 1. Try v1 format: /api/website/{id}/realtime
        let v1Path = "/api/website/\(websiteId)/realtime"
        print("🔄 Trying v1 realtime endpoint: \(v1Path)")
        let v1Request = self.createRequest(path: v1Path, method: "GET")

        return self.performRequest(request: v1Request)
            .handleEvents(receiveOutput: { _ in
                // Store the successful format for future use
                print("✅ Found working endpoint: singular_realtime")
                UserDefaults.standard.set("singular_realtime", forKey: "umami_realtime_format")
                UserDefaults.standard.set(0, forKey: "umami_realtime_failure_count")
            })
            .catch { _ -> AnyPublisher<RealtimeData, Error> in
                // 2. Try alternative format: /api/realtime/{id}
                let altPath = "/api/realtime/\(websiteId)"
                print("🔄 Trying alternative realtime endpoint: \(altPath)")
                let altRequest = self.createRequest(path: altPath, method: "GET")

                return self.performRequest(request: altRequest)
                    .handleEvents(receiveOutput: { _ in
                        // Store the successful format for future use
                        print("✅ Found working endpoint: alt_realtime")
                        UserDefaults.standard.set("alt_realtime", forKey: "umami_realtime_format")
                        UserDefaults.standard.set(0, forKey: "umami_realtime_failure_count")
                    })
                    .catch { _ -> AnyPublisher<RealtimeData, Error> in
                        // 3. Try another common format: /api/v1/websites/{id}/realtime
                        let v1ApiPath = "/api/v1/websites/\(websiteId)/realtime"
                        print("🔄 Trying v1 API realtime endpoint: \(v1ApiPath)")
                        let v1ApiRequest = self.createRequest(path: v1ApiPath, method: "GET")

                        return self.performRequest(request: v1ApiRequest)
                            .handleEvents(receiveOutput: { _ in
                                // Store the successful format for future use
                                print("✅ Found working endpoint: v1_plural_realtime")
                                UserDefaults.standard.set("v1_plural_realtime", forKey: "umami_realtime_format")
                                UserDefaults.standard.set(0, forKey: "umami_realtime_failure_count")
                            })
                            .catch { _ -> AnyPublisher<RealtimeData, Error> in
                                // 4. Try one more format: /api/v1/website/{id}/realtime
                                let v1ApiSingularPath = "/api/v1/website/\(websiteId)/realtime"
                                print("🔄 Trying v1 API singular realtime endpoint: \(v1ApiSingularPath)")
                                let v1ApiSingularRequest = self.createRequest(path: v1ApiSingularPath, method: "GET")

                                return self.performRequest(request: v1ApiSingularRequest)
                                    .handleEvents(receiveOutput: { _ in
                                        // Store the successful format for future use
                                        print("✅ Found working endpoint: v1_singular_realtime")
                                        UserDefaults.standard.set("v1_singular_realtime", forKey: "umami_realtime_format")
                                        UserDefaults.standard.set(0, forKey: "umami_realtime_failure_count")
                                    })
                                    .catch { _ -> AnyPublisher<RealtimeData, Error> in
                                        // 5. Try v2 format: /api/v2/websites/{id}/realtime
                                        let v2Path = "/api/v2/websites/\(websiteId)/realtime"
                                        print("🔄 Trying v2 API realtime endpoint: \(v2Path)")
                                        let v2Request = self.createRequest(path: v2Path, method: "GET")

                                        return self.performRequest(request: v2Request)
                                            .handleEvents(receiveOutput: { _ in
                                                // Store the successful format for future use
                                                print("✅ Found working endpoint: v2_realtime")
                                                UserDefaults.standard.set("v2_realtime", forKey: "umami_realtime_format")
                                                UserDefaults.standard.set(0, forKey: "umami_realtime_failure_count")
                                            })
                                            .catch { _ -> AnyPublisher<RealtimeData, Error> in
                                                // 6. Try v2 singular format: /api/v2/website/{id}/realtime
                                                let v2SingularPath = "/api/v2/website/\(websiteId)/realtime"
                                                print("🔄 Trying v2 API singular realtime endpoint: \(v2SingularPath)")
                                                let v2SingularRequest = self.createRequest(path: v2SingularPath, method: "GET")

                                                return self.performRequest(request: v2SingularRequest)
                                                    .handleEvents(receiveOutput: { _ in
                                                        // Store the successful format for future use
                                                        print("✅ Found working endpoint: v2_singular_realtime")
                                                        UserDefaults.standard.set("v2_singular_realtime", forKey: "umami_realtime_format")
                                                        UserDefaults.standard.set(0, forKey: "umami_realtime_failure_count")
                                                    })
                                                    .catch { error -> AnyPublisher<RealtimeData, Error> in
                                                        // If all else fails, pass the error through
                                                        print("⚠️ All realtime endpoints failed: \(error.localizedDescription)")

                                                        // Increment the failure counter for tracking purposes
                                                        let currentCount = UserDefaults.standard.integer(forKey: "umami_realtime_failure_count")
                                                        UserDefaults.standard.set(currentCount + 1, forKey: "umami_realtime_failure_count")

                                                        // Return the error
                                                        return Fail(error: APIError.endpointNotFound("All realtime endpoints failed"))
                                                            .eraseToAnyPublisher()
                                                    }
                                                    .eraseToAnyPublisher()
                                            }
                                            .eraseToAnyPublisher()
                                    }
                                    .eraseToAnyPublisher()
                            }
                            .eraseToAnyPublisher()
                    }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    func getRealtimeData(websiteId: String) -> AnyPublisher<RealtimeData, Error> {
        // Track persistent failures but don't use mock data
        let persistentFailureCount = UserDefaults.standard.integer(forKey: "umami_realtime_failure_count")
        if persistentFailureCount > 5 {
            print("⚠️ Note: Multiple persistent failures with realtime data")
        }

        // Check if we've already determined the realtime endpoint format
        let realtimeFormat = UserDefaults.standard.string(forKey: "umami_realtime_format")

        // Choose the appropriate endpoint format based on what we know
        let path: String

        if let format = realtimeFormat {
            // Use the stored format that we know works
            switch format {
            case "alt_realtime":
                path = "/api/realtime/\(websiteId)"
                print("📊 Using cached alternative realtime endpoint: \(path)")
            case "singular_realtime":
                path = "/api/website/\(websiteId)/realtime"
                print("📊 Using cached singular realtime endpoint: \(path)")
            case "v1_plural_realtime":
                path = "/api/v1/websites/\(websiteId)/realtime"
                print("📊 Using cached v1 plural realtime endpoint: \(path)")
            case "v1_singular_realtime":
                path = "/api/v1/website/\(websiteId)/realtime"
                print("📊 Using cached v1 singular realtime endpoint: \(path)")
            case "v2_realtime":
                path = "/api/v2/websites/\(websiteId)/realtime"
                print("📊 Using cached v2 plural realtime endpoint: \(path)")
            case "v2_singular_realtime":
                path = "/api/v2/website/\(websiteId)/realtime"
                print("📊 Using cached v2 singular realtime endpoint: \(path)")
            default:
                // Default to the standard v2 format
                path = "/api/websites/\(websiteId)/realtime"
                print("📊 Using standard realtime endpoint: \(path)")
            }
        } else if apiVersion == .v1 {
            // If we know it's v1 API but don't have a specific format yet
            path = "/api/website/\(websiteId)/realtime"
            print("📊 Using v1 singular realtime endpoint based on API version: \(path)")
        } else {
            // Default to the standard v2 format if we don't know yet
            path = "/api/websites/\(websiteId)/realtime"
            print("📊 Using standard realtime endpoint: \(path)")
        }

        let request = createRequest(path: path, method: "GET")

        return performRequest(request: request)
            .catch { error -> AnyPublisher<RealtimeData, Error> in
                // If we get a 404 error or server error, try alternative endpoints
                if case APIError.endpointNotFound = error {
                    print("⚠️ Primary realtime endpoint failed (404), trying alternatives")
                    // Clear the stored format since it's not working
                    UserDefaults.standard.removeObject(forKey: "umami_realtime_format")
                    return self.tryAlternativeRealtimeEndpoints(websiteId: websiteId)
                } else if case APIError.serverError = error {
                    print("⚠️ Primary realtime endpoint failed (server error), trying alternatives")
                    return self.tryAlternativeRealtimeEndpoints(websiteId: websiteId)
                } else if case APIError.decodingError = error {
                    // If we get a decoding error, the API might be returning a different format
                    print("⚠️ Decoding error for realtime data: \(error.localizedDescription)")

                    // Try alternative formats if we haven't already determined a working format
                    if realtimeFormat == nil {
                        print("🔄 Trying alternative formats for realtime")
                        return self.tryAlternativeRealtimeEndpoints(websiteId: websiteId)
                    }

                    // Increment the failure counter for tracking purposes
                    let currentCount = UserDefaults.standard.integer(forKey: "umami_realtime_failure_count")
                    UserDefaults.standard.set(currentCount + 1, forKey: "umami_realtime_failure_count")

                    // Return the error
                    return Fail(error: APIError.decodingError)
                        .eraseToAnyPublisher()
                } else {
                    return Fail(error: error).eraseToAnyPublisher()
                }
            }
            .handleEvents(receiveOutput: { _ in
                // On success, reset the failure counter
                UserDefaults.standard.set(0, forKey: "umami_realtime_failure_count")

                // If we don't have a stored format yet, store this successful one
                if realtimeFormat == nil {
                    if path.contains("/api/websites/") {
                        UserDefaults.standard.set("standard", forKey: "umami_realtime_format")
                        print("✅ Caching successful endpoint format: standard")
                    } else if path.contains("/api/website/") {
                        UserDefaults.standard.set("singular_realtime", forKey: "umami_realtime_format")
                        print("✅ Caching successful endpoint format: singular_realtime")
                    } else if path.contains("/api/realtime/") {
                        UserDefaults.standard.set("alt_realtime", forKey: "umami_realtime_format")
                        print("✅ Caching successful endpoint format: alt_realtime")
                    } else if path.contains("/api/v1/websites/") {
                        UserDefaults.standard.set("v1_plural_realtime", forKey: "umami_realtime_format")
                        print("✅ Caching successful endpoint format: v1_plural_realtime")
                    } else if path.contains("/api/v1/website/") {
                        UserDefaults.standard.set("v1_singular_realtime", forKey: "umami_realtime_format")
                        print("✅ Caching successful endpoint format: v1_singular_realtime")
                    } else if path.contains("/api/v2/websites/") {
                        UserDefaults.standard.set("v2_realtime", forKey: "umami_realtime_format")
                        print("✅ Caching successful endpoint format: v2_realtime")
                    } else if path.contains("/api/v2/website/") {
                        UserDefaults.standard.set("v2_singular_realtime", forKey: "umami_realtime_format")
                        print("✅ Caching successful endpoint format: v2_singular_realtime")
                    }
                }
            })
            .eraseToAnyPublisher()
    }
}

// MARK: - Helper Structures

struct EmptyResponse: Codable {}

// MARK: - API Errors

enum APIError: Error {
    case invalidURL
    case unauthorized
    case networkError(Error)
    case serverError(String)
    case decodingError
    case unknown
    case endpointNotFound(String)
    case apiVersionMismatch

    var message: String {
        switch self {
        case .invalidURL:
            return "Invalid URL. Please check the URL and try again."
        case .unauthorized:
            return "Unauthorized. Please log in again."
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .serverError(let message):
            return "Server error: \(message)"
        case .decodingError:
            return "Error processing server response."
        case .endpointNotFound(let path):
            return "Endpoint not found: \(path). This may be due to an API version mismatch between the app and server."
        case .apiVersionMismatch:
            return "API version mismatch. The app may need to be updated to work with your Umami server version."
        case .unknown:
            return "An unknown error occurred."
        }
    }
}

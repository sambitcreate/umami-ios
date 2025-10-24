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
    private let jsonDecoder: JSONDecoder
    private let jsonEncoder: JSONEncoder
    private let serverType: ServerType

    init(serverURL: String, serverType: ServerType = .selfHosted) throws {
        guard let url = URL(string: serverURL) else {
            throw AuthError.invalidURL
        }
        self.baseURL = url
        self.serverType = serverType

        self.jsonDecoder = JSONDecoder()
        self.jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase

        self.jsonEncoder = JSONEncoder()
        self.jsonEncoder.keyEncodingStrategy = .convertToSnakeCase
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

    func setAPIKey(_ key: String) {
        self.apiKey = key
    }

    // MARK: - Helper Methods

    private func createRequest(path: String, method: String, body: Encodable? = nil) -> URLRequest {
        let normalizedPath = normalize(path: path)
        // Handle URLs with query parameters correctly
        let apiURL: URL
        if normalizedPath.contains("?") {
            // Path contains query parameters, construct URL directly
            apiURL = URL(string: normalizedPath, relativeTo: baseURL) ?? baseURL.appendingPathComponent(normalizedPath)
        } else {
            // Path is just a path component, use appendingPathComponent
            apiURL = baseURL.appendingPathComponent(normalizedPath)
        }

        var request = URLRequest(url: apiURL)
        request.httpMethod = method
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        switch serverType {
        case .selfHosted:
            if let token = authToken {
                request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            }
        case .cloud:
            if let apiKey = apiKey {
                request.addValue(apiKey, forHTTPHeaderField: "x-umami-api-key")
            }
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

    private func performRequest<T: Decodable>(request: URLRequest) -> AnyPublisher<T, Error> {
        // Debug: Print request details
        print("🌐 API Request: \(request.httpMethod ?? "GET") \(request.url?.absoluteString ?? "unknown")")
        if let headers = request.allHTTPHeaderFields {
            print("🔑 Headers: \(headers)")
        }

        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw APIError.unknown
                }

                // Debug: Print response details
                print("📡 Response Status: \(httpResponse.statusCode) for \(request.url?.absoluteString ?? "unknown")")
                if let responseString = String(data: data, encoding: .utf8) {
                    print("📄 Response Body: \(responseString)")
                }

                if httpResponse.statusCode == 401 {
                    throw APIError.unauthorized
                }

                guard (200...299).contains(httpResponse.statusCode) else {
                    // Try to parse error message from response
                    if let errorResponse = try? JSONDecoder().decode([String: String].self, from: data),
                       let errorMessage = errorResponse["error"] ?? errorResponse["message"] {
                        throw APIError.serverError(errorMessage)
                    } else {
                        throw APIError.serverError("Status code: \(httpResponse.statusCode)")
                    }
                }
                return data
            }
            .flatMap { data -> AnyPublisher<T, Error> in
                if data.isEmpty, T.self == EmptyResponse.self,
                   let emptyResponse = EmptyResponse() as? T {
                    return Just(emptyResponse)
                        .setFailureType(to: Error.self)
                        .eraseToAnyPublisher()
                    .decode(type: T.self, decoder: self.jsonDecoder)
                    .mapError { error in
                        if let apiError = error as? APIError {
                            return apiError
                        } else if error is DecodingError {
                            print("Decoding error: \(error)")
                            return APIError.decodingError
                        } else {
                            return APIError.networkError(error)
                        }
                    }
                    .eraseToAnyPublisher()
            }
            .mapError { error in
                if let apiError = error as? APIError {
                    return apiError
                } else if error is DecodingError {
                    print("Decoding error: \(error)")
                    return APIError.decodingError
                } else {
                    return APIError.networkError(error)
                }
            }
            .eraseToAnyPublisher()
    }

    private func performVoidRequest(request: URLRequest) -> AnyPublisher<Void, Error> {
        print("🌐 API Request: \(request.httpMethod ?? "GET") \(request.url?.absoluteString ?? "unknown")")
        if let headers = request.allHTTPHeaderFields {
            print("🔑 Headers: \(headers)")
        }

        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw APIError.unknown
                }

                print("📡 Response Status: \(httpResponse.statusCode) for \(request.url?.absoluteString ?? "unknown")")
                if let responseString = String(data: data, encoding: .utf8), !responseString.isEmpty {
                    print("📄 Response Body: \(responseString)")
                }

                if httpResponse.statusCode == 401 {
                    throw APIError.unauthorized
                }

                guard (200...299).contains(httpResponse.statusCode) else {
                    if let errorResponse = try? JSONDecoder().decode([String: String].self, from: data),
                       let errorMessage = errorResponse["error"] ?? errorResponse["message"] {
                        throw APIError.serverError(errorMessage)
                    }

                    throw APIError.serverError("Status code: \(httpResponse.statusCode)")
                }

                return ()
            }
            .mapError { error in
                if let apiError = error as? APIError {
                    return apiError
                }
                return APIError.networkError(error)
            }
            .eraseToAnyPublisher()
    }

    private func normalize(path: String) -> String {
        guard serverType == .cloud else { return path }

        if path.hasPrefix("/api/me/") {
            return "/v1/" + path.dropFirst("/api/me/".count)
        }

        if path == "/api/me" {
            return "/v1/account"
        }

        if path.hasPrefix("/api/") {
            return "/v1/" + path.dropFirst("/api/".count)
        }

        if path == "/api" {
            return "/v1"
        }

        return path
    }

    // MARK: - Authentication

    func login(username: String, password: String) -> AnyPublisher<AuthResponse, Error> {
        let credentials = AuthCredentials(username: username, password: password)
        let request = createRequest(path: "/api/auth/login", method: "POST", body: credentials)
        return performRequest(request: request)
    }

    func verifyToken() -> AnyPublisher<User, Error> {
        guard authToken != nil else {
            return Fail(error: APIError.unauthorized).eraseToAnyPublisher()
        }

        let request = createRequest(path: "/api/auth/verify", method: "GET")
        return performRequest(request: request)
    }

    func logout() -> AnyPublisher<EmptyResponse, Error> {
        guard authToken != nil else {
            return Just(EmptyResponse()).setFailureType(to: Error.self).eraseToAnyPublisher()
        }

        let request = createRequest(path: "/api/auth/logout", method: "POST")
        return performRequest(request: request)
    }

    // MARK: - Websites

    func getWebsites(page: Int = 1, pageSize: Int = 10) -> AnyPublisher<WebsiteListResponse, Error> {
        var components = URLComponents(string: "/api/me/websites")
        components?.queryItems = [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "pageSize", value: "\(pageSize)")
        ]
        
        let path = components?.url?.absoluteString ?? "/api/me/websites"
        let request = createRequest(path: path, method: "GET")
        return performRequest(request: request)
    }
    
    func getAllWebsites() -> AnyPublisher<[WebsiteModel], Error> {
        // Start with first page to get total count
        return getWebsites(page: 1, pageSize: 50) // Use larger page size to minimize requests
            .flatMap { firstPageResponse -> AnyPublisher<[WebsiteModel], Error> in
                let totalCount = firstPageResponse.count
                let firstPageData = firstPageResponse.data
                
                // If all websites fit in first page, return them
                if firstPageData.count >= totalCount {
                    return Just(firstPageData)
                        .setFailureType(to: Error.self)
                        .eraseToAnyPublisher()
                }
                
                // Calculate how many more pages we need
                let pageSize = 50
                let totalPages = (totalCount + pageSize - 1) / pageSize // Ceiling division
                
                // Create publishers for remaining pages
                let remainingPagePublishers = (2...totalPages).map { page in
                    self.getWebsites(page: page, pageSize: pageSize)
                        .map { $0.data }
                }
                
                // Combine all pages
                if remainingPagePublishers.isEmpty {
                    return Just(firstPageData)
                        .setFailureType(to: Error.self)
                        .eraseToAnyPublisher()
                } else {
                    return Publishers.MergeMany(remainingPagePublishers)
                        .collect()
                        .map { additionalPages in
                            var allWebsites = firstPageData
                            for pageData in additionalPages {
                                allWebsites.append(contentsOf: pageData)
                            }
                            return allWebsites
                        }
                        .eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
    }

    func getWebsite(id: String) -> AnyPublisher<WebsiteModel, Error> {
        let request = createRequest(path: "/api/websites/\(id)", method: "GET")
        return performRequest(request: request)
    }

    func createWebsite(body: CreateWebsiteRequest) -> AnyPublisher<WebsiteModel, Error> {
        let request = createRequest(path: "/api/websites", method: "POST", body: body)
        return performRequest(request: request)
    }

    func updateWebsite(id: String, body: UpdateWebsiteRequest) -> AnyPublisher<WebsiteModel, Error> {
        let request = createRequest(path: "/api/websites/\(id)", method: "POST", body: body)
        return performRequest(request: request)
    }

    func deleteWebsite(id: String) -> AnyPublisher<Void, Error> {
        let request = createRequest(path: "/api/websites/\(id)", method: "DELETE")
        return performVoidRequest(request: request)
    }

    func getWebsiteStats(id: String, dateRange: DateRange) -> AnyPublisher<WebsiteStatsResponse, Error> {
        var components = URLComponents(string: "/api/websites/\(id)/stats")
        components?.queryItems = [
            URLQueryItem(name: "startAt", value: "\(dateRange.startAt)"),
            URLQueryItem(name: "endAt", value: "\(dateRange.endAt)")
        ]

        if let timezone = dateRange.timezone {
            components?.queryItems?.append(URLQueryItem(name: "timezone", value: timezone))
        }

        guard let path = components?.string else {
            return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
        }

        let request = createRequest(path: path, method: "GET")
        return performRequest(request: request)
    }

    func getWebsiteMetrics(id: String, dateRange: DateRange, type: String = "url") -> AnyPublisher<WebsiteMetricsResponse, Error> {
        var components = URLComponents(string: "/api/websites/\(id)/metrics")
        components?.queryItems = [
            URLQueryItem(name: "startAt", value: "\(dateRange.startAt)"),
            URLQueryItem(name: "endAt", value: "\(dateRange.endAt)"),
            URLQueryItem(name: "type", value: type)
        ]

        if let timezone = dateRange.timezone {
            components?.queryItems?.append(URLQueryItem(name: "timezone", value: timezone))
        }

        guard let path = components?.string else {
            return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
        }

        let request = createRequest(path: path, method: "GET")
        return performRequest(request: request)
    }

    func getWebsitePageviews(id: String, dateRange: DateRange) -> AnyPublisher<PageviewsResponse, Error> {
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
    }

    // MARK: - Active Users & Realtime

    func getWebsiteActive(id: String) -> AnyPublisher<ActiveUsersResponse, Error> {
        let request = createRequest(path: "/api/websites/\(id)/active", method: "GET")
        return performRequest(request: request)
    }

    func getActiveUsers(websiteId: String) -> AnyPublisher<ActiveUsersResponse, Error> {
        let request = createRequest(path: "/api/websites/\(websiteId)/active", method: "GET")
        return performRequest(request: request)
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
        case .unknown:
            return "An unknown error occurred."
        }
    }
}

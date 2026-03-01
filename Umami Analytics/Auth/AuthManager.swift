//
//  AuthManager.swift
//  Umami Analytics
//
//  Created by Augment on 4/17/25.
//

import Foundation
import Combine
import Security
import OSLog

@MainActor
final class AuthManager {
    static let shared = AuthManager()

    private enum Constants {
        static let cloudBaseURL = "https://api.umami.is"
    }

    private let tokenKey = "umami.auth.token"
    private let apiKeyKey = "umami.auth.apiKey"
    private let serverURLKey = "umami.server.url"
    private let serverTypeKey = "umami.server.type"
    private let userKey = "umami.auth.user"
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "UmamiAnalytics", category: "Auth")

    private(set) var apiClient: APIClient?
    private var storedSelfHostedServerURL: String?

    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var serverURL: String?
    @Published var serverType: ServerType = .selfHosted
    @Published var isLoading = false
    @Published var cloudAPIKey: String?

    private init() {
        loadServerType()
        loadSavedServerURL()
        restoreSession()
        loadUser()
        if cloudAPIKey == nil {
            cloudAPIKey = loadAPIKey()
        }
    }

    var savedSelfHostedServerURL: String? {
        storedSelfHostedServerURL
    }

    // MARK: - Authentication

    func setServerType(_ type: ServerType) {
        serverType = type
        saveServerType(type)

        switch type {
        case .cloud:
            serverURL = Constants.cloudBaseURL
            cloudAPIKey = loadAPIKey()
        case .selfHosted:
            serverURL = storedSelfHostedServerURL
        }
    }

    func login(
        serverType: ServerType,
        serverURL: String?,
        username: String?,
        password: String?,
        apiKey: String?,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        Task { @MainActor in
            do {
                try await login(
                    serverType: serverType,
                    serverURL: serverURL,
                    username: username,
                    password: password,
                    apiKey: apiKey
                )
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }

    func logout(completion: @escaping (Result<Void, Error>) -> Void) {
        Task { @MainActor in
            do {
                try await logout()
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }

    func verifyAuthentication(completion: @escaping (Result<Void, Error>) -> Void) {
        Task { @MainActor in
            do {
                try await verifyAuthentication()
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }

    func login(
        serverType: ServerType,
        serverURL: String?,
        username: String?,
        password: String?,
        apiKey: String?
    ) async throws {
        isLoading = true
        defer { isLoading = false }

        switch serverType {
        case .selfHosted:
            guard let trimmedURL = serverURL?.trimmingCharacters(in: .whitespacesAndNewlines),
                  !trimmedURL.isEmpty else {
                throw AuthError.invalidURL
            }

            var finalURL = trimmedURL
            if !finalURL.lowercased().hasPrefix("http") {
                finalURL = "https://\(finalURL)"
            }
            if finalURL.hasSuffix("/") {
                finalURL.removeLast()
            }

            guard let username = username?.trimmingCharacters(in: .whitespacesAndNewlines),
                  !username.isEmpty,
                  let password,
                  !password.isEmpty else {
                throw AuthError.invalidCredentials
            }

            let client = try APIClient(serverURL: finalURL, serverType: .selfHosted)

            do {
                let response = try await client.loginAsync(username: username, password: password)
                client.setAuthToken(response.token)

                apiClient = client
                saveAuthToken(response.token)
                saveServerURL(finalURL)
                saveServerType(.selfHosted)
                self.serverType = .selfHosted
                self.serverURL = finalURL
                storedSelfHostedServerURL = finalURL
                currentUser = response.user
                saveUser(response.user)
                isAuthenticated = true
            } catch {
                apiClient = nil
                isAuthenticated = false
                throw error
            }

        case .cloud:
            guard let key = apiKey?.trimmingCharacters(in: .whitespacesAndNewlines),
                  !key.isEmpty else {
                throw AuthError.missingAPIKey
            }

            let client = try APIClient(serverURL: Constants.cloudBaseURL, serverType: .cloud)
            client.setAPIKey(key)

            do {
                _ = try await client.getWebsitesAsync(page: 1, pageSize: 1)

                apiClient = client
                saveAPIKey(key)
                cloudAPIKey = key
                self.serverType = .cloud
                saveServerType(.cloud)
                self.serverURL = Constants.cloudBaseURL
                clearStoredUser()
                isAuthenticated = true
            } catch {
                apiClient = nil
                isAuthenticated = false
                throw error
            }
        }
    }

    func logout() async throws {
        isLoading = true
        defer { isLoading = false }

        switch serverType {
        case .selfHosted:
            var logoutError: Error?
            if let apiClient {
                do {
                    try await apiClient.logoutAsync()
                } catch {
                    logoutError = error
                    logger.error("Remote logout failed; clearing local session anyway: \(error.localizedDescription, privacy: .public)")
                }
            }
            clearAuthData(for: .selfHosted)
            if let logoutError {
                throw logoutError
            }
        case .cloud:
            clearAuthData(for: .cloud)
        }
    }

    func verifyAuthentication() async throws {
        guard let apiClient, isAuthenticated else {
            throw AuthError.invalidCredentials
        }

        isLoading = true
        defer { isLoading = false }

        switch serverType {
        case .selfHosted:
            do {
                let user = try await apiClient.verifyTokenAsync()
                currentUser = user
                saveUser(user)
            } catch {
                if let apiError = error as? APIError, case .unauthorized = apiError {
                    isAuthenticated = false
                }
                throw error
            }

        case .cloud:
            _ = try await apiClient.getWebsitesAsync(page: 1, pageSize: 1)
        }
    }

    // MARK: - Token & Secret Management

    private func saveAuthToken(_ token: String) {
        saveToKeychain(value: token, key: tokenKey)
    }

    private func loadAuthToken() -> String? {
        loadFromKeychain(key: tokenKey)
    }

    private func clearAuthToken() {
        deleteFromKeychain(key: tokenKey)
    }

    private func saveAPIKey(_ key: String) {
        saveToKeychain(value: key, key: apiKeyKey)
    }

    private func loadAPIKey() -> String? {
        loadFromKeychain(key: apiKeyKey)
    }

    private func clearAPIKey() {
        deleteFromKeychain(key: apiKeyKey)
        cloudAPIKey = nil
    }

    private func saveServerURL(_ url: String) {
        storedSelfHostedServerURL = url
        UserDefaults.standard.set(url, forKey: serverURLKey)
    }

    private func loadSavedServerURL() {
        if let url = UserDefaults.standard.string(forKey: serverURLKey) {
            logger.debug("Restoring saved server URL.")
            storedSelfHostedServerURL = url
            if serverType == .selfHosted {
                serverURL = url
            }
        } else {
            logger.debug("No saved server URL was found.")
        }
    }

    private func loadServerType() {
        if let storedValue = UserDefaults.standard.string(forKey: serverTypeKey),
           let storedType = ServerType(rawValue: storedValue) {
            serverType = storedType
        } else {
            serverType = .selfHosted
        }
    }

    private func saveServerType(_ type: ServerType) {
        UserDefaults.standard.set(type.rawValue, forKey: serverTypeKey)
    }

    private func restoreSession() {
        switch serverType {
        case .selfHosted:
            guard let url = storedSelfHostedServerURL else {
                isAuthenticated = false
                cloudAPIKey = loadAPIKey()
                return
            }

            do {
                let client = try APIClient(serverURL: url, serverType: .selfHosted)
                apiClient = client

                if let token = loadAuthToken() {
                    client.setAuthToken(token)
                    serverURL = url
                    isAuthenticated = true
                } else {
                    isAuthenticated = false
                }
            } catch {
                logger.error("Failed to restore self-hosted session: \(error.localizedDescription, privacy: .public)")
                isAuthenticated = false
            }

        case .cloud:
            do {
                let client = try APIClient(serverURL: Constants.cloudBaseURL, serverType: .cloud)
                apiClient = client
                serverURL = Constants.cloudBaseURL

                if let key = loadAPIKey() {
                    client.setAPIKey(key)
                    cloudAPIKey = key
                    isAuthenticated = true
                } else {
                    isAuthenticated = false
                }
            } catch {
                logger.error("Failed to restore cloud session: \(error.localizedDescription, privacy: .public)")
                isAuthenticated = false
            }
        }
    }

    private func saveUser(_ user: User) {
        guard serverType == .selfHosted else { return }

        if let userData = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(userData, forKey: userKey)
            currentUser = user
        }
    }

    private func loadUser() {
        guard serverType == .selfHosted else {
            currentUser = nil
            return
        }

        if let userData = UserDefaults.standard.data(forKey: userKey),
           let user = try? JSONDecoder().decode(User.self, from: userData) {
            currentUser = user
        }
    }

    private func clearStoredUser() {
        UserDefaults.standard.removeObject(forKey: userKey)
        currentUser = nil
    }

    private func clearAuthData(for type: ServerType) {
        switch type {
        case .selfHosted:
            clearAuthToken()
            apiClient?.clearAuthToken()
            clearStoredUser()
        case .cloud:
            clearAPIKey()
        }

        apiClient = nil
        isAuthenticated = false
        currentUser = nil
    }

    // MARK: - Keychain Helpers

    private func saveToKeychain(value: String, key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]

        var attributes = query
        attributes[kSecValueData as String] = value.data(using: .utf8)

        SecItemDelete(query as CFDictionary)
        SecItemAdd(attributes as CFDictionary, nil)
    }

    private func loadFromKeychain(key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true
        ]

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)

        guard status == errSecSuccess,
              let data = item as? Data,
              !data.isEmpty,
              let value = String(data: data, encoding: .utf8) else {
            return nil
        }

        return value
    }

    private func deleteFromKeychain(key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]

        SecItemDelete(query as CFDictionary)
    }
}

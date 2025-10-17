//
//  AuthManager.swift
//  Umami Analytics
//
//  Created by Augment on 4/17/25.
//

import Foundation
import Combine
import Security

class AuthManager {
    static let shared = AuthManager()

    private enum Constants {
        static let cloudBaseURL = "https://api.umami.is"
    }

    private let tokenKey = "umami.auth.token"
    private let apiKeyKey = "umami.auth.apiKey"
    private let serverURLKey = "umami.server.url"
    private let serverTypeKey = "umami.server.type"
    private let userKey = "umami.auth.user"

    private(set) var apiClient: APIClient?
    private var cancellables = Set<AnyCancellable>()
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
        switch serverType {
        case .selfHosted:
            guard let trimmedURL = serverURL?.trimmingCharacters(in: .whitespacesAndNewlines),
                  !trimmedURL.isEmpty else {
                completion(.failure(AuthError.invalidURL))
                return
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
                  let password = password,
                  !password.isEmpty else {
                completion(.failure(AuthError.invalidCredentials))
                return
            }

            do {
                let client = try APIClient(serverURL: finalURL, serverType: .selfHosted)
                apiClient = client

                client.login(username: username, password: password)
                    .receive(on: DispatchQueue.main)
                    .sink(
                        receiveCompletion: { [weak self] result in
                            if case .failure(let error) = result {
                                self?.isAuthenticated = false
                                completion(.failure(error))
                            }
                        },
                        receiveValue: { [weak self] response in
                            guard let self = self else { return }

                            self.saveAuthToken(response.token)
                            self.saveServerURL(finalURL)
                            self.saveServerType(.selfHosted)
                            self.serverType = .selfHosted
                            self.serverURL = finalURL
                            self.storedSelfHostedServerURL = finalURL

                            self.apiClient?.setAuthToken(response.token)
                            self.currentUser = response.user
                            self.saveUser(response.user)

                            self.isAuthenticated = true
                            completion(.success(()))
                        }
                    )
                    .store(in: &cancellables)
            } catch {
                completion(.failure(error))
            }

        case .cloud:
            guard let key = apiKey?.trimmingCharacters(in: .whitespacesAndNewlines),
                  !key.isEmpty else {
                completion(.failure(AuthError.missingAPIKey))
                return
            }

            do {
                let client = try APIClient(serverURL: Constants.cloudBaseURL, serverType: .cloud)
                client.setAPIKey(key)

                client.getWebsites(page: 1, pageSize: 1)
                    .receive(on: DispatchQueue.main)
                    .sink(
                        receiveCompletion: { [weak self] result in
                            if case .failure(let error) = result {
                                self?.isAuthenticated = false
                                completion(.failure(error))
                            }
                        },
                        receiveValue: { [weak self] _ in
                            guard let self = self else { return }

                            self.apiClient = client
                            self.saveAPIKey(key)
                            self.cloudAPIKey = key
                            self.serverType = .cloud
                            self.saveServerType(.cloud)
                            self.serverURL = Constants.cloudBaseURL

                            self.clearStoredUser()
                            self.isAuthenticated = true
                            completion(.success(()))
                        }
                    )
                    .store(in: &cancellables)
            } catch {
                completion(.failure(error))
            }
        }
    }

    func logout(completion: @escaping (Result<Void, Error>) -> Void) {
        switch serverType {
        case .selfHosted:
            guard let apiClient = apiClient else {
                clearAuthData(for: .selfHosted)
                completion(.success(()))
                return
            }

            apiClient.logout()
                .receive(on: DispatchQueue.main)
                .sink(
                    receiveCompletion: { [weak self] result in
                        switch result {
                        case .failure(let error):
                            completion(.failure(error))
                        case .finished:
                            self?.clearAuthData(for: .selfHosted)
                            completion(.success(()))
                        }
                    },
                    receiveValue: { [weak self] _ in
                        self?.clearAuthData(for: .selfHosted)
                        completion(.success(()))
                    }
                )
                .store(in: &cancellables)

        case .cloud:
            clearAuthData(for: .cloud)
            completion(.success(()))
        }
    }

    func verifyAuthentication(completion: @escaping (Result<Void, Error>) -> Void) {
        guard let apiClient = apiClient, isAuthenticated else {
            completion(.failure(AuthError.invalidCredentials))
            return
        }

        switch serverType {
        case .selfHosted:
            apiClient.verifyToken()
                .receive(on: DispatchQueue.main)
                .sink(
                    receiveCompletion: { [weak self] result in
                        if case .failure(let error) = result {
                            if let apiError = error as? APIError, case .unauthorized = apiError {
                                self?.isAuthenticated = false
                            }
                            completion(.failure(error))
                        }
                    },
                    receiveValue: { [weak self] user in
                        self?.currentUser = user
                        self?.saveUser(user)
                        completion(.success(()))
                    }
                )
                .store(in: &cancellables)

        case .cloud:
            apiClient.getWebsites(page: 1, pageSize: 1)
                .receive(on: DispatchQueue.main)
                .sink(
                    receiveCompletion: { result in
                        if case .failure(let error) = result {
                            completion(.failure(error))
                        }
                    },
                    receiveValue: { _ in
                        completion(.success(()))
                    }
                )
                .store(in: &cancellables)
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
            print("📱 Restoring server URL: \(url)")
            storedSelfHostedServerURL = url
            if serverType == .selfHosted {
                serverURL = url
            }
        } else {
            print("📱 No saved server URL found")
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
                print("❌ Error creating API client: \(error)")
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
                print("❌ Error creating Cloud API client: \(error)")
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

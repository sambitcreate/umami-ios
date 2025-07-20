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

    private let tokenKey = "umami.auth.token"
    private let serverURLKey = "umami.server.url"
    private let userKey = "umami.auth.user"

    private(set) var apiClient: APIClient?
    private var cancellables = Set<AnyCancellable>()

    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var serverURL: String?
    @Published var isLoading = false

    private init() {
        // Load saved server URL first, then token and user
        loadServerURL()
        loadAuthToken()
        loadUser()
    }

    // MARK: - Authentication

    func login(serverURL: String, username: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        // Ensure URL has a scheme
        var finalURL = serverURL
        if !serverURL.lowercased().hasPrefix("http") {
            finalURL = "https://\(serverURL)"
        }

        // Remove trailing slash if present
        if finalURL.hasSuffix("/") {
            finalURL.removeLast()
        }

        do {
            // Create API client with the server URL
            let client = try APIClient(serverURL: finalURL)
            self.apiClient = client

            client.login(username: username, password: password)
                .receive(on: DispatchQueue.main)
                .sink(
                    receiveCompletion: { [weak self] result in
                        if case .failure(let error) = result {
                            completion(.failure(error))
                            self?.isAuthenticated = false
                        }
                    },
                    receiveValue: { [weak self] response in
                        guard let self = self else { return }

                        // Save token and server URL
                        self.saveAuthToken(response.token)
                        self.saveServerURL(finalURL)
                        self.saveUser(response.user)

                        // Update state
                        self.apiClient?.setAuthToken(response.token)
                        self.currentUser = response.user
                        self.isAuthenticated = true
                        self.serverURL = finalURL

                        // Verify the token works by calling verify endpoint
                        client.verifyToken()
                            .sink(
                                receiveCompletion: { verifyResult in
                                    switch verifyResult {
                                    case .failure(let error):
                                        print("⚠️ Token verification failed: \(error)")
                                        // Still complete successfully since login worked
                                        completion(.success(response.user))
                                    case .finished:
                                        print("✅ Token verification successful")
                                        completion(.success(response.user))
                                    }
                                },
                                receiveValue: { verifiedUser in
                                    print("✅ Token verified for user: \(verifiedUser.username)")
                                }
                            )
                            .store(in: &self.cancellables)
                    }
                )
                .store(in: &cancellables)
        } catch {
            completion(.failure(error))
        }
    }

    func logout(completion: @escaping (Result<Void, Error>) -> Void) {
        guard let apiClient = apiClient else {
            clearAuthData()
            completion(.success(()))
            return
        }

        apiClient.logout()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] result in
                    if case .failure(let error) = result {
                        completion(.failure(error))
                    } else {
                        self?.clearAuthData()
                        completion(.success(()))
                    }
                },
                receiveValue: { [weak self] _ in
                    self?.clearAuthData()
                    completion(.success(()))
                }
            )
            .store(in: &cancellables)
    }

    func verifyAuthentication(completion: @escaping (Result<User, Error>) -> Void) {
        guard let apiClient = apiClient, isAuthenticated else {
            completion(.failure(AuthError.invalidCredentials))
            return
        }

        apiClient.verifyToken()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] result in
                    if case .failure(let error) = result {
                        self?.isAuthenticated = false
                        completion(.failure(error))
                    }
                },
                receiveValue: { [weak self] user in
                    self?.currentUser = user
                    self?.saveUser(user)
                    completion(.success(user))
                }
            )
            .store(in: &cancellables)
    }

    // MARK: - Token Management

    private func saveAuthToken(_ token: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: tokenKey,
            kSecValueData as String: token.data(using: .utf8)!
        ]

        // Delete any existing token
        SecItemDelete(query as CFDictionary)

        // Add the new token
        SecItemAdd(query as CFDictionary, nil)
    }

    private func loadAuthToken() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: tokenKey,
            kSecReturnData as String: true
        ]

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)

        if status == errSecSuccess, let data = item as? Data, let token = String(data: data, encoding: .utf8) {
            // Only set token if API client exists
            if let client = apiClient {
                client.setAuthToken(token)
                isAuthenticated = true
            } else {
                // If no API client yet, we'll set the token when the client is created
                isAuthenticated = false
            }
        } else {
            isAuthenticated = false
        }
    }

    private func saveServerURL(_ url: String) {
        UserDefaults.standard.set(url, forKey: serverURLKey)
        serverURL = url
    }

    private func loadServerURL() {
        if let url = UserDefaults.standard.string(forKey: serverURLKey) {
            serverURL = url
            do {
                apiClient = try APIClient(serverURL: url)
                // After creating the API client, load and set the auth token
                loadAndSetAuthToken()
            } catch {
                print("Error creating API client: \(error)")
            }
        }
    }
    
    private func loadAndSetAuthToken() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: tokenKey,
            kSecReturnData as String: true
        ]

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)

        if status == errSecSuccess, let data = item as? Data, let token = String(data: data, encoding: .utf8) {
            apiClient?.setAuthToken(token)
            isAuthenticated = true
        }
    }

    private func saveUser(_ user: User) {
        if let userData = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(userData, forKey: userKey)
            currentUser = user
        }
    }

    private func loadUser() {
        if let userData = UserDefaults.standard.data(forKey: userKey),
           let user = try? JSONDecoder().decode(User.self, from: userData) {
            currentUser = user
        }
    }

    private func clearAuthData() {
        // Clear token from keychain
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: tokenKey
        ]
        SecItemDelete(query as CFDictionary)

        // Clear user data
        UserDefaults.standard.removeObject(forKey: userKey)

        // Update state
        apiClient?.clearAuthToken()
        isAuthenticated = false
        currentUser = nil
    }
}

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
final class AuthManager: ObservableObject {
    static let shared = AuthManager()

    private enum Constants {
        static let cloudAPIBaseURL = "https://api.umami.is"
        static let cloudTrackerBaseURL = "https://cloud.umami.is"
    }

    private enum StorageKey {
        static let currentSession = "umami.session.current"
        static let lastSelectedServerType = "umami.server.type"
        static let selfHostedServerURL = "umami.server.url.selfHosted"
        static let publicShareServerURL = "umami.server.url.publicShare"
    }

    private enum SecretKind: String {
        case bearerToken = "token"
        case cloudAPIKey = "apiKey"
        case shareToken = "shareToken"
    }

    private(set) var apiClient: APIClient?

    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "UmamiAnalytics", category: "Auth")

    private var storedSelfHostedServerURL: String?
    private var storedPublicShareServerURL: String?

    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var serverURL: String?
    @Published var serverType: ServerType = .selfHosted
    @Published var isLoading = false
    @Published var cloudAPIKey: String?
    @Published var currentSession: UmamiSession?
    @Published var serverConfig: ServerConfig?
    @Published var availableTeams: [WorkspaceTeam] = []
    @Published var selectedWorkspace: WorkspaceSelection = .personal

    private init() {
        loadServerType()
        loadSavedServerURLs()
        restoreSession()
    }

    var savedSelfHostedServerURL: String? {
        storedSelfHostedServerURL
    }

    var savedPublicShareServerURL: String? {
        storedPublicShareServerURL
    }

    var workspaceOptions: [WorkspaceSelection] {
        [.personal] + availableTeams.map {
            WorkspaceSelection(teamId: $0.id, name: $0.name)
        }
    }

    var isReadOnlySession: Bool {
        currentSession?.isReadOnly == true
    }

    var activeCloudRegion: CloudRegion {
        currentSession?.cloudRegion ?? .global
    }

    // MARK: - Authentication

    func setServerType(_ type: ServerType) {
        serverType = type
        saveServerType(type)

        switch type {
        case .cloud:
            serverURL = Constants.cloudAPIBaseURL
            cloudAPIKey = currentSession?.serverType == .cloud ? loadSecret(kind: .cloudAPIKey, for: currentSession) : nil
        case .selfHosted:
            serverURL = storedSelfHostedServerURL
        case .publicShare:
            serverURL = storedPublicShareServerURL
        }
    }

    func login(
        serverType: ServerType,
        serverURL: String?,
        username: String?,
        password: String?,
        apiKey: String?,
        shareID: String? = nil,
        cloudRegion: CloudRegion = .global,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        Task { @MainActor in
            do {
                try await login(
                    serverType: serverType,
                    serverURL: serverURL,
                    username: username,
                    password: password,
                    apiKey: apiKey,
                    shareID: shareID,
                    cloudRegion: cloudRegion
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
        apiKey: String?,
        shareID: String? = nil,
        cloudRegion: CloudRegion = .global
    ) async throws {
        isLoading = true
        defer { isLoading = false }

        switch serverType {
        case .selfHosted:
            let finalURL = try normalizedServerURL(serverURL)
            guard let username = username?.trimmingCharacters(in: .whitespacesAndNewlines),
                  !username.isEmpty,
                  let password,
                  !password.isEmpty else {
                throw AuthError.invalidCredentials
            }

            let session = UmamiSession(
                serverType: .selfHosted,
                baseURL: finalURL,
                normalizedBaseURL: finalURL,
                cloudRegion: nil,
                trackerBaseURL: finalURL,
                shareId: nil,
                sharedWebsiteId: nil
            )
            let client = try APIClient(serverURL: finalURL, serverType: .selfHosted)

            do {
                let response = try await client.loginAsync(username: username, password: password)
                client.setAuthToken(response.token)

                let bootstrap = try await loadSelfHostedBootstrap(client: client, session: session, fallbackUser: response.user)
                saveServerURL(finalURL, for: .selfHosted)
                persistAuthenticatedSession(
                    session: session,
                    client: client,
                    secret: response.token,
                    secretKind: .bearerToken,
                    currentUser: bootstrap.user,
                    serverConfig: bootstrap.config,
                    teams: bootstrap.teams
                )
            } catch {
                resetRuntimeState(clearSelection: false)
                throw error
            }

        case .cloud:
            guard let key = apiKey?.trimmingCharacters(in: .whitespacesAndNewlines),
                  !key.isEmpty else {
                throw AuthError.missingAPIKey
            }

            let session = UmamiSession(
                serverType: .cloud,
                baseURL: Constants.cloudAPIBaseURL,
                normalizedBaseURL: Constants.cloudAPIBaseURL,
                cloudRegion: cloudRegion,
                trackerBaseURL: Constants.cloudTrackerBaseURL,
                shareId: nil,
                sharedWebsiteId: nil
            )
            let client = try APIClient(serverURL: Constants.cloudAPIBaseURL, serverType: .cloud, cloudRegion: cloudRegion)
            client.setAPIKey(key)

            do {
                _ = try await client.getWebsitesAsync(page: 1, pageSize: 1)

                persistAuthenticatedSession(
                    session: session,
                    client: client,
                    secret: key,
                    secretKind: .cloudAPIKey,
                    currentUser: nil,
                    serverConfig: ServerConfig(cloudMode: true, privateMode: nil, trackerScriptName: "script.js"),
                    teams: []
                )
                cloudAPIKey = key
            } catch {
                resetRuntimeState(clearSelection: false)
                throw error
            }

        case .publicShare:
            let finalURL = try normalizedServerURL(serverURL)
            guard let shareID = shareID?.trimmingCharacters(in: .whitespacesAndNewlines),
                  !shareID.isEmpty else {
                throw AuthError.missingShareID
            }

            let client = try APIClient(serverURL: finalURL, serverType: .publicShare)

            do {
                let share = try await client.getShareSessionAsync(shareId: shareID)
                client.setShareToken(share.token)

                let session = UmamiSession(
                    serverType: .publicShare,
                    baseURL: finalURL,
                    normalizedBaseURL: finalURL,
                    cloudRegion: nil,
                    trackerBaseURL: finalURL,
                    shareId: shareID,
                    sharedWebsiteId: share.websiteId
                )

                saveServerURL(finalURL, for: .publicShare)
                persistAuthenticatedSession(
                    session: session,
                    client: client,
                    secret: share.token,
                    secretKind: .shareToken,
                    currentUser: nil,
                    serverConfig: ServerConfig(privateMode: true, trackerScriptName: "script.js"),
                    teams: []
                )
            } catch {
                resetRuntimeState(clearSelection: false)
                throw error
            }
        }
    }

    func logout() async throws {
        isLoading = true
        defer { isLoading = false }

        let session = currentSession
        var logoutError: Error?

        if let session, session.serverType == .selfHosted, let apiClient {
            do {
                try await apiClient.logoutAsync()
            } catch {
                logoutError = error
                logger.error("Remote logout failed; clearing local session anyway: \(error.localizedDescription, privacy: .public)")
            }
        }

        clearCurrentSession()

        if let logoutError {
            throw logoutError
        }
    }

    func verifyAuthentication() async throws {
        guard let apiClient, let session = currentSession, isAuthenticated else {
            throw AuthError.invalidCredentials
        }

        isLoading = true
        defer { isLoading = false }

        switch session.serverType {
        case .selfHosted:
            let bootstrap = try await loadSelfHostedBootstrap(client: apiClient, session: session, fallbackUser: currentUser)
            currentUser = bootstrap.user
            availableTeams = bootstrap.teams
            serverConfig = bootstrap.config
            persistUser(bootstrap.user, for: session)
            persistTeams(bootstrap.teams, for: session)
            persistServerConfig(bootstrap.config, for: session)
            selectedWorkspace = sanitizedWorkspaceSelection(loadedWorkspaceSelection(for: session), teams: bootstrap.teams)
            persistWorkspaceSelection(selectedWorkspace, for: session)

        case .cloud:
            _ = try await apiClient.getWebsitesAsync(page: 1, pageSize: 1)
            serverConfig = serverConfig ?? ServerConfig(cloudMode: true, trackerScriptName: "script.js")

        case .publicShare:
            guard let websiteId = session.sharedWebsiteId else {
                throw AuthError.invalidCredentials
            }
            _ = try await apiClient.getWebsiteAsync(id: websiteId)
        }
    }

    func selectWorkspace(_ selection: WorkspaceSelection) {
        selectedWorkspace = sanitizedWorkspaceSelection(selection, teams: availableTeams)
        if let session = currentSession {
            persistWorkspaceSelection(selectedWorkspace, for: session)
        }
    }

    func trackerScriptURL() -> String {
        let baseURLString = currentSession?.trackerBaseURL ?? serverURL ?? Constants.cloudTrackerBaseURL
        let scriptName = serverConfig?.trackerScriptName ?? "script.js"

        guard let url = URL(string: baseURLString) else {
            return baseURLString.isEmpty ? scriptName : "\(baseURLString)/\(scriptName)"
        }

        return url.appendingPathComponent(scriptName).absoluteString
    }

    // MARK: - Private Bootstrap

    private func loadSelfHostedBootstrap(
        client: APIClient,
        session: UmamiSession,
        fallbackUser: User?
    ) async throws -> (user: User, config: ServerConfig?, teams: [WorkspaceTeam]) {
        async let configTask = client.getServerConfigAsync()
        async let userTask = client.getCurrentUserAsync()
        async let teamsTask = client.getMyTeamsAsync(page: 1, pageSize: 100)

        let resolvedUser: User
        do {
            resolvedUser = try await userTask
        } catch {
            if let fallbackUser {
                resolvedUser = fallbackUser
            } else {
                throw error
            }
        }

        let resolvedConfig = try? await configTask
        let resolvedTeams = (try? await teamsTask) ?? []

        persistUser(resolvedUser, for: session)
        persistTeams(resolvedTeams, for: session)
        persistServerConfig(resolvedConfig, for: session)

        return (resolvedUser, resolvedConfig, resolvedTeams)
    }

    private func persistAuthenticatedSession(
        session: UmamiSession,
        client: APIClient,
        secret: String,
        secretKind: SecretKind,
        currentUser: User?,
        serverConfig: ServerConfig?,
        teams: [WorkspaceTeam]
    ) {
        currentSession = session
        apiClient = client
        serverType = session.serverType
        serverURL = session.baseURL
        isAuthenticated = true
        self.currentUser = currentUser
        self.serverConfig = serverConfig
        self.availableTeams = teams
        self.selectedWorkspace = sanitizedWorkspaceSelection(.personal, teams: teams)

        persistSession(session)
        saveSecret(secret, kind: secretKind, for: session)
        persistServerConfig(serverConfig, for: session)
        persistTeams(teams, for: session)
        persistWorkspaceSelection(selectedWorkspace, for: session)

        if let currentUser {
            persistUser(currentUser, for: session)
        } else {
            clearPersistedUser(for: session)
        }
    }

    // MARK: - Session Restore

    private func restoreSession() {
        guard let session = loadCurrentSession() else {
            resetRuntimeState(clearSelection: false)
            serverType = loadSavedServerType()
            serverURL = initialServerURL(for: serverType)
            return
        }

        do {
            let client = try APIClient(
                serverURL: session.baseURL,
                serverType: session.serverType,
                cloudRegion: session.cloudRegion ?? .global
            )

            let secret: String?
            switch session.serverType {
            case .selfHosted:
                secret = loadSecret(kind: .bearerToken, for: session)
                if let secret {
                    client.setAuthToken(secret)
                }
            case .cloud:
                secret = loadSecret(kind: .cloudAPIKey, for: session)
                if let secret {
                    client.setAPIKey(secret)
                    cloudAPIKey = secret
                }
            case .publicShare:
                secret = loadSecret(kind: .shareToken, for: session)
                if let secret {
                    client.setShareToken(secret)
                }
            }

            guard secret != nil else {
                clearCurrentSession()
                return
            }

            currentSession = session
            apiClient = client
            serverType = session.serverType
            serverURL = session.baseURL
            isAuthenticated = true
            serverConfig = loadPersistedServerConfig(for: session)
            currentUser = loadPersistedUser(for: session)
            availableTeams = loadPersistedTeams(for: session)
            selectedWorkspace = sanitizedWorkspaceSelection(loadedWorkspaceSelection(for: session), teams: availableTeams)
        } catch {
            logger.error("Failed to restore session: \(error.localizedDescription, privacy: .public)")
            clearCurrentSession()
        }
    }

#if DEBUG
    func configureUITestSession() {
        let baseURL = "https://ui-test.umami.local"
        let session = UmamiSession(
            serverType: .selfHosted,
            baseURL: baseURL,
            normalizedBaseURL: baseURL,
            cloudRegion: nil,
            trackerBaseURL: baseURL,
            shareId: nil,
            sharedWebsiteId: nil
        )

        currentSession = session
        apiClient = try? APIClient(serverURL: baseURL, serverType: .selfHosted)
        serverType = .selfHosted
        serverURL = baseURL
        isAuthenticated = true
        currentUser = User(
            id: "ui-test-user",
            username: "UITest",
            role: "admin",
            createdAt: nil,
            isAdmin: true
        )
        availableTeams = []
        selectedWorkspace = .personal
        serverConfig = ServerConfig()
    }
#endif

    // MARK: - Persistence Helpers

    private func persistSession(_ session: UmamiSession) {
        if let encoded = try? JSONEncoder().encode(session) {
            UserDefaults.standard.set(encoded, forKey: StorageKey.currentSession)
        }
    }

    private func loadCurrentSession() -> UmamiSession? {
        guard let data = UserDefaults.standard.data(forKey: StorageKey.currentSession) else {
            return nil
        }
        return try? JSONDecoder().decode(UmamiSession.self, from: data)
    }

    private func clearCurrentSessionStorage() {
        UserDefaults.standard.removeObject(forKey: StorageKey.currentSession)
    }

    private func saveServerType(_ type: ServerType) {
        UserDefaults.standard.set(type.rawValue, forKey: StorageKey.lastSelectedServerType)
    }

    private func loadSavedServerType() -> ServerType {
        if let storedValue = UserDefaults.standard.string(forKey: StorageKey.lastSelectedServerType),
           let storedType = ServerType(rawValue: storedValue) {
            return storedType
        }
        return .selfHosted
    }

    private func loadServerType() {
        serverType = loadSavedServerType()
    }

    private func saveServerURL(_ url: String, for type: ServerType) {
        switch type {
        case .selfHosted:
            storedSelfHostedServerURL = url
            UserDefaults.standard.set(url, forKey: StorageKey.selfHostedServerURL)
        case .publicShare:
            storedPublicShareServerURL = url
            UserDefaults.standard.set(url, forKey: StorageKey.publicShareServerURL)
        case .cloud:
            break
        }
    }

    private func loadSavedServerURLs() {
        storedSelfHostedServerURL = UserDefaults.standard.string(forKey: StorageKey.selfHostedServerURL)
        storedPublicShareServerURL = UserDefaults.standard.string(forKey: StorageKey.publicShareServerURL)
    }

    private func initialServerURL(for type: ServerType) -> String? {
        switch type {
        case .cloud:
            return Constants.cloudAPIBaseURL
        case .selfHosted:
            return storedSelfHostedServerURL
        case .publicShare:
            return storedPublicShareServerURL
        }
    }

    private func normalizedServerURL(_ value: String?) throws -> String {
        guard let trimmed = value?.trimmingCharacters(in: .whitespacesAndNewlines),
              !trimmed.isEmpty else {
            throw AuthError.invalidURL
        }

        let candidate = trimmed.contains("://") ? trimmed : "https://\(trimmed)"
        guard var components = URLComponents(string: candidate),
              let scheme = components.scheme?.lowercased(),
              scheme == "http" || scheme == "https",
              let host = components.host,
              !host.isEmpty else {
            throw AuthError.invalidURL
        }

        components.scheme = scheme
        components.host = host.lowercased()
        components.query = nil
        components.fragment = nil

        if (scheme == "https" && components.port == 443) || (scheme == "http" && components.port == 80) {
            components.port = nil
        }

        var path = components.path
        while path.hasSuffix("/") {
            path.removeLast()
        }
        if path == "/api" || path.hasSuffix("/api") {
            path.removeLast(4)
        }
        components.path = path

        guard let url = components.url else {
            throw AuthError.invalidURL
        }

        return url.absoluteString
    }

    // MARK: - Namespaced Storage

    private func namespacedKey(_ base: String, session: UmamiSession) -> String {
        let namespace = session.identifier.replacingOccurrences(
            of: "[^A-Za-z0-9]+",
            with: "_",
            options: .regularExpression
        )
        return "\(base).\(namespace)"
    }

    private func saveSecret(_ value: String, kind: SecretKind, for session: UmamiSession) {
        saveToKeychain(value: value, key: namespacedKey("secret.\(kind.rawValue)", session: session))
    }

    private func loadSecret(kind: SecretKind, for session: UmamiSession?) -> String? {
        guard let session else { return nil }
        return loadFromKeychain(key: namespacedKey("secret.\(kind.rawValue)", session: session))
    }

    private func deleteSecret(kind: SecretKind, for session: UmamiSession) {
        deleteFromKeychain(key: namespacedKey("secret.\(kind.rawValue)", session: session))
    }

    private func persistUser(_ user: User, for session: UmamiSession) {
        if let data = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(data, forKey: namespacedKey("user", session: session))
        }
    }

    private func loadPersistedUser(for session: UmamiSession) -> User? {
        guard let data = UserDefaults.standard.data(forKey: namespacedKey("user", session: session)) else {
            return nil
        }
        return try? JSONDecoder().decode(User.self, from: data)
    }

    private func clearPersistedUser(for session: UmamiSession) {
        UserDefaults.standard.removeObject(forKey: namespacedKey("user", session: session))
    }

    private func persistServerConfig(_ config: ServerConfig?, for session: UmamiSession) {
        let key = namespacedKey("config", session: session)
        guard let config else {
            UserDefaults.standard.removeObject(forKey: key)
            return
        }
        if let data = try? JSONEncoder().encode(config) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    private func loadPersistedServerConfig(for session: UmamiSession) -> ServerConfig? {
        guard let data = UserDefaults.standard.data(forKey: namespacedKey("config", session: session)) else {
            return nil
        }
        return try? JSONDecoder().decode(ServerConfig.self, from: data)
    }

    private func persistTeams(_ teams: [WorkspaceTeam], for session: UmamiSession) {
        if let data = try? JSONEncoder().encode(teams) {
            UserDefaults.standard.set(data, forKey: namespacedKey("teams", session: session))
        }
    }

    private func loadPersistedTeams(for session: UmamiSession) -> [WorkspaceTeam] {
        guard let data = UserDefaults.standard.data(forKey: namespacedKey("teams", session: session)),
              let teams = try? JSONDecoder().decode([WorkspaceTeam].self, from: data) else {
            return []
        }
        return teams
    }

    private func persistWorkspaceSelection(_ selection: WorkspaceSelection, for session: UmamiSession) {
        if let data = try? JSONEncoder().encode(selection) {
            UserDefaults.standard.set(data, forKey: namespacedKey("workspace", session: session))
        }
    }

    private func loadedWorkspaceSelection(for session: UmamiSession) -> WorkspaceSelection {
        guard let data = UserDefaults.standard.data(forKey: namespacedKey("workspace", session: session)),
              let selection = try? JSONDecoder().decode(WorkspaceSelection.self, from: data) else {
            return .personal
        }
        return selection
    }

    private func sanitizedWorkspaceSelection(_ selection: WorkspaceSelection, teams: [WorkspaceTeam]) -> WorkspaceSelection {
        guard let teamId = selection.teamId else {
            return .personal
        }

        if let matchingTeam = teams.first(where: { $0.id == teamId }) {
            return WorkspaceSelection(teamId: matchingTeam.id, name: matchingTeam.name)
        }

        return .personal
    }

    // MARK: - Reset Helpers

    private func clearCurrentSession() {
        guard let session = currentSession else {
            resetRuntimeState(clearSelection: true)
            clearCurrentSessionStorage()
            return
        }

        switch session.serverType {
        case .selfHosted:
            deleteSecret(kind: .bearerToken, for: session)
        case .cloud:
            deleteSecret(kind: .cloudAPIKey, for: session)
        case .publicShare:
            deleteSecret(kind: .shareToken, for: session)
        }

        clearPersistedUser(for: session)
        UserDefaults.standard.removeObject(forKey: namespacedKey("config", session: session))
        UserDefaults.standard.removeObject(forKey: namespacedKey("teams", session: session))
        UserDefaults.standard.removeObject(forKey: namespacedKey("workspace", session: session))
        clearCurrentSessionStorage()

        resetRuntimeState(clearSelection: true)
        serverURL = initialServerURL(for: serverType)
    }

    private func resetRuntimeState(clearSelection: Bool) {
        apiClient = nil
        isAuthenticated = false
        currentUser = nil
        currentSession = nil
        serverConfig = nil
        availableTeams = []
        cloudAPIKey = nil
        if clearSelection {
            selectedWorkspace = .personal
        }
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

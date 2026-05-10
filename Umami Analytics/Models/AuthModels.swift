//
//  AuthModels.swift
//  Umami Analytics
//
//  Created by Augment on 4/17/25.
//

import Foundation

struct AuthCredentials: Codable, Sendable {
    let username: String
    let password: String
}

struct AuthResponse: Codable, Sendable {
    let token: String
    let user: User
}

struct User: Codable, Sendable {
    let id: String
    let username: String
    let role: String
    let createdAt: String?
    let isAdmin: Bool

    enum CodingKeys: String, CodingKey {
        case id, username, role, createdAt, isAdmin
    }

    init(id: String, username: String, role: String, createdAt: String? = nil, isAdmin: Bool? = nil) {
        self.id = id
        self.username = username
        self.role = role
        self.createdAt = createdAt
        self.isAdmin = isAdmin ?? (role == "admin")
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        username = try container.decode(String.self, forKey: .username)
        role = (try? container.decode(String.self, forKey: .role)) ?? "user"
        createdAt = try? container.decode(String.self, forKey: .createdAt)
        isAdmin = (try? container.decode(Bool.self, forKey: .isAdmin)) ?? (role == "admin")
    }
}

struct CurrentUserResponse: Decodable, Sendable {
    let user: User

    private enum CodingKeys: String, CodingKey {
        case user
    }

    init(from decoder: Decoder) throws {
        if let directUser = try? User(from: decoder) {
            user = directUser
            return
        }

        let container = try decoder.container(keyedBy: CodingKeys.self)
        user = try container.decode(User.self, forKey: .user)
    }
}

struct ServerInfo: Codable, Sendable {
    let url: String
    let name: String
}

enum CloudRegion: String, Codable, CaseIterable, Identifiable, Sendable {
    case global
    case us
    case eu

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .global:
            return "Global"
        case .us:
            return "United States"
        case .eu:
            return "Europe"
        }
    }

    var pathComponent: String? {
        switch self {
        case .global:
            return nil
        case .us, .eu:
            return rawValue
        }
    }
}

enum ServerType: String, Codable, CaseIterable, Sendable {
    case cloud
    case selfHosted = "self"
    case publicShare = "share"

    var displayName: String {
        switch self {
        case .cloud:
            return "Umami Cloud"
        case .selfHosted:
            return "Self Hosted"
        case .publicShare:
            return "Shared Dashboard"
        }
    }
}

struct ServerConfig: Codable, Sendable, Equatable {
    let cloudMode: Bool?
    let privateMode: Bool?
    let trackerScriptName: String?
    let linksUrl: String?
    let pixelsUrl: String?

    init(
        cloudMode: Bool? = nil,
        privateMode: Bool? = nil,
        trackerScriptName: String? = nil,
        linksUrl: String? = nil,
        pixelsUrl: String? = nil
    ) {
        self.cloudMode = cloudMode
        self.privateMode = privateMode
        self.trackerScriptName = trackerScriptName
        self.linksUrl = linksUrl
        self.pixelsUrl = pixelsUrl
    }
}

struct WorkspaceTeam: Codable, Identifiable, Hashable, Sendable {
    let id: String
    let name: String
    let role: String?
    let accessCode: String?

    init(id: String, name: String, role: String? = nil, accessCode: String? = nil) {
        self.id = id
        self.name = name
        self.role = role
        self.accessCode = accessCode
    }
}

struct WorkspaceSelection: Codable, Equatable, Hashable, Sendable {
    let teamId: String?
    let name: String

    static let personal = WorkspaceSelection(teamId: nil, name: "Personal")

    var id: String {
        teamId ?? "personal"
    }

    var isPersonal: Bool {
        teamId == nil
    }
}

struct UmamiSession: Codable, Equatable, Sendable {
    let serverType: ServerType
    let baseURL: String
    let normalizedBaseURL: String
    let cloudRegion: CloudRegion?
    let trackerBaseURL: String
    let shareId: String?
    let sharedWebsiteId: String?

    var identifier: String {
        let regionSegment = cloudRegion?.rawValue ?? "none"
        let shareSegment = shareId ?? "none"
        return "\(serverType.rawValue)|\(normalizedBaseURL)|\(regionSegment)|\(shareSegment)"
    }

    var isReadOnly: Bool {
        serverType == .publicShare
    }

    var isCloud: Bool {
        serverType == .cloud
    }
}

struct ShareBootstrapResponse: Codable, Sendable {
    let websiteId: String
    let token: String
}

enum AuthError: Error, Sendable {
    case invalidURL
    case invalidCredentials
    case missingAPIKey
    case missingShareID
    case networkError(String)
    case serverError(String)
    case decodingError
    case unknown

    var message: String {
        switch self {
        case .invalidURL:
            return "Invalid server URL. Please check the URL and try again."
        case .invalidCredentials:
            return "Incorrect username or password."
        case .missingAPIKey:
            return "Please enter your Umami Cloud API key."
        case .missingShareID:
            return "Please enter the shared dashboard ID."
        case .networkError(let description):
            return "Network error: \(description)"
        case .serverError(let message):
            return "Server error: \(message)"
        case .decodingError:
            return "Error processing server response."
        case .unknown:
            return "An unknown error occurred."
        }
    }
}

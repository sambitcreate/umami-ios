//
//  AuthModels.swift
//  Umami Analytics
//
//  Created by Augment on 4/17/25.
//

import Foundation

struct AuthCredentials: Codable {
    let username: String
    let password: String
}

struct AuthResponse: Codable {
    let token: String
    let user: User
}

struct User: Codable, Identifiable {
    let id: String
    let username: String
    let role: String?
    let createdAt: String?
    let isAdmin: Bool?
    let teams: [Team]?

    // Computed property for backward compatibility
    var unwrappedRole: String { role ?? "user" }
    var unwrappedIsAdmin: Bool { isAdmin ?? false }

    enum CodingKeys: String, CodingKey {
        case id, username, role, createdAt, isAdmin, teams
    }

    // Custom decoder to handle different API formats
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // Required fields
        id = try container.decode(String.self, forKey: .id)
        username = try container.decode(String.self, forKey: .username)

        // Optional fields with defaults
        role = try container.decodeIfPresent(String.self, forKey: .role)
        createdAt = try container.decodeIfPresent(String.self, forKey: .createdAt)
        isAdmin = try container.decodeIfPresent(Bool.self, forKey: .isAdmin)
        teams = try container.decodeIfPresent([Team].self, forKey: .teams)
    }

    // Standard encoder
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(username, forKey: .username)
        try container.encodeIfPresent(role, forKey: .role)
        try container.encodeIfPresent(createdAt, forKey: .createdAt)
        try container.encodeIfPresent(isAdmin, forKey: .isAdmin)
        try container.encodeIfPresent(teams, forKey: .teams)
    }

    // Default initializer
    init(id: String, username: String, role: String? = nil, createdAt: String? = nil, isAdmin: Bool? = nil, teams: [Team]? = nil) {
        self.id = id
        self.username = username
        self.role = role
        self.createdAt = createdAt
        self.isAdmin = isAdmin
        self.teams = teams
    }
}

// Team model for Umami v3
struct Team: Codable, Identifiable {
    let id: String
    let name: String
    let createdAt: String?
}

struct ServerInfo: Codable {
    let url: String
    let name: String
}

enum AuthError: Error {
    case invalidURL
    case invalidCredentials
    case networkError(Error)
    case serverError(String)
    case decodingError
    case unknown
    
    var message: String {
        switch self {
        case .invalidURL:
            return "Invalid server URL. Please check the URL and try again."
        case .invalidCredentials:
            return "Incorrect username or password."
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

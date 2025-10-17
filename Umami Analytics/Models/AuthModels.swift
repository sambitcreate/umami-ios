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

struct User: Codable {
    let id: String
    let username: String
    let role: String
    let createdAt: String?
    let isAdmin: Bool

    enum CodingKeys: String, CodingKey {
        case id, username, role, createdAt, isAdmin
    }
}

struct ServerInfo: Codable {
    let url: String
    let name: String
}

enum ServerType: String, Codable, CaseIterable {
    case cloud
    case selfHosted = "self"

    var displayName: String {
        switch self {
        case .cloud:
            return "Umami Cloud"
        case .selfHosted:
            return "Self Hosted"
        }
    }
}

enum AuthError: Error {
    case invalidURL
    case invalidCredentials
    case missingAPIKey
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
        case .missingAPIKey:
            return "Please enter your Umami Cloud API key."
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

//
//  SettingsView.swift
//  Umami Analytics
//
//  Extracted from ContentView.swift
//

import SwiftUI

@MainActor
struct SettingsView: View {
    @State private var showingLogoutConfirmation = false

    private var authManager: AuthManager { AuthManager.shared }

    private var maskedAPIKey: String {
        guard let key = authManager.cloudAPIKey, !key.isEmpty else {
            return "Not stored"
        }

        let prefix = key.prefix(4)
        let suffix = key.suffix(4)
        return "\(prefix)…\(suffix)"
    }

    private var appVersion: String {
        let shortVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "Unknown"
        let buildNumber = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "0"
        return "\(shortVersion) (\(buildNumber))"
    }

    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("Account")) {
                    if let user = authManager.currentUser {
                        HStack {
                            Text("Username")
                            Spacer()
                            Text(user.username)
                                .foregroundStyle(.secondary)
                        }

                        HStack {
                            Text("Role")
                            Spacer()
                            Text(user.role)
                                .foregroundStyle(.secondary)
                        }
                    } else {
                        HStack {
                            Text("Mode")
                            Spacer()
                            Text(authManager.serverType.displayName)
                                .foregroundStyle(.secondary)
                        }

                        if authManager.serverType == .cloud {
                            HStack {
                                Text("API Key")
                                Spacer()
                                Text(maskedAPIKey)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }

                    Button("Sign Out") {
                        showingLogoutConfirmation = true
                    }
                    .foregroundStyle(.red)
                }

                Section(header: Text("Server")) {
                    HStack {
                        Text("Type")
                        Spacer()
                        Text(authManager.serverType.displayName)
                            .foregroundStyle(.secondary)
                    }

                    if let serverURL = authManager.serverURL {
                        HStack {
                            Text("URL")
                            Spacer()
                            Text(serverURL)
                                .foregroundStyle(.secondary)
                        }
                    } else if let savedURL = authManager.savedSelfHostedServerURL {
                        HStack {
                            Text("Last URL")
                            Spacer()
                            Text(savedURL)
                                .foregroundStyle(.secondary)
                        }
                    }

                    if authManager.serverType == .cloud {
                        HStack {
                            Text("Authentication")
                            Spacer()
                            Text("API Key Header")
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                Section(header: Text("About")) {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text(appVersion)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
            .alert("Sign Out", isPresented: $showingLogoutConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Sign Out", role: .destructive) {
                    Task { @MainActor in
                        try? await authManager.logout()
                    }
                }
            } message: {
                Text("Are you sure you want to sign out?")
            }
        }
    }
}

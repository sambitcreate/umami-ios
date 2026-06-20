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
    @State private var selectedWorkspaceID = AuthManager.shared.selectedWorkspace.id
    @StateObject private var resourceViewModel = WebsiteViewModel(shouldStartBackgroundRefresh: false)

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

                    HStack {
                        Text("Session")
                        Spacer()
                        Text(authManager.isReadOnlySession ? "Read Only" : "Read/Write")
                            .foregroundStyle(.secondary)
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

                    if let session = authManager.currentSession {
                        HStack {
                            Text("Tracker URL")
                            Spacer()
                            Text(session.trackerBaseURL)
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                        }
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

                        HStack {
                            Text("Region")
                            Spacer()
                            Text(authManager.activeCloudRegion.displayName)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                Section(header: Text("Workspace")) {
                    HStack {
                        Text("Current")
                        Spacer()
                        Text(currentWorkspace.name)
                            .foregroundStyle(.secondary)
                    }

                    if !authManager.availableTeams.isEmpty {
                        Menu {
                            ForEach(authManager.workspaceOptions, id: \.id) { workspace in
                                Button(workspace.name) {
                                    selectedWorkspaceID = workspace.id
                                    resourceViewModel.applyWorkspaceSelection(workspace, reloadResources: true)
                                }
                            }
                        } label: {
                            HStack {
                                Text("Switch Workspace")
                                Spacer()
                                Text("Choose")
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }

                    if let teamId = currentWorkspace.teamId {
                        HStack {
                            Text("Team ID")
                            Spacer()
                            Text(teamId)
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                        }
                    }
                }

                Section(header: Text("Resources")) {
                    resourceSummary
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
            .onAppear {
                selectedWorkspaceID = authManager.selectedWorkspace.id
                resourceViewModel.loadWebsites()
            }
            .onChange(of: authManager.selectedWorkspace) { newSelection in
                selectedWorkspaceID = newSelection.id
                resourceViewModel.applyWorkspaceSelection(newSelection, reloadResources: true)
            }
            .onChange(of: resourceViewModel.filteredWebsites.map(\.id)) { _ in
                refreshWorkspaceResources()
            }
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

    private var currentWorkspace: WorkspaceSelection {
        if let selected = authManager.workspaceOptions.first(where: { $0.id == selectedWorkspaceID }) {
            return selected
        }
        return authManager.selectedWorkspace
    }

    private var resourceSummary: some View {
        VStack(alignment: .leading, spacing: 14) {
            resourceCountRow(title: "Reports", count: resourceViewModel.reports.count)
            resourceCountRow(title: "Segments", count: resourceViewModel.segments.count)
            resourceCountRow(title: "Cohorts", count: resourceViewModel.cohorts.count)
            resourceCountRow(title: "Links", count: resourceViewModel.links.count)
            resourceCountRow(title: "Pixels", count: resourceViewModel.pixels.count)

            if resourceViewModel.isLoadingResources {
                ProgressView()
            }

            if !resourceViewModel.reports.isEmpty {
                resourceItemList(title: "Saved Reports", items: resourceViewModel.reports.prefix(3).map { "\($0.name) - \($0.type)" })
            }

            if !resourceViewModel.segments.isEmpty {
                resourceItemList(title: "Segments", items: resourceViewModel.segments.prefix(3).map { $0.name })
            }

            if !resourceViewModel.cohorts.isEmpty {
                resourceItemList(title: "Cohorts", items: resourceViewModel.cohorts.prefix(3).map { $0.name })
            }

            if !resourceViewModel.links.isEmpty {
                resourceItemList(title: "Links", items: resourceViewModel.links.prefix(3).map { "\($0.name) - \($0.slug)" })
            }

            if !resourceViewModel.pixels.isEmpty {
                resourceItemList(title: "Pixels", items: resourceViewModel.pixels.prefix(3).map { "\($0.name) - \($0.slug)" })
            }
        }
    }

    private func resourceCountRow(title: String, count: Int) -> some View {
        HStack {
            Text(title)
            Spacer()
            Text("\(count)")
                .foregroundStyle(.secondary)
        }
    }

    private func resourceItemList(title: String, items: [String]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.footnote)
                .fontWeight(.medium)

            ForEach(items, id: \.self) { item in
                Text(item)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        }
    }

    private func refreshWorkspaceResources() {
        resourceViewModel.selectedWebsite = resourceViewModel.filteredWebsites.first
        resourceViewModel.loadWorkspaceResources()
    }
}

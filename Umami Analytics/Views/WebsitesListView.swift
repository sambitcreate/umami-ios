//
//  WebsitesListView.swift
//  Umami Analytics
//
//  Extracted from ContentView.swift
//

import SwiftUI

@MainActor
struct WebsitesView: View {
    @ObservedObject var viewModel: WebsiteViewModel
    @ObservedObject private var authManager = AuthManager.shared
    @State private var showingAddWebsite = false
    @State private var websiteToEdit: WebsiteModel?
    @State private var websiteForScript: WebsiteModel?
    @State private var websitePendingDeletion: WebsiteModel?
    @State private var showingDeleteConfirmation = false

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.hasWebsites {
                    List {
                        workspaceSection

                        ForEach(viewModel.filteredWebsites) { website in
                            NavigationLink {
                                WebsiteDetailContainerView(website: website)
                            } label: {
                                WebsiteRowView(website: website, isStarred: viewModel.isStarred(website.id))
                            }
                            .swipeActions(edge: .leading, allowsFullSwipe: true) {
                                Button {
                                    viewModel.toggleStar(website.id)
                                } label: {
                                    Label(
                                        viewModel.isStarred(website.id) ? "Unstar" : "Star",
                                        systemImage: viewModel.isStarred(website.id) ? "star.slash" : "star.fill"
                                    )
                                }
                                .tint(.yellow)

                                if canManageWebsites {
                                    Button {
                                        websiteForScript = website
                                    } label: {
                                        Label("Script", systemImage: "doc.on.doc")
                                    }
                                    .tint(.purple)
                                }
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                if canManageWebsites {
                                    Button {
                                        websiteToEdit = website
                                    } label: {
                                        Label("Edit", systemImage: "square.and.pencil")
                                    }
                                    .tint(.blue)

                                    Button(role: .destructive) {
                                        websitePendingDeletion = website
                                        showingDeleteConfirmation = true
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                            }
                            .contextMenu {
                                Button {
                                    viewModel.toggleStar(website.id)
                                } label: {
                                    Label(
                                        viewModel.isStarred(website.id) ? "Remove from Dashboard" : "Add to Dashboard",
                                        systemImage: viewModel.isStarred(website.id) ? "star.slash" : "star.fill"
                                    )
                                }

                                if canManageWebsites {
                                    Button {
                                        websiteToEdit = website
                                    } label: {
                                        Label("Edit Website", systemImage: "square.and.pencil")
                                    }

                                    Button {
                                        websiteForScript = website
                                    } label: {
                                        Label("Tracking Script", systemImage: "doc.on.doc")
                                    }

                                    Divider()

                                    Button(role: .destructive) {
                                        websitePendingDeletion = website
                                        showingDeleteConfirmation = true
                                    } label: {
                                        Label("Delete Website", systemImage: "trash")
                                    }
                                }
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                    .refreshable {
                        viewModel.loadWebsites()
                    }
                } else {
                    VStack(spacing: 20) {
                        Image(systemName: "globe")
                            .font(.largeTitle)
                            .imageScale(.large)
                            .foregroundStyle(.secondary)

                        Text("No websites found")
                            .font(.headline)
                            .foregroundStyle(.secondary)

                        Text(
                            authManager.isReadOnlySession
                            ? "This shared dashboard does not currently expose any websites."
                            : "Websites connected to your selected workspace will appear here."
                        )
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)

                        if canManageWebsites {
                            Button("Add Website") {
                                showingAddWebsite = true
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.accentColor)
                        }

                        Button("Refresh") {
                            viewModel.loadWebsites()
                        }
                        .buttonStyle(.bordered)
                        .padding()
                    }
                    .padding()
                }
            }
            .navigationTitle("Websites")
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    if canManageWebsites {
                        Button {
                            showingAddWebsite = true
                        } label: {
                            Label("Add Website", systemImage: "plus")
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.accentColor)
                        .accessibilityLabel("Add website")
                    }

                    Button(action: {
                        viewModel.loadWebsites()
                    }) {
                        Image(systemName: "arrow.clockwise")
                    }
                    .buttonStyle(.bordered)
                    .accessibilityLabel("Refresh")
                }
            }
            .overlay {
                if viewModel.isLoading || viewModel.isPerformingAction {
                    UmamiLoadingStatus(
                        message: viewModel.isPerformingAction ? "Updating website" : "Loading websites"
                    )
                }
            }
            .alert("Error", isPresented: Binding<Bool>(
                get: { viewModel.errorMessage != nil },
                set: { if !$0 { viewModel.errorMessage = nil } }
            )) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(viewModel.errorMessage ?? "Unknown error")
            }
            .confirmationDialog(
                "Delete Website",
                isPresented: $showingDeleteConfirmation,
                presenting: websitePendingDeletion
            ) { website in
                Button("Delete", role: .destructive) {
                    viewModel.deleteWebsite(website) { _ in
                        websitePendingDeletion = nil
                    }
                }

                Button("Cancel", role: .cancel) {
                    websitePendingDeletion = nil
                }
            } message: { website in
                Text("Are you sure you want to delete \(website.name)? This action cannot be undone.")
            }
        }
        .onAppear {
            viewModel.loadWebsites()
        }
        .sheet(isPresented: $showingAddWebsite) {
            WebsiteFormView(mode: .create, viewModel: viewModel)
        }
        .sheet(item: $websiteToEdit) { website in
            WebsiteFormView(mode: .edit(website), viewModel: viewModel)
        }
        .sheet(item: $websiteForScript) { website in
            TrackingScriptView(website: website)
        }
    }

    private var canManageWebsites: Bool {
        !authManager.isReadOnlySession
    }

    @ViewBuilder
    private var workspaceSection: some View {
        if authManager.workspaceOptions.count > 1 || authManager.isReadOnlySession {
            Section {
                HStack {
                    Label("Workspace", systemImage: "person.2")
                    Spacer()
                    Picker(
                        "Workspace",
                        selection: Binding(
                            get: { authManager.selectedWorkspace },
                            set: { viewModel.applyWorkspaceSelection($0) }
                        )
                    ) {
                        ForEach(authManager.workspaceOptions, id: \.id) { option in
                            Text(option.name).tag(option)
                        }
                    }
                    .pickerStyle(.menu)
                    .disabled(authManager.isReadOnlySession)
                }

                if authManager.isReadOnlySession {
                    Label("Editing is unavailable while browsing a public share.", systemImage: "lock.fill")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}

// MARK: - Website Row

@MainActor
struct WebsiteRowView: View {
    let website: WebsiteModel
    var isStarred: Bool = false

    var body: some View {
        HStack(spacing: 12) {
            WebsiteFaviconView(domain: website.domain, size: 28)

            VStack(alignment: .leading, spacing: 4) {
                Text(website.name)
                    .font(.headline)

                Text(website.domain)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            if isStarred {
                Image(systemName: "star.fill")
                    .foregroundStyle(.yellow)
                    .font(.caption)
                    .accessibilityHidden(true)
            }
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(website.name), \(website.domain)\(isStarred ? ", starred" : "")")
    }
}

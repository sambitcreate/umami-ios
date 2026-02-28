//
//  WebsitesListView.swift
//  Umami Analytics
//
//  Extracted from ContentView.swift
//

import SwiftUI

@MainActor
struct WebsitesView: View {
    @StateObject private var viewModel = WebsiteViewModel()
    @State private var showingAddWebsite = false
    @State private var websiteToEdit: WebsiteModel?
    @State private var websiteForScript: WebsiteModel?
    @State private var websitePendingDeletion: WebsiteModel?
    @State private var showingDeleteConfirmation = false

    var body: some View {
        NavigationView {
            Group {
                if viewModel.hasWebsites {
                    List {
                        ForEach(viewModel.websites) { website in
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

                                Button {
                                    websiteForScript = website
                                } label: {
                                    Label("Script", systemImage: "doc.on.doc")
                                }
                                .tint(.purple)
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
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
                            .contextMenu {
                                Button {
                                    viewModel.toggleStar(website.id)
                                } label: {
                                    Label(
                                        viewModel.isStarred(website.id) ? "Remove from Dashboard" : "Add to Dashboard",
                                        systemImage: viewModel.isStarred(website.id) ? "star.slash" : "star.fill"
                                    )
                                }

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
                    .listStyle(InsetGroupedListStyle())
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

                        Text("Websites connected to your Umami account will appear here.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)

                        Button("Add Website") {
                            showingAddWebsite = true
                        }
                        .buttonStyle(.borderedProminent)

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
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button {
                        showingAddWebsite = true
                    } label: {
                        Image(systemName: "plus")
                    }

                    Button(action: {
                        viewModel.loadWebsites()
                    }) {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
            .overlay {
                if viewModel.isLoading || viewModel.isPerformingAction {
                    ProgressView()
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
            }
        }
        .padding(.vertical, 4)
    }
}

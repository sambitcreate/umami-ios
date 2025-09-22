//
//  ContentView.swift
//  Umami Analytics
//
//  Created by Sambit Biswas on 4/17/25.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject private var appState: AppState

    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            // Dashboard Tab
            DashboardView(selectedTab: $selectedTab)
                .tabItem {
                    Label("Dashboard", systemImage: "chart.bar")
                }
                .tag(0)

            // Websites Tab
            WebsitesView()
                .tabItem {
                    Label("Websites", systemImage: "globe")
                }
                .tag(1)

            // Settings Tab
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .tag(2)
        }
    }
}

struct DashboardView: View {
    @EnvironmentObject private var appState: AppState
    @StateObject private var viewModel = WebsiteViewModel()
    @Binding var selectedTab: Int
    // Dashboard now focuses on greeting + recent sites

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Welcome header
                    if let user = AuthManager.shared.currentUser {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Welcome, \(user.username)")
                                .font(.title)
                                .fontWeight(.bold)

                            if let serverURL = AuthManager.shared.serverURL {
                                Text("Connected to: \(serverURL)")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                    }

                    if viewModel.hasWebsites {
                        // Recent sites
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Your Recent Sites:")
                                .font(.headline)
                                .padding(.horizontal)

                            ForEach(viewModel.websites.prefix(3)) { website in
                                NavigationLink(
                                    destination: WebsiteDetailView(
                                        viewModel: WebsiteViewModel(selectedWebsite: website)
                                    )
                                ) {
                                    DashboardWebsiteRow(website: website)
                                }
                            }

                            Button(action: { selectedTab = 1 }) {
                                Text("View All Websites")
                                    .font(.headline)
                                    .foregroundColor(.blue)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color(UIColor.secondarySystemBackground))
                                    .cornerRadius(10)
                            }
                            .padding(.horizontal)
                        }
                    } else {
                        // Empty state
                        VStack(spacing: 20) {
                            Image(systemName: "chart.bar.xaxis")
                                .font(.system(size: 60))
                                .foregroundColor(.gray)

                            Text("No websites found")
                                .font(.headline)
                                .foregroundColor(.secondary)

                            Text("Add websites to your Umami account to see analytics data here.")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)

                            Button(action: { selectedTab = 1 }) {
                                Text("Go to Websites")
                                    .fontWeight(.semibold)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 10)
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                        }
                        .padding(40)
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Dashboard")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        viewModel.loadWebsites()
                    }) {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
            .overlay {
                if viewModel.isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color(UIColor.systemBackground))
                                .frame(width: 100, height: 100)
                                .shadow(radius: 5)
                        )
                }
            }
            .alert(isPresented: Binding<Bool>(
                get: { viewModel.errorMessage != nil },
                set: { if !$0 { viewModel.errorMessage = nil } }
            )) {
                Alert(
                    title: Text("Error"),
                    message: Text(viewModel.errorMessage ?? "Unknown error"),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
        .onAppear {
            viewModel.loadWebsites()
        }
    }
}

struct DashboardWebsiteRow: View {
    let website: WebsiteModel

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(website.name)
                    .font(.headline)

                Text(website.domain)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(10)
        .padding(.horizontal)
    }
}

struct WebsitesView: View {
    @StateObject private var viewModel = WebsiteViewModel()
    @State private var showingAddWebsite = false

    var body: some View {
        NavigationView {
            Group {
                if viewModel.hasWebsites {
                    List {
                        ForEach(viewModel.websites) { website in
                            NavigationLink(
                                destination: WebsiteDetailView(
                                    viewModel: WebsiteViewModel(selectedWebsite: website)
                                )
                            ) {
                                WebsiteRowView(website: website)
                            }
                        }
                    }
                    .listStyle(InsetGroupedListStyle())
                } else {
                    VStack(spacing: 20) {
                        Image(systemName: "globe")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)

                        Text("No websites found")
                            .font(.headline)
                            .foregroundColor(.secondary)

                        Text("Websites connected to your Umami account will appear here.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)

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
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        viewModel.loadWebsites()
                    }) {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
            .overlay {
                if viewModel.isLoading {
                    ProgressView()
                }
            }
            .alert(isPresented: Binding<Bool>(
                get: { viewModel.errorMessage != nil },
                set: { if !$0 { viewModel.errorMessage = nil } }
            )) {
                Alert(
                    title: Text("Error"),
                    message: Text(viewModel.errorMessage ?? "Unknown error"),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
        .onAppear {
            viewModel.loadWebsites()
        }
    }
}

struct WebsiteRowView: View {
    let website: WebsiteModel

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(website.name)
                .font(.headline)

            Text(website.domain)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}

struct SettingsView: View {
    @EnvironmentObject private var appState: AppState
    @State private var showingLogoutConfirmation = false

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Account")) {
                    if let user = AuthManager.shared.currentUser {
                        HStack {
                            Text("Username")
                            Spacer()
                            Text(user.username)
                                .foregroundColor(.secondary)
                        }

                        HStack {
                            Text("Role")
                            Spacer()
                            Text(user.role)
                                .foregroundColor(.secondary)
                        }
                    }

                    Button("Sign Out") {
                        showingLogoutConfirmation = true
                    }
                    .foregroundColor(.red)
                }

                Section(header: Text("Server")) {
                    if let serverURL = AuthManager.shared.serverURL {
                        HStack {
                            Text("URL")
                            Spacer()
                            Text(serverURL)
                                .foregroundColor(.secondary)
                        }
                    }
                }

                Section(header: Text("About")) {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
            .alert("Sign Out", isPresented: $showingLogoutConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Sign Out", role: .destructive) {
                    AuthManager.shared.logout { _ in
                        // Logout handled by AppState observer
                    }
                }
            } message: {
                Text("Are you sure you want to sign out?")
            }
        }
    }
}

struct StatCard: View {
    var title: String
    var value: String
    var icon: String

    var body: some View {
        VStack {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.blue)
                Spacer()
            }
            .padding(.bottom, 5)

            HStack {
                Text(value)
                    .font(.title)
                    .fontWeight(.bold)
                Spacer()
            }

            HStack {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(10)
    }
}

#Preview {
    ContentView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        .environmentObject(AppState())
}

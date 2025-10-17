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
            DashboardView()
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
    @State private var selectedPeriod: StatsPeriod = .day

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Welcome header
                    let authManager = AuthManager.shared
                    if let user = authManager.currentUser {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Welcome, \(user.username)")
                                .font(.title)
                                .fontWeight(.bold)

                            if let serverURL = authManager.serverURL {
                                Text("Connected to: \(serverURL)")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                    } else {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(authManager.serverType.displayName)
                                .font(.title)
                                .fontWeight(.bold)

                            if authManager.serverType == .cloud {
                                Text("Connected using your Umami Cloud API key.")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }

                            if let serverURL = authManager.serverURL {
                                Text("Endpoint: \(serverURL)")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                    }

                    // Period selector
                    HStack {
                        Text("Period:")
                            .font(.headline)

                        Picker("Period", selection: $selectedPeriod) {
                            Text("Today").tag(StatsPeriod.day)
                            Text("This Week").tag(StatsPeriod.week)
                            Text("This Month").tag(StatsPeriod.month)
                            Text("This Year").tag(StatsPeriod.year)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .onChange(of: selectedPeriod) { newValue in
                            viewModel.changePeriod(newValue)
                        }
                    }
                    .padding(.horizontal)

                    if viewModel.hasWebsites {
                        // Total stats cards
                        VStack(spacing: 16) {
                            HStack(spacing: 16) {
                                StatCard(title: "Visitors", value: viewModel.formattedVisitors, icon: "person.fill")
                                StatCard(title: "Pageviews", value: viewModel.formattedPageviews, icon: "doc.text.fill")
                            }

                            HStack(spacing: 16) {
                                StatCard(title: "Bounce Rate", value: viewModel.formattedBounceRate, icon: "arrow.up.arrow.down")
                                StatCard(title: "Avg. Duration", value: viewModel.formattedDuration, icon: "clock.fill")
                            }
                        }
                        .padding(.horizontal)

                        // Chart
                        if let pageviewsData = viewModel.pageviewsData {
                            AnalyticsChartView(
                                pageviews: pageviewsData.pageviews,
                                visitors: pageviewsData.sessions,
                                period: viewModel.selectedPeriod
                            )
                            .padding(.horizontal)
                        } else {
                            AnalyticsChartView(
                                pageviews: [],
                                visitors: [],
                                period: viewModel.selectedPeriod
                            )
                            .padding(.horizontal)
                        }

                        // Website list
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Your Websites")
                                .font(.headline)
                                .padding(.horizontal)

                            ForEach(viewModel.websites.prefix(3)) { website in
                                NavigationLink(destination: {
                                    // Create a new view model instance with the selected website
                                    let detailViewModel = WebsiteViewModel()
                                    detailViewModel.selectWebsite(website)
                                    return WebsiteDetailView(viewModel: detailViewModel)
                                }()) {
                                    DashboardWebsiteRow(website: website)
                                }
                            }

                            NavigationLink(destination: WebsitesView()) {
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

                            NavigationLink(destination: WebsitesView()) {
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
        HStack(spacing: 12) {
            WebsiteFaviconView(domain: website.domain)

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
                            NavigationLink(destination: {
                                // Create a new view model instance with the selected website
                                let detailViewModel = WebsiteViewModel()
                                detailViewModel.selectWebsite(website)
                                return WebsiteDetailView(viewModel: detailViewModel)
                            }()) {
                                WebsiteRowView(website: website)
                            }
                            .swipeActions(edge: .leading, allowsFullSwipe: false) {
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

struct WebsiteRowView: View {
    let website: WebsiteModel

    var body: some View {
        HStack(spacing: 12) {
            WebsiteFaviconView(domain: website.domain, size: 28)

            VStack(alignment: .leading, spacing: 4) {
                Text(website.name)
                    .font(.headline)

                Text(website.domain)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

struct WebsiteFaviconView: View {
    var domain: String
    var size: CGFloat = 36

    private var faviconURL: URL? {
        var trimmedDomain = domain.trimmingCharacters(in: .whitespacesAndNewlines)

        if trimmedDomain.hasPrefix("http://") || trimmedDomain.hasPrefix("https://") {
            if let url = URL(string: trimmedDomain), let host = url.host {
                trimmedDomain = host
            }
        }

        guard !trimmedDomain.isEmpty else { return nil }

        let encodedDomain = trimmedDomain.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? trimmedDomain
        let urlString = "https://www.google.com/s2/favicons?sz=64&domain=\(encodedDomain)"
        return URL(string: urlString)
    }

    var body: some View {
        AsyncImage(url: faviconURL) { phase in
            switch phase {
            case .success(let image):
                image
                    .resizable()
                    .scaledToFit()
                    .frame(width: size, height: size)
                    .clipShape(RoundedRectangle(cornerRadius: size / 4, style: .continuous))
            case .failure:
                placeholder
            case .empty:
                placeholder.overlay(
                    ProgressView()
                        .scaleEffect(0.6)
                )
            @unknown default:
                placeholder
            }
        }
        .frame(width: size, height: size)
    }

    private var placeholder: some View {
        RoundedRectangle(cornerRadius: size / 4, style: .continuous)
            .fill(Color(UIColor.secondarySystemBackground))
            .overlay(
                Image(systemName: "globe")
                    .font(.system(size: size / 2))
                    .foregroundColor(.secondary)
            )
    }
}

struct SettingsView: View {
    @EnvironmentObject private var appState: AppState
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

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Account")) {
                    if let user = authManager.currentUser {
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
                    } else {
                        HStack {
                            Text("Mode")
                            Spacer()
                            Text(authManager.serverType.displayName)
                                .foregroundColor(.secondary)
                        }

                        if authManager.serverType == .cloud {
                            HStack {
                                Text("API Key")
                                Spacer()
                                Text(maskedAPIKey)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }

                    Button("Sign Out") {
                        showingLogoutConfirmation = true
                    }
                    .foregroundColor(.red)
                }

                Section(header: Text("Server")) {
                    HStack {
                        Text("Type")
                        Spacer()
                        Text(authManager.serverType.displayName)
                            .foregroundColor(.secondary)
                    }

                    if let serverURL = authManager.serverURL {
                        HStack {
                            Text("URL")
                            Spacer()
                            Text(serverURL)
                                .foregroundColor(.secondary)
                        }
                    } else if let savedURL = authManager.savedSelfHostedServerURL {
                        HStack {
                            Text("Last URL")
                            Spacer()
                            Text(savedURL)
                                .foregroundColor(.secondary)
                        }
                    }

                    if authManager.serverType == .cloud {
                        HStack {
                            Text("Authentication")
                            Spacer()
                            Text("API Key Header")
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

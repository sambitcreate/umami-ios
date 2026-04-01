//
//  DashboardView.swift
//  Umami Analytics
//
//  Extracted from ContentView.swift
//

import SwiftUI

@MainActor
struct DashboardView: View {
    @StateObject private var viewModel = WebsiteViewModel()
    @ObservedObject private var authManager = AuthManager.shared

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    welcomeHeader
                    workspaceSelector
                    periodSelector

                    if viewModel.hasWebsites {
                        statsCards
                        chartSection
                        starredWebsitesSection
                    } else {
                        emptyState
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Dashboard")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
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
            .alert("Error", isPresented: Binding<Bool>(
                get: { viewModel.errorMessage != nil },
                set: { if !$0 { viewModel.errorMessage = nil } }
            )) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(viewModel.errorMessage ?? "Unknown error")
            }
        }
        .onAppear {
            viewModel.loadWebsites()
            viewModel.loadDashboardStats()
        }
        .onChange(of: authManager.selectedWorkspace) { _, newSelection in
            viewModel.applyWorkspaceSelection(newSelection)
        }
    }

    // MARK: - Subviews

    @ViewBuilder
    private var welcomeHeader: some View {
        if let user = authManager.currentUser {
            VStack(alignment: .leading, spacing: 8) {
                Text("Welcome, \(user.username)")
                    .font(.title)
                    .fontWeight(.bold)

                Text(authManager.selectedWorkspace.name)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                if let serverURL = authManager.serverURL {
                    Text("Connected to: \(serverURL)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
        } else {
            VStack(alignment: .leading, spacing: 8) {
                Text(authManager.serverType.displayName)
                    .font(.title)
                    .fontWeight(.bold)

                if authManager.isReadOnlySession {
                    Label("Read-only shared analytics", systemImage: "lock.fill")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                } else {
                    Text(authManager.selectedWorkspace.name)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                if authManager.serverType == .cloud {
                    Text("Connected using your Umami Cloud API key.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                if let serverURL = authManager.serverURL {
                    Text("Endpoint: \(serverURL)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
        }
    }

    @ViewBuilder
    private var workspaceSelector: some View {
        if authManager.workspaceOptions.count > 1 || authManager.isReadOnlySession {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("Workspace")
                        .font(.headline)

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
                    Text("Public shares stay read-only, so website settings remain hidden.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal)
        }
    }

    private var periodSelector: some View {
        HStack {
            Text("Period:")
                .font(.headline)

            Picker("Period", selection: $viewModel.selectedPeriod) {
                Text("Today").tag(StatsPeriod.day)
                Text("This Week").tag(StatsPeriod.week)
                Text("This Month").tag(StatsPeriod.month)
                Text("This Year").tag(StatsPeriod.year)
            }
            .pickerStyle(.segmented)
            .onChange(of: viewModel.selectedPeriod) { _, newValue in
                viewModel.changePeriod(newValue)
            }
        }
        .padding(.horizontal)
    }

    private var statsCards: some View {
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
    }

    private var chartSection: some View {
        Group {
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
        }
    }

    private var starredWebsitesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(viewModel.hasStarredWebsites ? "Starred Websites" : "Top Websites")
                    .font(.headline)

                Spacer()

                if !viewModel.hasStarredWebsites && viewModel.hasWebsites {
                    Text("Star websites to pin them here")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal)

            ForEach(viewModel.dashboardWebsites) { website in
                NavigationLink {
                    WebsiteDetailContainerView(website: website)
                } label: {
                    DashboardWebsiteCard(
                        website: website,
                        stats: viewModel.dashboardStats[website.id]
                    )
                }
            }

            NavigationLink(destination: WebsitesView()) {
                Text("View All Websites")
                    .font(.headline)
                    .foregroundStyle(.blue)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(10)
            }
            .padding(.horizontal)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 20) {
            Image(systemName: authManager.isReadOnlySession ? "lock.doc" : "chart.bar.xaxis")
                .font(.largeTitle)
                .imageScale(.large)
                .foregroundStyle(.secondary)

            Text(authManager.isReadOnlySession ? "No shared website loaded" : "No websites found")
                .font(.headline)
                .foregroundStyle(.secondary)

            Text(
                authManager.isReadOnlySession
                ? "This shared dashboard session does not currently expose a website."
                : "Add websites to your selected workspace to see analytics data here."
            )
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            if !authManager.isReadOnlySession {
                NavigationLink(destination: WebsitesView()) {
                    Text("Go to Websites")
                        .fontWeight(.semibold)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Color.blue)
                        .foregroundStyle(.white)
                        .cornerRadius(10)
                }
            }
        }
        .padding(40)
    }
}

// MARK: - Dashboard Website Card

@MainActor
struct DashboardWebsiteCard: View {
    let website: WebsiteModel
    let stats: WebsiteStatsResponse?

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                WebsiteFaviconView(domain: website.domain, size: 32)

                VStack(alignment: .leading, spacing: 2) {
                    Text(website.name)
                        .font(.headline)
                        .foregroundStyle(.primary)

                    Text(website.domain)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.top, 14)
            .padding(.bottom, 10)

            HStack(spacing: 0) {
                metricCell(icon: "person.fill", label: "Visitors", value: stats.map { formatCompact($0.visitors) } ?? "--", color: .blue)
                Divider().frame(height: 36)
                metricCell(icon: "doc.text.fill", label: "Views", value: stats.map { formatCompact($0.pageviews) } ?? "--", color: .indigo)
                Divider().frame(height: 36)
                metricCell(icon: "arrow.up.arrow.down", label: "Bounce", value: stats.map { formatBounce($0) } ?? "--", color: .orange)
            }
            .padding(.horizontal, 8)
            .padding(.bottom, 14)
        }
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
        .padding(.horizontal)
    }

    private func metricCell(icon: String, label: String, value: String, color: Color) -> some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 10))
                    .foregroundStyle(color)

                Text(value)
                    .font(.system(.subheadline, design: .rounded))
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                    .contentTransition(.numericText())
            }

            Text(label)
                .font(.system(size: 10))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }

    private func formatCompact(_ number: Int) -> String {
        if number >= 1_000_000 {
            return String(format: "%.1fM", Double(number) / 1_000_000)
        } else if number >= 1_000 {
            return String(format: "%.1fK", Double(number) / 1_000)
        } else {
            return "\(number)"
        }
    }

    private func formatBounce(_ stats: WebsiteStatsResponse) -> String {
        guard stats.visits > 0 else { return "0%" }
        let rate = Double(stats.bounces) / Double(stats.visits) * 100
        return String(format: "%.0f%%", rate)
    }
}

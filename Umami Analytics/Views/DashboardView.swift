//
//  DashboardView.swift
//  Umami Analytics
//
//  Extracted from ContentView.swift
//

import SwiftUI

@MainActor
struct DashboardView: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @ObservedObject private var viewModel: WebsiteViewModel
    @ObservedObject private var authManager = AuthManager.shared
    @Binding private var selectedTab: Int

    init(viewModel: WebsiteViewModel, selectedTab: Binding<Int>) {
        self.viewModel = viewModel
        self._selectedTab = selectedTab
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    header
                    workspaceSelector
                    periodSelector

                    if viewModel.hasWebsites {
                        liveOverview
                        metricGrid
                        activitySection
                    } else {
                        emptyState
                    }
                }
                .padding(.vertical)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Overview")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: triggerDashboardRefresh) {
                        Image(systemName: "arrow.clockwise")
                            .symbolRenderingMode(.hierarchical)
                    }
                    .accessibilityLabel("Refresh dashboard")
                }
            }
            .refreshable {
                await refreshDashboard()
            }
            .overlay {
                if viewModel.isLoading && !viewModel.hasWebsites {
                    ProgressView()
                        .scaleEffect(1.4)
                        .padding(28)
                        .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .shadow(color: .primary.opacity(0.12), radius: 18, x: 0, y: 8)
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
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            ViewThatFits(in: .horizontal) {
                headerRow

                VStack(alignment: .leading, spacing: 10) {
                    headerText
                    statusPill
                }
            }

            if let serverURL = authManager.serverURL {
                Label(serverURL, systemImage: "server.rack")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .truncationMode(.middle)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal)
    }

    private var headerRow: some View {
        HStack(alignment: .firstTextBaseline) {
            headerText
            Spacer(minLength: 12)
            statusPill
        }
    }

    private var headerText: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Live watchlist")
                .font(.largeTitle.bold())
                .accessibilityAddTraits(.isHeader)

            Text(headerSubtitle)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    private var headerSubtitle: String {
        if authManager.isReadOnlySession {
            return "Read-only shared analytics"
        }

        if let user = authManager.currentUser {
            return "\(user.username) in \(authManager.selectedWorkspace.name)"
        }

        return authManager.selectedWorkspace.name
    }

    private var statusPill: some View {
        HStack(spacing: 6) {
            Image(systemName: "circle.fill")
                .font(.system(size: 8))
                .foregroundStyle(totalActiveUsers > 0 ? .green : .secondary)

            Text(totalActiveUsers > 0 ? "Live" : "Quiet")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.primary)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 7)
        .background(Color(.secondarySystemGroupedBackground), in: Capsule())
        .accessibilityElement(children: .combine)
        .accessibilityLabel(totalActiveUsers > 0 ? "Live traffic is active" : "No live traffic detected")
    }

    @ViewBuilder
    private var workspaceSelector: some View {
        if authManager.workspaceOptions.count > 1 || authManager.isReadOnlySession {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Label("Workspace", systemImage: "person.2.crop.square.stack")
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
            .dashboardPanel()
        }
    }

    private var periodSelector: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Window")
                .font(.headline)

            Picker("Window", selection: $viewModel.selectedPeriod) {
                Text(StatsPeriod.day.displayName).tag(StatsPeriod.day)
                Text(StatsPeriod.week.displayName).tag(StatsPeriod.week)
                Text(StatsPeriod.month.displayName).tag(StatsPeriod.month)
                Text(StatsPeriod.year.displayName).tag(StatsPeriod.year)
            }
            .pickerStyle(.segmented)
            .onChange(of: viewModel.selectedPeriod) { newValue in
                viewModel.changeDashboardPeriod(newValue)
            }
        }
        .padding(.horizontal)
    }

    private var liveOverview: some View {
        VStack(alignment: .leading, spacing: 18) {
            ViewThatFits(in: .horizontal) {
                liveOverviewRow

                VStack(alignment: .leading, spacing: 14) {
                    activeNowBlock
                    liveOverviewBadges
                }
            }

            if !partialLoadText.isEmpty {
                Label(partialLoadText, systemImage: "exclamationmark.triangle.fill")
                    .font(.footnote)
                    .foregroundStyle(.orange)
            }

            if !rankedDashboardWebsites.isEmpty {
                VStack(spacing: 10) {
                    ForEach(rankedDashboardWebsites) { website in
                        LiveSiteRow(
                            website: website,
                            activeUsers: viewModel.dashboardActiveUsers[website.id],
                            stats: viewModel.dashboardStats[website.id],
                            statsDidFail: viewModel.dashboardStatsFailedWebsiteIds.contains(website.id),
                            activeUsersDidFail: viewModel.dashboardActiveUsersFailedWebsiteIds.contains(website.id),
                            maxPageviews: maxDashboardPageviews,
                            formatNumber: viewModel.formatNumber
                        )
                    }
                }
            }
        }
        .dashboardPanel()
    }

    private var liveOverviewRow: some View {
        HStack(alignment: .top, spacing: 14) {
            activeNowBlock
            Spacer()
            liveOverviewBadges
        }
    }

    private var activeNowBlock: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Active now", systemImage: "dot.radiowaves.left.and.right")
                .font(.headline)
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(.secondary)

            Text(viewModel.formatNumber(totalActiveUsers))
                .font(.system(.largeTitle, design: .rounded).weight(.bold))
                .contentTransition(.numericText())

            Text(liveStatusText)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    private var liveOverviewBadges: some View {
        VStack(alignment: .trailing, spacing: 8) {
            DashboardBadge(
                icon: "eye",
                value: "\(rankedDashboardWebsites.count)",
                label: rankedDashboardWebsites.count == 1 ? "watched site" : "watched sites"
            )

            DashboardBadge(
                icon: "globe",
                value: "\(viewModel.filteredWebsites.count)",
                label: viewModel.filteredWebsites.count == 1 ? "total site" : "total sites"
            )

            if let dashboardLastUpdated = viewModel.dashboardLastUpdated {
                Text("Updated \(Self.relativeFormatter.localizedString(for: dashboardLastUpdated, relativeTo: Date()))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var metricGrid: some View {
        LazyVGrid(columns: dashboardMetricColumns, spacing: 12) {
            DashboardMetricTile(
                title: "Visitors",
                value: viewModel.formatNumber(aggregateVisitors),
                context: "\(viewModel.selectedPeriod.displayName) across \(watchlistScopeText)",
                icon: "person.2.fill",
                color: .blue
            )

            DashboardMetricTile(
                title: "Pageviews",
                value: viewModel.formatNumber(aggregatePageviews),
                context: aggregateVisits > 0 ? "\(viewModel.formatNumber(aggregateVisits)) visits" : "waiting for traffic",
                icon: "chart.line.uptrend.xyaxis",
                color: .indigo
            )

            DashboardMetricTile(
                title: "Bounce",
                value: formatBounceRate(visits: aggregateVisits, bounces: aggregateBounces),
                context: aggregateVisits > 0 ? "of \(viewModel.formatNumber(aggregateVisits)) visits" : "no visits yet",
                icon: "arrow.down.right.and.arrow.up.left",
                color: .orange
            )

            DashboardMetricTile(
                title: "Avg. time",
                value: formatDuration(aggregateAverageDuration),
                context: "per pageview",
                icon: "timer",
                color: .teal
            )
        }
        .padding(.horizontal)
    }

    private var activitySection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text(viewModel.hasStarredWebsites ? "Pinned watchlist" : "Most recent sites")
                        .font(.headline)

                    Text(viewModel.hasStarredWebsites ? "Your starred websites stay on deck." : "Star websites to pin them here.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Button {
                    selectedTab = 1
                } label: {
                    Label("All", systemImage: "square.grid.2x2")
                        .labelStyle(.iconOnly)
                        .frame(width: 36, height: 36)
                }
                .buttonStyle(.bordered)
                .accessibilityLabel("View all websites")
            }

            ForEach(rankedDashboardWebsites) { website in
                NavigationLink {
                    WebsiteDetailContainerView(website: website)
                } label: {
                    DashboardWebsiteCard(
                        website: website,
                        stats: viewModel.dashboardStats[website.id],
                        activeUsers: viewModel.dashboardActiveUsers[website.id],
                        statsDidFail: viewModel.dashboardStatsFailedWebsiteIds.contains(website.id),
                        activeUsersDidFail: viewModel.dashboardActiveUsersFailedWebsiteIds.contains(website.id),
                        formatNumber: viewModel.formatNumber
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal)
    }

    private var emptyState: some View {
        VStack(spacing: 18) {
            Image(systemName: authManager.isReadOnlySession ? "lock.doc" : "chart.bar.xaxis")
                .font(.largeTitle)
                .imageScale(.large)
                .foregroundStyle(.secondary)

            VStack(spacing: 6) {
                Text(authManager.isReadOnlySession ? "No shared website loaded" : "No websites yet")
                    .font(.headline)

                Text(
                    authManager.isReadOnlySession
                    ? "This shared dashboard session does not currently expose a website."
                    : "Add a website to turn this overview into live traffic, trends, and pinned watchlists."
                )
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            }

            if !authManager.isReadOnlySession {
                Button {
                    selectedTab = 1
                } label: {
                    Label("Go to Websites", systemImage: "plus.circle.fill")
                        .fontWeight(.semibold)
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .frame(maxWidth: .infinity)
        .dashboardPanel()
        .padding(.top, 12)
    }

    private var liveStatusText: String {
        if totalActiveUsers > 0 {
            return "Across \(watchlistScopeText)"
        }

        if viewModel.dashboardLastUpdated == nil {
            return "Checking live traffic..."
        }

        return "No active visitors in the last poll"
    }

    private var partialLoadText: String {
        let failedCount = viewModel.dashboardFailedWebsiteIds.intersection(Set(rankedDashboardWebsites.map(\.id))).count
        guard failedCount > 0 else { return "" }
        let loadedCount = max(rankedDashboardWebsites.count - failedCount, 0)
        return "\(loadedCount) of \(rankedDashboardWebsites.count) watched sites loaded"
    }

    private var watchlistScopeText: String {
        "\(rankedDashboardWebsites.count) watched \(rankedDashboardWebsites.count == 1 ? "site" : "sites")"
    }

    private var dashboardMetricColumns: [GridItem] {
        if dynamicTypeSize.isAccessibilitySize {
            return [GridItem(.flexible())]
        }

        return [GridItem(.adaptive(minimum: 155), spacing: 12)]
    }

    private var statsList: [WebsiteStatsResponse] {
        viewModel.dashboardWebsites.compactMap { viewModel.dashboardStats[$0.id] }
    }

    private var aggregatePageviews: Int {
        statsList.reduce(0) { $0 + $1.pageviews }
    }

    private var aggregateVisitors: Int {
        statsList.reduce(0) { $0 + $1.visitors }
    }

    private var aggregateVisits: Int {
        statsList.reduce(0) { $0 + $1.visits }
    }

    private var aggregateBounces: Int {
        statsList.reduce(0) { $0 + $1.bounces }
    }

    private var aggregateTotalTime: Int {
        statsList.reduce(0) { $0 + $1.totaltime }
    }

    private var aggregateAverageDuration: Double {
        guard aggregatePageviews > 0 else { return 0 }
        return Double(aggregateTotalTime) / Double(aggregatePageviews)
    }

    private var totalActiveUsers: Int {
        viewModel.dashboardActiveUsers.values.reduce(0, +)
    }

    private var maxDashboardPageviews: Int {
        max(rankedDashboardWebsites.compactMap { viewModel.dashboardStats[$0.id]?.pageviews }.max() ?? 0, 1)
    }

    private var rankedDashboardWebsites: [WebsiteModel] {
        viewModel.dashboardWebsites.sorted { lhs, rhs in
            let lhsActive = viewModel.dashboardActiveUsers[lhs.id] ?? 0
            let rhsActive = viewModel.dashboardActiveUsers[rhs.id] ?? 0

            if lhsActive != rhsActive {
                return lhsActive > rhsActive
            }

            let lhsViews = viewModel.dashboardStats[lhs.id]?.pageviews ?? 0
            let rhsViews = viewModel.dashboardStats[rhs.id]?.pageviews ?? 0
            return lhsViews > rhsViews
        }
    }

    private func triggerDashboardRefresh() {
        Task {
            await viewModel.refreshDashboardAsync()
        }
    }

    private func refreshDashboard() async {
        await viewModel.refreshDashboardAsync()
    }

    private func formatBounceRate(visits: Int, bounces: Int) -> String {
        guard visits > 0 else { return "--" }
        return String(format: "%.0f%%", (Double(bounces) / Double(visits)) * 100)
    }

    private func formatDuration(_ seconds: Double) -> String {
        if seconds < 60 {
            return String(format: "%.0fs", seconds)
        }

        let minutes = Int(seconds / 60)
        let remainingSeconds = Int(seconds.truncatingRemainder(dividingBy: 60))
        return String(format: "%dm %ds", minutes, remainingSeconds)
    }

    private static let relativeFormatter: RelativeDateTimeFormatter = {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter
    }()
}

private struct DashboardBadge: View {
    let icon: String
    let value: String
    let label: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(value)
                .font(.headline.monospacedDigit())

            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(.tertiarySystemGroupedBackground), in: Capsule())
    }
}

private struct DashboardMetricTile: View {
    let title: String
    let value: String
    let context: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.headline)
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(color)

                Spacer()
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .font(.system(.title2, design: .rounded).weight(.bold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
                    .contentTransition(.numericText())

                Text(title)
                    .font(.subheadline.weight(.semibold))

                Text(context)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title): \(value), \(context)")
    }
}

private struct LiveSiteRow: View {
    let website: WebsiteModel
    let activeUsers: Int?
    let stats: WebsiteStatsResponse?
    let statsDidFail: Bool
    let activeUsersDidFail: Bool
    let maxPageviews: Int
    let formatNumber: (Int) -> String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 10) {
                WebsiteFaviconView(domain: website.domain, size: 28)
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: 2) {
                    Text(website.name)
                        .font(.subheadline.weight(.semibold))
                        .lineLimit(1)

                    Text(statusText)
                        .font(.caption)
                        .foregroundStyle(statusColor)
                }

                Spacer()

                Text(stats.map { formatNumber($0.pageviews) } ?? "--")
                    .font(.subheadline.monospacedDigit().weight(.semibold))
                    .contentTransition(.numericText())
            }

            ProgressView(value: Double(stats?.pageviews ?? 0), total: Double(maxPageviews))
                .tint((activeUsers ?? 0) > 0 ? .green : .blue)
                .accessibilityHidden(true)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(website.name), \(statusText), \(stats?.pageviews ?? 0) pageviews")
    }

    private var statusText: String {
        if activeUsersDidFail {
            return "Active unknown"
        }

        guard let activeUsers else {
            return "Checking live traffic"
        }

        if activeUsers > 0 {
            return "\(formatNumber(activeUsers)) active now"
        }

        if statsDidFail && stats == nil {
            return "Stats unavailable"
        }

        return "No active visitors"
    }

    private var statusColor: Color {
        if activeUsersDidFail || statsDidFail {
            return .orange
        }

        return (activeUsers ?? 0) > 0 ? .green : .secondary
    }
}

@MainActor
struct DashboardWebsiteCard: View {
    let website: WebsiteModel
    let stats: WebsiteStatsResponse?
    let activeUsers: Int?
    let statsDidFail: Bool
    let activeUsersDidFail: Bool
    let formatNumber: (Int) -> String

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 12) {
                WebsiteFaviconView(domain: website.domain, size: 34)
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: 3) {
                    Text(website.name)
                        .font(.headline)
                        .foregroundStyle(.primary)
                        .lineLimit(1)

                    Text(website.domain)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 3) {
                    Label(activeUsersText, systemImage: "circle.fill")
                        .labelStyle(.titleAndIcon)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(activeStatusColor)

                    Text(activeUsersDidFail ? "unknown" : "active")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }

            ViewThatFits(in: .horizontal) {
                HStack(spacing: 0) {
                    metricCell(icon: "person.fill", label: "Visitors", value: visitorText, color: .blue)
                    Divider().frame(height: 34)
                    metricCell(icon: "doc.text.fill", label: "Views", value: pageviewText, color: .indigo)
                    Divider().frame(height: 34)
                    metricCell(icon: "arrow.up.arrow.down", label: "Bounce", value: bounceText, color: .orange)
                }

                LazyVGrid(columns: [GridItem(.adaptive(minimum: 92), spacing: 8)], spacing: 8) {
                    metricCell(icon: "person.fill", label: "Visitors", value: visitorText, color: .blue)
                    metricCell(icon: "doc.text.fill", label: "Views", value: pageviewText, color: .indigo)
                    metricCell(icon: "arrow.up.arrow.down", label: "Bounce", value: bounceText, color: .orange)
                }
            }
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilitySummary)
    }

    private func metricCell(icon: String, label: String, value: String, color: Color) -> some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 10))
                    .foregroundStyle(color)

                Text(value)
                    .font(.subheadline.monospacedDigit().weight(.semibold))
                    .foregroundStyle(.primary)
                    .contentTransition(.numericText())
            }

            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }

    private var visitorText: String {
        stats.map { formatNumber($0.visitors) } ?? "--"
    }

    private var pageviewText: String {
        stats.map { formatNumber($0.pageviews) } ?? "--"
    }

    private var bounceText: String {
        stats.map { formatBounce($0) } ?? "--"
    }

    private var activeUsersText: String {
        activeUsers.map(formatNumber) ?? "--"
    }

    private var activeStatusColor: Color {
        if activeUsersDidFail || statsDidFail {
            return .orange
        }

        return (activeUsers ?? 0) > 0 ? .green : .secondary
    }

    private var accessibilitySummary: String {
        "\(website.name), \(website.domain), \(activeUsersAccessibilityText), \(visitorText) visitors, \(pageviewText) views, \(bounceText) bounce"
    }

    private var activeUsersAccessibilityText: String {
        guard let activeUsers else {
            return "active visitors unknown"
        }

        return "\(activeUsers) active visitors"
    }

    private func formatBounce(_ stats: WebsiteStatsResponse) -> String {
        guard stats.visits > 0 else { return "--" }
        let rate = Double(stats.bounces) / Double(stats.visits) * 100
        return String(format: "%.0f%%", rate)
    }
}

private extension View {
    func dashboardPanel() -> some View {
        self
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            .padding(.horizontal)
    }
}

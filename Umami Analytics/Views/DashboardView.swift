//
//  DashboardView.swift
//  Umami Analytics
//
//  Extracted from ContentView.swift
//

import SwiftUI

@MainActor
struct DashboardView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
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
                        metricSection
                        trafficSummary
                        activitySection
                    } else {
                        emptyState
                    }
                }
                .padding(.vertical)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Dashboard")
            .navigationBarTitleDisplayMode(.inline)
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
                    UmamiLoadingStatus(message: "Loading dashboard")
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
        headerText
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal)
    }

    private var headerText: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Traffic at a glance")
                .font(.largeTitle.bold())
                .accessibilityAddTraits(.isHeader)

            Text(headerSubtitle)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    private var headerSubtitle: String {
        if authManager.isReadOnlySession {
            return "A quick read of this shared website"
        }

        return "Your key numbers across \(authManager.selectedWorkspace.name)"
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
            Text("Time range")
                .font(.headline)

            if dynamicTypeSize >= .xxLarge {
                Picker("Time range", selection: $viewModel.selectedPeriod) {
                    periodOptions
                }
                .pickerStyle(.menu)
            } else {
                Picker("Time range", selection: $viewModel.selectedPeriod) {
                    periodOptions
                }
                .pickerStyle(.segmented)
            }
        }
        .padding(.horizontal)
        .onChange(of: viewModel.selectedPeriod) { newValue in
            viewModel.changeDashboardPeriod(newValue)
        }
    }

    @ViewBuilder
    private var periodOptions: some View {
        Text(StatsPeriod.day.displayName).tag(StatsPeriod.day)
        Text(StatsPeriod.week.displayName).tag(StatsPeriod.week)
        Text(StatsPeriod.month.displayName).tag(StatsPeriod.month)
        Text(StatsPeriod.year.displayName).tag(StatsPeriod.year)
    }

    private var liveOverview: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .firstTextBaseline) {
                Label("Right now", systemImage: "dot.radiowaves.left.and.right")
                    .font(.headline)
                    .symbolRenderingMode(.hierarchical)

                Spacer()

                if let dashboardLastUpdated = viewModel.dashboardLastUpdated {
                    Text("Updated \(Self.relativeFormatter.localizedString(for: dashboardLastUpdated, relativeTo: Date()))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            HStack(alignment: .firstTextBaseline, spacing: 10) {
                Text(viewModel.formatNumber(totalActiveUsers))
                    .font(.system(.largeTitle, design: .rounded).weight(.bold))
                    .monospacedDigit()
                    .contentTransition(reduceMotion ? .identity : .numericText())

                Text(totalActiveUsers == 1 ? "person is on your sites" : "people are on your sites")
                    .font(.body)
                    .foregroundStyle(.secondary)
            }

            Text(liveStatusText)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            if !partialLoadText.isEmpty {
                Label(partialLoadText, systemImage: "exclamationmark.triangle.fill")
                    .font(.footnote)
                    .foregroundStyle(.orange)
            }
        }
        .dashboardPanel()
    }

    private var metricSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 3) {
                Text(viewModel.selectedPeriod.displayName)
                    .font(.headline)

                Text("Combined results from \(watchlistScopeText)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            LazyVGrid(columns: dashboardMetricColumns, spacing: 12) {
                DashboardMetricTile(
                    title: "Visitors",
                    value: viewModel.formatNumber(aggregateVisitors),
                    explanation: "People who visited your sites",
                    icon: "person.2.fill",
                    color: .blue
                )

                DashboardMetricTile(
                    title: "Pageviews",
                    value: viewModel.formatNumber(aggregatePageviews),
                    explanation: "Total pages viewed",
                    icon: "doc.text.fill",
                    color: .indigo
                )

                DashboardMetricTile(
                    title: "Bounce rate",
                    value: formatBounceRate(visits: aggregateVisits, bounces: aggregateBounces),
                    explanation: "Visits that ended after one page",
                    icon: "arrow.uturn.backward",
                    color: .orange
                )

                DashboardMetricTile(
                    title: "Average time",
                    value: formatDuration(aggregateAverageDuration),
                    explanation: "Average time per pageview",
                    icon: "timer",
                    color: .teal
                )
            }
        }
        .padding(.horizontal)
    }

    private var trafficSummary: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("Quick read", systemImage: "lightbulb.max.fill")
                .font(.headline)
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(.indigo)

            Text(trafficSummaryText)
                .font(.body)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .dashboardPanel()
        .accessibilityElement(children: .combine)
    }

    private var activitySection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text("By website")
                        .font(.headline)

                    Text("Tap a site to explore its pages, audience, events, and sessions.")
                        .font(.subheadline)
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
                .buttonStyle(UmamiPressableCardStyle())
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
            return "Live activity updates automatically every few seconds."
        }

        if viewModel.dashboardLastUpdated == nil {
            return "Checking live traffic..."
        }

        return "No one is active right now. Your period totals are shown below."
    }

    private var partialLoadText: String {
        let failedCount = viewModel.dashboardFailedWebsiteIds.intersection(Set(rankedDashboardWebsites.map(\.id))).count
        guard failedCount > 0 else { return "" }
        let loadedCount = max(rankedDashboardWebsites.count - failedCount, 0)
        return "\(loadedCount) of \(rankedDashboardWebsites.count) watched sites loaded"
    }

    private var watchlistScopeText: String {
        let scope = viewModel.hasStarredWebsites ? "pinned" : "recent"
        let noun = rankedDashboardWebsites.count == 1 ? "site" : "sites"
        return "\(rankedDashboardWebsites.count) \(scope) \(noun)"
    }

    private var dashboardMetricColumns: [GridItem] {
        if dynamicTypeSize >= .xxLarge {
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

    private var trafficSummaryText: String {
        guard !statsList.isEmpty else {
            return "We are still collecting the numbers for this time range."
        }

        guard aggregateVisitors > 0 || aggregatePageviews > 0 else {
            return "No traffic was recorded in this time range. Try a longer range or check that tracking is installed."
        }

        var sentences = [
            "These sites recorded \(viewModel.formatNumber(aggregateVisitors)) visitors and \(viewModel.formatNumber(aggregatePageviews)) pageviews."
        ]

        if aggregateVisitors > 0 {
            let pagesPerVisitor = Double(aggregatePageviews) / Double(aggregateVisitors)
            sentences.append("That is about \(String(format: "%.1f", pagesPerVisitor)) pages per visitor.")
        }

        if aggregateVisits > 0 {
            let bounce = formatBounceRate(visits: aggregateVisits, bounces: aggregateBounces)
            sentences.append("The bounce rate was \(bounce).")
        }

        return sentences.joined(separator: " ")
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

private struct DashboardMetricTile: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let title: String
    let value: String
    let explanation: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline) {
                Image(systemName: icon)
                    .font(.headline)
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(color)

                Text(title)
                    .font(.subheadline.weight(.semibold))
            }

            Text(value)
                .font(.system(.title2, design: .rounded).weight(.bold))
                .monospacedDigit()
                .lineLimit(1)
                .minimumScaleFactor(0.75)
                .contentTransition(reduceMotion ? .identity : .numericText())

            Text(explanation)
                .font(.footnote)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(14)
        .frame(maxWidth: .infinity, minHeight: 170, alignment: .topLeading)
        .umamiCardSurface(cornerRadius: UmamiDesignMetrics.compactCornerRadius)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title): \(value). \(explanation)")
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
        .umamiCardSurface(cornerRadius: UmamiDesignMetrics.compactCornerRadius)
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

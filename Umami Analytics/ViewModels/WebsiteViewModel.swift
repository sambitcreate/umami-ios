//
//  WebsiteViewModel.swift
//  Umami Analytics
//
//  Created by Augment on 4/17/25.
//

import Foundation
import SwiftUI

@MainActor
final class WebsiteViewModel: ObservableObject {
    let service: WebsiteServicing
    var websitesTask: Task<Void, Never>?
    var dashboardStatsTask: Task<Void, Never>?
    var refreshTask: Task<Void, Never>?
    var realtimeSnapshotTask: Task<Void, Never>?
    var activeUsersTask: Task<Void, Never>?
    var tabTasks: [WebsiteDetailTab: Task<Void, Never>] = [:]
    var tabLoadTokens: [WebsiteDetailTab: UUID] = [:]
    var eventsPageRequestID = UUID()
    var sessionsPageRequestID = UUID()
    var eventDataInspectorRequestID = UUID()
    var eventDataValuesRequestID = UUID()

    let refreshInterval: TimeInterval
    let pageSize: Int
    let realtimePollInterval: TimeInterval
    let shouldStartBackgroundRefresh: Bool

    static let starredKey = "starredWebsiteIds"

    // MARK: - Core Published State

    @Published var websites: [WebsiteModel] = []
    @Published var isLoading = false
    @Published var isRefreshing = false
    @Published var isPerformingAction = false
    @Published var errorMessage: String?
    @Published var selectedPeriod: StatsPeriod = .day
    @Published var queryOptions = AnalyticsQueryOptions()
    @Published var availableFilterValues: [AnalyticsFilterKey: [FilterValue]] = [:]
    @Published var isLoadingFilterValues = false

    // Selected website properties
    @Published var selectedWebsite: WebsiteModel?
    @Published var websiteStats: WebsiteStatsResponse?
    @Published var websiteMetrics: WebsiteMetricsResponse?
    @Published var pageviewsData: PageviewsResponse?
    @Published var activeUsers: ActiveUsersResponse?
    @Published var activeUsersCount = 0
    @Published var hasActiveUsersData = false

    // Dashboard
    @Published var starredWebsiteIds: Set<String> = []
    @Published var dashboardStats: [String: WebsiteStatsResponse] = [:]

    // MARK: - Advanced Analytics State

    @Published var selectedDetailTab: WebsiteDetailTab = .overview
    @Published var tabLoading: [WebsiteDetailTab: Bool] = [:]
    @Published var tabErrors: [WebsiteDetailTab: String] = [:]

    @Published var metricsByDimension: [MetricDimension: [MetricItem]] = [:]
    @Published var eventSeries: [TimeSeriesData] = []
    @Published var eventsPage: PaginatedResponse<AnalyticsRecord>?
    @Published var sessionsPage: PaginatedResponse<AnalyticsRecord>?
    @Published var sessionStats: [String: MetricValue] = [:]
    @Published var sessionsWeekly: [WeeklySessionPoint] = []
    @Published var selectedSessionID: String?
    @Published var isLoadingSessionDetail = false
    @Published var selectedSessionRecord: AnalyticsRecord?
    @Published var selectedSessionActivity: [AnalyticsRecord] = []
    @Published var selectedSessionProperties: [String: JSONValue] = [:]
    @Published var realtimeSnapshot: RealtimeData?
    @Published var eventDataState = EventDataState()

    @Published var reports: [SavedReport] = []
    @Published var segments: [SegmentDefinition] = []
    @Published var cohorts: [SegmentDefinition] = []
    @Published var links: [TrackedAsset] = []
    @Published var pixels: [TrackedAsset] = []
    @Published var isLoadingResources = false

    @Published var eventsSearchQuery = ""
    @Published var sessionsSearchQuery = ""
    @Published var hasMoreEvents = false
    @Published var isLoadingMoreEvents = false
    @Published var hasMoreSessions = false
    @Published var isLoadingMoreSessions = false

    var loadedTabs: Set<WebsiteDetailTab> = []
    var nextEventsPage = 1
    var nextSessionsPage = 1

    // MARK: - Initialization

    init(
        service: WebsiteServicing? = nil,
        shouldStartBackgroundRefresh: Bool = true,
        config: AnalyticsRuntimeConfig = .default,
        initialWebsite: WebsiteModel? = nil
    ) {
        self.service = service ?? WebsiteService.shared
        self.shouldStartBackgroundRefresh = shouldStartBackgroundRefresh
        self.refreshInterval = config.dashboardRefreshInterval
        self.pageSize = config.eventsSessionsPageSize
        self.realtimePollInterval = config.realtimePollInterval
        loadStarredIds()

        if let initialWebsite {
            selectedWebsite = initialWebsite
        } else {
            loadCachedWebsites()
        }

        if shouldStartBackgroundRefresh {
            startBackgroundRefresh()
        }

        if let initialWebsite {
            selectWebsite(initialWebsite)
        }
    }

    // MARK: - Data Loading

    func loadWebsites() {
        websitesTask?.cancel()
        websitesTask = Task { @MainActor [weak self] in
            await self?.loadWebsitesAsync()
        }
    }

    private func loadWebsitesAsync() async {
        isLoading = true
        errorMessage = nil

        defer {
            isLoading = false
            websitesTask = nil
        }

        do {
            let websites = try await service.fetchWebsitesAsync()
            guard !Task.isCancelled else { return }

            self.websites = websites
            loadDashboardStats()
            syncSelectedWebsiteWithVisibleContext(reloadCurrentTab: true)
        } catch {
            guard !Task.isCancelled else { return }
            setRootError(error)
            loadCachedWebsites()
        }
    }

    func loadCachedWebsites() {
        let cachedWebsites = service.fetchCachedWebsites()

        guard !cachedWebsites.isEmpty else {
            return
        }

        websites = cachedWebsites.map { cdWebsite in
            WebsiteModel(
                id: cdWebsite.id ?? "",
                name: cdWebsite.name ?? "Unknown",
                domain: cdWebsite.domain ?? "",
                shareId: nil,
                userId: nil,
                teamId: nil,
                createdAt: ISO8601DateFormatter().string(from: cdWebsite.lastUpdated ?? Date())
            )
        }

        if selectedWebsite == nil, let firstWebsite = websites.first {
            selectedWebsite = firstWebsite
        }
    }

    func loadCachedStats(websiteId: String) {
        guard let cachedStats = service.fetchCachedStats(for: websiteId, period: selectedPeriod) else {
            return
        }

        var stats = WebsiteStatsResponse(
            pageviews: Int(cachedStats.pageviews),
            visitors: Int(cachedStats.visitors),
            visits: 0,
            bounces: 0,
            totaltime: 0,
            comparison: nil
        )
        stats.cachedBounceRate = cachedStats.bounceRate
        stats.cachedAvgDuration = cachedStats.avgDuration
        websiteStats = stats
    }

    func selectWebsite(_ website: WebsiteModel) {
        stopRealtimeSnapshotPolling()
        stopRealtimeUpdates()
        cancelTabLoads()

        selectedWebsite = website
        selectedDetailTab = .overview
        loadedTabs.removeAll()
        tabErrors.removeAll()
        tabLoading.removeAll()
        resetWebsiteSelectionState()

        service.invalidateAnalyticsCache(for: website.id)
        loadTabIfNeeded(.overview, force: true)
    }

    func selectDetailTab(_ tab: WebsiteDetailTab) {
        let previousTab = selectedDetailTab
        selectedDetailTab = tab

        if previousTab == .realtime && tab != .realtime {
            stopRealtimeSnapshotPolling()
        }

        if previousTab == .overview && tab != .overview {
            stopRealtimeUpdates()
        }

        loadTabIfNeeded(tab)
    }

    func refreshCurrentTab() {
        guard let websiteId = selectedWebsite?.id else { return }
        service.invalidateAnalyticsCache(for: websiteId)
        loadedTabs.remove(selectedDetailTab)
        loadTabIfNeeded(selectedDetailTab, force: true)
    }

    func loadWebsiteData(website: WebsiteModel) {
        if selectedWebsite?.id != website.id {
            selectWebsite(website)
            return
        }

        refreshCurrentTab()
    }

    func createWebsite(name: String, domain: String, shareId: String?, teamId: String?, completion: @escaping (Result<WebsiteModel, Error>) -> Void) {
        isPerformingAction = true

        Task { @MainActor [weak self] in
            guard let self else { return }

            defer { isPerformingAction = false }

            do {
                let website = try await service.createWebsiteAsync(name: name, domain: domain, shareId: shareId, teamId: teamId, id: nil)
                if let index = websites.firstIndex(where: { $0.id == website.id }) {
                    websites[index] = website
                } else {
                    websites.insert(website, at: 0)
                }
                loadDashboardStats()
                completion(.success(website))
            } catch {
                setRootError(error)
                completion(.failure(error))
            }
        }
    }

    func updateWebsite(_ website: WebsiteModel, name: String, domain: String, shareId: String?, completion: @escaping (Result<WebsiteModel, Error>) -> Void) {
        isPerformingAction = true

        Task { @MainActor [weak self] in
            guard let self else { return }

            defer { isPerformingAction = false }

            do {
                let updatedWebsite = try await service.updateWebsiteAsync(id: website.id, name: name, domain: domain, shareId: shareId)

                if let index = websites.firstIndex(where: { $0.id == updatedWebsite.id }) {
                    websites[index] = updatedWebsite
                }

                if selectedWebsite?.id == updatedWebsite.id {
                    selectedWebsite = updatedWebsite
                    loadTabIfNeeded(selectedDetailTab, force: true)
                }

                loadDashboardStats()
                completion(.success(updatedWebsite))
            } catch {
                setRootError(error)
                completion(.failure(error))
            }
        }
    }

    func deleteWebsite(_ website: WebsiteModel, completion: @escaping (Result<Void, Error>) -> Void) {
        isPerformingAction = true

        Task { @MainActor [weak self] in
            guard let self else { return }

            defer { isPerformingAction = false }

            do {
                try await service.deleteWebsiteAsync(id: website.id)
                websites.removeAll { $0.id == website.id }

                if selectedWebsite?.id == website.id {
                    stopRealtimeSnapshotPolling()
                    stopRealtimeUpdates()
                    cancelTabLoads()
                    selectedWebsite = nil
                    resetWebsiteSelectionState()

                    if let nextWebsite = websites.first {
                        selectWebsite(nextWebsite)
                    }
                }

                loadDashboardStats()
                completion(.success(()))
            } catch {
                setRootError(error)
                completion(.failure(error))
            }
        }
    }

    func changePeriod(_ period: StatsPeriod) {
        selectedPeriod = period
        loadDashboardStats()

        guard let website = selectedWebsite else {
            return
        }

        service.invalidateAnalyticsCache(for: website.id)
        loadedTabs.removeAll()
        refreshRequestTracking()
        loadTabIfNeeded(selectedDetailTab, force: true)
    }

    // MARK: - Tab Routing

    func loadTabIfNeeded(_ tab: WebsiteDetailTab, force: Bool = false) {
        guard let website = selectedWebsite else { return }

        if !force && loadedTabs.contains(tab) {
            resumeLivePollingIfNeeded(for: tab, websiteId: website.id)
            return
        }

        tabTasks[tab]?.cancel()

        let token = UUID()
        tabLoadTokens[tab] = token
        setTabLoading(tab, true)
        tabErrors[tab] = nil

        let websiteId = website.id
        let period = selectedPeriod

        tabTasks[tab] = Task { @MainActor [weak self] in
            await self?.performTabLoad(tab, websiteId: websiteId, period: period, token: token)
        }
    }

    private func performTabLoad(_ tab: WebsiteDetailTab, websiteId: String, period: StatsPeriod, token: UUID) async {
        defer {
            if isCurrentTabLoad(tab: tab, token: token, websiteId: websiteId, period: period) {
                setTabLoading(tab, false)
                tabTasks[tab] = nil
                tabLoadTokens.removeValue(forKey: tab)
            }
        }

        switch tab {
        case .overview:
            await loadOverviewTab(websiteId: websiteId, period: period)
        case .audience:
            await loadAudienceTab(websiteId: websiteId, period: period)
        case .events:
            await loadEventsTab(websiteId: websiteId, period: period)
        case .sessions:
            await loadSessionsTab(websiteId: websiteId, period: period)
        case .realtime:
            await loadRealtimeTab(websiteId: websiteId, period: period)
        }

        guard isCurrentTabLoad(tab: tab, token: token, websiteId: websiteId, period: period) else {
            return
        }

        loadedTabs.insert(tab)
    }

    // MARK: - Starred Persistence

    func loadStarredIds() {
        let ids = UserDefaults.standard.stringArray(forKey: Self.starredKey) ?? []
        starredWebsiteIds = Set(ids)
    }

    func saveStarredIds() {
        UserDefaults.standard.set(Array(starredWebsiteIds), forKey: Self.starredKey)
    }

    // MARK: - Background Refresh

    func startBackgroundRefresh() {
        stopBackgroundRefresh()

        refreshTask = Task { @MainActor [weak self] in
            guard let self else { return }

            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: sleepInterval(for: refreshInterval))
                guard !Task.isCancelled else { break }
                await refreshDataInBackground()
            }
        }
    }

    func stopBackgroundRefresh() {
        refreshTask?.cancel()
        refreshTask = nil
    }

    private func refreshDataInBackground() async {
        loadDashboardStats()

        guard selectedWebsite != nil else {
            return
        }

        loadedTabs.remove(selectedDetailTab)
        loadTabIfNeeded(selectedDetailTab, force: true)
    }

    // MARK: - Helpers

    func loadDashboardStats() {
        dashboardStatsTask?.cancel()

        let websites = dashboardWebsites
        let period = selectedPeriod

        dashboardStatsTask = Task { @MainActor [weak self] in
            guard let self else { return }
            defer { dashboardStatsTask = nil }

            guard !websites.isEmpty else {
                dashboardStats = [:]
                return
            }

            var statsByWebsite: [String: WebsiteStatsResponse] = [:]

            for website in websites {
                do {
                    statsByWebsite[website.id] = try await service.fetchWebsiteStatsAsync(
                        id: website.id,
                        period: period,
                        query: queryOptions
                    )
                } catch {
                    continue
                }
            }

            guard !Task.isCancelled, selectedPeriod == period else { return }
            dashboardStats = statsByWebsite
        }
    }

    func contextMatches(websiteId: String, period: StatsPeriod) -> Bool {
        selectedWebsite?.id == websiteId && selectedPeriod == period
    }

    func normalizedSearchQuery(_ value: String) -> String? {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }

    func captureResult<T>(_ operation: @MainActor () async throws -> T) async -> Result<T, Error> {
        do {
            return .success(try await operation())
        } catch {
            return .failure(error)
        }
    }

    private func resetWebsiteSelectionState() {
        refreshRequestTracking()
        websiteStats = nil
        websiteMetrics = nil
        pageviewsData = nil
        activeUsers = nil
        activeUsersCount = 0
        hasActiveUsersData = false
        metricsByDimension.removeAll()
        eventSeries = []
        eventsPage = nil
        sessionsPage = nil
        selectedSessionID = nil
        isLoadingSessionDetail = false
        sessionStats = [:]
        sessionsWeekly = []
        selectedSessionRecord = nil
        selectedSessionActivity = []
        selectedSessionProperties = [:]
        realtimeSnapshot = nil
        eventDataState = EventDataState()
        reports = []
        segments = []
        cohorts = []
        links = []
        pixels = []
        eventsSearchQuery = ""
        sessionsSearchQuery = ""
        hasMoreEvents = false
        hasMoreSessions = false
        isLoadingMoreEvents = false
        isLoadingMoreSessions = false
        availableFilterValues = [:]
        isLoadingFilterValues = false
        nextEventsPage = 1
        nextSessionsPage = 1
    }

    private func cancelTabLoads() {
        tabTasks.values.forEach { $0.cancel() }
        tabTasks.removeAll()
        tabLoadTokens.removeAll()
    }

    private func isCurrentTabLoad(tab: WebsiteDetailTab, token: UUID, websiteId: String, period: StatsPeriod) -> Bool {
        tabLoadTokens[tab] == token && contextMatches(websiteId: websiteId, period: period)
    }

    private func resumeLivePollingIfNeeded(for tab: WebsiteDetailTab, websiteId: String) {
        if tab == .realtime {
            startRealtimeSnapshotPolling(websiteId: websiteId)
        }

        if tab == .overview {
            startRealtimeUpdates(websiteId: websiteId)
        }
    }

    func sleepInterval(for interval: TimeInterval) -> UInt64 {
        UInt64(max(interval, 0.05) * 1_000_000_000)
    }

    func refreshRequestTracking() {
        eventsPageRequestID = UUID()
        sessionsPageRequestID = UUID()
        eventDataInspectorRequestID = UUID()
        eventDataValuesRequestID = UUID()
    }

    // MARK: - Cleanup

    deinit {
        websitesTask?.cancel()
        dashboardStatsTask?.cancel()
        refreshTask?.cancel()
        realtimeSnapshotTask?.cancel()
        activeUsersTask?.cancel()
        tabTasks.values.forEach { $0.cancel() }
    }
}

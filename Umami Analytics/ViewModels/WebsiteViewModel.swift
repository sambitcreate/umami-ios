//
//  WebsiteViewModel.swift
//  Umami Analytics
//
//  Created by Augment on 4/17/25.
//

import Foundation
import Combine
import SwiftUI

class WebsiteViewModel: ObservableObject {
    private final class CancellableBag {
        var cancellables = Set<AnyCancellable>()
    }

    private static var retainedBags: [CancellableBag] = []
    private static let retainedBagsLock = NSLock()

    private let service: WebsiteServicing
    private let cancellableBag = CancellableBag()
    private var refreshTimer: Timer?
    private var realtimeSnapshotTimer: Timer?
    private let refreshInterval: TimeInterval
    private let pageSize: Int
    private let realtimePollInterval: TimeInterval
    private let shouldStartBackgroundRefresh: Bool

    private static let starredKey = "starredWebsiteIds"

    // MARK: - Core Published State

    @Published var websites: [WebsiteModel] = []
    @Published var isLoading = false
    @Published var isRefreshing = false
    @Published var isPerformingAction = false
    @Published var errorMessage: String?
    @Published var selectedPeriod: StatsPeriod = .day

    // Selected website properties
    @Published var selectedWebsite: WebsiteModel?
    @Published var websiteStats: WebsiteStatsResponse?
    @Published var websiteMetrics: WebsiteMetricsResponse?
    @Published var pageviewsData: PageviewsResponse?
    @Published var activeUsers: ActiveUsersResponse?
    @Published var activeUsersCount: Int = 0
    @Published var hasActiveUsersData: Bool = false

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
    @Published var selectedSessionRecord: AnalyticsRecord?
    @Published var selectedSessionActivity: [AnalyticsRecord] = []
    @Published var selectedSessionProperties: [String: JSONValue] = [:]
    @Published var realtimeSnapshot: RealtimeData?
    @Published var eventDataState = EventDataState()

    @Published var eventsSearchQuery = ""
    @Published var sessionsSearchQuery = ""
    @Published var hasMoreEvents = false
    @Published var isLoadingMoreEvents = false
    @Published var hasMoreSessions = false
    @Published var isLoadingMoreSessions = false

    private var loadedTabs: Set<WebsiteDetailTab> = []
    private var nextEventsPage = 1
    private var nextSessionsPage = 1

    // MARK: - Computed properties for UI

    var hasWebsites: Bool {
        !websites.isEmpty
    }

    var formattedPageviews: String {
        guard let stats = websiteStats else { return "--" }
        return formatNumber(stats.pageviews)
    }

    var formattedVisitors: String {
        guard let stats = websiteStats else { return "--" }
        return formatNumber(stats.visitors)
    }

    var formattedBounceRate: String {
        guard let stats = websiteStats else { return "--" }
        return String(format: "%.1f%%", stats.bounceRate * 100)
    }

    var formattedDuration: String {
        guard let stats = websiteStats else { return "--" }
        let seconds = stats.avgDuration

        if seconds < 60 {
            return String(format: "%.0fs", seconds)
        }

        let minutes = Int(seconds / 60)
        let remainingSeconds = Int(seconds.truncatingRemainder(dividingBy: 60))
        return String(format: "%dm %ds", minutes, remainingSeconds)
    }

    // Dashboard websites: starred first, fallback to first 3
    var dashboardWebsites: [WebsiteModel] {
        let starred = websites.filter { starredWebsiteIds.contains($0.id) }
        if !starred.isEmpty {
            return Array(starred.prefix(3))
        }
        return Array(websites.prefix(3))
    }

    var hasStarredWebsites: Bool {
        !starredWebsiteIds.isEmpty && websites.contains(where: { starredWebsiteIds.contains($0.id) })
    }

    func isStarred(_ websiteId: String) -> Bool {
        starredWebsiteIds.contains(websiteId)
    }

    func toggleStar(_ websiteId: String) {
        if starredWebsiteIds.contains(websiteId) {
            starredWebsiteIds.remove(websiteId)
        } else {
            starredWebsiteIds.insert(websiteId)
        }
        saveStarredIds()
    }

    private func loadStarredIds() {
        let ids = UserDefaults.standard.stringArray(forKey: Self.starredKey) ?? []
        starredWebsiteIds = Set(ids)
    }

    private func saveStarredIds() {
        UserDefaults.standard.set(Array(starredWebsiteIds), forKey: Self.starredKey)
    }

    // MARK: - Initialization

    init(
        service: WebsiteServicing = WebsiteService.shared,
        shouldStartBackgroundRefresh: Bool = true,
        config: AnalyticsRuntimeConfig = .default
    ) {
        self.service = service
        self.shouldStartBackgroundRefresh = shouldStartBackgroundRefresh
        self.refreshInterval = config.dashboardRefreshInterval
        self.pageSize = config.eventsSessionsPageSize
        self.realtimePollInterval = config.realtimePollInterval
        loadStarredIds()
        loadCachedWebsites()
        if shouldStartBackgroundRefresh {
            startBackgroundRefresh()
        }
    }

    // MARK: - Data Loading

    func loadWebsites() {
        isLoading = true
        errorMessage = nil

        service.fetchWebsites()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false

                    if case .failure(let error) = completion {
                        if let apiError = error as? APIError {
                            self?.errorMessage = apiError.message
                        } else {
                            self?.errorMessage = error.localizedDescription
                        }

                        self?.loadCachedWebsites()
                    }
                },
                receiveValue: { [weak self] websites in
                    guard let self = self else { return }

                    self.websites = websites
                    self.loadDashboardStats()

                    if let selectedId = self.selectedWebsite?.id,
                       let website = websites.first(where: { $0.id == selectedId }) {
                        self.selectedWebsite = website
                        self.loadTabIfNeeded(self.selectedDetailTab, force: true)
                    } else if let firstWebsite = websites.first, self.selectedWebsite == nil {
                        self.selectWebsite(firstWebsite)
                    }
                }
            )
            .store(in: &cancellableBag.cancellables)
    }

    func loadCachedWebsites() {
        let cachedWebsites = service.fetchCachedWebsites()

        guard !cachedWebsites.isEmpty else {
            return
        }

        let modelWebsites = cachedWebsites.map { cdWebsite -> WebsiteModel in
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

        DispatchQueue.main.async {
            self.websites = modelWebsites
            if self.selectedWebsite == nil, let firstWebsite = modelWebsites.first {
                self.selectWebsite(firstWebsite)
            }
        }
    }

    private func loadCachedStats(websiteId: String) {
        if let cachedStats = service.fetchCachedStats(for: websiteId, period: selectedPeriod) {
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
            DispatchQueue.main.async {
                self.websiteStats = stats
            }
        }
    }

    func selectWebsite(_ website: WebsiteModel) {
        stopRealtimeSnapshotPolling()
        stopRealtimeUpdates()

        selectedWebsite = website
        loadedTabs.removeAll()
        tabErrors.removeAll()

        metricsByDimension.removeAll()
        websiteMetrics = nil
        eventSeries = []
        eventsPage = nil
        sessionsPage = nil
        sessionStats = [:]
        sessionsWeekly = []
        selectedSessionRecord = nil
        selectedSessionActivity = []
        selectedSessionProperties = [:]
        realtimeSnapshot = nil
        eventDataState = EventDataState()

        hasMoreEvents = false
        hasMoreSessions = false
        isLoadingMoreEvents = false
        isLoadingMoreSessions = false
        nextEventsPage = 1
        nextSessionsPage = 1

        service.invalidateAnalyticsCache(for: website.id)
        loadTabIfNeeded(.overview, force: true)
    }

    func selectDetailTab(_ tab: WebsiteDetailTab) {
        let previousTab = selectedDetailTab
        selectedDetailTab = tab

        if previousTab == .realtime && tab != .realtime {
            stopRealtimeSnapshotPolling()
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

        service.createWebsite(name: name, domain: domain, shareId: shareId, teamId: teamId, id: nil)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] result in
                    self?.isPerformingAction = false

                    if case .failure(let error) = result {
                        if let apiError = error as? APIError {
                            self?.errorMessage = apiError.message
                            completion(.failure(apiError))
                        } else {
                            self?.errorMessage = error.localizedDescription
                            completion(.failure(error))
                        }
                    }
                },
                receiveValue: { [weak self] website in
                    guard let self = self else { return }

                    if let index = self.websites.firstIndex(where: { $0.id == website.id }) {
                        self.websites[index] = website
                    } else {
                        self.websites.insert(website, at: 0)
                    }

                    completion(.success(website))
                }
            )
            .store(in: &cancellableBag.cancellables)
    }

    func updateWebsite(_ website: WebsiteModel, name: String, domain: String, shareId: String?, completion: @escaping (Result<WebsiteModel, Error>) -> Void) {
        isPerformingAction = true

        service.updateWebsite(id: website.id, name: name, domain: domain, shareId: shareId)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] result in
                    self?.isPerformingAction = false

                    if case .failure(let error) = result {
                        if let apiError = error as? APIError {
                            self?.errorMessage = apiError.message
                            completion(.failure(apiError))
                        } else {
                            self?.errorMessage = error.localizedDescription
                            completion(.failure(error))
                        }
                    }
                },
                receiveValue: { [weak self] updatedWebsite in
                    guard let self = self else { return }

                    if let index = self.websites.firstIndex(where: { $0.id == updatedWebsite.id }) {
                        self.websites[index] = updatedWebsite
                    }

                    if self.selectedWebsite?.id == updatedWebsite.id {
                        self.selectedWebsite = updatedWebsite
                        self.loadTabIfNeeded(self.selectedDetailTab, force: true)
                    }

                    completion(.success(updatedWebsite))
                }
            )
            .store(in: &cancellableBag.cancellables)
    }

    func deleteWebsite(_ website: WebsiteModel, completion: @escaping (Result<Void, Error>) -> Void) {
        isPerformingAction = true

        service.deleteWebsite(id: website.id)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] result in
                    self?.isPerformingAction = false

                    switch result {
                    case .failure(let error):
                        if let apiError = error as? APIError {
                            self?.errorMessage = apiError.message
                            completion(.failure(apiError))
                        } else {
                            self?.errorMessage = error.localizedDescription
                            completion(.failure(error))
                        }
                    case .finished:
                        completion(.success(()))
                    }
                },
                receiveValue: { [weak self] in
                    guard let self = self else { return }

                    self.websites.removeAll { $0.id == website.id }

                    if self.selectedWebsite?.id == website.id {
                        self.stopRealtimeSnapshotPolling()
                        self.stopRealtimeUpdates()

                        self.selectedWebsite = nil
                        self.websiteStats = nil
                        self.websiteMetrics = nil
                        self.pageviewsData = nil
                        self.activeUsers = nil
                        self.activeUsersCount = 0
                        self.hasActiveUsersData = false
                        self.metricsByDimension.removeAll()
                        self.eventSeries = []
                        self.eventsPage = nil
                        self.sessionsPage = nil
                        self.sessionStats = [:]
                        self.sessionsWeekly = []
                        self.selectedSessionRecord = nil
                        self.selectedSessionActivity = []
                        self.selectedSessionProperties = [:]
                        self.realtimeSnapshot = nil
                        self.eventDataState = EventDataState()

                        if let nextWebsite = self.websites.first {
                            self.selectWebsite(nextWebsite)
                        }
                    }
                }
            )
            .store(in: &cancellableBag.cancellables)
    }

    func changePeriod(_ period: StatsPeriod) {
        selectedPeriod = period
        loadDashboardStats()

        guard let website = selectedWebsite else {
            return
        }

        service.invalidateAnalyticsCache(for: website.id)
        loadedTabs.removeAll()
        loadTabIfNeeded(selectedDetailTab, force: true)
    }

    // MARK: - Dashboard Stats

    func loadDashboardStats() {
        for website in dashboardWebsites {
            service.fetchWebsiteStats(id: website.id, period: selectedPeriod)
                .receive(on: DispatchQueue.main)
                .sink(
                    receiveCompletion: { _ in },
                    receiveValue: { [weak self] response in
                        self?.dashboardStats[website.id] = response
                    }
                )
                .store(in: &cancellableBag.cancellables)
        }
    }

    // MARK: - Detail Tabs

    private func loadTabIfNeeded(_ tab: WebsiteDetailTab, force: Bool = false) {
        guard let website = selectedWebsite else { return }
        if !force && loadedTabs.contains(tab) {
            if tab == .realtime {
                startRealtimeSnapshotPolling(websiteId: website.id)
            }
            return
        }

        setTabLoading(tab, true)
        tabErrors[tab] = nil

        switch tab {
        case .overview:
            loadOverviewTab(websiteId: website.id)
        case .audience:
            loadAudienceTab(websiteId: website.id)
        case .events:
            loadEventsTab(websiteId: website.id)
        case .sessions:
            loadSessionsTab(websiteId: website.id)
        case .realtime:
            loadRealtimeTab(websiteId: website.id)
        }

        loadedTabs.insert(tab)
    }

    private func loadOverviewTab(websiteId: String) {
        loadWebsiteStats(websiteId: websiteId, captureErrorOn: .overview)
        loadMetricDimension(.url, websiteId: websiteId, captureErrorOn: .overview)
        loadPageviewsData(websiteId: websiteId, captureErrorOn: .overview)
        loadActiveUsers(websiteId: websiteId, captureErrorOn: .overview)
        startRealtimeUpdates(websiteId: websiteId)
        setTabLoading(.overview, false)
    }

    private func loadAudienceTab(websiteId: String) {
        let dimensions: [MetricDimension] = [.url, .referrer, .browser, .device, .country, .event, .channel]
        for dimension in dimensions {
            loadMetricDimension(dimension, websiteId: websiteId, captureErrorOn: .audience)
        }
        setTabLoading(.audience, false)
    }

    private func loadEventsTab(websiteId: String) {
        loadMetricDimension(.event, websiteId: websiteId, captureErrorOn: .events)

        service.fetchWebsiteEventSeries(id: websiteId, period: selectedPeriod, eventName: nil)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        self?.setTabError(.events, error: error)
                    }
                },
                receiveValue: { [weak self] series in
                    self?.eventSeries = series
                }
            )
            .store(in: &cancellableBag.cancellables)

        nextEventsPage = 1
        hasMoreEvents = true
        loadEventsPage(reset: true)

        loadEventDataInspector(websiteId: websiteId)
        setTabLoading(.events, false)
    }

    private func loadSessionsTab(websiteId: String) {
        service.fetchWebsiteSessionStats(id: websiteId, period: selectedPeriod)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        self?.setTabError(.sessions, error: error)
                    }
                },
                receiveValue: { [weak self] stats in
                    self?.sessionStats = stats
                }
            )
            .store(in: &cancellableBag.cancellables)

        service.fetchWebsiteSessionsWeekly(id: websiteId, period: selectedPeriod)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        self?.setTabError(.sessions, error: error)
                    }
                },
                receiveValue: { [weak self] weekly in
                    self?.sessionsWeekly = weekly
                }
            )
            .store(in: &cancellableBag.cancellables)

        nextSessionsPage = 1
        hasMoreSessions = true
        loadSessionsPage(reset: true)
        setTabLoading(.sessions, false)
    }

    private func loadRealtimeTab(websiteId: String) {
        startRealtimeSnapshotPolling(websiteId: websiteId)
        setTabLoading(.realtime, false)
    }

    // MARK: - Tab Data Actions

    func loadMoreEvents() {
        guard hasMoreEvents,
              !isLoadingMoreEvents,
              selectedWebsite != nil else {
            return
        }
        loadEventsPage(reset: false)
    }

    func loadMoreSessions() {
        guard hasMoreSessions,
              !isLoadingMoreSessions,
              selectedWebsite != nil else {
            return
        }
        loadSessionsPage(reset: false)
    }

    func applyEventsSearch(_ search: String) {
        eventsSearchQuery = search
        nextEventsPage = 1
        hasMoreEvents = true
        loadEventsPage(reset: true)
    }

    func applySessionsSearch(_ search: String) {
        sessionsSearchQuery = search
        nextSessionsPage = 1
        hasMoreSessions = true
        loadSessionsPage(reset: true)
    }

    func selectEventDataEvent(_ eventName: String?) {
        eventDataState.selectedEvent = eventName
        reloadEventDataValues()
    }

    func selectEventDataProperty(_ propertyName: String?) {
        eventDataState.selectedProperty = propertyName
        reloadEventDataValues()
    }

    // MARK: - Existing Core Loaders (Overview)

    private func loadWebsiteStats(websiteId: String, captureErrorOn tab: WebsiteDetailTab? = nil) {
        loadCachedStats(websiteId: websiteId)

        let hasCachedData = service.fetchCachedStats(for: websiteId, period: selectedPeriod) != nil
        if hasCachedData {
            isRefreshing = true
        } else {
            isLoading = true
        }

        service.fetchWebsiteStats(id: websiteId, period: selectedPeriod)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    self?.isRefreshing = false

                    if case .failure(let error) = completion {
                        if let tab {
                            self?.setTabError(tab, error: error)
                        } else {
                            self?.setRootError(error)
                        }
                    }
                },
                receiveValue: { [weak self] response in
                    self?.websiteStats = response
                }
            )
            .store(in: &cancellableBag.cancellables)
    }

    private func loadMetricDimension(_ dimension: MetricDimension, websiteId: String, captureErrorOn tab: WebsiteDetailTab? = nil) {
        let primaryType = dimension == .url ? "path" : dimension.rawValue

        let publisher: AnyPublisher<WebsiteMetricsResponse, Error>
        if dimension == .url {
            publisher = service
                .fetchWebsiteMetrics(id: websiteId, period: selectedPeriod, type: primaryType)
                .catch { _ in
                    self.service.fetchWebsiteMetrics(id: websiteId, period: self.selectedPeriod, type: "url")
                }
                .eraseToAnyPublisher()
        } else {
            publisher = service
                .fetchWebsiteMetrics(id: websiteId, period: selectedPeriod, type: primaryType)
                .eraseToAnyPublisher()
        }

        publisher
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        if let tab {
                            self?.setTabError(tab, error: error)
                        }
                    }
                },
                receiveValue: { [weak self] response in
                    self?.metricsByDimension[dimension] = response
                    if dimension == .url {
                        self?.websiteMetrics = response
                    }
                }
            )
            .store(in: &cancellableBag.cancellables)
    }

    private func loadPageviewsData(websiteId: String, captureErrorOn tab: WebsiteDetailTab? = nil) {
        service.fetchWebsitePageviews(id: websiteId, period: selectedPeriod)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        if let tab {
                            self?.setTabError(tab, error: error)
                        }
                    }
                },
                receiveValue: { [weak self] response in
                    self?.pageviewsData = response
                }
            )
            .store(in: &cancellableBag.cancellables)
    }

    private func loadActiveUsers(websiteId: String, captureErrorOn tab: WebsiteDetailTab? = nil) {
        service.fetchActiveUsers(id: websiteId)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion, let tab {
                        self?.setTabError(tab, error: error)
                    }
                },
                receiveValue: { [weak self] response in
                    self?.activeUsers = response
                    self?.activeUsersCount = response.visitors
                    self?.hasActiveUsersData = true
                }
            )
            .store(in: &cancellableBag.cancellables)
    }

    // MARK: - Events Tab

    private func loadEventsPage(reset: Bool) {
        guard let websiteId = selectedWebsite?.id else { return }

        let page = reset ? 1 : nextEventsPage
        isLoadingMoreEvents = !reset

        service.fetchWebsiteEvents(
            id: websiteId,
            period: selectedPeriod,
            page: page,
            pageSize: pageSize,
            search: eventsSearchQuery.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : eventsSearchQuery
        )
        .receive(on: DispatchQueue.main)
        .sink(
            receiveCompletion: { [weak self] completion in
                self?.isLoadingMoreEvents = false
                if case .failure(let error) = completion {
                    self?.setTabError(.events, error: error)
                }
            },
            receiveValue: { [weak self] response in
                guard let self = self else { return }

                if reset || self.eventsPage == nil {
                    self.eventsPage = response
                } else if let current = self.eventsPage {
                    self.eventsPage = PaginatedResponse(
                        data: current.data + response.data,
                        count: max(current.count, response.count),
                        page: response.page,
                        pageSize: response.pageSize
                    )
                }

                let totalLoaded = self.eventsPage?.data.count ?? 0
                self.hasMoreEvents = totalLoaded < (self.eventsPage?.count ?? totalLoaded)
                self.nextEventsPage = page + 1
            }
        )
        .store(in: &cancellableBag.cancellables)
    }

    private func loadEventDataInspector(websiteId: String) {
        eventDataState.isLoading = true

        service.fetchEventDataFields(id: websiteId, period: selectedPeriod)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { [weak self] fields in
                    self?.eventDataState.availableFields = fields
                }
            )
            .store(in: &cancellableBag.cancellables)

        service.fetchEventDataProperties(id: websiteId, period: selectedPeriod, propertyName: nil)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { [weak self] properties in
                    self?.eventDataState.availableProperties = properties
                }
            )
            .store(in: &cancellableBag.cancellables)

        service.fetchEventDataEvents(id: websiteId, period: selectedPeriod, event: nil)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        self?.setTabError(.events, error: error)
                    }
                    self?.eventDataState.isLoading = false
                },
                receiveValue: { [weak self] events in
                    self?.eventDataState.availableEvents = events
                }
            )
            .store(in: &cancellableBag.cancellables)

        service.fetchEventDataStats(id: websiteId, period: selectedPeriod)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { [weak self] stats in
                    self?.eventDataState.stats = stats
                }
            )
            .store(in: &cancellableBag.cancellables)

        reloadEventDataValues()
    }

    private func reloadEventDataValues() {
        guard let websiteId = selectedWebsite?.id else { return }
        let selectedProperty = eventDataState.selectedProperty?.trimmingCharacters(in: .whitespacesAndNewlines)

        guard let propertyName = selectedProperty, !propertyName.isEmpty else {
            eventDataState.availableValues = []
            return
        }

        service.fetchEventDataValues(
            id: websiteId,
            period: selectedPeriod,
            eventName: eventDataState.selectedEvent,
            propertyName: propertyName
        )
        .receive(on: DispatchQueue.main)
        .sink(
            receiveCompletion: { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.setTabError(.events, error: error)
                }
            },
            receiveValue: { [weak self] values in
                self?.eventDataState.availableValues = values
            }
        )
        .store(in: &cancellableBag.cancellables)
    }

    // MARK: - Sessions Tab

    private func loadSessionsPage(reset: Bool) {
        guard let websiteId = selectedWebsite?.id else { return }

        let page = reset ? 1 : nextSessionsPage
        isLoadingMoreSessions = !reset

        service.fetchWebsiteSessions(
            id: websiteId,
            period: selectedPeriod,
            page: page,
            pageSize: pageSize,
            search: sessionsSearchQuery.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : sessionsSearchQuery
        )
        .receive(on: DispatchQueue.main)
        .sink(
            receiveCompletion: { [weak self] completion in
                self?.isLoadingMoreSessions = false
                if case .failure(let error) = completion {
                    self?.setTabError(.sessions, error: error)
                }
            },
            receiveValue: { [weak self] response in
                guard let self = self else { return }

                if reset || self.sessionsPage == nil {
                    self.sessionsPage = response
                } else if let current = self.sessionsPage {
                    self.sessionsPage = PaginatedResponse(
                        data: current.data + response.data,
                        count: max(current.count, response.count),
                        page: response.page,
                        pageSize: response.pageSize
                    )
                }

                let totalLoaded = self.sessionsPage?.data.count ?? 0
                self.hasMoreSessions = totalLoaded < (self.sessionsPage?.count ?? totalLoaded)
                self.nextSessionsPage = page + 1
            }
        )
        .store(in: &cancellableBag.cancellables)
    }

    func loadSessionDetail(sessionId: String) {
        guard let websiteId = selectedWebsite?.id else { return }

        service.fetchWebsiteSession(id: websiteId, sessionId: sessionId)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        self?.setTabError(.sessions, error: error)
                    }
                },
                receiveValue: { [weak self] session in
                    self?.selectedSessionRecord = session
                }
            )
            .store(in: &cancellableBag.cancellables)
    }

    func loadSessionActivity(sessionId: String) {
        guard let websiteId = selectedWebsite?.id else { return }

        service.fetchWebsiteSessionActivity(id: websiteId, sessionId: sessionId, period: selectedPeriod)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        self?.setTabError(.sessions, error: error)
                    }
                },
                receiveValue: { [weak self] activity in
                    self?.selectedSessionActivity = activity
                }
            )
            .store(in: &cancellableBag.cancellables)
    }

    func loadSessionProperties(sessionId: String) {
        guard let websiteId = selectedWebsite?.id else { return }

        service.fetchWebsiteSessionProperties(id: websiteId, sessionId: sessionId)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        self?.setTabError(.sessions, error: error)
                    }
                },
                receiveValue: { [weak self] properties in
                    self?.selectedSessionProperties = properties
                }
            )
            .store(in: &cancellableBag.cancellables)
    }

    // MARK: - Realtime

    private func loadRealtimeSnapshot(websiteId: String) {
        service.fetchRealtimeSnapshot(websiteId: websiteId)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        self?.setTabError(.realtime, error: error)
                    }
                },
                receiveValue: { [weak self] snapshot in
                    self?.realtimeSnapshot = snapshot
                    self?.activeUsersCount = snapshot.sessions
                    self?.hasActiveUsersData = true
                }
            )
            .store(in: &cancellableBag.cancellables)
    }

    private func startRealtimeSnapshotPolling(websiteId: String) {
        stopRealtimeSnapshotPolling()

        loadRealtimeSnapshot(websiteId: websiteId)

        realtimeSnapshotTimer = Timer.scheduledTimer(withTimeInterval: realtimePollInterval, repeats: true) { [weak self] _ in
            self?.loadRealtimeSnapshot(websiteId: websiteId)
        }
    }

    private func stopRealtimeSnapshotPolling() {
        realtimeSnapshotTimer?.invalidate()
        realtimeSnapshotTimer = nil
    }

    // MARK: - Active Users Polling (existing behavior)

    private func startRealtimeUpdates(websiteId: String) {
        service.startRealtimeUpdates(for: websiteId, interval: realtimePollInterval) { [weak self] count in
            DispatchQueue.main.async {
                self?.activeUsersCount = count
                self?.hasActiveUsersData = true
            }
        }
    }

    func stopRealtimeUpdates() {
        if let websiteId = selectedWebsite?.id {
            service.stopRealtimeUpdates(for: websiteId)
        }
    }

    func handleDetailDisappear() {
        stopRealtimeSnapshotPolling()
        stopRealtimeUpdates()
    }

    // MARK: - Helper Methods

    private func formatNumber(_ number: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal

        if number >= 1_000_000 {
            formatter.maximumFractionDigits = 1
            return (formatter.string(from: NSNumber(value: Double(number) / 1_000_000)) ?? "0") + "M"
        }

        if number >= 1_000 {
            formatter.maximumFractionDigits = 1
            return (formatter.string(from: NSNumber(value: Double(number) / 1_000)) ?? "0") + "K"
        }

        return formatter.string(from: NSNumber(value: number)) ?? "0"
    }

    private func setRootError(_ error: Error) {
        if let apiError = error as? APIError {
            errorMessage = apiError.message
        } else {
            errorMessage = error.localizedDescription
        }
    }

    private func setTabError(_ tab: WebsiteDetailTab, error: Error) {
        if let apiError = error as? APIError {
            tabErrors[tab] = apiError.message
        } else {
            tabErrors[tab] = error.localizedDescription
        }
    }

    private func setTabLoading(_ tab: WebsiteDetailTab, _ loading: Bool) {
        tabLoading[tab] = loading
    }

    // MARK: - Background Refresh

    private func startBackgroundRefresh() {
        stopBackgroundRefresh()

        refreshTimer = Timer.scheduledTimer(withTimeInterval: refreshInterval, repeats: true) { [weak self] _ in
            self?.refreshDataInBackground()
        }
    }

    private func stopBackgroundRefresh() {
        refreshTimer?.invalidate()
        refreshTimer = nil
    }

    private func refreshDataInBackground() {
        loadDashboardStats()

        guard selectedWebsite != nil else {
            return
        }

        loadTabIfNeeded(selectedDetailTab, force: true)
    }

    // MARK: - Cleanup

    deinit {
        stopRealtimeSnapshotPolling()
        stopRealtimeUpdates()
        if shouldStartBackgroundRefresh {
            stopBackgroundRefresh()
        }

        let bag = cancellableBag
        Self.retainedBagsLock.lock()
        Self.retainedBags.append(bag)
        Self.retainedBagsLock.unlock()

        DispatchQueue.global().async {
            Self.retainedBagsLock.lock()
            Self.retainedBags.removeAll { $0 === bag }
            Self.retainedBagsLock.unlock()
        }
    }
}

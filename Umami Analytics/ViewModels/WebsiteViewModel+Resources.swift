//
//  WebsiteViewModel+Resources.swift
//  Umami Analytics
//
//  Created by OpenAI Codex on 4/1/26.
//

import Foundation

extension WebsiteViewModel {
    var currentWorkspaceSelection: WorkspaceSelection {
        AuthManager.shared.selectedWorkspace
    }

    var isReadOnlySession: Bool {
        AuthManager.shared.isReadOnlySession
    }

    func applyWorkspaceSelection(_ selection: WorkspaceSelection, reloadResources: Bool = false) {
        if AuthManager.shared.selectedWorkspace != selection {
            AuthManager.shared.selectWorkspace(selection)
        }
        rebuildWebsiteDerivedState()
        syncSelectedWebsiteWithVisibleContext(reloadCurrentTab: true)
        loadDashboardStats()

        if reloadResources {
            loadWorkspaceResources()
        }
    }

    func updateComparison(_ comparison: AnalyticsComparison) {
        guard queryOptions.compare != comparison else { return }
        queryOptions.compare = comparison
        reloadForQueryChange()
    }

    func updateFilter(_ key: AnalyticsFilterKey, value: String?) {
        let existing = queryOptions.filters[key]
        queryOptions.setFilter(key, value: value)
        guard existing != queryOptions.filters[key] else { return }
        reloadForQueryChange()
    }

    func clearQuerySelections() {
        guard queryOptions.hasActiveSelections else { return }
        queryOptions = .default
        reloadForQueryChange()
    }

    func loadFilterValues() {
        guard let websiteId = selectedWebsite?.id else { return }
        let period = selectedPeriod
        let query = queryOptions
        let requestID = UUID()
        filterValuesRequestID = requestID
        filterValuesTask?.cancel()
        isLoadingFilterValues = true

        filterValuesTask = Task { @MainActor [weak self] in
            guard let self else { return }
            defer {
                if contextMatches(websiteId: websiteId, period: period), queryOptions == query, filterValuesRequestID == requestID {
                    isLoadingFilterValues = false
                    filterValuesTask = nil
                }
            }

            var nextValues: [AnalyticsFilterKey: [FilterValue]] = [:]

            for key in [AnalyticsFilterKey.path, .referrer, .browser, .os, .device, .country, .event] {
                guard !Task.isCancelled else { return }
                let type = key == .path ? "path" : key.rawValue
                if let values = try? await service.fetchWebsiteValuesAsync(id: websiteId, type: type, period: period, search: nil, query: query) {
                    nextValues[key] = Array(values.prefix(20))
                }
            }

            guard !Task.isCancelled else { return }
            if let segmentValues = try? await service.fetchWebsiteSegmentsAsync(websiteId: websiteId, type: .segment) {
                nextValues[.segment] = segmentValues.map { FilterValue(value: $0.id, label: $0.name) }
            }

            guard !Task.isCancelled else { return }
            if let cohortValues = try? await service.fetchWebsiteSegmentsAsync(websiteId: websiteId, type: .cohort) {
                nextValues[.cohort] = cohortValues.map { FilterValue(value: $0.id, label: $0.name) }
            }

            guard contextMatches(websiteId: websiteId, period: period),
                  queryOptions == query,
                  filterValuesRequestID == requestID else { return }
            availableFilterValues = nextValues
        }
    }

    func loadWorkspaceResources() {
        let selectedWebsiteID = selectedWebsite?.id ?? filteredWebsites.first?.id
        let workspace = AuthManager.shared.selectedWorkspace
        let teamId = workspace.teamId
        let requestID = UUID()
        resourcesRequestID = requestID
        resourcesTask?.cancel()
        isLoadingResources = true

        resourcesTask = Task { @MainActor [weak self] in
            guard let self else { return }
            defer {
                if resourcesRequestID == requestID, AuthManager.shared.selectedWorkspace == workspace {
                    isLoadingResources = false
                    resourcesTask = nil
                }
            }

            async let linkResult = captureResult {
                try await self.service.fetchLinksAsync(teamId: teamId)
            }
            async let pixelResult = captureResult {
                try await self.service.fetchPixelsAsync(teamId: teamId)
            }

            let linksResult = await linkResult
            let pixelsResult = await pixelResult

            guard !Task.isCancelled,
                  resourcesRequestID == requestID,
                  AuthManager.shared.selectedWorkspace == workspace else { return }

            switch linksResult {
            case .success(let links):
                self.links = links
            case .failure(let error):
                setRootError(error)
            }

            switch pixelsResult {
            case .success(let pixels):
                self.pixels = pixels
            case .failure(let error):
                setRootError(error)
            }

            guard let selectedWebsiteID else {
                reports = []
                segments = []
                cohorts = []
                return
            }

            async let reportsResult = captureResult {
                try await self.service.fetchWebsiteReportsAsync(websiteId: selectedWebsiteID)
            }
            async let segmentsResult = captureResult {
                try await self.service.fetchWebsiteSegmentsAsync(websiteId: selectedWebsiteID, type: .segment)
            }
            async let cohortsResult = captureResult {
                try await self.service.fetchWebsiteSegmentsAsync(websiteId: selectedWebsiteID, type: .cohort)
            }

            let resolvedReports = await reportsResult
            let resolvedSegments = await segmentsResult
            let resolvedCohorts = await cohortsResult

            guard !Task.isCancelled,
                  resourcesRequestID == requestID,
                  AuthManager.shared.selectedWorkspace == workspace,
                  selectedWebsite?.id == selectedWebsiteID || selectedWebsite == nil else { return }

            switch resolvedReports {
            case .success(let reports):
                self.reports = reports
            case .failure(let error):
                setRootError(error)
            }

            switch resolvedSegments {
            case .success(let segments):
                self.segments = segments
            case .failure(let error):
                setRootError(error)
            }

            switch resolvedCohorts {
            case .success(let cohorts):
                self.cohorts = cohorts
            case .failure(let error):
                setRootError(error)
            }
        }
    }

    private func reloadForQueryChange() {
        loadDashboardStats()

        guard let websiteId = selectedWebsite?.id else { return }

        service.invalidateAnalyticsCache(for: websiteId)
        loadedTabs.removeAll()
        tabTasks.values.forEach { $0.cancel() }
        tabTasks.removeAll()
        tabLoadTokens.removeAll()
        refreshRequestTracking()
        loadTabIfNeeded(selectedDetailTab, force: true)
    }

    func syncSelectedWebsiteWithVisibleContext(reloadCurrentTab: Bool) {
        let visibleWebsites = filteredWebsites

        guard let nextVisibleWebsite = visibleWebsites.first else {
            stopRealtimeSnapshotPolling()
            stopRealtimeUpdates()
            tabTasks.values.forEach { $0.cancel() }
            tabTasks.removeAll()
            tabLoadTokens.removeAll()
            selectedWebsite = nil
            loadedTabs.removeAll()
            tabErrors.removeAll()
            tabLoading.removeAll()
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
            return
        }

        if let selectedId = selectedWebsite?.id,
           let visibleSelection = visibleWebsites.first(where: { $0.id == selectedId }) {
            selectedWebsite = visibleSelection
            if reloadCurrentTab {
                loadTabIfNeeded(selectedDetailTab, force: true)
            }
            return
        }

        selectWebsite(nextVisibleWebsite)
    }
}

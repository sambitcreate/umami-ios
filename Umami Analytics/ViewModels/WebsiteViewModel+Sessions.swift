//
//  WebsiteViewModel+Sessions.swift
//  Umami Analytics
//
//  Extracted from WebsiteViewModel.swift
//

import Foundation

// MARK: - Sessions Tab

extension WebsiteViewModel {

    func loadSessionsTab(websiteId: String, period: StatsPeriod) async {
        async let statsResult = fetchSessionStatsResult(websiteId: websiteId, period: period)
        async let weeklyResult = fetchSessionsWeeklyResult(websiteId: websiteId, period: period)

        nextSessionsPage = 1
        hasMoreSessions = true

        guard contextMatches(websiteId: websiteId, period: period) else { return }

        switch await statsResult {
        case .success(let stats):
            sessionStats = stats
        case .failure(let error):
            setTabError(.sessions, error: error)
        }

        switch await weeklyResult {
        case .success(let weekly):
            sessionsWeekly = weekly
        case .failure(let error):
            setTabError(.sessions, error: error)
        }

        await loadSessionsPage(reset: true, websiteId: websiteId, period: period, search: normalizedSearchQuery(sessionsSearchQuery))
    }

    func fetchSessionStatsResult(websiteId: String, period: StatsPeriod) async -> Result<[String: MetricValue], Error> {
        await captureResult {
            try await service.fetchWebsiteSessionStatsAsync(id: websiteId, period: period)
        }
    }

    func fetchSessionsWeeklyResult(websiteId: String, period: StatsPeriod) async -> Result<[WeeklySessionPoint], Error> {
        await captureResult {
            try await service.fetchWebsiteSessionsWeeklyAsync(id: websiteId, period: period)
        }
    }

    func loadMoreSessions() {
        guard hasMoreSessions,
              !isLoadingMoreSessions,
              let websiteId = selectedWebsite?.id else {
            return
        }

        let period = selectedPeriod
        let search = normalizedSearchQuery(sessionsSearchQuery)

        Task { @MainActor [weak self] in
            await self?.loadSessionsPage(reset: false, websiteId: websiteId, period: period, search: search)
        }
    }

    func applySessionsSearch(_ search: String) {
        sessionsSearchQuery = search
        nextSessionsPage = 1
        hasMoreSessions = true

        guard let websiteId = selectedWebsite?.id else { return }

        let period = selectedPeriod
        let normalizedSearch = normalizedSearchQuery(search)

        Task { @MainActor [weak self] in
            await self?.loadSessionsPage(reset: true, websiteId: websiteId, period: period, search: normalizedSearch)
        }
    }

    func loadSessionsPage(reset: Bool, websiteId: String? = nil, period: StatsPeriod? = nil, search: String? = nil) async {
        guard let websiteId = websiteId ?? selectedWebsite?.id else { return }
        let period = period ?? selectedPeriod
        let search = search ?? normalizedSearchQuery(sessionsSearchQuery)

        let page = reset ? 1 : nextSessionsPage
        isLoadingMoreSessions = !reset

        defer {
            if contextMatches(websiteId: websiteId, period: period) {
                isLoadingMoreSessions = false
            }
        }

        let result = await captureResult {
            try await service.fetchWebsiteSessionsAsync(
                id: websiteId,
                period: period,
                page: page,
                pageSize: pageSize,
                search: search
            )
        }

        guard contextMatches(websiteId: websiteId, period: period) else { return }

        switch result {
        case .success(let response):
            if reset || sessionsPage == nil {
                sessionsPage = response
            } else if let current = sessionsPage {
                sessionsPage = PaginatedResponse(
                    data: current.data + response.data,
                    count: max(current.count, response.count),
                    page: response.page,
                    pageSize: response.pageSize
                )
            }

            let totalLoaded = sessionsPage?.data.count ?? 0
            hasMoreSessions = totalLoaded < (sessionsPage?.count ?? totalLoaded)
            nextSessionsPage = page + 1
        case .failure(let error):
            setTabError(.sessions, error: error)
        }
    }

    func loadSessionDetail(sessionId: String) {
        guard let websiteId = selectedWebsite?.id else { return }
        let period = selectedPeriod

        Task { @MainActor [weak self] in
            guard let self else { return }

            let result = await captureResult {
                try await self.service.fetchWebsiteSessionAsync(id: websiteId, sessionId: sessionId)
            }

            guard contextMatches(websiteId: websiteId, period: period) else { return }

            switch result {
            case .success(let session):
                selectedSessionRecord = session
            case .failure(let error):
                setTabError(.sessions, error: error)
            }
        }
    }

    func loadSessionActivity(sessionId: String) {
        guard let websiteId = selectedWebsite?.id else { return }
        let period = selectedPeriod

        Task { @MainActor [weak self] in
            guard let self else { return }

            let result = await captureResult {
                try await self.service.fetchWebsiteSessionActivityAsync(id: websiteId, sessionId: sessionId, period: period)
            }

            guard contextMatches(websiteId: websiteId, period: period) else { return }

            switch result {
            case .success(let activity):
                selectedSessionActivity = activity
            case .failure(let error):
                setTabError(.sessions, error: error)
            }
        }
    }

    func loadSessionProperties(sessionId: String) {
        guard let websiteId = selectedWebsite?.id else { return }
        let period = selectedPeriod

        Task { @MainActor [weak self] in
            guard let self else { return }

            let result = await captureResult {
                try await self.service.fetchWebsiteSessionPropertiesAsync(id: websiteId, sessionId: sessionId)
            }

            guard contextMatches(websiteId: websiteId, period: period) else { return }

            switch result {
            case .success(let properties):
                selectedSessionProperties = properties
            case .failure(let error):
                setTabError(.sessions, error: error)
            }
        }
    }
}

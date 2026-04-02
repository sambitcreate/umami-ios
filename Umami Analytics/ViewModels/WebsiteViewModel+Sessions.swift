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
        let requestID = UUID()

        sessionsPageRequestID = requestID
        nextSessionsPage = 1
        hasMoreSessions = true

        let resolvedStatsResult = await statsResult
        let resolvedWeeklyResult = await weeklyResult

        guard contextMatches(websiteId: websiteId, period: period), requestID == sessionsPageRequestID else { return }

        switch resolvedStatsResult {
        case .success(let stats):
            sessionStats = stats
        case .failure(let error):
            setTabError(.sessions, error: error)
        }

        switch resolvedWeeklyResult {
        case .success(let weekly):
            sessionsWeekly = weekly
        case .failure(let error):
            setTabError(.sessions, error: error)
        }

        await loadSessionsPage(
            reset: true,
            websiteId: websiteId,
            period: period,
            search: normalizedSearchQuery(sessionsSearchQuery),
            requestID: requestID
        )
    }

    func fetchSessionStatsResult(websiteId: String, period: StatsPeriod) async -> Result<[String: MetricValue], Error> {
        await captureResult {
            try await service.fetchWebsiteSessionStatsAsync(id: websiteId, period: period, query: queryOptions)
        }
    }

    func fetchSessionsWeeklyResult(websiteId: String, period: StatsPeriod) async -> Result<[WeeklySessionPoint], Error> {
        await captureResult {
            try await service.fetchWebsiteSessionsWeeklyAsync(id: websiteId, period: period, query: queryOptions)
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
        let requestID = sessionsPageRequestID

        Task { @MainActor [weak self] in
            await self?.loadSessionsPage(
                reset: false,
                websiteId: websiteId,
                period: period,
                search: search,
                requestID: requestID
            )
        }
    }

    func applySessionsSearch(_ search: String) {
        sessionsSearchQuery = search
        let requestID = UUID()
        sessionsPageRequestID = requestID
        nextSessionsPage = 1
        hasMoreSessions = true

        guard let websiteId = selectedWebsite?.id else { return }

        let period = selectedPeriod
        let normalizedSearch = normalizedSearchQuery(search)

        Task { @MainActor [weak self] in
            await self?.loadSessionsPage(
                reset: true,
                websiteId: websiteId,
                period: period,
                search: normalizedSearch,
                requestID: requestID
            )
        }
    }

    func loadSessionsPage(
        reset: Bool,
        websiteId: String? = nil,
        period: StatsPeriod? = nil,
        search: String? = nil,
        requestID: UUID? = nil
    ) async {
        guard let websiteId = websiteId ?? selectedWebsite?.id else { return }
        let period = period ?? selectedPeriod
        let search = search ?? normalizedSearchQuery(sessionsSearchQuery)
        let requestID = requestID ?? sessionsPageRequestID

        let page = reset ? 1 : nextSessionsPage
        isLoadingMoreSessions = !reset

        defer {
            if contextMatches(websiteId: websiteId, period: period), requestID == sessionsPageRequestID {
                isLoadingMoreSessions = false
            }
        }

        let result = await captureResult {
            try await service.fetchWebsiteSessionsAsync(
                id: websiteId,
                period: period,
                page: page,
                pageSize: pageSize,
                search: search,
                query: queryOptions
            )
        }

        guard contextMatches(websiteId: websiteId, period: period), requestID == sessionsPageRequestID else { return }

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
            if reset {
                hasMoreSessions = false
            }
            setTabError(.sessions, error: error)
        }
    }

    func loadSessionDetail(sessionId: String) {
        guard let websiteId = selectedWebsite?.id else { return }
        let period = selectedPeriod
        selectedSessionID = sessionId
        isLoadingSessionDetail = true
        selectedSessionRecord = nil
        selectedSessionActivity = []
        selectedSessionProperties = [:]

        Task { @MainActor [weak self] in
            guard let self else { return }

            async let detailResult = captureResult {
                try await self.service.fetchWebsiteSessionAsync(id: websiteId, sessionId: sessionId)
            }
            async let activityResult = captureResult {
                try await self.service.fetchWebsiteSessionActivityAsync(id: websiteId, sessionId: sessionId, period: period)
            }
            async let propertiesResult = captureResult {
                try await self.service.fetchWebsiteSessionPropertiesAsync(id: websiteId, sessionId: sessionId)
            }

            defer {
                if contextMatches(websiteId: websiteId, period: period), selectedSessionID == sessionId {
                    isLoadingSessionDetail = false
                }
            }

            let resolvedDetail = await detailResult
            let resolvedActivity = await activityResult
            let resolvedProperties = await propertiesResult

            guard contextMatches(websiteId: websiteId, period: period), selectedSessionID == sessionId else { return }

            switch resolvedDetail {
            case .success(let session):
                selectedSessionRecord = session
            case .failure(let error):
                setTabError(.sessions, error: error)
            }

            switch resolvedActivity {
            case .success(let activity):
                selectedSessionActivity = activity
            case .failure(let error):
                setTabError(.sessions, error: error)
            }

            switch resolvedProperties {
            case .success(let properties):
                selectedSessionProperties = properties
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

//
//  WebsiteViewModel+Overview.swift
//  Umami Analytics
//
//  Extracted from WebsiteViewModel.swift
//

import Foundation

// MARK: - Overview Tab Data Loading

extension WebsiteViewModel {

    func loadOverviewTab(websiteId: String, period: StatsPeriod) async {
        loadCachedStats(websiteId: websiteId)

        let hasCachedData = service.fetchCachedStats(for: websiteId, period: period) != nil
        if hasCachedData {
            isRefreshing = true
        } else {
            isLoading = true
        }

        defer {
            if contextMatches(websiteId: websiteId, period: period) {
                isLoading = false
                isRefreshing = false
            }
        }

        async let statsResult = fetchWebsiteStatsResult(websiteId: websiteId, period: period)
        async let metricsResult = fetchMetricDimensionResult(.url, websiteId: websiteId, period: period)
        async let pageviewsResult = fetchPageviewsResult(websiteId: websiteId, period: period)
        async let activeUsersResult = fetchActiveUsersResult(websiteId: websiteId)

        await applyWebsiteStatsResult(await statsResult, websiteId: websiteId, period: period, tab: .overview)
        await applyMetricDimensionResult(await metricsResult, dimension: .url, websiteId: websiteId, period: period, tab: .overview)
        await applyPageviewsResult(await pageviewsResult, websiteId: websiteId, period: period, tab: .overview)
        await applyActiveUsersResult(await activeUsersResult, websiteId: websiteId, period: period, tab: .overview)

        guard contextMatches(websiteId: websiteId, period: period) else { return }
        startRealtimeUpdates(websiteId: websiteId)
    }

    func loadAudienceTab(websiteId: String, period: StatsPeriod) async {
        async let referrerResult = fetchMetricDimensionResult(.referrer, websiteId: websiteId, period: period)
        async let browserResult = fetchMetricDimensionResult(.browser, websiteId: websiteId, period: period)
        async let deviceResult = fetchMetricDimensionResult(.device, websiteId: websiteId, period: period)
        async let countryResult = fetchMetricDimensionResult(.country, websiteId: websiteId, period: period)
        async let eventResult = fetchMetricDimensionResult(.event, websiteId: websiteId, period: period)
        async let channelResult = fetchMetricDimensionResult(.channel, websiteId: websiteId, period: period)

        await applyMetricDimensionResult(await referrerResult, dimension: .referrer, websiteId: websiteId, period: period, tab: .audience)
        await applyMetricDimensionResult(await browserResult, dimension: .browser, websiteId: websiteId, period: period, tab: .audience)
        await applyMetricDimensionResult(await deviceResult, dimension: .device, websiteId: websiteId, period: period, tab: .audience)
        await applyMetricDimensionResult(await countryResult, dimension: .country, websiteId: websiteId, period: period, tab: .audience)
        await applyMetricDimensionResult(await eventResult, dimension: .event, websiteId: websiteId, period: period, tab: .audience)
        await applyMetricDimensionResult(await channelResult, dimension: .channel, websiteId: websiteId, period: period, tab: .audience)
    }

    func fetchWebsiteStatsResult(websiteId: String, period: StatsPeriod) async -> Result<WebsiteStatsResponse, Error> {
        await captureResult {
            try await service.fetchWebsiteStatsAsync(id: websiteId, period: period)
        }
    }

    func fetchMetricDimensionResult(_ dimension: MetricDimension, websiteId: String, period: StatsPeriod) async -> Result<WebsiteMetricsResponse, Error> {
        await captureResult {
            let primaryType = dimension == .url ? "path" : dimension.rawValue
            do {
                return try await service.fetchWebsiteMetricsAsync(id: websiteId, period: period, type: primaryType)
            } catch where dimension == .url {
                return try await service.fetchWebsiteMetricsAsync(id: websiteId, period: period, type: "url")
            }
        }
    }

    func fetchPageviewsResult(websiteId: String, period: StatsPeriod) async -> Result<PageviewsResponse, Error> {
        await captureResult {
            try await service.fetchWebsitePageviewsAsync(id: websiteId, period: period)
        }
    }

    func fetchActiveUsersResult(websiteId: String) async -> Result<ActiveUsersResponse, Error> {
        await captureResult {
            try await service.fetchActiveUsersAsync(id: websiteId)
        }
    }

    func applyWebsiteStatsResult(_ result: Result<WebsiteStatsResponse, Error>, websiteId: String, period: StatsPeriod, tab: WebsiteDetailTab?) async {
        guard contextMatches(websiteId: websiteId, period: period) else { return }

        switch result {
        case .success(let response):
            websiteStats = response
        case .failure(let error):
            if let tab {
                setTabError(tab, error: error)
            } else {
                setRootError(error)
            }
        }
    }

    func applyMetricDimensionResult(_ result: Result<WebsiteMetricsResponse, Error>, dimension: MetricDimension, websiteId: String, period: StatsPeriod, tab: WebsiteDetailTab?) async {
        guard contextMatches(websiteId: websiteId, period: period) else { return }

        switch result {
        case .success(let response):
            metricsByDimension[dimension] = response
            if dimension == .url {
                websiteMetrics = response
            }
        case .failure(let error):
            if let tab {
                setTabError(tab, error: error)
            }
        }
    }

    func applyPageviewsResult(_ result: Result<PageviewsResponse, Error>, websiteId: String, period: StatsPeriod, tab: WebsiteDetailTab?) async {
        guard contextMatches(websiteId: websiteId, period: period) else { return }

        switch result {
        case .success(let response):
            pageviewsData = response
        case .failure(let error):
            if let tab {
                setTabError(tab, error: error)
            }
        }
    }

    func applyActiveUsersResult(_ result: Result<ActiveUsersResponse, Error>, websiteId: String, period: StatsPeriod, tab: WebsiteDetailTab?) async {
        guard contextMatches(websiteId: websiteId, period: period) else { return }

        switch result {
        case .success(let response):
            activeUsers = response
            activeUsersCount = response.visitors
            hasActiveUsersData = true
        case .failure(let error):
            if let tab {
                setTabError(tab, error: error)
            }
        }
    }
}

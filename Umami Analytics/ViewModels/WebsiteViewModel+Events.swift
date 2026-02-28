//
//  WebsiteViewModel+Events.swift
//  Umami Analytics
//
//  Extracted from WebsiteViewModel.swift
//

import Foundation

// MARK: - Events Tab

extension WebsiteViewModel {

    func loadEventsTab(websiteId: String, period: StatsPeriod) async {
        async let metricResult = fetchMetricDimensionResult(.event, websiteId: websiteId, period: period)
        async let seriesResult = captureResult {
            try await service.fetchWebsiteEventSeriesAsync(id: websiteId, period: period, eventName: nil)
        }

        nextEventsPage = 1
        hasMoreEvents = true

        await applyMetricDimensionResult(await metricResult, dimension: .event, websiteId: websiteId, period: period, tab: .events)

        let eventSeriesResult = await seriesResult
        if contextMatches(websiteId: websiteId, period: period) {
            switch eventSeriesResult {
            case .success(let series):
                eventSeries = series
            case .failure(let error):
                setTabError(.events, error: error)
            }
        }

        await loadEventsPage(reset: true, websiteId: websiteId, period: period, search: normalizedSearchQuery(eventsSearchQuery))
        await loadEventDataInspector(websiteId: websiteId, period: period)
    }

    func loadMoreEvents() {
        guard hasMoreEvents,
              !isLoadingMoreEvents,
              let websiteId = selectedWebsite?.id else {
            return
        }

        let period = selectedPeriod
        let search = normalizedSearchQuery(eventsSearchQuery)

        Task { @MainActor [weak self] in
            await self?.loadEventsPage(reset: false, websiteId: websiteId, period: period, search: search)
        }
    }

    func applyEventsSearch(_ search: String) {
        eventsSearchQuery = search
        nextEventsPage = 1
        hasMoreEvents = true

        guard let websiteId = selectedWebsite?.id else { return }

        let period = selectedPeriod
        let normalizedSearch = normalizedSearchQuery(search)

        Task { @MainActor [weak self] in
            await self?.loadEventsPage(reset: true, websiteId: websiteId, period: period, search: normalizedSearch)
        }
    }

    func selectEventDataEvent(_ eventName: String?) {
        eventDataState.selectedEvent = eventName
        reloadEventDataValues()
    }

    func selectEventDataProperty(_ propertyName: String?) {
        eventDataState.selectedProperty = propertyName
        reloadEventDataValues()
    }

    func loadEventsPage(reset: Bool, websiteId: String? = nil, period: StatsPeriod? = nil, search: String? = nil) async {
        guard let websiteId = websiteId ?? selectedWebsite?.id else { return }
        let period = period ?? selectedPeriod
        let search = search ?? normalizedSearchQuery(eventsSearchQuery)

        let page = reset ? 1 : nextEventsPage
        isLoadingMoreEvents = !reset

        defer {
            if contextMatches(websiteId: websiteId, period: period) {
                isLoadingMoreEvents = false
            }
        }

        let result = await captureResult {
            try await service.fetchWebsiteEventsAsync(
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
            if reset || eventsPage == nil {
                eventsPage = response
            } else if let current = eventsPage {
                eventsPage = PaginatedResponse(
                    data: current.data + response.data,
                    count: max(current.count, response.count),
                    page: response.page,
                    pageSize: response.pageSize
                )
            }

            let totalLoaded = eventsPage?.data.count ?? 0
            hasMoreEvents = totalLoaded < (eventsPage?.count ?? totalLoaded)
            nextEventsPage = page + 1
        case .failure(let error):
            setTabError(.events, error: error)
        }
    }

    func loadEventDataInspector(websiteId: String, period: StatsPeriod) async {
        eventDataState.isLoading = true
        defer {
            if contextMatches(websiteId: websiteId, period: period) {
                eventDataState.isLoading = false
            }
        }

        async let fieldsResult = captureResult {
            try await service.fetchEventDataFieldsAsync(id: websiteId, period: period)
        }
        async let propertiesResult = captureResult {
            try await service.fetchEventDataPropertiesAsync(id: websiteId, period: period, propertyName: nil)
        }
        async let eventsResult = captureResult {
            try await service.fetchEventDataEventsAsync(id: websiteId, period: period, event: nil)
        }
        async let statsResult = captureResult {
            try await service.fetchEventDataStatsAsync(id: websiteId, period: period)
        }

        guard contextMatches(websiteId: websiteId, period: period) else { return }

        switch await fieldsResult {
        case .success(let fields):
            eventDataState.availableFields = fields
        case .failure:
            eventDataState.availableFields = []
        }

        switch await propertiesResult {
        case .success(let properties):
            eventDataState.availableProperties = properties
        case .failure:
            eventDataState.availableProperties = []
        }

        switch await eventsResult {
        case .success(let events):
            eventDataState.availableEvents = events
            eventDataState.errorMessage = nil
        case .failure(let error):
            eventDataState.availableEvents = []
            eventDataState.errorMessage = error.localizedDescription
        }

        switch await statsResult {
        case .success(let stats):
            eventDataState.stats = stats
        case .failure:
            eventDataState.stats = [:]
        }

        await reloadEventDataValues(websiteId: websiteId, period: period)
    }

    func reloadEventDataValues() {
        guard let websiteId = selectedWebsite?.id else { return }
        let period = selectedPeriod

        Task { @MainActor [weak self] in
            await self?.reloadEventDataValues(websiteId: websiteId, period: period)
        }
    }

    func reloadEventDataValues(websiteId: String, period: StatsPeriod) async {
        let selectedProperty = eventDataState.selectedProperty?.trimmingCharacters(in: .whitespacesAndNewlines)

        guard let propertyName = selectedProperty, !propertyName.isEmpty else {
            if contextMatches(websiteId: websiteId, period: period) {
                eventDataState.availableValues = []
            }
            return
        }

        let result = await captureResult {
            try await service.fetchEventDataValuesAsync(
                id: websiteId,
                period: period,
                eventName: eventDataState.selectedEvent,
                propertyName: propertyName
            )
        }

        guard contextMatches(websiteId: websiteId, period: period) else { return }

        switch result {
        case .success(let values):
            eventDataState.availableValues = values
            eventDataState.errorMessage = nil
        case .failure(let error):
            eventDataState.availableValues = []
            eventDataState.errorMessage = error.localizedDescription
        }
    }
}

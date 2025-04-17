//
//  WebsiteService.swift
//  Umami Analytics
//
//  Created by Augment on 4/17/25.
//

import Foundation
import Combine
import CoreData
import SwiftUI

class WebsiteService {
    static let shared = WebsiteService()

    private var cancellables = Set<AnyCancellable>()
    private var realtimeTimers: [String: Timer] = [:]

    // MARK: - Website List

    func fetchWebsites() -> AnyPublisher<[WebsiteModel], Error> {
        // If in debug mode, return mock data
        if DebugManager.shared.isDebugMode {
            return Just(DebugManager.shared.getMockWebsites())
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }

        guard let apiClient = AuthManager.shared.apiClient else {
            return Fail(error: APIError.unauthorized).eraseToAnyPublisher()
        }

        return apiClient.getWebsites()
            .map { response in
                return response.data
            }
            .handleEvents(receiveOutput: { [weak self] websites in
                self?.saveWebsitesToCoreData(websites)
            })
            .eraseToAnyPublisher()
    }

    // MARK: - Website Details

    func fetchWebsiteDetails(id: String) -> AnyPublisher<WebsiteModel, Error> {
        guard let apiClient = AuthManager.shared.apiClient else {
            return Fail(error: APIError.unauthorized).eraseToAnyPublisher()
        }

        return apiClient.getWebsite(id: id)
            .eraseToAnyPublisher()
    }

    // MARK: - Website Stats

    func fetchWebsiteStats(id: String, period: StatsPeriod = .day) -> AnyPublisher<WebsiteStatsResponse, Error> {
        // If in debug mode, return mock data
        if DebugManager.shared.isDebugMode {
            let mockStats = DebugManager.shared.getMockStats()
            let now = Date()
            let startDate = createDateRange(for: period).startAt

            let response = WebsiteStatsResponse(
                websiteId: id,
                startDate: ISO8601DateFormatter().string(from: Date(timeIntervalSince1970: Double(startDate) / 1000)),
                endDate: ISO8601DateFormatter().string(from: now),
                stats: mockStats
            )

            return Just(response)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }

        guard let apiClient = AuthManager.shared.apiClient else {
            return Fail(error: APIError.unauthorized).eraseToAnyPublisher()
        }

        let dateRange = createDateRange(for: period)

        return apiClient.getWebsiteStats(id: id, dateRange: dateRange)
            .handleEvents(receiveOutput: { [weak self] response in
                self?.saveStatsToCache(websiteId: id, stats: response.stats, period: period)
            })
            .eraseToAnyPublisher()
    }

    // MARK: - Website Metrics

    func fetchWebsiteMetrics(id: String, period: StatsPeriod = .day) -> AnyPublisher<WebsiteMetricsResponse, Error> {
        // If in debug mode, return mock data
        if DebugManager.shared.isDebugMode {
            let mockMetrics = DebugManager.shared.getMockMetrics()
            let now = Date()
            let startDate = createDateRange(for: period).startAt

            let response = WebsiteMetricsResponse(
                websiteId: id,
                startDate: ISO8601DateFormatter().string(from: Date(timeIntervalSince1970: Double(startDate) / 1000)),
                endDate: ISO8601DateFormatter().string(from: now),
                metrics: mockMetrics
            )

            return Just(response)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }

        guard let apiClient = AuthManager.shared.apiClient else {
            return Fail(error: APIError.unauthorized).eraseToAnyPublisher()
        }

        let dateRange = createDateRange(for: period)

        return apiClient.getWebsiteMetrics(id: id, dateRange: dateRange)
            .handleEvents(receiveOutput: { [weak self] response in
                self?.saveMetricsToCache(websiteId: id, metrics: response.metrics, period: period)
            })
            .eraseToAnyPublisher()
    }

    // MARK: - Realtime Data

    func startRealtimeUpdates(for websiteId: String, interval: TimeInterval = 5.0, completion: @escaping (RealtimeData) -> Void) {
        stopRealtimeUpdates(for: websiteId)

        // Fetch initial data
        fetchRealtimeData(for: websiteId)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { data in
                    completion(data)
                }
            )
            .store(in: &cancellables)

        // Set up timer for periodic updates
        let timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.fetchRealtimeData(for: websiteId)
                .sink(
                    receiveCompletion: { _ in },
                    receiveValue: { data in
                        completion(data)
                    }
                )
                .store(in: &self.cancellables)
        }

        realtimeTimers[websiteId] = timer
    }

    func stopRealtimeUpdates(for websiteId: String) {
        realtimeTimers[websiteId]?.invalidate()
        realtimeTimers.removeValue(forKey: websiteId)
    }

    private func fetchRealtimeData(for websiteId: String) -> AnyPublisher<RealtimeData, Error> {
        // If in debug mode, return mock data
        if DebugManager.shared.isDebugMode {
            return Just(DebugManager.shared.getMockRealtimeData())
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }

        guard let apiClient = AuthManager.shared.apiClient else {
            return Fail(error: APIError.unauthorized).eraseToAnyPublisher()
        }

        return apiClient.getRealtimeData(websiteId: websiteId)
            .eraseToAnyPublisher()
    }

    // MARK: - CoreData Operations

    private func saveWebsitesToCoreData(_ websites: [WebsiteModel]) {
        let context = PersistenceController.shared.container.viewContext

        context.perform {
            // Fetch existing server
            let serverFetchRequest: NSFetchRequest<UmamiServer> = UmamiServer.fetchRequest()
            if let serverURL = AuthManager.shared.serverURL {
                serverFetchRequest.predicate = NSPredicate(format: "url == %@", serverURL)

                do {
                    let existingServers = try context.fetch(serverFetchRequest)
                    let server: UmamiServer

                    if let existingServer = existingServers.first {
                        server = existingServer
                    } else {
                        // Create new server if none exists
                        server = UmamiServer(context: context)
                        server.url = serverURL
                        server.name = "Umami Server"
                    }

                    // Create or update websites
                    for website in websites {
                        let websiteFetchRequest: NSFetchRequest<UmamiWebsite> = UmamiWebsite.fetchRequest()
                        websiteFetchRequest.predicate = NSPredicate(format: "id == %@", website.id)

                        let existingWebsites = try context.fetch(websiteFetchRequest)

                        if let existingWebsite = existingWebsites.first {
                            // Update existing website
                            existingWebsite.name = website.name
                            existingWebsite.domain = website.domain
                            existingWebsite.lastUpdated = Date()
                        } else {
                            // Create new website
                            let newWebsite = UmamiWebsite(context: context)
                            newWebsite.id = website.id
                            newWebsite.name = website.name
                            newWebsite.domain = website.domain
                            newWebsite.lastUpdated = Date()
                            newWebsite.server = server
                        }
                    }

                    try context.save()
                } catch {
                    print("Error saving websites to CoreData: \(error)")
                }
            }
        }
    }

    private func saveStatsToCache(websiteId: String, stats: WebsiteStatsModel, period: StatsPeriod) {
        let context = PersistenceController.shared.container.viewContext

        context.perform {
            // Fetch the website
            let websiteFetchRequest: NSFetchRequest<UmamiWebsite> = UmamiWebsite.fetchRequest()
            websiteFetchRequest.predicate = NSPredicate(format: "id == %@", websiteId)

            do {
                let websites = try context.fetch(websiteFetchRequest)

                if let website = websites.first {
                    // Create or update stats
                    let statsFetchRequest: NSFetchRequest<UmamiWebsiteStats> = UmamiWebsiteStats.fetchRequest()
                    statsFetchRequest.predicate = NSPredicate(format: "website == %@ AND period == %@", website, period.rawValue)

                    let existingStats = try context.fetch(statsFetchRequest)

                    if let existingStats = existingStats.first {
                        // Update existing stats
                        existingStats.pageviews = Int64(stats.pageviews)
                        existingStats.visitors = Int64(stats.uniques)
                        existingStats.date = Date()
                    } else {
                        // Create new stats
                        let newStats = UmamiWebsiteStats(context: context)
                        newStats.website = website
                        newStats.pageviews = Int64(stats.pageviews)
                        newStats.visitors = Int64(stats.uniques)
                        newStats.date = Date()
                        newStats.period = period.rawValue
                    }

                    try context.save()
                }
            } catch {
                print("Error saving stats to CoreData: \(error)")
            }
        }
    }

    private func saveMetricsToCache(websiteId: String, metrics: WebsiteMetrics, period: StatsPeriod) {
        // For simplicity, we're not implementing full metrics caching in this example
        // In a real app, you would create additional CoreData entities for each metric type
        print("Metrics received for website \(websiteId) for period \(period.rawValue)")
    }

    // MARK: - Helper Methods

    private func createDateRange(for period: StatsPeriod) -> DateRange {
        let now = Date()
        let calendar = Calendar.current

        var startDate: Date
        let endDate = now
        let unit: String

        switch period {
        case .day:
            startDate = calendar.date(byAdding: .day, value: -1, to: now)!
            unit = "hour"
        case .week:
            startDate = calendar.date(byAdding: .day, value: -7, to: now)!
            unit = "day"
        case .month:
            startDate = calendar.date(byAdding: .month, value: -1, to: now)!
            unit = "day"
        case .year:
            startDate = calendar.date(byAdding: .year, value: -1, to: now)!
            unit = "month"
        }

        let startTimestamp = Int64(startDate.timeIntervalSince1970 * 1000)
        let endTimestamp = Int64(endDate.timeIntervalSince1970 * 1000)

        return DateRange(
            startAt: startTimestamp,
            endAt: endTimestamp,
            unit: unit,
            timezone: TimeZone.current.identifier
        )
    }

    // MARK: - Fetch from CoreData

    func fetchCachedWebsites() -> [UmamiWebsite] {
        let context = PersistenceController.shared.container.viewContext
        let fetchRequest: NSFetchRequest<UmamiWebsite> = UmamiWebsite.fetchRequest()

        do {
            return try context.fetch(fetchRequest)
        } catch {
            print("Error fetching websites from CoreData: \(error)")
            return []
        }
    }

    func fetchCachedStats(for websiteId: String, period: StatsPeriod) -> UmamiWebsiteStats? {
        let context = PersistenceController.shared.container.viewContext

        let websiteFetchRequest: NSFetchRequest<UmamiWebsite> = UmamiWebsite.fetchRequest()
        websiteFetchRequest.predicate = NSPredicate(format: "id == %@", websiteId)

        do {
            let websites = try context.fetch(websiteFetchRequest)

            if let website = websites.first {
                let statsFetchRequest: NSFetchRequest<UmamiWebsiteStats> = UmamiWebsiteStats.fetchRequest()
                statsFetchRequest.predicate = NSPredicate(format: "website == %@ AND period == %@", website, period.rawValue)

                let stats = try context.fetch(statsFetchRequest)
                return stats.first
            }
        } catch {
            print("Error fetching stats from CoreData: \(error)")
        }

        return nil
    }
}

// MARK: - Helper Types

enum StatsPeriod: String {
    case day = "day"
    case week = "week"
    case month = "month"
    case year = "year"

    var displayName: String {
        switch self {
        case .day: return "Today"
        case .week: return "This Week"
        case .month: return "This Month"
        case .year: return "This Year"
        }
    }
}



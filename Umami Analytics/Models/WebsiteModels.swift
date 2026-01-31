//
//  WebsiteModels.swift
//  Umami Analytics
//
//  Created by Augment on 4/17/25.
//

import Foundation

// MARK: - Website Models

struct WebsiteModel: Codable, Identifiable {
    let id: String
    let name: String
    let domain: String
    let shareId: String?
    let userId: String?
    let teamId: String?
    let createdAt: String?
    let updatedAt: String?

    enum CodingKeys: String, CodingKey {
        case id, name, domain, shareId, userId, teamId, createdAt, updatedAt
    }

    // Standard memberwise initializer for manual creation
    init(id: String, name: String, domain: String, shareId: String? = nil, userId: String? = nil, teamId: String? = nil, createdAt: String? = nil, updatedAt: String? = nil) {
        self.id = id
        self.name = name
        self.domain = domain
        self.shareId = shareId
        self.userId = userId
        self.teamId = teamId
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    // Custom decoder to handle different API formats
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // Required fields
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        domain = try container.decode(String.self, forKey: .domain)

        // Optional fields
        shareId = try container.decodeIfPresent(String.self, forKey: .shareId)
        userId = try container.decodeIfPresent(String.self, forKey: .userId)
        teamId = try container.decodeIfPresent(String.self, forKey: .teamId)
        createdAt = try container.decodeIfPresent(String.self, forKey: .createdAt)
        updatedAt = try container.decodeIfPresent(String.self, forKey: .updatedAt)
    }
}

struct WebsiteStatsModel: Codable {
    let pageviews: Int
    let uniques: Int
    let bounces: Int
    let totalTime: Int

    var bounceRate: Double {
        guard uniques > 0 else { return 0 }
        return Double(bounces) / Double(uniques)
    }

    var avgDuration: Double {
        guard pageviews > 0 else { return 0 }
        return Double(totalTime) / Double(pageviews)
    }
}

struct WebsiteMetrics: Codable {
    let pageviews: [PageviewMetric]
    let sessions: [SessionMetric]
    let events: [EventMetric]
    let countries: [CountryMetric]
    let browsers: [BrowserMetric]
    let os: [OSMetric]
    let devices: [DeviceMetric]
    let referrers: [ReferrerMetric]
    let pages: [PageMetric]

    // Custom initializer for creating mock data
    init(pageviews: [PageviewMetric],
         sessions: [SessionMetric],
         events: [EventMetric],
         countries: [CountryMetric],
         browsers: [BrowserMetric],
         os: [OSMetric],
         devices: [DeviceMetric],
         referrers: [ReferrerMetric],
         pages: [PageMetric]) {
        self.pageviews = pageviews
        self.sessions = sessions
        self.events = events
        self.countries = countries
        self.browsers = browsers
        self.os = os
        self.devices = devices
        self.referrers = referrers
        self.pages = pages
    }

    // Custom decoder to handle different API formats
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // Decode all fields with fallbacks to empty arrays if not present
        pageviews = try container.decodeIfPresent([PageviewMetric].self, forKey: .pageviews) ?? []
        sessions = try container.decodeIfPresent([SessionMetric].self, forKey: .sessions) ?? []
        events = try container.decodeIfPresent([EventMetric].self, forKey: .events) ?? []
        countries = try container.decodeIfPresent([CountryMetric].self, forKey: .countries) ?? []
        browsers = try container.decodeIfPresent([BrowserMetric].self, forKey: .browsers) ?? []
        os = try container.decodeIfPresent([OSMetric].self, forKey: .os) ?? []
        devices = try container.decodeIfPresent([DeviceMetric].self, forKey: .devices) ?? []
        referrers = try container.decodeIfPresent([ReferrerMetric].self, forKey: .referrers) ?? []
        pages = try container.decodeIfPresent([PageMetric].self, forKey: .pages) ?? []
    }

    enum CodingKeys: String, CodingKey {
        case pageviews, sessions, events, countries, browsers, os, devices, referrers, pages
    }
}

// MARK: - Metric Models

struct PageviewMetric: Codable, Identifiable {
    var id: String { date }
    let date: String
    let value: Int
}

struct SessionMetric: Codable, Identifiable {
    var id: String { date }
    let date: String
    let value: Int
}

struct EventMetric: Codable, Identifiable {
    var id: String { name }
    let name: String
    let value: Int
}

struct CountryMetric: Codable, Identifiable {
    var id: String { code }
    let code: String
    let name: String
    let value: Int
}

struct BrowserMetric: Codable, Identifiable {
    var id: String { name }
    let name: String
    let value: Int
}

struct OSMetric: Codable, Identifiable {
    var id: String { name }
    let name: String
    let value: Int
}

struct DeviceMetric: Codable, Identifiable {
    var id: String { device }
    let device: String
    let value: Int
}

struct ReferrerMetric: Codable, Identifiable {
    var id: String { referrer }
    let referrer: String
    let value: Int
}

struct PageMetric: Codable, Identifiable {
    var id: String { url }
    let url: String
    let title: String?
    let value: Int
}

// MARK: - Request/Response Models

struct DateRange: Codable {
    let startAt: Int64
    let endAt: Int64
    let unit: String
    let timezone: String?
}

struct WebsiteRequest: Codable {
    let dateRange: DateRange
    let filters: [String: String]?
}

struct WebsiteListResponse: Codable {
    let data: [WebsiteModel]
    let count: Int?
    let pagination: Pagination?

    // Custom decoder to handle different API formats
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // Decode required data field
        data = try container.decode([WebsiteModel].self, forKey: .data)

        // Decode optional fields
        count = try container.decodeIfPresent(Int.self, forKey: .count)
        pagination = try container.decodeIfPresent(Pagination.self, forKey: .pagination)
    }

    // Standard encoder
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(data, forKey: .data)
        try container.encodeIfPresent(count, forKey: .count)
        try container.encodeIfPresent(pagination, forKey: .pagination)
    }

    // Computed property for total count
    var totalCount: Int {
        count ?? data.count
    }

    enum CodingKeys: String, CodingKey {
        case data, count, pagination
    }
}

struct Pagination: Codable {
    let page: Int?
    let pageSize: Int?
    let count: Int?
    let totalPages: Int?
}

struct WebsiteStatsResponse: Codable {
    let websiteId: String?
    let startDate: String
    let endDate: String
    let stats: WebsiteStatsModel

    // Custom initializer for creating mock data
    init(websiteId: String, startDate: String, endDate: String, stats: WebsiteStatsModel) {
        self.websiteId = websiteId
        self.startDate = startDate
        self.endDate = endDate
        self.stats = stats
    }

    // Custom decoder to handle different API formats
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // Try to decode websiteId, but make it optional
        websiteId = try container.decodeIfPresent(String.self, forKey: .websiteId)

        // Decode dates
        startDate = try container.decode(String.self, forKey: .startDate)
        endDate = try container.decode(String.self, forKey: .endDate)

        // Decode stats
        stats = try container.decode(WebsiteStatsModel.self, forKey: .stats)
    }

    enum CodingKeys: String, CodingKey {
        case websiteId, startDate, endDate, stats
    }
}

struct WebsiteMetricsResponse: Codable {
    let websiteId: String?
    let startDate: String
    let endDate: String
    let metrics: WebsiteMetrics

    // Custom initializer for creating mock data
    init(websiteId: String, startDate: String, endDate: String, metrics: WebsiteMetrics) {
        self.websiteId = websiteId
        self.startDate = startDate
        self.endDate = endDate
        self.metrics = metrics
    }

    // Custom decoder to handle different API formats
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // Try to decode websiteId, but make it optional
        websiteId = try container.decodeIfPresent(String.self, forKey: .websiteId)

        // Decode dates
        startDate = try container.decode(String.self, forKey: .startDate)
        endDate = try container.decode(String.self, forKey: .endDate)

        // Decode metrics
        metrics = try container.decode(WebsiteMetrics.self, forKey: .metrics)
    }

    enum CodingKeys: String, CodingKey {
        case websiteId, startDate, endDate, metrics
    }
}

// MARK: - Real-time Data Models

// Base protocol for different realtime data formats
protocol RealtimeDataProtocol {
    var timestamp: Int64 { get }
    var sessions: Int { get }
    var countries: [String: Int] { get }
    var urls: [String: Int]? { get }
    var referrers: [String: Int]? { get }
    var events: [RealtimeEvent] { get }
    var series: RealtimeSeries? { get }
    var totals: RealtimeTotals? { get }

    // Computed property to get the website ID if available
    var websiteId: String? { get }

    // Computed properties to get pageviews in a consistent format
    var pageviews: [RealtimePageview] { get }
}

// Original RealtimeData model for v1 API
struct RealtimeData: Codable, RealtimeDataProtocol {
    let websiteId: String?
    let timestamp: Int64
    var pageviews: [RealtimePageview]
    let sessions: Int
    var events: [RealtimeEvent]
    let countries: [String: Int]
    let urls: [String: Int]?
    let referrers: [String: Int]?
    let series: RealtimeSeries?
    let totals: RealtimeTotals?

    // Default initializer
    init(websiteId: String?, timestamp: Int64, pageviews: [RealtimePageview], sessions: Int, events: [RealtimeEvent], countries: [String: Int], urls: [String: Int]? = nil, referrers: [String: Int]? = nil, series: RealtimeSeries? = nil, totals: RealtimeTotals? = nil) {
        self.websiteId = websiteId
        self.timestamp = timestamp
        self.pageviews = pageviews
        self.sessions = sessions
        self.events = events
        self.countries = countries
        self.urls = urls
        self.referrers = referrers
        self.series = series
        self.totals = totals
    }

    // Custom decoder to handle different API formats
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // Try to decode websiteId, but make it optional
        websiteId = try container.decodeIfPresent(String.self, forKey: .websiteId)

        // Decode timestamp
        timestamp = try container.decode(Int64.self, forKey: .timestamp)

        // Try to decode sessions, default to totals.visitors if not present
        if container.contains(.sessions) {
            sessions = try container.decode(Int.self, forKey: .sessions)
        } else if let totals = try container.decodeIfPresent(RealtimeTotals.self, forKey: .totals) {
            sessions = totals.visitors
        } else {
            sessions = 0
        }

        // Try to decode countries
        if container.contains(.countries) {
            countries = try container.decode([String: Int].self, forKey: .countries)
        } else {
            countries = [:]
        }

        // Try to decode urls
        urls = try container.decodeIfPresent([String: Int].self, forKey: .urls)

        // Try to decode referrers
        referrers = try container.decodeIfPresent([String: Int].self, forKey: .referrers)

        // Try to decode series
        series = try container.decodeIfPresent(RealtimeSeries.self, forKey: .series)

        // Try to decode totals
        totals = try container.decodeIfPresent(RealtimeTotals.self, forKey: .totals)

        // Try to decode pageviews or convert from urls
        if container.contains(.pageviews) {
            pageviews = try container.decode([RealtimePageview].self, forKey: .pageviews)
        } else {
            // Convert urls to pageviews if available
            pageviews = []
            if let urlData = urls {
                for (url, _) in urlData {
                    pageviews.append(RealtimePageview(url: url, title: nil, timestamp: timestamp))
                }
            }
        }

        // Try to decode events
        if container.contains(.events) {
            events = try container.decode([RealtimeEvent].self, forKey: .events)
        } else {
            events = []
        }
    }

    enum CodingKeys: String, CodingKey {
        case websiteId, timestamp, pageviews, sessions, events, countries, urls, referrers, series, totals
    }
}

struct RealtimeSeries: Codable {
    let views: [Int]
    let visitors: [Int]
}

struct RealtimeTotals: Codable {
    let views: Int
    let visitors: Int
    let events: Int
    let countries: Int
}

struct RealtimePageview: Codable, Identifiable {
    var id: String { url }
    let url: String
    let title: String?
    let timestamp: Int64
}

struct RealtimeEvent: Codable, Identifiable {
    var id: UUID { UUID() } // Events don't have a natural ID, so we generate one
    let name: String
    let timestamp: Int64
    let data: [String: String]?
}

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
    let resetAt: String?
    let updatedAt: String?
    let deletedAt: String?
    let createdBy: String?

    enum CodingKeys: String, CodingKey {
        case id, name, domain, shareId, userId, teamId, createdAt
        case resetAt, updatedAt, deletedAt, createdBy
    }

    init(id: String, name: String, domain: String, shareId: String? = nil,
         userId: String? = nil, teamId: String? = nil, createdAt: String? = nil,
         resetAt: String? = nil, updatedAt: String? = nil,
         deletedAt: String? = nil, createdBy: String? = nil) {
        self.id = id
        self.name = name
        self.domain = domain
        self.shareId = shareId
        self.userId = userId
        self.teamId = teamId
        self.createdAt = createdAt
        self.resetAt = resetAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
        self.createdBy = createdBy
    }
}

// MARK: - Metric Display Models

struct PageMetric: Codable, Identifiable {
    var id: String { url }
    let url: String
    let title: String?
    let value: Int
}

struct ReferrerMetric: Codable, Identifiable {
    var id: String { referrer }
    let referrer: String
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

struct CountryMetric: Codable, Identifiable {
    var id: String { code }
    let code: String
    let name: String
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

struct CreateWebsiteRequest: Codable {
    let name: String
    let domain: String
    let shareId: String?
    let teamId: String?
    let id: String?
}

struct UpdateWebsiteRequest: Codable {
    let name: String?
    let domain: String?
    let shareId: String?
}

struct WebsiteListResponse: Codable {
    let data: [WebsiteModel]
    let count: Int
    let page: Int?
    let pageSize: Int?
}

// Supports both flat numeric and nested {value, prev} stat payloads.
struct WebsiteStatsResponse: Codable {
    let pageviews: Int
    let visitors: Int
    let visits: Int
    let bounces: Int
    let totaltime: Int
    let comparison: StatsComparison?

    // Cached values for offline display (excluded from Codable via CodingKeys)
    var cachedBounceRate: Double?
    var cachedAvgDuration: Double?

    enum CodingKeys: String, CodingKey {
        case pageviews, visitors, visits, bounces, totaltime, comparison
    }

    init(
        pageviews: Int,
        visitors: Int,
        visits: Int,
        bounces: Int,
        totaltime: Int,
        comparison: StatsComparison? = nil
    ) {
        self.pageviews = pageviews
        self.visitors = visitors
        self.visits = visits
        self.bounces = bounces
        self.totaltime = totaltime
        self.comparison = comparison
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        func decodeMetric(_ key: CodingKeys) -> Int {
            if let value = try? container.decode(Int.self, forKey: key) {
                return value
            }

            if let doubleValue = try? container.decode(Double.self, forKey: key) {
                return Int(doubleValue.rounded())
            }

            if let metricValue = try? container.decode(MetricValue.self, forKey: key) {
                return metricValue.value
            }

            return 0
        }

        pageviews = decodeMetric(.pageviews)
        visitors = decodeMetric(.visitors)
        visits = decodeMetric(.visits)
        bounces = decodeMetric(.bounces)
        totaltime = decodeMetric(.totaltime)
        comparison = try? container.decode(StatsComparison.self, forKey: .comparison)
    }

    var bounceRate: Double {
        if let cached = cachedBounceRate {
            return cached
        }
        guard visits > 0 else { return 0 }
        return Double(bounces) / Double(visits)
    }

    var avgDuration: Double {
        if let cached = cachedAvgDuration {
            return cached
        }
        guard pageviews > 0 else { return 0 }
        return Double(totaltime) / Double(pageviews)
    }
}

struct StatsComparison: Codable {
    let pageviews: Int
    let visitors: Int
    let visits: Int
    let bounces: Int
    let totaltime: Int
}

// Updated to match latest Umami API - metrics endpoint returns array directly
typealias WebsiteMetricsResponse = [MetricItem]

struct MetricItem: Codable, Identifiable {
    var id: String { x }
    let x: String  // The metric value (URL, browser, etc.)
    let y: Int     // The count
}

// Updated to match latest Umami API - pageviews endpoint response structure
struct PageviewsResponse: Codable {
    let pageviews: [TimeSeriesData]
    let sessions: [TimeSeriesData]
}

struct TimeSeriesData: Codable, Identifiable, Equatable {
    var id: Date { date }
    let date: Date
    let value: Int

    private enum CodingKeys: String, CodingKey {
        case x
        case y
    }

    init(date: Date, value: Int) {
        self.date = date
        self.value = value
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if let intValue = try? container.decode(Int.self, forKey: .y) {
            self.value = intValue
        } else if let doubleValue = try? container.decode(Double.self, forKey: .y) {
            self.value = Int(doubleValue.rounded())
        } else {
            throw DecodingError.dataCorruptedError(
                forKey: .y,
                in: container,
                debugDescription: "Unable to decode numeric value for time series entry"
            )
        }

        if let epochValue = try? container.decode(Int64.self, forKey: .x) {
            self.date = Self.dateFromEpochValue(Double(epochValue))
        } else if let epochValue = try? container.decode(Double.self, forKey: .x) {
            self.date = Self.dateFromEpochValue(epochValue)
        } else if let stringValue = try? container.decode(String.self, forKey: .x) {
            if let parsedDate = Self.parseDateString(stringValue) {
                self.date = parsedDate
            } else {
                throw DecodingError.dataCorruptedError(
                    forKey: .x,
                    in: container,
                    debugDescription: "Unrecognised timestamp format: \(stringValue)"
                )
            }
        } else {
            throw DecodingError.dataCorruptedError(
                forKey: .x,
                in: container,
                debugDescription: "Unable to decode timestamp for time series entry"
            )
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        let milliseconds = Int64(date.timeIntervalSince1970 * 1000)
        try container.encode(milliseconds, forKey: .x)
        try container.encode(value, forKey: .y)
    }

    static func == (lhs: TimeSeriesData, rhs: TimeSeriesData) -> Bool {
        lhs.date == rhs.date && lhs.value == rhs.value
    }

    private static func dateFromEpochValue(_ value: Double) -> Date {
        let seconds = abs(value) > 9_999_999_999 ? value / 1000 : value
        return Date(timeIntervalSince1970: seconds)
    }

    private static func parseDateString(_ value: String) -> Date? {
        if let numeric = Double(value) {
            return dateFromEpochValue(numeric)
        }

        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = isoFormatter.date(from: value) {
            return date
        }

        isoFormatter.formatOptions = [.withInternetDateTime]
        if let date = isoFormatter.date(from: value) {
            return date
        }

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone.current

        for format in ["yyyy-MM-dd HH:mm:ss", "yyyy-MM-dd'T'HH:mm:ss", "yyyy-MM-dd"] {
            formatter.dateFormat = format
            if let date = formatter.date(from: value) {
                return date
            }
        }

        return nil
    }
}

// Active users endpoint response
struct ActiveUsersResponse: Codable {
    let visitors: Int  // Number of active users
}

// MARK: - Real-time Data Models

struct RealtimeData: Decodable {
    let websiteId: String?
    let timestamp: Int64?
    let pageviews: [RealtimePageview]
    let sessions: Int
    let events: [RealtimeEvent]
    let countries: [String: Int]

    enum CodingKeys: String, CodingKey {
        case websiteId
        case timestamp
        case pageviews
        case sessions
        case events
        case countries
        case visitors
        case activeVisitors
    }

    init(
        websiteId: String? = nil,
        timestamp: Int64? = nil,
        pageviews: [RealtimePageview] = [],
        sessions: Int = 0,
        events: [RealtimeEvent] = [],
        countries: [String: Int] = [:]
    ) {
        self.websiteId = websiteId
        self.timestamp = timestamp
        self.pageviews = pageviews
        self.sessions = sessions
        self.events = events
        self.countries = countries
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        websiteId = try? container.decode(String.self, forKey: .websiteId)
        timestamp = try? container.decode(Int64.self, forKey: .timestamp)
        pageviews = (try? container.decode([RealtimePageview].self, forKey: .pageviews)) ?? []
        events = (try? container.decode([RealtimeEvent].self, forKey: .events)) ?? []
        countries = (try? container.decode([String: Int].self, forKey: .countries)) ?? [:]

        if let sessionCount = try? container.decode(Int.self, forKey: .sessions) {
            sessions = sessionCount
        } else if let visitors = try? container.decode(Int.self, forKey: .visitors) {
            sessions = visitors
        } else if let visitors = try? container.decode(Int.self, forKey: .activeVisitors) {
            sessions = visitors
        } else {
            sessions = 0
        }
    }
}

struct RealtimePageview: Codable, Identifiable {
    var id: String { url }
    let url: String
    let title: String?
    let timestamp: Int64
}

struct RealtimeEvent: Codable, Identifiable {
    var id: String { "\(name)-\(timestamp)" }
    let name: String
    let timestamp: Int64
    let data: [String: String]?
}

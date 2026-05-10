//
//  WebsiteModels.swift
//  Umami Analytics
//
//  Created by Augment on 4/17/25.
//

import Foundation

// MARK: - Website Models

struct WebsiteModel: Codable, Identifiable, Sendable {
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

struct PageMetric: Codable, Identifiable, Sendable {
    var id: String { url }
    let url: String
    let title: String?
    let value: Int
}

struct ReferrerMetric: Codable, Identifiable, Sendable {
    var id: String { referrer }
    let referrer: String
    let value: Int
}

struct BrowserMetric: Codable, Identifiable, Sendable {
    var id: String { name }
    let name: String
    let value: Int
}

struct OSMetric: Codable, Identifiable, Sendable {
    var id: String { name }
    let name: String
    let value: Int
}

struct DeviceMetric: Codable, Identifiable, Sendable {
    var id: String { device }
    let device: String
    let value: Int
}

struct CountryMetric: Codable, Identifiable, Sendable {
    var id: String { code }
    let code: String
    let name: String
    let value: Int
}

// MARK: - Request/Response Models

struct DateRange: Codable, Sendable {
    let startAt: Int64
    let endAt: Int64
    let unit: String
    let timezone: String?
}

struct WebsiteRequest: Codable, Sendable {
    let dateRange: DateRange
    let filters: [String: String]?
}

struct CreateWebsiteRequest: Codable, Sendable {
    let name: String
    let domain: String
    let shareId: String?
    let teamId: String?
    let id: String?
}

struct UpdateWebsiteRequest: Codable, Sendable {
    let name: String?
    let domain: String?
    let shareId: String?
}

struct TransferWebsiteRequest: Codable, Sendable {
    let userId: String?
    let teamId: String?
}

struct WebsiteListResponse: Codable, Sendable {
    let data: [WebsiteModel]
    let count: Int
    let page: Int?
    let pageSize: Int?
}

struct WebsiteDateRangeResponse: Codable, Sendable {
    let startDate: String?
    let endDate: String?
}

struct SavedReport: Codable, Identifiable, Sendable {
    let id: String
    let websiteId: String?
    let teamId: String?
    let name: String
    let type: String
    let description: String?
    let updatedAt: String?
}

enum SegmentType: String, Codable, CaseIterable, Identifiable, Sendable {
    case segment
    case cohort

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .segment:
            return "Segments"
        case .cohort:
            return "Cohorts"
        }
    }
}

struct SegmentDefinition: Decodable, Identifiable, Sendable {
    let id: String
    let websiteId: String?
    let name: String
    let type: SegmentType
    let parameters: [String: JSONValue]?
    let updatedAt: String?
}

struct TrackedAsset: Codable, Identifiable, Sendable {
    let id: String
    let name: String
    let slug: String
    let url: String?
    let teamId: String?
}

// Supports both flat numeric and nested {value, prev} stat payloads.
struct WebsiteStatsResponse: Codable, Sendable {
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

struct StatsComparison: Codable, Sendable {
    let pageviews: Int
    let visitors: Int
    let visits: Int
    let bounces: Int
    let totaltime: Int
}

// Updated to match latest Umami API - metrics endpoint returns array directly
typealias WebsiteMetricsResponse = [MetricItem]

struct MetricItem: Codable, Identifiable, Sendable {
    var id: String { x }
    let x: String  // The metric value (URL, browser, etc.)
    let y: Int     // The count
}

struct ExpandedMetricItem: Codable, Identifiable, Sendable {
    var id: String { name }
    let name: String
    let pageviews: Int
    let visitors: Int
    let visits: Int
    let bounces: Int
    let totaltime: Int
}

struct WebsiteExportResponse: Decodable, Sendable {
    let data: String?
    let url: String?
    let filename: String?

    init(from decoder: Decoder) throws {
        if let container = try? decoder.singleValueContainer(),
           let string = try? container.decode(String.self) {
            data = string
            url = nil
            filename = nil
            return
        }

        let container = try decoder.container(keyedBy: DynamicCodingKey.self)
        data = try? container.decode(String.self, forKey: DynamicCodingKey("data"))
        url = try? container.decode(String.self, forKey: DynamicCodingKey("url"))
        filename = try? container.decode(String.self, forKey: DynamicCodingKey("filename"))
    }
}

// Updated to match latest Umami API - pageviews endpoint response structure
struct PageviewsResponse: Codable, Sendable {
    let pageviews: [TimeSeriesData]
    let sessions: [TimeSeriesData]
}

struct TimeSeriesData: Codable, Identifiable, Equatable, Sendable {
    var id: Date { date }
    let date: Date
    let value: Int

    private enum CodingKeys: String, CodingKey {
        case x
        case t
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

        if let epochValue = try? container.decode(Int64.self, forKey: .t) {
            self.date = Self.dateFromEpochValue(Double(epochValue))
        } else if let epochValue = try? container.decode(Double.self, forKey: .t) {
            self.date = Self.dateFromEpochValue(epochValue)
        } else if let stringValue = try? container.decode(String.self, forKey: .t),
                  let parsedDate = Self.parseDateString(stringValue) {
            self.date = parsedDate
        } else if let epochValue = try? container.decode(Int64.self, forKey: .x) {
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
struct ActiveUsersResponse: Codable, Sendable {
    let visitors: Int  // Number of active users
}

// MARK: - Real-time Data Models

struct RealtimeData: Decodable, Sendable {
    let websiteId: String?
    let timestamp: Int64?
    let pageviews: [RealtimePageview]
    let referrers: [String: Int]
    let series: RealtimeSeries?
    let totals: RealtimeTotals?
    let sessions: Int
    let events: [RealtimeEvent]
    let countries: [String: Int]

    enum CodingKeys: String, CodingKey {
        case websiteId
        case timestamp
        case pageviews
        case urls
        case referrers
        case series
        case totals
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
        referrers: [String: Int] = [:],
        series: RealtimeSeries? = nil,
        totals: RealtimeTotals? = nil,
        sessions: Int = 0,
        events: [RealtimeEvent] = [],
        countries: [String: Int] = [:]
    ) {
        self.websiteId = websiteId
        self.timestamp = timestamp
        self.pageviews = pageviews
        self.referrers = referrers
        self.series = series
        self.totals = totals
        self.sessions = sessions
        self.events = events
        self.countries = countries
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        websiteId = try? container.decode(String.self, forKey: .websiteId)
        timestamp = try? container.decode(Int64.self, forKey: .timestamp)
        if let pageviewRows = try? container.decode([RealtimePageview].self, forKey: .pageviews) {
            pageviews = pageviewRows
        } else if let urlCounts = try? container.decode([String: Int].self, forKey: .urls) {
            let responseTimestamp = timestamp ?? 0
            pageviews = urlCounts
                .sorted { $0.value > $1.value }
                .map { RealtimePageview(url: $0.key, title: "\($0.value)", timestamp: responseTimestamp, count: $0.value) }
        } else {
            pageviews = []
        }
        events = (try? container.decode([RealtimeEvent].self, forKey: .events)) ?? []
        countries = (try? container.decode([String: Int].self, forKey: .countries)) ?? [:]
        referrers = (try? container.decode([String: Int].self, forKey: .referrers)) ?? [:]
        series = try? container.decode(RealtimeSeries.self, forKey: .series)
        totals = try? container.decode(RealtimeTotals.self, forKey: .totals)

        if let totalVisitors = totals?.visitors {
            sessions = totalVisitors
        } else if let sessionCount = try? container.decode(Int.self, forKey: .sessions) {
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

struct RealtimePageview: Codable, Identifiable, Sendable {
    var id: String { url }
    let url: String
    let title: String?
    let timestamp: Int64
    let count: Int?

    init(url: String, title: String? = nil, timestamp: Int64 = 0, count: Int? = nil) {
        self.url = url
        self.title = title
        self.timestamp = timestamp
        self.count = count
    }
}

struct RealtimeEvent: Decodable, Identifiable, Sendable {
    var id: String { "\(name)-\(timestamp)" }
    let name: String
    let timestamp: Int64
    let data: [String: String]?

    private enum CodingKeys: String, CodingKey {
        case name
        case eventName
        case timestamp
        case createdAt
        case data
    }

    init(name: String, timestamp: Int64, data: [String: String]? = nil) {
        self.name = name
        self.timestamp = timestamp
        self.data = data
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let decodedName = (try? container.decode(String.self, forKey: .name))
            ?? (try? container.decode(String.self, forKey: .eventName))
            ?? "pageview"
        name = decodedName.isEmpty ? "pageview" : decodedName
        data = try? container.decode([String: String].self, forKey: .data)

        if let millis = try? container.decode(Int64.self, forKey: .timestamp) {
            timestamp = millis
        } else if let createdAt = try? container.decode(String.self, forKey: .createdAt),
                  let date = TimeSeriesData.parseDateStringForRealtime(createdAt) {
            timestamp = Int64(date.timeIntervalSince1970 * 1000)
        } else {
            timestamp = 0
        }
    }
}

struct RealtimeSeries: Decodable, Sendable {
    let views: [TimeSeriesData]
    let visitors: [TimeSeriesData]
}

struct RealtimeTotals: Decodable, Sendable {
    let views: Int?
    let visitors: Int?
    let events: Int?
    let countries: Int?
}

private extension TimeSeriesData {
    static func parseDateStringForRealtime(_ value: String) -> Date? {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = formatter.date(from: value) {
            return date
        }

        formatter.formatOptions = [.withInternetDateTime]
        return formatter.date(from: value)
    }
}

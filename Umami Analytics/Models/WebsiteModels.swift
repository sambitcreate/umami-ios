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

    private enum CodingKeys: String, CodingKey {
        case x
        case y
    }

    init(x: String, y: Int) {
        self.x = x
        self.y = y
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let stringValue = try? container.decode(String.self, forKey: .x) {
            x = stringValue
        } else if let intValue = try? container.decode(Int.self, forKey: .x) {
            x = String(intValue)
        } else if let doubleValue = try? container.decode(Double.self, forKey: .x) {
            x = String(doubleValue)
        } else {
            x = ""
        }

        if let intValue = try? container.decode(Int.self, forKey: .y) {
            y = intValue
        } else if let doubleValue = try? container.decode(Double.self, forKey: .y) {
            y = Int(doubleValue.rounded())
        } else if let stringValue = try? container.decode(String.self, forKey: .y),
                  let numeric = Double(stringValue) {
            y = Int(numeric.rounded())
        } else {
            y = 0
        }
    }
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

    private enum CodingKeys: String, CodingKey {
        case pageviews
        case sessions
    }

    init(pageviews: [TimeSeriesData], sessions: [TimeSeriesData]) {
        self.pageviews = pageviews
        self.sessions = sessions
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        pageviews = (try? container.decodeIfPresent(LossyArray<TimeSeriesData>.self, forKey: .pageviews)?.elements) ?? []
        sessions = (try? container.decodeIfPresent(LossyArray<TimeSeriesData>.self, forKey: .sessions)?.elements) ?? []
    }
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
        } else if let stringValue = try? container.decode(String.self, forKey: .y),
                  let numeric = Double(stringValue) {
            self.value = Int(numeric.rounded())
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

struct EventSeriesPoint: Decodable, Sendable {
    let eventName: String
    let date: Date
    let value: Int

    private enum CodingKeys: String, CodingKey {
        case x
        case t
        case y
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        eventName = (try? container.decode(String.self, forKey: .x)) ?? ""

        if let intValue = try? container.decode(Int.self, forKey: .y) {
            value = intValue
        } else if let doubleValue = try? container.decode(Double.self, forKey: .y) {
            value = Int(doubleValue.rounded())
        } else if let stringValue = try? container.decode(String.self, forKey: .y),
                  let intValue = Int(stringValue) {
            value = intValue
        } else {
            value = 0
        }

        if let epochValue = try? container.decode(Int64.self, forKey: .t) {
            date = TimeSeriesData.dateFromEventSeriesEpoch(Double(epochValue))
        } else if let epochValue = try? container.decode(Double.self, forKey: .t) {
            date = TimeSeriesData.dateFromEventSeriesEpoch(epochValue)
        } else if let stringValue = try? container.decode(String.self, forKey: .t),
                  let parsedDate = TimeSeriesData.parseEventSeriesDate(stringValue) {
            date = parsedDate
        } else {
            date = Date(timeIntervalSince1970: 0)
        }
    }
}

extension TimeSeriesData {
    static func dateFromEventSeriesEpoch(_ value: Double) -> Date {
        dateFromEpochValue(value)
    }

    static func parseEventSeriesDate(_ value: String) -> Date? {
        parseDateString(value)
    }
}

// Active users endpoint response
struct ActiveUsersResponse: Codable, Sendable {
    let visitors: Int  // Number of active users

    private enum CodingKeys: String, CodingKey {
        case visitors
    }

    init(visitors: Int) {
        self.visitors = visitors
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        visitors = container.decodeFlexibleInt(forKey: .visitors) ?? 0
    }
}

// MARK: - Real-time Data Models

struct RealtimeData: Decodable, Sendable {
    let websiteId: String?
    let timestamp: Int64?
    let pageviews: [RealtimePageview]
    let sessions: Int
    let events: [RealtimeEvent]
    let countries: [String: Int]
    let urls: [String: Int]
    let referrers: [String: Int]
    let series: RealtimeSeries?
    let totals: RealtimeTotals?

    enum CodingKeys: String, CodingKey {
        case websiteId
        case timestamp
        case pageviews
        case urls
        case referrers
        case sessions
        case events
        case countries
        case visitors
        case activeVisitors
        case series
        case totals
    }

    init(
        websiteId: String? = nil,
        timestamp: Int64? = nil,
        pageviews: [RealtimePageview] = [],
        sessions: Int = 0,
        events: [RealtimeEvent] = [],
        countries: [String: Int] = [:],
        urls: [String: Int] = [:],
        referrers: [String: Int] = [:],
        series: RealtimeSeries? = nil,
        totals: RealtimeTotals? = nil
    ) {
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

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        websiteId = try? container.decode(String.self, forKey: .websiteId)
        let decodedTimestamp = Self.decodeTimestamp(container: container, forKey: .timestamp)
        timestamp = decodedTimestamp
        urls = container.decodeFlexibleIntDictionary(forKey: .urls)
        referrers = container.decodeFlexibleIntDictionary(forKey: .referrers)
        series = try? container.decode(RealtimeSeries.self, forKey: .series)
        totals = try? container.decode(RealtimeTotals.self, forKey: .totals)

        let decodedPageviews = (try? container.decode(LossyArray<RealtimePageview>.self, forKey: .pageviews).elements) ?? []
        if decodedPageviews.isEmpty, !urls.isEmpty {
            pageviews = urls
                .sorted { $0.value > $1.value }
                .map { RealtimePageview(url: $0.key, title: "\($0.value) views", timestamp: decodedTimestamp ?? 0, count: $0.value) }
        } else {
            pageviews = decodedPageviews
        }

        events = (try? container.decode(LossyArray<RealtimeEvent>.self, forKey: .events).elements) ?? []
        countries = container.decodeFlexibleIntDictionary(forKey: .countries)

        if let sessionCount = container.decodeFlexibleInt(forKey: .sessions) {
            sessions = sessionCount
        } else if let totalVisitors = totals?.visitors {
            sessions = totalVisitors
        } else if let visitors = container.decodeFlexibleInt(forKey: .visitors) {
            sessions = visitors
        } else if let visitors = container.decodeFlexibleInt(forKey: .activeVisitors) {
            sessions = visitors
        } else {
            sessions = countries.values.reduce(0, +)
        }
    }

    private static func decodeTimestamp(container: KeyedDecodingContainer<CodingKeys>, forKey key: CodingKeys) -> Int64? {
        if let value = try? container.decode(Int64.self, forKey: key) {
            return value
        }
        if let value = try? container.decode(Double.self, forKey: key) {
            return Int64(value.rounded())
        }
        if let value = try? container.decode(String.self, forKey: key) {
            if let numeric = Double(value) {
                return Int64(numeric.rounded())
            }
            if let date = ISO8601DateFormatter().date(from: value) {
                return Int64(date.timeIntervalSince1970 * 1000)
            }
        }
        return nil
    }
}

struct RealtimeTotals: Decodable, Sendable {
    let views: Int?
    let visitors: Int?
    let visits: Int?
    let pageviews: Int?
    let events: Int?
    let countries: Int?

    private enum CodingKeys: String, CodingKey {
        case views
        case visitors
        case visits
        case pageviews
        case events
        case countries
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        views = container.decodeFlexibleInt(forKey: .views)
        visitors = container.decodeFlexibleInt(forKey: .visitors)
        visits = container.decodeFlexibleInt(forKey: .visits)
        pageviews = container.decodeFlexibleInt(forKey: .pageviews)
        events = container.decodeFlexibleInt(forKey: .events)
        countries = container.decodeFlexibleInt(forKey: .countries)
    }
}

struct RealtimePageview: Decodable, Identifiable, Sendable {
    var id: String { url }
    let url: String
    let title: String?
    let timestamp: Int64
    let count: Int?

    private enum CodingKeys: String, CodingKey {
        case url
        case urlPath
        case path
        case title
        case pageTitle
        case timestamp
        case createdAt
        case count
    }

    init(url: String, title: String?, timestamp: Int64, count: Int? = nil) {
        self.url = url
        self.title = title
        self.timestamp = timestamp
        self.count = count
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        url = (try? container.decode(String.self, forKey: .url))
            ?? (try? container.decode(String.self, forKey: .urlPath))
            ?? (try? container.decode(String.self, forKey: .path))
            ?? ""
        title = (try? container.decode(String.self, forKey: .title))
            ?? (try? container.decode(String.self, forKey: .pageTitle))
        timestamp = Self.decodeTimestamp(container: container) ?? 0
        count = container.decodeFlexibleInt(forKey: .count)
    }

    private static func decodeTimestamp(container: KeyedDecodingContainer<CodingKeys>) -> Int64? {
        if let value = try? container.decode(Int64.self, forKey: .timestamp) {
            return value
        }
        if let value = try? container.decode(Double.self, forKey: .timestamp) {
            return Int64(value.rounded())
        }
        if let value = try? container.decode(String.self, forKey: .timestamp),
           let numeric = Double(value) {
            return Int64(numeric.rounded())
        }
        if let createdAt = try? container.decode(String.self, forKey: .createdAt),
           let date = ISO8601DateFormatter().date(from: createdAt) {
            return Int64(date.timeIntervalSince1970 * 1000)
        }
        return nil
    }
}

struct RealtimeSeries: Decodable, Sendable {
    let views: [TimeSeriesData]
    let visitors: [TimeSeriesData]
}

struct RealtimeEvent: Decodable, Identifiable, Sendable {
    var id: String { "\(name)-\(timestamp)" }
    let name: String
    let timestamp: Int64
    let data: [String: JSONValue]?

    private enum CodingKeys: String, CodingKey {
        case type = "__type"
        case name
        case eventName
        case timestamp
        case createdAt
        case data
        case urlPath
        case referrerDomain
    }

    init(name: String, timestamp: Int64, data: [String: JSONValue]? = nil) {
        self.name = name
        self.timestamp = timestamp
        self.data = data
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let eventName = (try? container.decode(String.self, forKey: .eventName)) ?? ""
        let type = (try? container.decode(String.self, forKey: .type)) ?? ""
        let path = (try? container.decode(String.self, forKey: .urlPath)) ?? ""
        name = (try? container.decode(String.self, forKey: .name))
            ?? (!eventName.isEmpty ? eventName : nil)
            ?? (type == "pageview" && !path.isEmpty ? path : nil)
            ?? (!type.isEmpty ? type : nil)
            ?? (!path.isEmpty ? path : nil)
            ?? "Event"
        timestamp = Self.decodeTimestamp(container: container) ?? 0
        data = try? container.decode([String: JSONValue].self, forKey: .data)
    }

    private static func decodeTimestamp(container: KeyedDecodingContainer<CodingKeys>) -> Int64? {
        if let value = try? container.decode(Int64.self, forKey: .timestamp) {
            return value
        }
        if let value = try? container.decode(Double.self, forKey: .timestamp) {
            return Int64(value.rounded())
        }
        if let value = try? container.decode(String.self, forKey: .timestamp) {
            if let numeric = Double(value) {
                return Int64(numeric.rounded())
            }
            if let date = ISO8601DateFormatter().date(from: value) {
                return Int64(date.timeIntervalSince1970 * 1000)
            }
        }
        if let createdAt = try? container.decode(String.self, forKey: .createdAt),
           let date = ISO8601DateFormatter().date(from: createdAt) {
            return Int64(date.timeIntervalSince1970 * 1000)
        }
        return nil
    }
}

private struct LossyArray<Element: Decodable>: Decodable {
    let elements: [Element]

    init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        var values: [Element] = []

        while !container.isAtEnd {
            if let value = try? container.decode(Element.self) {
                values.append(value)
            } else {
                _ = try? container.decode(JSONValue.self)
            }
        }

        elements = values
    }
}

private extension KeyedDecodingContainer {
    func decodeFlexibleInt(forKey key: Key) -> Int? {
        if let value = try? decode(Int.self, forKey: key) {
            return value
        }
        if let value = try? decode(Double.self, forKey: key) {
            return Int(value.rounded())
        }
        if let value = try? decode(String.self, forKey: key),
           let numeric = Double(value) {
            return Int(numeric.rounded())
        }
        if let value = try? decode(JSONValue.self, forKey: key) {
            return value.intValue
        }
        return nil
    }

    func decodeFlexibleIntDictionary(forKey key: Key) -> [String: Int] {
        if let values = try? decode([String: Int].self, forKey: key) {
            return values
        }
        if let values = try? decode([String: Double].self, forKey: key) {
            return values.mapValues { Int($0.rounded()) }
        }
        if let values = try? decode([String: String].self, forKey: key) {
            return values.compactMapValues { Double($0).map { Int($0.rounded()) } }
        }
        if let values = try? decode([String: JSONValue].self, forKey: key) {
            return values.compactMapValues(\.intValue)
        }
        return [:]
    }
}

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
    let createdAt: String

    enum CodingKeys: String, CodingKey {
        case id, name, domain, shareId, userId, teamId, createdAt
    }
}

// Updated to match latest Umami API response structure
struct WebsiteStatsModel: Codable {
    let pageviews: StatValue
    let visitors: StatValue
    let visits: StatValue
    let bounces: StatValue
    let totaltime: StatValue

    var bounceRate: Double {
        guard visits.value > 0 else { return 0 }
        return Double(bounces.value) / Double(visits.value)
    }

    var avgDuration: Double {
        guard pageviews.value > 0 else { return 0 }
        return Double(totaltime.value) / Double(pageviews.value)
    }
}

struct StatValue: Codable {
    let value: Int
    let prev: Int
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
    let count: Int
}

// Updated to match latest Umami API - stats endpoint returns stats directly
struct WebsiteStatsResponse: Codable {
    let pageviews: StatValue
    let visitors: StatValue
    let visits: StatValue
    let bounces: StatValue
    let totaltime: StatValue

    var bounceRate: Double {
        guard visits.value > 0 else { return 0 }
        return Double(bounces.value) / Double(visits.value)
    }

    var avgDuration: Double {
        guard pageviews.value > 0 else { return 0 }
        return Double(totaltime.value) / Double(pageviews.value)
    }
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

        if let milliseconds = try? container.decode(Int64.self, forKey: .x) {
            self.date = Date(timeIntervalSince1970: TimeInterval(milliseconds) / 1000)
        } else if let doubleMilliseconds = try? container.decode(Double.self, forKey: .x) {
            self.date = Date(timeIntervalSince1970: doubleMilliseconds / 1000)
        } else if let stringValue = try? container.decode(String.self, forKey: .x) {
            if let numericValue = Int64(stringValue) {
                self.date = Date(timeIntervalSince1970: TimeInterval(numericValue) / 1000)
            } else {
                let isoFormatter = ISO8601DateFormatter()
                if let parsedDate = isoFormatter.date(from: stringValue) {
                    self.date = parsedDate
                } else {
                    throw DecodingError.dataCorruptedError(
                        forKey: .x,
                        in: container,
                        debugDescription: "Unrecognised timestamp format: \(stringValue)"
                    )
                }
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
}

// Active users endpoint response
struct ActiveUsersResponse: Codable {
    let visitors: Int  // Number of active users
}

// MARK: - Real-time Data Models

struct RealtimeData: Codable {
    let websiteId: String
    let timestamp: Int64
    let pageviews: [RealtimePageview]
    let sessions: Int
    let events: [RealtimeEvent]
    let countries: [String: Int]
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

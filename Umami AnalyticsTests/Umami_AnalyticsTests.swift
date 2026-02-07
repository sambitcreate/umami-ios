//
//  Umami_AnalyticsTests.swift
//  Umami AnalyticsTests
//
//  Created by Sambit Biswas on 4/17/25.
//

import Foundation
import Testing
@testable import Umami_Analytics

struct Umami_AnalyticsTests {

    @Test func websiteStatsDecodesFlatPayload() throws {
        let json = """
        {
          "pageviews": 120,
          "visitors": 80,
          "visits": 95,
          "bounces": 30,
          "totaltime": 2400
        }
        """.data(using: .utf8)!

        let decoded = try JSONDecoder().decode(WebsiteStatsResponse.self, from: json)

        #expect(decoded.pageviews == 120)
        #expect(decoded.visitors == 80)
        #expect(decoded.visits == 95)
        #expect(decoded.bounces == 30)
        #expect(decoded.totaltime == 2400)
    }

    @Test func websiteStatsDecodesNestedMetricPayload() throws {
        let json = """
        {
          "pageviews": { "value": 120, "prev": 90 },
          "visitors": { "value": 80, "prev": 70 },
          "visits": { "value": 95, "prev": 88 },
          "bounces": { "value": 30, "prev": 26 },
          "totaltime": { "value": 2400, "prev": 2000 }
        }
        """.data(using: .utf8)!

        let decoded = try JSONDecoder().decode(WebsiteStatsResponse.self, from: json)

        #expect(decoded.pageviews == 120)
        #expect(decoded.visitors == 80)
        #expect(decoded.visits == 95)
        #expect(decoded.bounces == 30)
        #expect(decoded.totaltime == 2400)
    }

    @Test func metricValueDecodesNumberAndObject() throws {
        let intJSON = "42".data(using: .utf8)!
        let objectJSON = "{\"value\": 50, \"prev\": 30}".data(using: .utf8)!

        let intMetric = try JSONDecoder().decode(MetricValue.self, from: intJSON)
        let objectMetric = try JSONDecoder().decode(MetricValue.self, from: objectJSON)

        #expect(intMetric.value == 42)
        #expect(intMetric.prev == nil)
        #expect(objectMetric.value == 50)
        #expect(objectMetric.prev == 30)
    }

    @Test func filterValueDecodesStringAndObject() throws {
        let stringJSON = "\"Chrome\"".data(using: .utf8)!
        let objectJSON = "{\"x\":\"Safari\",\"y\":10}".data(using: .utf8)!

        let stringValue = try JSONDecoder().decode(FilterValue.self, from: stringJSON)
        let objectValue = try JSONDecoder().decode(FilterValue.self, from: objectJSON)

        #expect(stringValue.value == "Chrome")
        #expect(stringValue.count == nil)
        #expect(objectValue.value == "Safari")
        #expect(objectValue.count == 10)
    }

    @Test func paginatedResponseDecodesObjectAndArray() throws {
        let objectJSON = """
        {
          "data": [{ "id": "1", "name": "signup", "count": 2 }],
          "count": 4,
          "page": 1,
          "pageSize": 1
        }
        """.data(using: .utf8)!

        let arrayJSON = """
        [{ "id": "2", "name": "purchase", "count": 1 }]
        """.data(using: .utf8)!

        let objectPage = try JSONDecoder().decode(PaginatedResponse<AnalyticsRecord>.self, from: objectJSON)
        let arrayPage = try JSONDecoder().decode(PaginatedResponse<AnalyticsRecord>.self, from: arrayJSON)

        #expect(objectPage.data.count == 1)
        #expect(objectPage.count == 4)
        #expect(arrayPage.data.count == 1)
        #expect(arrayPage.count == 1)
    }

    @Test func timeSeriesDataDecodesNumericIsoAndSqlTimestamps() throws {
        let numericJSON = "{\"x\": 1730400000000, \"y\": 4}".data(using: .utf8)!
        let isoJSON = "{\"x\": \"2024-11-01T00:00:00Z\", \"y\": 6}".data(using: .utf8)!
        let sqlJSON = "{\"x\": \"2026-02-06 06:00:00\", \"y\": 8}".data(using: .utf8)!

        let numeric = try JSONDecoder().decode(TimeSeriesData.self, from: numericJSON)
        let iso = try JSONDecoder().decode(TimeSeriesData.self, from: isoJSON)
        let sql = try JSONDecoder().decode(TimeSeriesData.self, from: sqlJSON)

        #expect(numeric.value == 4)
        #expect(iso.value == 6)
        #expect(sql.value == 8)
        #expect(numeric.date.timeIntervalSince1970 > 0)
        #expect(iso.date.timeIntervalSince1970 > 0)
        #expect(sql.date.timeIntervalSince1970 > 0)
    }

    @Test func weeklySessionPointDecodesMultipleShapes() throws {
        let xyJSON = "{\"x\": 1730400000000, \"y\": 12}".data(using: .utf8)!
        let dayJSON = "{\"day\": \"2024-11-01\", \"value\": 8}".data(using: .utf8)!
        let dateJSON = "{\"date\": \"2024-11-02T00:00:00Z\", \"sessions\": 9}".data(using: .utf8)!

        let xy = try JSONDecoder().decode(WeeklySessionPoint.self, from: xyJSON)
        let day = try JSONDecoder().decode(WeeklySessionPoint.self, from: dayJSON)
        let date = try JSONDecoder().decode(WeeklySessionPoint.self, from: dateJSON)

        #expect(xy.value == 12)
        #expect(day.value == 8)
        #expect(date.value == 9)
    }

    @Test func analyticsRecordUsesDeterministicDisplayFields() throws {
        let json = """
        {
          "eventName": "signup",
          "url": "/pricing",
          "sessionId": "abc123",
          "count": 7,
          "timestamp": 1730400000000
        }
        """.data(using: .utf8)!

        let record = try JSONDecoder().decode(AnalyticsRecord.self, from: json)

        #expect(record.eventPrimaryText == "signup")
        #expect(record.eventSecondaryText == "/pricing")
        #expect(record.sessionPrimaryText == "abc123")
        #expect(record.metricValue == 7)
        #expect(record.timestampDate != nil)
    }
}

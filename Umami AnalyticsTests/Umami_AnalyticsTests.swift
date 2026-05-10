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
        let nullJSON = "null".data(using: .utf8)!

        let intMetric = try JSONDecoder().decode(MetricValue.self, from: intJSON)
        let objectMetric = try JSONDecoder().decode(MetricValue.self, from: objectJSON)
        let nullMetric = try JSONDecoder().decode(MetricValue.self, from: nullJSON)

        #expect(intMetric.value == 42)
        #expect(intMetric.prev == nil)
        #expect(objectMetric.value == 50)
        #expect(objectMetric.prev == 30)
        #expect(nullMetric.value == 0)
        #expect(nullMetric.prev == nil)
    }

    @Test func filterValueDecodesStringAndObject() throws {
        let stringJSON = "\"Chrome\"".data(using: .utf8)!
        let objectJSON = "{\"x\":\"Safari\",\"y\":10}".data(using: .utf8)!
        let documentedEventDataJSON = "{\"propertyName\":\"age\",\"dataType\":2,\"value\":\"33\",\"total\":4}".data(using: .utf8)!

        let stringValue = try JSONDecoder().decode(FilterValue.self, from: stringJSON)
        let objectValue = try JSONDecoder().decode(FilterValue.self, from: objectJSON)
        let documentedEventDataValue = try JSONDecoder().decode(FilterValue.self, from: documentedEventDataJSON)

        #expect(stringValue.value == "Chrome")
        #expect(stringValue.count == nil)
        #expect(objectValue.value == "Safari")
        #expect(objectValue.count == 10)
        #expect(documentedEventDataValue.value == "33")
        #expect(documentedEventDataValue.count == 4)
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
        let eventSeriesJSON = "{\"x\": \"signup\", \"t\": \"2024-11-01T00:00:00Z\", \"y\": 9}".data(using: .utf8)!

        let numeric = try JSONDecoder().decode(TimeSeriesData.self, from: numericJSON)
        let iso = try JSONDecoder().decode(TimeSeriesData.self, from: isoJSON)
        let sql = try JSONDecoder().decode(TimeSeriesData.self, from: sqlJSON)
        let eventSeries = try JSONDecoder().decode(TimeSeriesData.self, from: eventSeriesJSON)

        #expect(numeric.value == 4)
        #expect(iso.value == 6)
        #expect(sql.value == 8)
        #expect(eventSeries.value == 9)
        #expect(numeric.date.timeIntervalSince1970 > 0)
        #expect(iso.date.timeIntervalSince1970 > 0)
        #expect(sql.date.timeIntervalSince1970 > 0)
        #expect(eventSeries.date.timeIntervalSince1970 > 0)
    }

    @Test func weeklySessionPointDecodesMultipleShapes() throws {
        let xyJSON = "{\"x\": 1730400000000, \"y\": 12}".data(using: .utf8)!
        let dayJSON = "{\"day\": \"2024-11-01\", \"value\": 8}".data(using: .utf8)!
        let dateJSON = "{\"date\": \"2024-11-02T00:00:00Z\", \"sessions\": 9}".data(using: .utf8)!
        let tupleJSON = "[1730400000000, 11]".data(using: .utf8)!

        let xy = try JSONDecoder().decode(WeeklySessionPoint.self, from: xyJSON)
        let day = try JSONDecoder().decode(WeeklySessionPoint.self, from: dayJSON)
        let date = try JSONDecoder().decode(WeeklySessionPoint.self, from: dateJSON)
        let tuple = try JSONDecoder().decode(WeeklySessionPoint.self, from: tupleJSON)

        #expect(xy.value == 12)
        #expect(day.value == 8)
        #expect(date.value == 9)
        #expect(tuple.value == 11)
    }

    @Test func weeklySessionsResponseDecodesArrayAndWrappedRecords() throws {
        let arrayJSON = """
        [
          { "x": 1730400000000, "y": 4 },
          { "x": 1730403600000, "y": 6 }
        ]
        """.data(using: .utf8)!

        let wrappedJSON = """
        {
          "records": [
            { "x": 1730400000000, "y": 5 }
          ]
        }
        """.data(using: .utf8)!
        let matrixJSON = """
        [
          [0, 1, 2],
          [3, 4, 5]
        ]
        """.data(using: .utf8)!

        let arrayResponse = try JSONDecoder().decode(WeeklySessionsResponse.self, from: arrayJSON)
        let wrappedResponse = try JSONDecoder().decode(WeeklySessionsResponse.self, from: wrappedJSON)
        let matrixResponse = try JSONDecoder().decode(WeeklySessionsResponse.self, from: matrixJSON)

        #expect(arrayResponse.data.count == 2)
        #expect(wrappedResponse.data.count == 1)
        #expect(matrixResponse.data.map(\.value) == [0, 1, 2, 3, 4, 5])
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

    @Test func realtimeDataDecodesCurrentRealtimePayload() throws {
        let json = """
        {
          "countries": { "US": 9, "IN": 3 },
          "urls": { "/": 43, "/docs": 4 },
          "referrers": { "umami.is": 31 },
          "events": [
            {
              "__type": "pageview",
              "sessionId": "abc",
              "eventName": "",
              "createdAt": "2025-10-22T00:15:29Z",
              "urlPath": "/docs/attribution"
            },
            {
              "__type": "custom",
              "sessionId": "def",
              "eventName": "signup",
              "createdAt": "2025-10-22T00:15:17Z"
            }
          ],
          "series": {
            "views": [{ "x": "2025-10-21T23:45:00Z", "y": 5 }],
            "visitors": [{ "x": "2025-10-21T23:45:00Z", "y": 3 }]
          },
          "totals": { "views": 69, "visitors": 42, "events": 12, "countries": 15 },
          "timestamp": 1761092151944
        }
        """.data(using: .utf8)!

        let decoded = try JSONDecoder().decode(RealtimeData.self, from: json)

        #expect(decoded.sessions == 42)
        #expect(decoded.pageviews.first?.url == "/")
        #expect(decoded.pageviews.first?.count == 43)
        #expect(decoded.events.map(\.name) == ["pageview", "signup"])
        #expect(decoded.events.allSatisfy { $0.timestamp > 0 })
        #expect(decoded.series?.views.first?.value == 5)
        #expect(decoded.referrers["umami.is"] == 31)
    }

    @Test func eventDataStatsDecodesDocumentedArrayPayload() throws {
        let json = """
        [
          {
            "events": 16,
            "properties": 13,
            "records": 26
          }
        ]
        """.data(using: .utf8)!

        let decoded = try JSONDecoder().decode(MetricMapResponse.self, from: json)

        #expect(decoded.metrics["events"]?.value == 16)
        #expect(decoded.metrics["properties"]?.value == 13)
        #expect(decoded.metrics["records"]?.value == 26)
    }

    @Test func eventStatsResponseDecodesWrappedPayload() throws {
        let json = """
        {
          "data": {
            "events": 753,
            "visitors": 607,
            "visits": 687,
            "uniqueEvents": 8,
            "comparison": {
              "events": 1809,
              "visitors": 1374
            }
          }
        }
        """.data(using: .utf8)!

        let decoded = try JSONDecoder().decode(EventStatsResponse.self, from: json)

        #expect(decoded.data["events"]?.value == 753)
        #expect(decoded.data["uniqueEvents"]?.value == 8)
        #expect(decoded.comparison?["events"]?.value == 1809)
    }

    @Test func sessionPropertiesDecodeDocumentedArrayPayload() throws {
        let json = """
        [
          {
            "dataKey": "email",
            "dataType": 1,
            "stringValue": "member@example.com",
            "numberValue": null,
            "dateValue": null
          },
          {
            "dataKey": "score",
            "dataType": 2,
            "stringValue": null,
            "numberValue": 42,
            "dateValue": null
          }
        ]
        """.data(using: .utf8)!

        let decoded = try JSONDecoder().decode(SessionPropertiesResponse.self, from: json)

        #expect(decoded.properties["email"] == .string("member@example.com"))
        #expect(decoded.properties["score"] == .number(42))
    }

    @Test func currentUserResponseDecodesWrappedAndDirectPayloads() throws {
        let wrappedJSON = """
        {
          "token": "token",
          "authKey": "auth:token",
          "user": {
            "id": "user-1",
            "username": "member",
            "role": "user",
            "createdAt": "2025-10-08T18:03:19.823Z",
            "isAdmin": false
          }
        }
        """.data(using: .utf8)!

        let directJSON = """
        {
          "id": "user-2",
          "username": "admin",
          "role": "admin"
        }
        """.data(using: .utf8)!

        let wrapped = try JSONDecoder().decode(CurrentUserResponse.self, from: wrappedJSON)
        let direct = try JSONDecoder().decode(CurrentUserResponse.self, from: directJSON)

        #expect(wrapped.user.id == "user-1")
        #expect(wrapped.user.isAdmin == false)
        #expect(direct.user.id == "user-2")
        #expect(direct.user.isAdmin == true)
    }
}

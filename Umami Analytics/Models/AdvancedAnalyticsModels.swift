import Foundation

enum WebsiteDetailTab: String, CaseIterable, Identifiable, Sendable {
    case overview
    case audience
    case events
    case sessions
    case realtime

    var id: String { rawValue }

    var title: String {
        switch self {
        case .overview:
            return "Overview"
        case .audience:
            return "Audience"
        case .events:
            return "Events"
        case .sessions:
            return "Sessions"
        case .realtime:
            return "Realtime"
        }
    }
}

enum AnalyticsComparison: String, CaseIterable, Identifiable, Codable, Sendable {
    case none
    case previous = "prev"
    case yearOverYear = "yoy"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .none:
            return "None"
        case .previous:
            return "Previous Period"
        case .yearOverYear:
            return "Year over Year"
        }
    }

    var queryValue: String? {
        switch self {
        case .none:
            return nil
        case .previous, .yearOverYear:
            return rawValue
        }
    }
}

enum AnalyticsFilterKey: String, CaseIterable, Identifiable, Codable, Sendable {
    case path
    case referrer
    case title
    case query
    case browser
    case os
    case device
    case country
    case region
    case city
    case language
    case hostname
    case event
    case tag
    case segment
    case cohort

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .path:
            return "Path"
        case .referrer:
            return "Referrer"
        case .title:
            return "Title"
        case .query:
            return "Query"
        case .browser:
            return "Browser"
        case .os:
            return "OS"
        case .device:
            return "Device"
        case .country:
            return "Country"
        case .region:
            return "Region"
        case .city:
            return "City"
        case .language:
            return "Language"
        case .hostname:
            return "Hostname"
        case .event:
            return "Event"
        case .tag:
            return "Tag"
        case .segment:
            return "Segment"
        case .cohort:
            return "Cohort"
        }
    }
}

struct AnalyticsQueryOptions: Codable, Equatable, Sendable {
    static let `default` = AnalyticsQueryOptions()

    var compare: AnalyticsComparison = .none
    var filters: [AnalyticsFilterKey: String] = [:]

    var hasActiveSelections: Bool {
        compare != .none || !filters.isEmpty
    }

    var activeFilters: [(key: AnalyticsFilterKey, value: String)] {
        filters
            .compactMap { key, value in
                let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !trimmed.isEmpty else { return nil }
                return (key, trimmed)
            }
            .sorted { $0.key.displayName < $1.key.displayName }
    }

    var cacheKey: String {
        let compareKey = Self.cacheComponent(compare.rawValue)
        let filterKey = activeFilters
            .map { "\(Self.cacheComponent($0.key.rawValue))=\(Self.cacheComponent($0.value))" }
            .joined(separator: "&")
        return "\(compareKey)|\(filterKey)"
    }

    var queryItems: [URLQueryItem] {
        comparisonQueryItems + filterQueryItems
    }

    var comparisonQueryItems: [URLQueryItem] {
        var items: [URLQueryItem] = []

        if let compareValue = compare.queryValue {
            items.append(URLQueryItem(name: "compare", value: compareValue))
        }

        return items
    }

    var filterQueryItems: [URLQueryItem] {
        var items: [URLQueryItem] = []

        for filter in activeFilters {
            items.append(URLQueryItem(name: filter.key.rawValue, value: filter.value))
        }

        return items
    }

    mutating func setFilter(_ key: AnalyticsFilterKey, value: String?) {
        let trimmed = value?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if trimmed.isEmpty {
            filters.removeValue(forKey: key)
        } else {
            filters[key] = trimmed
        }
    }

    private static func cacheComponent(_ value: String) -> String {
        Data(value.utf8)
            .base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }
}

enum MetricDimension: String, CaseIterable, Identifiable, Sendable {
    case url
    case referrer
    case browser
    case os
    case device
    case country
    case event

    var id: String { rawValue }

    var title: String {
        switch self {
        case .url:
            return "Pages"
        case .referrer:
            return "Referrers"
        case .browser:
            return "Browsers"
        case .os:
            return "Operating Systems"
        case .device:
            return "Devices"
        case .country:
            return "Countries"
        case .event:
            return "Events"
        }
    }
}

struct MetricValue: Decodable, Equatable, Sendable {
    let value: Int
    let prev: Int?

    init(value: Int, prev: Int? = nil) {
        self.value = value
        self.prev = prev
    }

    private enum CodingKeys: String, CodingKey {
        case value
        case prev
    }

    init(from decoder: Decoder) throws {
        if let singleValue = try? decoder.singleValueContainer() {
            if singleValue.decodeNil() {
                self.value = 0
                self.prev = nil
                return
            }

            if let intValue = try? singleValue.decode(Int.self) {
                self.value = intValue
                self.prev = nil
                return
            }

            if let doubleValue = try? singleValue.decode(Double.self) {
                self.value = Int(doubleValue.rounded())
                self.prev = nil
                return
            }

            if let stringValue = try? singleValue.decode(String.self),
               let numeric = Double(stringValue) {
                self.value = Int(numeric.rounded())
                self.prev = nil
                return
            }
        }

        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.value = Self.decodeInt(in: container, forKey: .value) ?? 0
        self.prev = Self.decodeInt(in: container, forKey: .prev)
    }

    private static func decodeInt(in container: KeyedDecodingContainer<CodingKeys>, forKey key: CodingKeys) -> Int? {
        if let intValue = try? container.decode(Int.self, forKey: key) {
            return intValue
        }
        if let doubleValue = try? container.decode(Double.self, forKey: key) {
            return Int(doubleValue.rounded())
        }
        if let stringValue = try? container.decode(String.self, forKey: key),
           let numeric = Double(stringValue) {
            return Int(numeric.rounded())
        }
        return nil
    }
}

struct FilterValue: Decodable, Identifiable, Equatable, Sendable {
    let value: String
    let label: String?
    let count: Int?
    let eventName: String?

    var id: String {
        if let eventName {
            return "\(eventName)|\(value)|\(label ?? "")"
        }
        if let label {
            return "\(value)|\(label)"
        }
        return value
    }

    var displayText: String {
        label ?? value
    }

    init(value: String, label: String? = nil, count: Int? = nil, eventName: String? = nil) {
        self.value = value
        self.label = label
        self.count = count
        self.eventName = eventName
    }

    init(from decoder: Decoder) throws {
        if let singleValue = try? decoder.singleValueContainer() {
            if let stringValue = try? singleValue.decode(String.self) {
                self.value = stringValue
                self.label = nil
                self.count = nil
                self.eventName = nil
                return
            }

            if let intValue = try? singleValue.decode(Int.self) {
                self.value = String(intValue)
                self.label = nil
                self.count = nil
                self.eventName = nil
                return
            }
        }

        let container = try decoder.container(keyedBy: DynamicCodingKey.self)

        let valueKeys = ["value", "x", "name", "id", "event", "eventName", "propertyName", "property", "dataKey", "label"]
        let labelKeys = ["label", "name", "title", "eventName", "propertyName", "dataKey"]
        let countKeys = ["count", "total", "y", "valueCount", "visitors", "sessions", "pageviews"]

        let decodedValue = Self.decodeString(container: container, keys: valueKeys) ?? ""
        self.value = decodedValue
        self.eventName = Self.decodeString(container: container, keys: ["eventName", "event"])

        let decodedLabel = Self.decodeString(container: container, keys: labelKeys)
        self.label = decodedLabel == decodedValue ? nil : decodedLabel

        self.count = Self.decodeInt(container: container, keys: countKeys)
    }

    private static func decodeString(container: KeyedDecodingContainer<DynamicCodingKey>, keys: [String]) -> String? {
        for key in keys {
            let codingKey = DynamicCodingKey(key)
            if let value = try? container.decode(String.self, forKey: codingKey) {
                return value
            }
            if let intValue = try? container.decode(Int.self, forKey: codingKey) {
                return String(intValue)
            }
            if let doubleValue = try? container.decode(Double.self, forKey: codingKey) {
                return String(doubleValue)
            }
        }
        return nil
    }

    private static func decodeInt(container: KeyedDecodingContainer<DynamicCodingKey>, keys: [String]) -> Int? {
        for key in keys {
            let codingKey = DynamicCodingKey(key)
            if let value = try? container.decode(Int.self, forKey: codingKey) {
                return value
            }
            if let value = try? container.decode(Double.self, forKey: codingKey) {
                return Int(value.rounded())
            }
            if let value = try? container.decode(String.self, forKey: codingKey),
               let intValue = Int(value) {
                return intValue
            }
        }
        return nil
    }
}

struct EventDataPropertyValue: Decodable, Sendable {
    let filterValue: FilterValue

    private enum CodingKeys: String, CodingKey {
        case eventName
        case propertyName
        case total
        case count
        case y
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let propertyName = Self.decodeString(container: container, forKey: .propertyName) ?? ""
        let eventName = Self.decodeString(container: container, forKey: .eventName)
        let label = eventName
            .flatMap { $0.isEmpty ? nil : "\($0) - \(propertyName)" }

        filterValue = FilterValue(
            value: propertyName,
            label: label == propertyName ? nil : label,
            count: Self.decodeInt(container: container, keys: [.total, .count, .y]),
            eventName: eventName
        )
    }

    private static func decodeString(container: KeyedDecodingContainer<CodingKeys>, forKey key: CodingKeys) -> String? {
        if let value = try? container.decode(String.self, forKey: key) {
            return value
        }
        if let value = try? container.decode(Int.self, forKey: key) {
            return String(value)
        }
        if let value = try? container.decode(Double.self, forKey: key) {
            return String(value)
        }
        return nil
    }

    private static func decodeInt(container: KeyedDecodingContainer<CodingKeys>, keys: [CodingKeys]) -> Int? {
        for key in keys {
            if let value = try? container.decode(Int.self, forKey: key) {
                return value
            }
            if let value = try? container.decode(Double.self, forKey: key) {
                return Int(value.rounded())
            }
            if let value = try? container.decode(String.self, forKey: key),
               let numeric = Double(value) {
                return Int(numeric.rounded())
            }
        }
        return nil
    }
}

enum JSONValue: Decodable, Equatable, Sendable {
    case string(String)
    case number(Double)
    case bool(Bool)
    case object([String: JSONValue])
    case array([JSONValue])
    case null

    init(from decoder: Decoder) throws {
        if let container = try? decoder.singleValueContainer() {
            if container.decodeNil() {
                self = .null
                return
            }
            if let value = try? container.decode(Bool.self) {
                self = .bool(value)
                return
            }
            if let value = try? container.decode(Double.self) {
                self = .number(value)
                return
            }
            if let value = try? container.decode(String.self) {
                self = .string(value)
                return
            }
        }

        if let object = try? [String: JSONValue](from: decoder) {
            self = .object(object)
            return
        }

        if let array = try? [JSONValue](from: decoder) {
            self = .array(array)
            return
        }

        self = .null
    }

    var stringValue: String? {
        switch self {
        case .string(let value):
            return value
        case .number(let value):
            return NumberFormatter.localizedString(from: NSNumber(value: value), number: .decimal)
        case .bool(let value):
            return String(value)
        case .null:
            return nil
        case .object, .array:
            return nil
        }
    }

    var intValue: Int? {
        switch self {
        case .number(let value):
            return Int(value.rounded())
        case .string(let value):
            return Double(value).map { Int($0.rounded()) }
        default:
            return nil
        }
    }
}

struct AnalyticsRecord: Decodable, Identifiable, Equatable, Sendable {
    let fields: [String: JSONValue]
    let id: String

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: DynamicCodingKey.self)
        var decodedFields: [String: JSONValue] = [:]

        for key in container.allKeys {
            decodedFields[key.stringValue] = try? container.decode(JSONValue.self, forKey: key)
        }

        self.fields = decodedFields
        self.id = Self.resolveID(fields: decodedFields)
    }

    private static func resolveID(fields: [String: JSONValue]) -> String {
        let idKeys = ["id", "sessionId", "eventId", "visitId"]
        for key in idKeys {
            if let raw = fields[key]?.stringValue, !raw.isEmpty {
                return raw
            }
        }

        let fallbackParts = [
            fields["timestamp"]?.stringValue,
            fields["createdAt"]?.stringValue,
            fields["eventName"]?.stringValue,
            fields["url"]?.stringValue,
            fields["urlPath"]?.stringValue,
            fields["pageTitle"]?.stringValue,
            fields["sessionId"]?.stringValue
        ].compactMap { $0 }

        if !fallbackParts.isEmpty {
            return fallbackParts.joined(separator: "|")
        }

        return UUID().uuidString
    }

    func stringValue(for keys: [String]) -> String? {
        for key in keys {
            if let value = fields[key]?.stringValue, !value.isEmpty {
                return value
            }
        }
        return nil
    }

    func intValue(for keys: [String]) -> Int? {
        for key in keys {
            if let value = fields[key]?.intValue {
                return value
            }
        }
        return nil
    }

    // Event list display precedence is fixed to keep rendering deterministic across payload variants.
    var eventPrimaryText: String {
        stringValue(for: ["eventName", "event", "name", "pageTitle", "title", "urlPath", "url", "path", "id"]) ?? "Unknown event"
    }

    var eventSecondaryText: String? {
        stringValue(for: ["urlPath", "url", "path", "pathname", "pageTitle", "referrerPath", "referrerDomain", "referrer", "browser", "country", "sessionId"])
    }

    // Session list display precedence is fixed to avoid UI jumps between endpoints.
    var sessionPrimaryText: String {
        stringValue(for: ["sessionId", "id", "hostname", "url", "path", "browser", "device"]) ?? "Session"
    }

    var sessionSecondaryText: String? {
        stringValue(for: ["browser", "os", "device", "country", "referrer", "hostname", "url"])
    }

    var metricValue: Int? {
        intValue(for: ["value", "count", "visitors", "sessions", "pageviews", "events"])
    }

    var timestampDate: Date? {
        if let millis = intValue(for: ["x", "timestamp", "createdAt", "updatedAt", "date"]) {
            return Date(timeIntervalSince1970: TimeInterval(millis) / 1000)
        }

        if let iso = stringValue(for: ["date", "createdAt", "updatedAt", "timestamp"]) {
            let formatter = ISO8601DateFormatter()
            return formatter.date(from: iso)
        }

        return nil
    }
}

struct WeeklySessionPoint: Decodable, Identifiable, Equatable, Sendable {
    let date: Date
    let value: Int

    var id: Date { date }

    private enum CodingKeys: String, CodingKey {
        case x
        case y
        case day
        case date
        case value
        case sessions
    }

    init(date: Date, value: Int) {
        self.date = date
        self.value = value
    }

    init(from decoder: Decoder) throws {
        if var unkeyed = try? decoder.unkeyedContainer() {
            let firstNumber = try? unkeyed.decode(Double.self)
            let firstString = firstNumber == nil ? (try? unkeyed.decode(String.self)) : nil

            if let firstNumber {
                date = Self.dateFromEpochValue(firstNumber)
            } else if let firstString, let parsedDate = Self.parseDateString(firstString) {
                date = parsedDate
            } else {
                date = Date(timeIntervalSince1970: 0)
            }

            if let secondInt = try? unkeyed.decode(Int.self) {
                value = secondInt
            } else if let secondDouble = try? unkeyed.decode(Double.self) {
                value = Int(secondDouble.rounded())
            } else if let secondString = try? unkeyed.decode(String.self),
                      let intValue = Int(secondString) {
                value = intValue
            } else {
                value = 0
            }
            return
        }

        let container = try decoder.container(keyedBy: CodingKeys.self)

        if let y = try? container.decode(Int.self, forKey: .y) {
            value = y
        } else if let y = try? container.decode(Double.self, forKey: .y) {
            value = Int(y.rounded())
        } else if let value = try? container.decode(Int.self, forKey: .value) {
            self.value = value
        } else if let sessions = try? container.decode(Int.self, forKey: .sessions) {
            self.value = sessions
        } else {
            self.value = 0
        }

        if let millis = try? container.decode(Int64.self, forKey: .x) {
            date = Self.dateFromEpochValue(Double(millis))
        } else if let xString = try? container.decode(String.self, forKey: .x),
                  let parsedDate = Self.parseDateString(xString) {
            date = parsedDate
        } else if let day = try? container.decode(String.self, forKey: .day) {
            date = Self.parseDateString(day) ?? Date(timeIntervalSince1970: 0)
        } else if let dateString = try? container.decode(String.self, forKey: .date) {
            date = Self.parseDateString(dateString) ?? Date(timeIntervalSince1970: 0)
        } else if let millis = try? container.decode(Double.self, forKey: .date) {
            date = Self.dateFromEpochValue(millis)
        } else {
            date = Date(timeIntervalSince1970: 0)
        }
    }

    private static func dateFromEpochValue(_ value: Double) -> Date {
        let seconds = abs(value) > 9_999_999_999 ? value / 1000 : value
        return Date(timeIntervalSince1970: seconds)
    }

    private static func parseDateString(_ value: String) -> Date? {
        if let number = Double(value) {
            return dateFromEpochValue(number)
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

struct WeeklySessionsResponse: Decodable, Sendable {
    let data: [WeeklySessionPoint]

    private enum CodingKeys: String, CodingKey {
        case data
        case items
        case results
        case records
    }

    init(from decoder: Decoder) throws {
        if let singleValue = try? decoder.singleValueContainer(),
           let matrix = try? singleValue.decode([[Int]].self) {
            data = Self.points(from: matrix)
            return
        }

        if let singleValue = try? decoder.singleValueContainer(),
           let array = try? singleValue.decode([WeeklySessionPoint].self) {
            data = array
            return
        }

        let container = try decoder.container(keyedBy: CodingKeys.self)

        if let direct = try? container.decode([WeeklySessionPoint].self, forKey: .data) {
            data = direct
        } else if let items = try? container.decode([WeeklySessionPoint].self, forKey: .items) {
            data = items
        } else if let results = try? container.decode([WeeklySessionPoint].self, forKey: .results) {
            data = results
        } else if let records = try? container.decode([WeeklySessionPoint].self, forKey: .records) {
            data = records
        } else {
            data = []
        }
    }

    private static func points(from matrix: [[Int]]) -> [WeeklySessionPoint] {
        let calendar = Calendar(identifier: .gregorian)
        let baseDate = calendar.startOfDay(for: Date(timeIntervalSince1970: 0))

        return matrix.enumerated().flatMap { dayOffset, hourlyValues in
            hourlyValues.enumerated().map { hourOffset, value in
                let dayDate = calendar.date(byAdding: .day, value: dayOffset, to: baseDate) ?? baseDate
                let hourDate = calendar.date(byAdding: .hour, value: hourOffset, to: dayDate) ?? dayDate
                return WeeklySessionPoint(date: hourDate, value: value)
            }
        }
    }
}

struct MetricMapResponse: Decodable, Sendable {
    let metrics: [String: MetricValue]

    init(from decoder: Decoder) throws {
        if let dictionary = try? [String: MetricValue](from: decoder) {
            metrics = dictionary
            return
        }

        if let records = try? [AnalyticsRecord](from: decoder),
           let first = records.first {
            metrics = first.fields.compactMapValues { value in
                switch value {
                case .number(let number):
                    return MetricValue(value: Int(number.rounded()))
                case .string(let string):
                    guard let intValue = Int(string) else { return nil }
                    return MetricValue(value: intValue)
                default:
                    return nil
                }
            }
            return
        }

        if let paginated = try? PaginatedResponse<AnalyticsRecord>(from: decoder),
           let first = paginated.data.first {
            metrics = first.fields.compactMapValues { value in
                switch value {
                case .number(let number):
                    return MetricValue(value: Int(number.rounded()))
                case .string(let string):
                    guard let intValue = Int(string) else { return nil }
                    return MetricValue(value: intValue)
                default:
                    return nil
                }
            }
            return
        }

        metrics = [:]
    }
}

struct EventStatsResponse: Decodable, Sendable {
    let data: [String: MetricValue]
    let comparison: [String: MetricValue]?

    private enum CodingKeys: String, CodingKey {
        case data
        case comparison
    }

    init(from decoder: Decoder) throws {
        if let container = try? decoder.container(keyedBy: CodingKeys.self),
           container.contains(.data) {
            if let nestedValues = try? container.decode([String: JSONValue].self, forKey: .data) {
                data = Self.metricValues(from: nestedValues.filter { $0.key != "comparison" })
                if case .object(let comparisonValues) = nestedValues["comparison"] {
                    comparison = Self.metricValues(from: comparisonValues)
                } else {
                    comparison = try? container.decode(MetricMapResponse.self, forKey: .comparison).metrics
                }
            } else {
                let nested = try container.decode(MetricMapResponse.self, forKey: .data)
                data = nested.metrics
                comparison = try? container.decode(MetricMapResponse.self, forKey: .comparison).metrics
            }
        } else {
            let direct = try MetricMapResponse(from: decoder)
            data = direct.metrics
            comparison = nil
        }
    }

    private static func metricValues(from values: [String: JSONValue]) -> [String: MetricValue] {
        values.compactMapValues { value in
            switch value {
            case .number(let number):
                return MetricValue(value: Int(number.rounded()))
            case .string(let string):
                guard let intValue = Int(string) else { return nil }
                return MetricValue(value: intValue)
            case .object(let object):
                if let metric = object["value"]?.intValue {
                    return MetricValue(value: metric, prev: object["prev"]?.intValue)
                }
                return nil
            default:
                return nil
            }
        }
    }
}

struct EventDataEventPropertyRow: Decodable, Sendable {
    let eventName: String
    let propertyName: String?
    let total: Int

    private enum CodingKeys: String, CodingKey {
        case eventName
        case propertyName
        case total
        case count
        case y
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        eventName = Self.decodeString(container: container, forKey: .eventName) ?? ""
        propertyName = Self.decodeString(container: container, forKey: .propertyName)
        total = Self.decodeInt(container: container, keys: [.total, .count, .y]) ?? 0
    }

    private static func decodeString(container: KeyedDecodingContainer<CodingKeys>, forKey key: CodingKeys) -> String? {
        if let value = try? container.decode(String.self, forKey: key) {
            return value
        }
        if let value = try? container.decode(Int.self, forKey: key) {
            return String(value)
        }
        if let value = try? container.decode(Double.self, forKey: key) {
            return String(value)
        }
        return nil
    }

    private static func decodeInt(container: KeyedDecodingContainer<CodingKeys>, keys: [CodingKeys]) -> Int? {
        for key in keys {
            if let value = try? container.decode(Int.self, forKey: key) {
                return value
            }
            if let value = try? container.decode(Double.self, forKey: key) {
                return Int(value.rounded())
            }
            if let value = try? container.decode(String.self, forKey: key),
               let numeric = Double(value) {
                return Int(numeric.rounded())
            }
        }
        return nil
    }
}

struct EventDataStatsResponse: Decodable, Sendable {
    let values: [String: MetricValue]

    init(from decoder: Decoder) throws {
        if let singleValue = try? decoder.singleValueContainer(),
           let dictionary = try? singleValue.decode([String: MetricValue].self) {
            values = dictionary
            return
        }

        if let singleValue = try? decoder.singleValueContainer(),
           let rows = try? singleValue.decode([[String: MetricValue]].self) {
            values = rows.first ?? [:]
            return
        }

        if let singleValue = try? decoder.singleValueContainer(),
           let rows = try? singleValue.decode([[String: Int]].self) {
            values = rows.first?.mapValues { MetricValue(value: $0) } ?? [:]
            return
        }

        values = [:]
    }
}

struct SessionPropertiesResponse: Decodable, Sendable {
    let values: [String: JSONValue]

    init(from decoder: Decoder) throws {
        if let singleValue = try? decoder.singleValueContainer(),
           let dictionary = try? singleValue.decode([String: JSONValue].self) {
            values = dictionary
            return
        }

        if let singleValue = try? decoder.singleValueContainer(),
           let rows = try? singleValue.decode([SessionPropertyRow].self) {
            values = rows.reduce(into: [String: JSONValue]()) { result, row in
                guard let key = row.key, !key.isEmpty else { return }
                result[key] = row.value
            }
            return
        }

        values = [:]
    }
}

private struct SessionPropertyRow: Decodable {
    let key: String?
    let value: JSONValue

    private enum CodingKeys: String, CodingKey {
        case dataKey
        case propertyName
        case name
        case stringValue
        case numberValue
        case dateValue
        case booleanValue
        case value
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        key = (try? container.decode(String.self, forKey: .dataKey))
            ?? (try? container.decode(String.self, forKey: .propertyName))
            ?? (try? container.decode(String.self, forKey: .name))

        if let stringValue = try? container.decodeIfPresent(String.self, forKey: .stringValue) {
            value = .string(stringValue)
        } else if let numberValue = try? container.decodeIfPresent(Double.self, forKey: .numberValue) {
            value = .number(numberValue)
        } else if let dateValue = try? container.decodeIfPresent(String.self, forKey: .dateValue) {
            value = .string(dateValue)
        } else if let booleanValue = try? container.decodeIfPresent(Bool.self, forKey: .booleanValue) {
            value = .bool(booleanValue)
        } else if let decodedValue = try? container.decodeIfPresent(JSONValue.self, forKey: .value) {
            value = decodedValue
        } else {
            value = .null
        }
    }
}

struct PaginatedResponse<T: Decodable & Sendable>: Decodable, Sendable {
    let data: [T]
    let count: Int
    let page: Int?
    let pageSize: Int?

    var hasMore: Bool {
        guard let page, let pageSize else {
            return data.count < count
        }
        return page * pageSize < count
    }

    private enum CodingKeys: String, CodingKey {
        case data
        case count
        case page
        case pageSize
        case results
        case items
        case total
    }

    init(data: [T], count: Int, page: Int? = nil, pageSize: Int? = nil) {
        self.data = data
        self.count = count
        self.page = page
        self.pageSize = pageSize
    }

    init(from decoder: Decoder) throws {
        if let singleValue = try? decoder.singleValueContainer(),
           let array = try? singleValue.decode([T].self) {
            self.data = array
            self.count = array.count
            self.page = nil
            self.pageSize = nil
            return
        }

        let container = try decoder.container(keyedBy: CodingKeys.self)

        if let data = try? container.decode([T].self, forKey: .data) {
            self.data = data
        } else if let items = try? container.decode([T].self, forKey: .items) {
            self.data = items
        } else if let results = try? container.decode([T].self, forKey: .results) {
            self.data = results
        } else {
            self.data = []
        }

        if let count = try? container.decode(Int.self, forKey: .count) {
            self.count = count
        } else if let total = try? container.decode(Int.self, forKey: .total) {
            self.count = total
        } else {
            self.count = data.count
        }

        self.page = try? container.decode(Int.self, forKey: .page)
        self.pageSize = try? container.decode(Int.self, forKey: .pageSize)
    }
}

struct EventDataState: Sendable {
    var availableFields: [FilterValue] = []
    var availableProperties: [FilterValue] = []
    var availableEvents: [FilterValue] = []
    var availableValues: [FilterValue] = []
    var stats: [String: MetricValue] = [:]

    var selectedEvent: String?
    var selectedProperty: String?

    var isLoading = false
    var errorMessage: String?

    mutating func resetSelections() {
        selectedEvent = nil
        selectedProperty = nil
        availableValues = []
        stats = [:]
    }
}

struct DynamicCodingKey: CodingKey, Sendable {
    var stringValue: String
    var intValue: Int?

    init(_ stringValue: String) {
        self.stringValue = stringValue
        self.intValue = nil
    }

    init?(stringValue: String) {
        self.init(stringValue)
    }

    init?(intValue: Int) {
        self.stringValue = "\(intValue)"
        self.intValue = intValue
    }
}

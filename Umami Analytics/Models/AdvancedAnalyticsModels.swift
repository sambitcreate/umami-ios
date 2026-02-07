import Foundation

enum WebsiteDetailTab: String, CaseIterable, Identifiable {
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

enum MetricDimension: String, CaseIterable, Identifiable {
    case url
    case referrer
    case browser
    case device
    case country
    case event
    case channel

    var id: String { rawValue }

    var title: String {
        switch self {
        case .url:
            return "Pages"
        case .referrer:
            return "Referrers"
        case .browser:
            return "Browsers"
        case .device:
            return "Devices"
        case .country:
            return "Countries"
        case .event:
            return "Events"
        case .channel:
            return "Channels"
        }
    }
}

struct MetricValue: Decodable, Equatable {
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
               let intValue = Int(stringValue) {
                self.value = intValue
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
           let intValue = Int(stringValue) {
            return intValue
        }
        return nil
    }
}

struct FilterValue: Decodable, Identifiable, Equatable {
    let value: String
    let label: String?
    let count: Int?

    var id: String {
        if let label {
            return "\(value)|\(label)"
        }
        return value
    }

    var displayText: String {
        label ?? value
    }

    init(value: String, label: String? = nil, count: Int? = nil) {
        self.value = value
        self.label = label
        self.count = count
    }

    init(from decoder: Decoder) throws {
        if let singleValue = try? decoder.singleValueContainer() {
            if let stringValue = try? singleValue.decode(String.self) {
                self.value = stringValue
                self.label = nil
                self.count = nil
                return
            }

            if let intValue = try? singleValue.decode(Int.self) {
                self.value = String(intValue)
                self.label = nil
                self.count = nil
                return
            }
        }

        let container = try decoder.container(keyedBy: DynamicCodingKey.self)

        let valueKeys = ["value", "x", "name", "id", "event", "property", "label"]
        let labelKeys = ["label", "name", "title"]
        let countKeys = ["count", "y", "valueCount", "visitors", "sessions", "pageviews"]

        let decodedValue = Self.decodeString(container: container, keys: valueKeys) ?? ""
        self.value = decodedValue

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

enum JSONValue: Decodable, Equatable {
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
            return Int(value)
        default:
            return nil
        }
    }
}

struct AnalyticsRecord: Decodable, Identifiable, Equatable {
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
        stringValue(for: ["eventName", "event", "name", "title", "url", "path", "id"]) ?? "Unknown event"
    }

    var eventSecondaryText: String? {
        stringValue(for: ["url", "path", "pathname", "referrer", "browser", "country", "sessionId"])
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

struct WeeklySessionPoint: Decodable, Identifiable, Equatable {
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
            date = Date(timeIntervalSince1970: TimeInterval(millis) / 1000)
        } else if let day = try? container.decode(String.self, forKey: .day) {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            date = formatter.date(from: day) ?? Date()
        } else if let dateString = try? container.decode(String.self, forKey: .date) {
            let isoFormatter = ISO8601DateFormatter()
            date = isoFormatter.date(from: dateString) ?? Date()
        } else if let millis = try? container.decode(Double.self, forKey: .date) {
            date = Date(timeIntervalSince1970: millis / 1000)
        } else {
            date = Date()
        }
    }
}

struct PaginatedResponse<T: Decodable>: Decodable {
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

struct EventDataState {
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

struct DynamicCodingKey: CodingKey {
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

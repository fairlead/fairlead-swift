import Foundation

/// A type-safe representation of arbitrary JSON values.
///
/// Used for untyped fields like `metadata`, `rules`, `bidder_config`, `meta`, and `delivery_goal`
/// that can contain any valid JSON structure.
public enum JSON: Sendable, Equatable, Hashable {
    case string(String)
    case number(Double)
    case bool(Bool)
    case object([String: JSON])
    case array([JSON])
    case null
}

// MARK: - Codable

extension JSON: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if container.decodeNil() {
            self = .null
        } else if let boolValue = try? container.decode(Bool.self) {
            self = .bool(boolValue)
        } else if let intValue = try? container.decode(Int.self) {
            self = .number(Double(intValue))
        } else if let doubleValue = try? container.decode(Double.self) {
            self = .number(doubleValue)
        } else if let stringValue = try? container.decode(String.self) {
            self = .string(stringValue)
        } else if let arrayValue = try? container.decode([JSON].self) {
            self = .array(arrayValue)
        } else if let objectValue = try? container.decode([String: JSON].self) {
            self = .object(objectValue)
        } else {
            throw DecodingError.typeMismatch(
                JSON.self,
                DecodingError.Context(
                    codingPath: decoder.codingPath,
                    debugDescription: "Unable to decode JSON value"
                )
            )
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .string(let value):
            try container.encode(value)
        case .number(let value):
            // Encode integers without decimal point
            if value == value.rounded() && !value.isInfinite && !value.isNaN {
                try container.encode(Int(value))
            } else {
                try container.encode(value)
            }
        case .bool(let value):
            try container.encode(value)
        case .object(let value):
            try container.encode(value)
        case .array(let value):
            try container.encode(value)
        case .null:
            try container.encodeNil()
        }
    }
}

// MARK: - Convenience Accessors

extension JSON {
    /// Returns the string value if this is a `.string`, otherwise `nil`.
    public var stringValue: String? {
        if case .string(let v) = self { return v }
        return nil
    }

    /// Returns the number value if this is a `.number`, otherwise `nil`.
    public var numberValue: Double? {
        if case .number(let v) = self { return v }
        return nil
    }

    /// Returns the bool value if this is a `.bool`, otherwise `nil`.
    public var boolValue: Bool? {
        if case .bool(let v) = self { return v }
        return nil
    }

    /// Returns the object value if this is an `.object`, otherwise `nil`.
    public var objectValue: [String: JSON]? {
        if case .object(let v) = self { return v }
        return nil
    }

    /// Returns the array value if this is an `.array`, otherwise `nil`.
    public var arrayValue: [JSON]? {
        if case .array(let v) = self { return v }
        return nil
    }

    /// Returns `true` if this is `.null`.
    public var isNull: Bool {
        if case .null = self { return true }
        return false
    }
}

// MARK: - ExpressibleBy Literals

extension JSON: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self = .string(value)
    }
}

extension JSON: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: Int) {
        self = .number(Double(value))
    }
}

extension JSON: ExpressibleByFloatLiteral {
    public init(floatLiteral value: Double) {
        self = .number(value)
    }
}

extension JSON: ExpressibleByBooleanLiteral {
    public init(booleanLiteral value: Bool) {
        self = .bool(value)
    }
}

extension JSON: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: JSON...) {
        self = .array(elements)
    }
}

extension JSON: ExpressibleByDictionaryLiteral {
    public init(dictionaryLiteral elements: (String, JSON)...) {
        self = .object(Dictionary(uniqueKeysWithValues: elements))
    }
}

extension JSON: ExpressibleByNilLiteral {
    public init(nilLiteral: ()) {
        self = .null
    }
}

import Foundation

// MARK: - Enums

/// Organization-level authorization role.
public enum Role: String, Codable, Sendable {
    case admin
    case member
    case viewer
}

/// API key environment — determines data isolation boundary.
public enum Environment: String, Codable, Sendable {
    case live
    case test
}

/// Advertiser/Ad/LineItem status.
public enum ActiveStatus: String, Codable, Sendable {
    case active
    case paused
}

/// Campaign status.
public enum CampaignStatus: String, Codable, Sendable {
    case draft
    case active
    case paused
    case completed
}

/// Ad format type.
public enum AdType: String, Codable, Sendable {
    case listingRef = "listing_ref"
    case native
    case display
}

/// Placement ad format.
public enum AdFormat: String, Codable, Sendable {
    case sponsoredListing = "sponsored_listing"
    case native
}

// MARK: - Audit

/// Represents who performed an action and when.
public struct Audit: Codable, Sendable, Equatable {
    /// When the action occurred.
    public let at: Date
    /// Who performed the action.
    public let by: String

    public init(at: Date, by: String) {
        self.at = at
        self.by = by
    }
}

// MARK: - Pagination

/// Offset-based pagination metadata from a list response.
public struct OffsetPaginationMeta: Codable, Sendable, Equatable {
    /// The offset of the first item in this page.
    public let offset: Int
    /// The maximum number of items per page.
    public let limit: Int
    /// The total number of results, if known.
    public let totalResults: Int?

    public init(offset: Int, limit: Int, totalResults: Int? = nil) {
        self.offset = offset
        self.limit = limit
        self.totalResults = totalResults
    }
}

/// A paginated list response from the API.
public struct ListResponse<T: Codable & Sendable>: Codable, Sendable {
    /// The items in this page.
    public let data: [T]
    /// Pagination metadata.
    public let pagination: OffsetPaginationMeta
    /// Additional response metadata.
    public let meta: [String: JSON]?

    public init(data: [T], pagination: OffsetPaginationMeta, meta: [String: JSON]? = nil) {
        self.data = data
        self.pagination = pagination
        self.meta = meta
    }

    /// Returns `true` if there are more results beyond this page.
    public func hasMore() -> Bool {
        if let totalResults = pagination.totalResults {
            return pagination.offset + data.count < totalResults
        }
        return data.count >= pagination.limit
    }
}

// MARK: - List Params

/// Common query parameters for list endpoints.
public struct ListParams: Sendable {
    /// Filter query string.
    public var query: String?
    /// Sort expression (e.g. "name:asc").
    public var sort: String?
    /// Pagination offset.
    public var offset: Int?
    /// Maximum items per page.
    public var limit: Int?

    public init(query: String? = nil, sort: String? = nil, offset: Int? = nil, limit: Int? = nil) {
        self.query = query
        self.sort = sort
        self.offset = offset
        self.limit = limit
    }

    /// Converts the params to URL query items, omitting nil values.
    internal func queryItems() -> [URLQueryItem] {
        var items: [URLQueryItem] = []
        if let query = query {
            items.append(URLQueryItem(name: "query", value: query))
        }
        if let sort = sort {
            items.append(URLQueryItem(name: "sort", value: sort))
        }
        if let offset = offset {
            items.append(URLQueryItem(name: "offset", value: String(offset)))
        }
        if let limit = limit {
            items.append(URLQueryItem(name: "limit", value: String(limit)))
        }
        return items
    }
}

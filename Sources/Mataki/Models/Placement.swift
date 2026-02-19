import Foundation

/// System-managed annotations for placements.
public struct PlacementAnnotations: Codable, Sendable, Equatable {
    /// Who created the placement and when.
    public let created: Audit?
    /// Who last updated the placement and when.
    public let updated: Audit?

    public init(created: Audit? = nil, updated: Audit? = nil) {
        self.created = created
        self.updated = updated
    }
}

/// Full placement representation (read model).
public struct Placement: Codable, Sendable, Equatable {
    /// The placement's unique identifier.
    public let id: String
    /// The organization this placement belongs to.
    public let organizationId: String
    /// The placement's display name.
    public let name: String
    /// URL-safe slug.
    public let slug: String
    /// The ad format.
    public let adFormat: AdFormat
    /// Maximum number of ads.
    public let maxAds: Int
    /// Placement rules configuration.
    public let rules: [String: JSON]
    /// Bidder configuration.
    public let bidderConfig: [String: JSON]
    /// Tags for categorization.
    public let tags: [String]
    /// Key-value labels.
    public let labels: [String: String]
    /// System-managed annotations.
    public let annotations: PlacementAnnotations?

    public init(
        id: String,
        organizationId: String,
        name: String,
        slug: String,
        adFormat: AdFormat,
        maxAds: Int = 0,
        rules: [String: JSON] = [:],
        bidderConfig: [String: JSON] = [:],
        tags: [String] = [],
        labels: [String: String] = [:],
        annotations: PlacementAnnotations? = nil
    ) {
        self.id = id
        self.organizationId = organizationId
        self.name = name
        self.slug = slug
        self.adFormat = adFormat
        self.maxAds = maxAds
        self.rules = rules
        self.bidderConfig = bidderConfig
        self.tags = tags
        self.labels = labels
        self.annotations = annotations
    }
}

/// Parameters for creating a placement.
public struct PlacementCreateParams: Encodable, Sendable {
    /// The placement name (required).
    public let name: String
    /// URL-safe slug (required).
    public let slug: String
    /// The ad format (required).
    public let adFormat: AdFormat
    /// Maximum number of ads.
    public let maxAds: Int?
    /// Placement rules configuration.
    public let rules: [String: JSON]?
    /// Bidder configuration.
    public let bidderConfig: [String: JSON]?
    /// Tags for categorization.
    public let tags: [String]?
    /// Key-value labels.
    public let labels: [String: String]?

    public init(
        name: String,
        slug: String,
        adFormat: AdFormat,
        maxAds: Int? = nil,
        rules: [String: JSON]? = nil,
        bidderConfig: [String: JSON]? = nil,
        tags: [String]? = nil,
        labels: [String: String]? = nil
    ) {
        self.name = name
        self.slug = slug
        self.adFormat = adFormat
        self.maxAds = maxAds
        self.rules = rules
        self.bidderConfig = bidderConfig
        self.tags = tags
        self.labels = labels
    }
}

/// Parameters for updating a placement. All fields are optional.
public struct PlacementUpdateParams: Encodable, Sendable {
    public let name: String?
    public let slug: String?
    public let adFormat: AdFormat?
    public let maxAds: Int?
    public let rules: [String: JSON]?
    public let bidderConfig: [String: JSON]?
    public let tags: [String]?
    public let labels: [String: String]?

    public init(
        name: String? = nil,
        slug: String? = nil,
        adFormat: AdFormat? = nil,
        maxAds: Int? = nil,
        rules: [String: JSON]? = nil,
        bidderConfig: [String: JSON]? = nil,
        tags: [String]? = nil,
        labels: [String: String]? = nil
    ) {
        self.name = name
        self.slug = slug
        self.adFormat = adFormat
        self.maxAds = maxAds
        self.rules = rules
        self.bidderConfig = bidderConfig
        self.tags = tags
        self.labels = labels
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(name, forKey: .name)
        try container.encodeIfPresent(slug, forKey: .slug)
        try container.encodeIfPresent(adFormat, forKey: .adFormat)
        try container.encodeIfPresent(maxAds, forKey: .maxAds)
        try container.encodeIfPresent(rules, forKey: .rules)
        try container.encodeIfPresent(bidderConfig, forKey: .bidderConfig)
        try container.encodeIfPresent(tags, forKey: .tags)
        try container.encodeIfPresent(labels, forKey: .labels)
    }

    private enum CodingKeys: String, CodingKey {
        case name, slug, adFormat, maxAds, rules, bidderConfig, tags, labels
    }
}

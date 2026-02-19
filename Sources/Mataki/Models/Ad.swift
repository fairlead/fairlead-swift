import Foundation

/// System-managed annotations for ads.
public struct AdAnnotations: Codable, Sendable, Equatable {
    /// Who created the ad and when.
    public let created: Audit?
    /// Who last updated the ad and when.
    public let updated: Audit?

    public init(created: Audit? = nil, updated: Audit? = nil) {
        self.created = created
        self.updated = updated
    }
}

/// Full ad representation (read model).
public struct Ad: Codable, Sendable, Equatable {
    /// The ad's unique identifier.
    public let id: String
    /// The parent line item's identifier.
    public let lineItemId: String
    /// The organization this ad belongs to.
    public let organizationId: String
    /// The ad format type.
    public let adType: AdType
    /// An external item identifier for integration.
    public let externalItemId: String?
    /// The quality score. Can be a number or string from the API.
    public let qualityScore: JSON
    /// Arbitrary metadata.
    public let metadata: [String: JSON]
    /// The ad's status.
    public let status: ActiveStatus
    /// Tags for categorization.
    public let tags: [String]
    /// Key-value labels.
    public let labels: [String: String]
    /// System-managed annotations.
    public let annotations: AdAnnotations?

    public init(
        id: String,
        lineItemId: String,
        organizationId: String,
        adType: AdType,
        externalItemId: String? = nil,
        qualityScore: JSON = .number(0),
        metadata: [String: JSON] = [:],
        status: ActiveStatus = .active,
        tags: [String] = [],
        labels: [String: String] = [:],
        annotations: AdAnnotations? = nil
    ) {
        self.id = id
        self.lineItemId = lineItemId
        self.organizationId = organizationId
        self.adType = adType
        self.externalItemId = externalItemId
        self.qualityScore = qualityScore
        self.metadata = metadata
        self.status = status
        self.tags = tags
        self.labels = labels
        self.annotations = annotations
    }
}

/// Parameters for creating an ad.
public struct AdCreateParams: Encodable, Sendable {
    /// The parent line item ID (required).
    public let lineItemId: String
    /// The ad format type (required).
    public let adType: AdType
    /// An external item identifier.
    public let externalItemId: String?
    /// The quality score.
    public let qualityScore: JSON?
    /// Arbitrary metadata.
    public let metadata: [String: JSON]?
    /// The ad's status.
    public let status: ActiveStatus?
    /// Tags for categorization.
    public let tags: [String]?
    /// Key-value labels.
    public let labels: [String: String]?

    public init(
        lineItemId: String,
        adType: AdType,
        externalItemId: String? = nil,
        qualityScore: JSON? = nil,
        metadata: [String: JSON]? = nil,
        status: ActiveStatus? = nil,
        tags: [String]? = nil,
        labels: [String: String]? = nil
    ) {
        self.lineItemId = lineItemId
        self.adType = adType
        self.externalItemId = externalItemId
        self.qualityScore = qualityScore
        self.metadata = metadata
        self.status = status
        self.tags = tags
        self.labels = labels
    }
}

/// Parameters for updating an ad. All fields are optional.
public struct AdUpdateParams: Encodable, Sendable {
    public let adType: AdType?
    public let externalItemId: String?
    public let qualityScore: JSON?
    public let metadata: [String: JSON]?
    public let status: ActiveStatus?
    public let tags: [String]?
    public let labels: [String: String]?

    public init(
        adType: AdType? = nil,
        externalItemId: String? = nil,
        qualityScore: JSON? = nil,
        metadata: [String: JSON]? = nil,
        status: ActiveStatus? = nil,
        tags: [String]? = nil,
        labels: [String: String]? = nil
    ) {
        self.adType = adType
        self.externalItemId = externalItemId
        self.qualityScore = qualityScore
        self.metadata = metadata
        self.status = status
        self.tags = tags
        self.labels = labels
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(adType, forKey: .adType)
        try container.encodeIfPresent(externalItemId, forKey: .externalItemId)
        try container.encodeIfPresent(qualityScore, forKey: .qualityScore)
        try container.encodeIfPresent(metadata, forKey: .metadata)
        try container.encodeIfPresent(status, forKey: .status)
        try container.encodeIfPresent(tags, forKey: .tags)
        try container.encodeIfPresent(labels, forKey: .labels)
    }

    private enum CodingKeys: String, CodingKey {
        case adType, externalItemId, qualityScore, metadata, status, tags, labels
    }
}

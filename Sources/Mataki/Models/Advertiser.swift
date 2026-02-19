import Foundation

/// System-managed annotations for advertisers.
public struct AdvertiserAnnotations: Codable, Sendable, Equatable {
    /// Who created the advertiser and when.
    public let created: Audit?
    /// Who last updated the advertiser and when.
    public let updated: Audit?

    public init(created: Audit? = nil, updated: Audit? = nil) {
        self.created = created
        self.updated = updated
    }
}

/// Full advertiser representation (read model).
public struct Advertiser: Codable, Sendable, Equatable {
    /// The advertiser's unique identifier.
    public let id: String
    /// The organization this advertiser belongs to.
    public let organizationId: String
    /// The advertiser's display name.
    public let name: String
    /// An external identifier for integration with other systems.
    public let externalId: String?
    /// The advertiser's status.
    public let status: ActiveStatus
    /// Arbitrary metadata.
    public let metadata: [String: JSON]
    /// Tags for categorization.
    public let tags: [String]
    /// Key-value labels.
    public let labels: [String: String]
    /// System-managed annotations.
    public let annotations: AdvertiserAnnotations?

    public init(
        id: String,
        organizationId: String,
        name: String,
        externalId: String? = nil,
        status: ActiveStatus = .active,
        metadata: [String: JSON] = [:],
        tags: [String] = [],
        labels: [String: String] = [:],
        annotations: AdvertiserAnnotations? = nil
    ) {
        self.id = id
        self.organizationId = organizationId
        self.name = name
        self.externalId = externalId
        self.status = status
        self.metadata = metadata
        self.tags = tags
        self.labels = labels
        self.annotations = annotations
    }
}

/// Parameters for creating an advertiser.
public struct AdvertiserCreateParams: Encodable, Sendable {
    /// The advertiser name (required).
    public let name: String
    /// An external identifier.
    public let externalId: String?
    /// The advertiser's status.
    public let status: ActiveStatus?
    /// Arbitrary metadata.
    public let metadata: [String: JSON]?
    /// Tags for categorization.
    public let tags: [String]?
    /// Key-value labels.
    public let labels: [String: String]?

    public init(
        name: String,
        externalId: String? = nil,
        status: ActiveStatus? = nil,
        metadata: [String: JSON]? = nil,
        tags: [String]? = nil,
        labels: [String: String]? = nil
    ) {
        self.name = name
        self.externalId = externalId
        self.status = status
        self.metadata = metadata
        self.tags = tags
        self.labels = labels
    }
}

/// Parameters for updating an advertiser. All fields are optional.
public struct AdvertiserUpdateParams: Encodable, Sendable {
    public let name: String?
    public let externalId: String?
    public let status: ActiveStatus?
    public let metadata: [String: JSON]?
    public let tags: [String]?
    public let labels: [String: String]?

    public init(
        name: String? = nil,
        externalId: String? = nil,
        status: ActiveStatus? = nil,
        metadata: [String: JSON]? = nil,
        tags: [String]? = nil,
        labels: [String: String]? = nil
    ) {
        self.name = name
        self.externalId = externalId
        self.status = status
        self.metadata = metadata
        self.tags = tags
        self.labels = labels
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(name, forKey: .name)
        try container.encodeIfPresent(externalId, forKey: .externalId)
        try container.encodeIfPresent(status, forKey: .status)
        try container.encodeIfPresent(metadata, forKey: .metadata)
        try container.encodeIfPresent(tags, forKey: .tags)
        try container.encodeIfPresent(labels, forKey: .labels)
    }

    private enum CodingKeys: String, CodingKey {
        case name, externalId, status, metadata, tags, labels
    }
}

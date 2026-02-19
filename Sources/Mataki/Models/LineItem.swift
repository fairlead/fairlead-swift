import Foundation

/// System-managed annotations for line items.
public struct LineItemAnnotations: Codable, Sendable, Equatable {
    /// Who created the line item and when.
    public let created: Audit?
    /// Who last updated the line item and when.
    public let updated: Audit?

    public init(created: Audit? = nil, updated: Audit? = nil) {
        self.created = created
        self.updated = updated
    }
}

/// Full line item representation (read model).
public struct LineItem: Codable, Sendable, Equatable {
    /// The line item's unique identifier.
    public let id: String
    /// The parent campaign's identifier.
    public let campaignId: String
    /// The organization this line item belongs to.
    public let organizationId: String
    /// The bidder type.
    public let bidderType: String
    /// The line item's status.
    public let status: ActiveStatus
    /// The bid strategy.
    public let bidStrategy: String
    /// The bid amount in cents.
    public let bidAmountCents: Int
    /// Targeting rules.
    public let targeting: [String: JSON]
    /// Priority value.
    public let priority: Int
    /// Delivery goal configuration.
    public let deliveryGoal: [String: JSON]?
    /// Tags for categorization.
    public let tags: [String]
    /// Key-value labels.
    public let labels: [String: String]
    /// System-managed annotations.
    public let annotations: LineItemAnnotations?

    public init(
        id: String,
        campaignId: String,
        organizationId: String,
        bidderType: String,
        status: ActiveStatus = .active,
        bidStrategy: String,
        bidAmountCents: Int,
        targeting: [String: JSON] = [:],
        priority: Int = 0,
        deliveryGoal: [String: JSON]? = nil,
        tags: [String] = [],
        labels: [String: String] = [:],
        annotations: LineItemAnnotations? = nil
    ) {
        self.id = id
        self.campaignId = campaignId
        self.organizationId = organizationId
        self.bidderType = bidderType
        self.status = status
        self.bidStrategy = bidStrategy
        self.bidAmountCents = bidAmountCents
        self.targeting = targeting
        self.priority = priority
        self.deliveryGoal = deliveryGoal
        self.tags = tags
        self.labels = labels
        self.annotations = annotations
    }
}

/// Parameters for creating a line item.
public struct LineItemCreateParams: Encodable, Sendable {
    /// The parent campaign ID (required).
    public let campaignId: String
    /// The bid strategy (required).
    public let bidStrategy: String
    /// The bid amount in cents (required).
    public let bidAmountCents: Int
    /// The bidder type.
    public let bidderType: String?
    /// The line item's status.
    public let status: ActiveStatus?
    /// Targeting rules.
    public let targeting: [String: JSON]?
    /// Priority value.
    public let priority: Int?
    /// Delivery goal configuration.
    public let deliveryGoal: [String: JSON]?
    /// Tags for categorization.
    public let tags: [String]?
    /// Key-value labels.
    public let labels: [String: String]?

    public init(
        campaignId: String,
        bidStrategy: String,
        bidAmountCents: Int,
        bidderType: String? = nil,
        status: ActiveStatus? = nil,
        targeting: [String: JSON]? = nil,
        priority: Int? = nil,
        deliveryGoal: [String: JSON]? = nil,
        tags: [String]? = nil,
        labels: [String: String]? = nil
    ) {
        self.campaignId = campaignId
        self.bidStrategy = bidStrategy
        self.bidAmountCents = bidAmountCents
        self.bidderType = bidderType
        self.status = status
        self.targeting = targeting
        self.priority = priority
        self.deliveryGoal = deliveryGoal
        self.tags = tags
        self.labels = labels
    }
}

/// Parameters for updating a line item. All fields are optional.
public struct LineItemUpdateParams: Encodable, Sendable {
    public let bidderType: String?
    public let status: ActiveStatus?
    public let bidStrategy: String?
    public let bidAmountCents: Int?
    public let targeting: [String: JSON]?
    public let priority: Int?
    public let deliveryGoal: [String: JSON]?
    public let tags: [String]?
    public let labels: [String: String]?

    public init(
        bidderType: String? = nil,
        status: ActiveStatus? = nil,
        bidStrategy: String? = nil,
        bidAmountCents: Int? = nil,
        targeting: [String: JSON]? = nil,
        priority: Int? = nil,
        deliveryGoal: [String: JSON]? = nil,
        tags: [String]? = nil,
        labels: [String: String]? = nil
    ) {
        self.bidderType = bidderType
        self.status = status
        self.bidStrategy = bidStrategy
        self.bidAmountCents = bidAmountCents
        self.targeting = targeting
        self.priority = priority
        self.deliveryGoal = deliveryGoal
        self.tags = tags
        self.labels = labels
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(bidderType, forKey: .bidderType)
        try container.encodeIfPresent(status, forKey: .status)
        try container.encodeIfPresent(bidStrategy, forKey: .bidStrategy)
        try container.encodeIfPresent(bidAmountCents, forKey: .bidAmountCents)
        try container.encodeIfPresent(targeting, forKey: .targeting)
        try container.encodeIfPresent(priority, forKey: .priority)
        try container.encodeIfPresent(deliveryGoal, forKey: .deliveryGoal)
        try container.encodeIfPresent(tags, forKey: .tags)
        try container.encodeIfPresent(labels, forKey: .labels)
    }

    private enum CodingKeys: String, CodingKey {
        case bidderType, status, bidStrategy, bidAmountCents, targeting, priority, deliveryGoal, tags, labels
    }
}

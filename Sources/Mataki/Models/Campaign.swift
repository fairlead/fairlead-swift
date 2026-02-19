import Foundation

/// System-managed annotations for campaigns.
public struct CampaignAnnotations: Codable, Sendable, Equatable {
    /// Who created the campaign and when.
    public let created: Audit?
    /// Who last updated the campaign and when.
    public let updated: Audit?

    public init(created: Audit? = nil, updated: Audit? = nil) {
        self.created = created
        self.updated = updated
    }
}

/// Full campaign representation (read model).
public struct Campaign: Codable, Sendable, Equatable {
    /// The campaign's unique identifier.
    public let id: String
    /// The parent advertiser's identifier.
    public let advertiserId: String
    /// The organization this campaign belongs to.
    public let organizationId: String
    /// The campaign's display name.
    public let name: String
    /// The campaign's status.
    public let status: CampaignStatus
    /// Total budget in cents.
    public let budgetTotalCents: Int?
    /// Daily budget in cents.
    public let budgetDailyCents: Int?
    /// Campaign start date (ISO 8601 date string).
    public let startDate: String?
    /// Campaign end date (ISO 8601 date string).
    public let endDate: String?
    /// Tags for categorization.
    public let tags: [String]
    /// Key-value labels.
    public let labels: [String: String]
    /// System-managed annotations.
    public let annotations: CampaignAnnotations?

    public init(
        id: String,
        advertiserId: String,
        organizationId: String,
        name: String,
        status: CampaignStatus = .draft,
        budgetTotalCents: Int? = nil,
        budgetDailyCents: Int? = nil,
        startDate: String? = nil,
        endDate: String? = nil,
        tags: [String] = [],
        labels: [String: String] = [:],
        annotations: CampaignAnnotations? = nil
    ) {
        self.id = id
        self.advertiserId = advertiserId
        self.organizationId = organizationId
        self.name = name
        self.status = status
        self.budgetTotalCents = budgetTotalCents
        self.budgetDailyCents = budgetDailyCents
        self.startDate = startDate
        self.endDate = endDate
        self.tags = tags
        self.labels = labels
        self.annotations = annotations
    }
}

/// Parameters for creating a campaign.
public struct CampaignCreateParams: Encodable, Sendable {
    /// The parent advertiser ID (required).
    public let advertiserId: String
    /// The campaign name (required).
    public let name: String
    /// The campaign's status.
    public let status: CampaignStatus?
    /// Total budget in cents.
    public let budgetTotalCents: Int?
    /// Daily budget in cents.
    public let budgetDailyCents: Int?
    /// Campaign start date (ISO 8601 date string).
    public let startDate: String?
    /// Campaign end date (ISO 8601 date string).
    public let endDate: String?
    /// Tags for categorization.
    public let tags: [String]?
    /// Key-value labels.
    public let labels: [String: String]?

    public init(
        advertiserId: String,
        name: String,
        status: CampaignStatus? = nil,
        budgetTotalCents: Int? = nil,
        budgetDailyCents: Int? = nil,
        startDate: String? = nil,
        endDate: String? = nil,
        tags: [String]? = nil,
        labels: [String: String]? = nil
    ) {
        self.advertiserId = advertiserId
        self.name = name
        self.status = status
        self.budgetTotalCents = budgetTotalCents
        self.budgetDailyCents = budgetDailyCents
        self.startDate = startDate
        self.endDate = endDate
        self.tags = tags
        self.labels = labels
    }
}

/// Parameters for updating a campaign. All fields are optional.
public struct CampaignUpdateParams: Encodable, Sendable {
    public let name: String?
    public let status: CampaignStatus?
    public let budgetTotalCents: Int?
    public let budgetDailyCents: Int?
    public let startDate: String?
    public let endDate: String?
    public let tags: [String]?
    public let labels: [String: String]?

    public init(
        name: String? = nil,
        status: CampaignStatus? = nil,
        budgetTotalCents: Int? = nil,
        budgetDailyCents: Int? = nil,
        startDate: String? = nil,
        endDate: String? = nil,
        tags: [String]? = nil,
        labels: [String: String]? = nil
    ) {
        self.name = name
        self.status = status
        self.budgetTotalCents = budgetTotalCents
        self.budgetDailyCents = budgetDailyCents
        self.startDate = startDate
        self.endDate = endDate
        self.tags = tags
        self.labels = labels
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(name, forKey: .name)
        try container.encodeIfPresent(status, forKey: .status)
        try container.encodeIfPresent(budgetTotalCents, forKey: .budgetTotalCents)
        try container.encodeIfPresent(budgetDailyCents, forKey: .budgetDailyCents)
        try container.encodeIfPresent(startDate, forKey: .startDate)
        try container.encodeIfPresent(endDate, forKey: .endDate)
        try container.encodeIfPresent(tags, forKey: .tags)
        try container.encodeIfPresent(labels, forKey: .labels)
    }

    private enum CodingKeys: String, CodingKey {
        case name, status, budgetTotalCents, budgetDailyCents, startDate, endDate, tags, labels
    }
}

import Foundation

/// System-managed annotations for organizations.
public struct OrganizationAnnotations: Codable, Sendable, Equatable {
    /// Who created the organization and when.
    public let created: Audit?
    /// Who last updated the organization and when.
    public let updated: Audit?

    public init(created: Audit? = nil, updated: Audit? = nil) {
        self.created = created
        self.updated = updated
    }
}

/// Full organization representation (read model).
public struct Organization: Codable, Sendable, Equatable {
    /// The organization's unique identifier.
    public let id: String
    /// The organization's display name.
    public let name: String
    /// The API version the organization is pinned to.
    public let apiVersion: String?
    /// Tags for categorization.
    public let tags: [String]
    /// Key-value labels.
    public let labels: [String: String]
    /// System-managed annotations.
    public let annotations: OrganizationAnnotations?

    public init(
        id: String,
        name: String,
        apiVersion: String? = nil,
        tags: [String] = [],
        labels: [String: String] = [:],
        annotations: OrganizationAnnotations? = nil
    ) {
        self.id = id
        self.name = name
        self.apiVersion = apiVersion
        self.tags = tags
        self.labels = labels
        self.annotations = annotations
    }
}

/// Parameters for creating an organization.
public struct OrganizationCreateParams: Encodable, Sendable {
    /// The organization name (required).
    public let name: String
    /// Tags for categorization.
    public let tags: [String]?
    /// Key-value labels.
    public let labels: [String: String]?

    public init(name: String, tags: [String]? = nil, labels: [String: String]? = nil) {
        self.name = name
        self.tags = tags
        self.labels = labels
    }
}

/// Parameters for updating an organization. All fields are optional — only provided fields are changed.
public struct OrganizationUpdateParams: Encodable, Sendable {
    /// The new organization name.
    public let name: String?
    /// Updated tags.
    public let tags: [String]?
    /// Updated labels.
    public let labels: [String: String]?

    public init(name: String? = nil, tags: [String]? = nil, labels: [String: String]? = nil) {
        self.name = name
        self.tags = tags
        self.labels = labels
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(name, forKey: .name)
        try container.encodeIfPresent(tags, forKey: .tags)
        try container.encodeIfPresent(labels, forKey: .labels)
    }

    private enum CodingKeys: String, CodingKey {
        case name, tags, labels
    }
}

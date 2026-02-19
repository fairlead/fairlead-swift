import Foundation

/// System-managed annotations for API keys.
public struct ApiKeyAnnotations: Codable, Sendable, Equatable {
    /// Who created the API key and when.
    public let created: Audit?
    /// Who last updated the API key and when.
    public let updated: Audit?
    /// When the API key was last used.
    public let lastUsed: Audit?

    public init(created: Audit? = nil, updated: Audit? = nil, lastUsed: Audit? = nil) {
        self.created = created
        self.updated = updated
        self.lastUsed = lastUsed
    }
}

/// Full API key representation (read model). Never contains the raw secret.
public struct ApiKey: Codable, Sendable, Equatable {
    /// The API key's unique identifier.
    public let id: String
    /// The organization this key belongs to.
    public let organizationId: String
    /// The API key's display name.
    public let name: String
    /// The prefix of the key (e.g. "mk_live_").
    public let keyPrefix: String
    /// The last few characters of the key.
    public let keySuffix: String
    /// The authorization role.
    public let role: Role
    /// Permission scopes.
    public let scopes: [String]
    /// The environment (live or test).
    public let environment: Environment
    /// Whether the key is currently active.
    public let isActive: Bool
    /// When the key expires, if set.
    public let expiresAt: Date?
    /// Tags for categorization.
    public let tags: [String]
    /// Key-value labels.
    public let labels: [String: String]
    /// System-managed annotations.
    public let annotations: ApiKeyAnnotations?

    public init(
        id: String,
        organizationId: String,
        name: String,
        keyPrefix: String,
        keySuffix: String,
        role: Role,
        scopes: [String] = [],
        environment: Environment,
        isActive: Bool,
        expiresAt: Date? = nil,
        tags: [String] = [],
        labels: [String: String] = [:],
        annotations: ApiKeyAnnotations? = nil
    ) {
        self.id = id
        self.organizationId = organizationId
        self.name = name
        self.keyPrefix = keyPrefix
        self.keySuffix = keySuffix
        self.role = role
        self.scopes = scopes
        self.environment = environment
        self.isActive = isActive
        self.expiresAt = expiresAt
        self.tags = tags
        self.labels = labels
        self.annotations = annotations
    }
}

/// Response returned when creating an API key.
/// The `rawKey` is shown once and cannot be retrieved again.
public struct CreateApiKeyResponse: Codable, Sendable {
    /// The created API key (without the raw secret).
    public let apiKey: ApiKey
    /// The raw API key string. Store this securely — it cannot be retrieved again.
    public let rawKey: String

    public init(apiKey: ApiKey, rawKey: String) {
        self.apiKey = apiKey
        self.rawKey = rawKey
    }
}

/// Parameters for creating an API key.
public struct ApiKeyCreateParams: Encodable, Sendable {
    /// The API key name (required).
    public let name: String
    /// The authorization role.
    public let role: Role?
    /// Permission scopes.
    public let scopes: [String]?
    /// When the key should expire.
    public let expiresAt: Date?
    /// The environment (live or test).
    public let environment: Environment?
    /// Tags for categorization.
    public let tags: [String]?
    /// Key-value labels.
    public let labels: [String: String]?

    public init(
        name: String,
        role: Role? = nil,
        scopes: [String]? = nil,
        expiresAt: Date? = nil,
        environment: Environment? = nil,
        tags: [String]? = nil,
        labels: [String: String]? = nil
    ) {
        self.name = name
        self.role = role
        self.scopes = scopes
        self.expiresAt = expiresAt
        self.environment = environment
        self.tags = tags
        self.labels = labels
    }
}

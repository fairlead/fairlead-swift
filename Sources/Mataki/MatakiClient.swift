import Foundation

/// The Mataki API client.
///
/// Create a client with an API key and use the resource properties to interact with the API:
///
/// ```swift
/// let client = MatakiClient(apiKey: "mk_live_...")
/// let org = try await client.organizations.get(id: "org_xxx")
/// ```
public final class MatakiClient: @unchecked Sendable {

    /// Access the Organizations API.
    public let organizations: OrganizationsResource

    /// Access the API Keys API.
    public let apiKeys: ApiKeysResource

    /// Access the Advertisers API.
    public let advertisers: AdvertisersResource

    /// Access the Campaigns API.
    public let campaigns: CampaignsResource

    /// Access the Line Items API.
    public let lineItems: LineItemsResource

    /// Access the Ads API.
    public let ads: AdsResource

    /// Access the Placements API.
    public let placements: PlacementsResource

    let httpClient: HTTPClient

    /// Creates a new Mataki API client.
    ///
    /// - Parameters:
    ///   - apiKey: Your Mataki API key (e.g. "mk_live_..." or "mk_test_...").
    ///   - options: Configuration options for the client.
    public init(apiKey: String, options: [ClientOption] = []) {
        let config = ClientConfig.resolve(apiKey: apiKey, options: options)
        self.httpClient = HTTPClient(config: config)

        self.organizations = OrganizationsResource(httpClient: httpClient)
        self.apiKeys = ApiKeysResource(httpClient: httpClient)
        self.advertisers = AdvertisersResource(httpClient: httpClient)
        self.campaigns = CampaignsResource(httpClient: httpClient)
        self.lineItems = LineItemsResource(httpClient: httpClient)
        self.ads = AdsResource(httpClient: httpClient)
        self.placements = PlacementsResource(httpClient: httpClient)
    }
}

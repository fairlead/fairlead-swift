import Foundation

/// Provides access to the Campaigns API.
public struct CampaignsResource: Sendable {
    let httpClient: HTTPClient

    /// Retrieves a paginated list of campaigns.
    ///
    /// - Parameter params: Optional query parameters for filtering, sorting, and pagination.
    /// - Returns: A paginated list of campaigns.
    public func list(params: ListParams? = nil) async throws -> ListResponse<Campaign> {
        return try await httpClient.request(
            method: "GET",
            path: "/campaigns",
            queryItems: params?.queryItems()
        )
    }

    /// Retrieves a single campaign by ID.
    ///
    /// - Parameter id: The campaign's unique identifier.
    /// - Returns: The campaign.
    public func get(id: String) async throws -> Campaign {
        return try await httpClient.request(
            method: "GET",
            path: "/campaigns/\(encodePath(id))"
        )
    }

    /// Creates a new campaign.
    ///
    /// - Parameter params: The campaign creation parameters.
    /// - Returns: The created campaign.
    public func create(params: CampaignCreateParams) async throws -> Campaign {
        return try await httpClient.request(
            method: "POST",
            path: "/campaigns",
            body: params
        )
    }

    /// Partially updates a campaign. Only provided fields are changed.
    ///
    /// - Parameters:
    ///   - id: The campaign's unique identifier.
    ///   - params: The fields to update.
    /// - Returns: The updated campaign.
    public func update(id: String, params: CampaignUpdateParams) async throws -> Campaign {
        return try await httpClient.request(
            method: "PATCH",
            path: "/campaigns/\(encodePath(id))",
            body: params
        )
    }

    /// Permanently deletes a campaign.
    ///
    /// - Parameter id: The campaign's unique identifier.
    public func delete(id: String) async throws {
        try await httpClient.requestVoid(
            method: "DELETE",
            path: "/campaigns/\(encodePath(id))"
        )
    }

    /// Returns an async sequence that automatically paginates through all campaigns.
    ///
    /// - Parameter params: Optional query parameters for filtering, sorting, and page size.
    /// - Returns: An `AutoPagingSequence` of campaigns.
    public func listAutoPaging(params: ListParams? = nil) -> AutoPagingSequence<Campaign> {
        return AutoPagingSequence(params: params) { listParams in
            try await self.list(params: listParams)
        }
    }
}

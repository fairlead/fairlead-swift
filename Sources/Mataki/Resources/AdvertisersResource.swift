import Foundation

/// Provides access to the Advertisers API.
public struct AdvertisersResource: Sendable {
    let httpClient: HTTPClient

    /// Retrieves a paginated list of advertisers.
    ///
    /// - Parameter params: Optional query parameters for filtering, sorting, and pagination.
    /// - Returns: A paginated list of advertisers.
    public func list(params: ListParams? = nil) async throws -> ListResponse<Advertiser> {
        return try await httpClient.request(
            method: "GET",
            path: "/advertisers",
            queryItems: params?.queryItems()
        )
    }

    /// Retrieves a single advertiser by ID.
    ///
    /// - Parameter id: The advertiser's unique identifier.
    /// - Returns: The advertiser.
    public func get(id: String) async throws -> Advertiser {
        return try await httpClient.request(
            method: "GET",
            path: "/advertisers/\(encodePath(id))"
        )
    }

    /// Creates a new advertiser.
    ///
    /// - Parameter params: The advertiser creation parameters.
    /// - Returns: The created advertiser.
    public func create(params: AdvertiserCreateParams) async throws -> Advertiser {
        return try await httpClient.request(
            method: "POST",
            path: "/advertisers",
            body: params
        )
    }

    /// Partially updates an advertiser. Only provided fields are changed.
    ///
    /// - Parameters:
    ///   - id: The advertiser's unique identifier.
    ///   - params: The fields to update.
    /// - Returns: The updated advertiser.
    public func update(id: String, params: AdvertiserUpdateParams) async throws -> Advertiser {
        return try await httpClient.request(
            method: "PATCH",
            path: "/advertisers/\(encodePath(id))",
            body: params
        )
    }

    /// Permanently deletes an advertiser.
    ///
    /// - Parameter id: The advertiser's unique identifier.
    public func delete(id: String) async throws {
        try await httpClient.requestVoid(
            method: "DELETE",
            path: "/advertisers/\(encodePath(id))"
        )
    }

    /// Returns an async sequence that automatically paginates through all advertisers.
    ///
    /// - Parameter params: Optional query parameters for filtering, sorting, and page size.
    /// - Returns: An `AutoPagingSequence` of advertisers.
    public func listAutoPaging(params: ListParams? = nil) -> AutoPagingSequence<Advertiser> {
        return AutoPagingSequence(params: params) { listParams in
            try await self.list(params: listParams)
        }
    }
}

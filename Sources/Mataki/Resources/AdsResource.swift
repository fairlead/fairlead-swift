import Foundation

/// Provides access to the Ads API.
public struct AdsResource: Sendable {
    let httpClient: HTTPClient

    /// Retrieves a paginated list of ads.
    ///
    /// - Parameter params: Optional query parameters for filtering, sorting, and pagination.
    /// - Returns: A paginated list of ads.
    public func list(params: ListParams? = nil) async throws -> ListResponse<Ad> {
        return try await httpClient.request(
            method: "GET",
            path: "/ads",
            queryItems: params?.queryItems()
        )
    }

    /// Retrieves a single ad by ID.
    ///
    /// - Parameter id: The ad's unique identifier.
    /// - Returns: The ad.
    public func get(id: String) async throws -> Ad {
        return try await httpClient.request(
            method: "GET",
            path: "/ads/\(encodePath(id))"
        )
    }

    /// Creates a new ad.
    ///
    /// - Parameter params: The ad creation parameters.
    /// - Returns: The created ad.
    public func create(params: AdCreateParams) async throws -> Ad {
        return try await httpClient.request(
            method: "POST",
            path: "/ads",
            body: params
        )
    }

    /// Partially updates an ad. Only provided fields are changed.
    ///
    /// - Parameters:
    ///   - id: The ad's unique identifier.
    ///   - params: The fields to update.
    /// - Returns: The updated ad.
    public func update(id: String, params: AdUpdateParams) async throws -> Ad {
        return try await httpClient.request(
            method: "PATCH",
            path: "/ads/\(encodePath(id))",
            body: params
        )
    }

    /// Permanently deletes an ad.
    ///
    /// - Parameter id: The ad's unique identifier.
    public func delete(id: String) async throws {
        try await httpClient.requestVoid(
            method: "DELETE",
            path: "/ads/\(encodePath(id))"
        )
    }

    /// Returns an async sequence that automatically paginates through all ads.
    ///
    /// - Parameter params: Optional query parameters for filtering, sorting, and page size.
    /// - Returns: An `AutoPagingSequence` of ads.
    public func listAutoPaging(params: ListParams? = nil) -> AutoPagingSequence<Ad> {
        return AutoPagingSequence(params: params) { listParams in
            try await self.list(params: listParams)
        }
    }
}

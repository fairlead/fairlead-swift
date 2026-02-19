import Foundation

/// Provides access to the Placements API.
public struct PlacementsResource: Sendable {
    let httpClient: HTTPClient

    /// Retrieves a paginated list of placements.
    ///
    /// - Parameter params: Optional query parameters for filtering, sorting, and pagination.
    /// - Returns: A paginated list of placements.
    public func list(params: ListParams? = nil) async throws -> ListResponse<Placement> {
        return try await httpClient.request(
            method: "GET",
            path: "/placements",
            queryItems: params?.queryItems()
        )
    }

    /// Retrieves a single placement by ID.
    ///
    /// - Parameter id: The placement's unique identifier.
    /// - Returns: The placement.
    public func get(id: String) async throws -> Placement {
        return try await httpClient.request(
            method: "GET",
            path: "/placements/\(encodePath(id))"
        )
    }

    /// Creates a new placement.
    ///
    /// - Parameter params: The placement creation parameters.
    /// - Returns: The created placement.
    public func create(params: PlacementCreateParams) async throws -> Placement {
        return try await httpClient.request(
            method: "POST",
            path: "/placements",
            body: params
        )
    }

    /// Partially updates a placement. Only provided fields are changed.
    ///
    /// - Parameters:
    ///   - id: The placement's unique identifier.
    ///   - params: The fields to update.
    /// - Returns: The updated placement.
    public func update(id: String, params: PlacementUpdateParams) async throws -> Placement {
        return try await httpClient.request(
            method: "PATCH",
            path: "/placements/\(encodePath(id))",
            body: params
        )
    }

    /// Permanently deletes a placement.
    ///
    /// - Parameter id: The placement's unique identifier.
    public func delete(id: String) async throws {
        try await httpClient.requestVoid(
            method: "DELETE",
            path: "/placements/\(encodePath(id))"
        )
    }

    /// Returns an async sequence that automatically paginates through all placements.
    ///
    /// - Parameter params: Optional query parameters for filtering, sorting, and page size.
    /// - Returns: An `AutoPagingSequence` of placements.
    public func listAutoPaging(params: ListParams? = nil) -> AutoPagingSequence<Placement> {
        return AutoPagingSequence(params: params) { listParams in
            try await self.list(params: listParams)
        }
    }
}

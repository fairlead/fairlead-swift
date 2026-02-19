import Foundation

/// Provides access to the Line Items API.
public struct LineItemsResource: Sendable {
    let httpClient: HTTPClient

    /// Retrieves a paginated list of line items.
    ///
    /// - Parameter params: Optional query parameters for filtering, sorting, and pagination.
    /// - Returns: A paginated list of line items.
    public func list(params: ListParams? = nil) async throws -> ListResponse<LineItem> {
        return try await httpClient.request(
            method: "GET",
            path: "/line-items",
            queryItems: params?.queryItems()
        )
    }

    /// Retrieves a single line item by ID.
    ///
    /// - Parameter id: The line item's unique identifier.
    /// - Returns: The line item.
    public func get(id: String) async throws -> LineItem {
        return try await httpClient.request(
            method: "GET",
            path: "/line-items/\(encodePath(id))"
        )
    }

    /// Creates a new line item.
    ///
    /// - Parameter params: The line item creation parameters.
    /// - Returns: The created line item.
    public func create(params: LineItemCreateParams) async throws -> LineItem {
        return try await httpClient.request(
            method: "POST",
            path: "/line-items",
            body: params
        )
    }

    /// Partially updates a line item. Only provided fields are changed.
    ///
    /// - Parameters:
    ///   - id: The line item's unique identifier.
    ///   - params: The fields to update.
    /// - Returns: The updated line item.
    public func update(id: String, params: LineItemUpdateParams) async throws -> LineItem {
        return try await httpClient.request(
            method: "PATCH",
            path: "/line-items/\(encodePath(id))",
            body: params
        )
    }

    /// Permanently deletes a line item.
    ///
    /// - Parameter id: The line item's unique identifier.
    public func delete(id: String) async throws {
        try await httpClient.requestVoid(
            method: "DELETE",
            path: "/line-items/\(encodePath(id))"
        )
    }

    /// Returns an async sequence that automatically paginates through all line items.
    ///
    /// - Parameter params: Optional query parameters for filtering, sorting, and page size.
    /// - Returns: An `AutoPagingSequence` of line items.
    public func listAutoPaging(params: ListParams? = nil) -> AutoPagingSequence<LineItem> {
        return AutoPagingSequence(params: params) { listParams in
            try await self.list(params: listParams)
        }
    }
}

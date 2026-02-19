import Foundation

/// Provides access to the Organizations API.
public struct OrganizationsResource: Sendable {
    let httpClient: HTTPClient

    /// Retrieves a paginated list of organizations.
    ///
    /// - Parameter params: Optional query parameters for filtering, sorting, and pagination.
    /// - Returns: A paginated list of organizations.
    public func list(params: ListParams? = nil) async throws -> ListResponse<Organization> {
        return try await httpClient.request(
            method: "GET",
            path: "/organizations",
            queryItems: params?.queryItems()
        )
    }

    /// Retrieves a single organization by ID.
    ///
    /// - Parameter id: The organization's unique identifier.
    /// - Returns: The organization.
    public func get(id: String) async throws -> Organization {
        return try await httpClient.request(
            method: "GET",
            path: "/organizations/\(encodePath(id))"
        )
    }

    /// Creates a new organization.
    ///
    /// - Parameter params: The organization creation parameters.
    /// - Returns: The created organization.
    public func create(params: OrganizationCreateParams) async throws -> Organization {
        return try await httpClient.request(
            method: "POST",
            path: "/organizations",
            body: params
        )
    }

    /// Partially updates an organization. Only provided fields are changed.
    ///
    /// - Parameters:
    ///   - id: The organization's unique identifier.
    ///   - params: The fields to update.
    /// - Returns: The updated organization.
    public func update(id: String, params: OrganizationUpdateParams) async throws -> Organization {
        return try await httpClient.request(
            method: "PATCH",
            path: "/organizations/\(encodePath(id))",
            body: params
        )
    }

    /// Permanently deletes an organization.
    ///
    /// - Parameter id: The organization's unique identifier.
    public func delete(id: String) async throws {
        try await httpClient.requestVoid(
            method: "DELETE",
            path: "/organizations/\(encodePath(id))"
        )
    }

    /// Returns an async sequence that automatically paginates through all organizations.
    ///
    /// - Parameter params: Optional query parameters for filtering, sorting, and page size.
    /// - Returns: An `AutoPagingSequence` of organizations.
    public func listAutoPaging(params: ListParams? = nil) -> AutoPagingSequence<Organization> {
        return AutoPagingSequence(params: params) { listParams in
            try await self.list(params: listParams)
        }
    }
}

import Foundation

/// Provides access to the API Keys API.
///
/// Note: API keys do not support `get` or `update` operations.
public struct ApiKeysResource: Sendable {
    let httpClient: HTTPClient

    /// Retrieves a paginated list of API keys.
    ///
    /// - Parameter params: Optional query parameters for filtering, sorting, and pagination.
    /// - Returns: A paginated list of API keys.
    public func list(params: ListParams? = nil) async throws -> ListResponse<ApiKey> {
        return try await httpClient.request(
            method: "GET",
            path: "/api-keys",
            queryItems: params?.queryItems()
        )
    }

    /// Creates a new API key.
    ///
    /// The raw key is returned once in the response and cannot be retrieved again.
    ///
    /// - Parameter params: The API key creation parameters.
    /// - Returns: The created API key and its raw secret.
    public func create(params: ApiKeyCreateParams) async throws -> CreateApiKeyResponse {
        return try await httpClient.request(
            method: "POST",
            path: "/api-keys",
            body: params
        )
    }

    /// Permanently deletes an API key.
    ///
    /// - Parameter id: The API key's unique identifier.
    public func delete(id: String) async throws {
        try await httpClient.requestVoid(
            method: "DELETE",
            path: "/api-keys/\(encodePath(id))"
        )
    }

    /// Returns an async sequence that automatically paginates through all API keys.
    ///
    /// - Parameter params: Optional query parameters for filtering, sorting, and page size.
    /// - Returns: An `AutoPagingSequence` of API keys.
    public func listAutoPaging(params: ListParams? = nil) -> AutoPagingSequence<ApiKey> {
        return AutoPagingSequence(params: params) { listParams in
            try await self.list(params: listParams)
        }
    }
}

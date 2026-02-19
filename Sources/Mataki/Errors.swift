import Foundation

/// Errors thrown by the Mataki SDK.
public enum MatakiError: Error, @unchecked Sendable {
    /// The API returned an HTTP error response (4xx/5xx).
    case api(APIError)
    /// A network or transport error occurred.
    case connection(Error)
    /// The response could not be parsed or was unexpected.
    case invalidResponse(String)
}

/// An error returned by the Mataki API (4xx/5xx responses).
public struct APIError: Error, Sendable, Equatable {
    /// The HTTP status code.
    public let statusCode: Int
    /// The error type identifier (e.g. "not_found_error", "invalid_request_error").
    public let type: String
    /// A human-readable error message.
    public let message: String
    /// Validation error details (typically on 400 responses).
    public let details: [ErrorDetail]
    /// The request ID for support reference.
    public let requestId: String?

    public init(statusCode: Int, type: String, message: String, details: [ErrorDetail] = [], requestId: String? = nil) {
        self.statusCode = statusCode
        self.type = type
        self.message = message
        self.details = details
        self.requestId = requestId
    }

    public var localizedDescription: String {
        if let requestId = requestId, !requestId.isEmpty {
            return "\(type) (status \(statusCode), request_id: \(requestId)): \(message)"
        }
        return "\(type) (status \(statusCode)): \(message)"
    }
}

/// A single validation error or sub-error within an API error response.
public struct ErrorDetail: Codable, Sendable, Equatable {
    /// The field that caused the error, if applicable.
    public let field: String?
    /// The error code (e.g. "required", "invalid_type").
    public let code: String
    /// A human-readable description of the error.
    public let message: String

    public init(field: String? = nil, code: String, message: String) {
        self.field = field
        self.code = code
        self.message = message
    }
}

// MARK: - Error Envelope (internal)

/// The top-level error response envelope: `{"error": {...}}`.
struct ErrorEnvelope: Codable {
    let error: ErrorBody
}

/// The inner error object within the envelope.
struct ErrorBody: Codable {
    let type: String
    let message: String
    let code: Int?
    let details: [ErrorDetail]?
    let requestId: String?

    enum CodingKeys: String, CodingKey {
        case type, message, code, details
        case requestId = "request_id"
    }
}

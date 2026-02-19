import Foundation

/// Internal HTTP client that handles request building, header injection, and response parsing.
struct HTTPClient: Sendable {
    let config: ClientConfig
    let session: URLSession

    init(config: ClientConfig) {
        self.config = config
        if let session = config.urlSession {
            self.session = session
        } else {
            let sessionConfig = URLSessionConfiguration.default
            sessionConfig.timeoutIntervalForRequest = config.timeout
            self.session = URLSession(configuration: sessionConfig)
        }
    }

    // MARK: - JSON Coding

    static let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)

            // Try ISO 8601 with fractional seconds first, then without
            if let date = ISO8601DateFormatter.withFractionalSeconds.date(from: dateString) {
                return date
            }
            if let date = ISO8601DateFormatter.standard.date(from: dateString) {
                return date
            }
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Unable to parse date: \(dateString)"
            )
        }
        return decoder
    }()

    static let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        encoder.dateEncodingStrategy = .custom { date, encoder in
            var container = encoder.singleValueContainer()
            let dateString = ISO8601DateFormatter.withFractionalSeconds.string(from: date)
            try container.encode(dateString)
        }
        return encoder
    }()

    // MARK: - Request Execution

    /// Sends an HTTP request and decodes the JSON response.
    ///
    /// - Parameters:
    ///   - method: The HTTP method (GET, POST, PATCH, DELETE).
    ///   - path: The API path (e.g. "/organizations").
    ///   - queryItems: Optional URL query parameters.
    ///   - body: Optional request body to encode as JSON.
    /// - Returns: The decoded response.
    /// - Throws: `MatakiError` on failure.
    func request<T: Decodable & Sendable>(
        method: String,
        path: String,
        queryItems: [URLQueryItem]? = nil,
        body: (any Encodable)? = nil
    ) async throws -> T {
        let (data, _) = try await executeRequest(method: method, path: path, queryItems: queryItems, body: body)
        return try decodeResponse(data)
    }

    /// Sends an HTTP request that expects no response body (e.g. DELETE returning 204).
    ///
    /// - Parameters:
    ///   - method: The HTTP method.
    ///   - path: The API path.
    ///   - queryItems: Optional URL query parameters.
    ///   - body: Optional request body to encode as JSON.
    /// - Throws: `MatakiError` on failure.
    func requestVoid(
        method: String,
        path: String,
        queryItems: [URLQueryItem]? = nil,
        body: (any Encodable)? = nil
    ) async throws {
        let _ = try await executeRequest(method: method, path: path, queryItems: queryItems, body: body)
    }

    // MARK: - Private

    private func executeRequest(
        method: String,
        path: String,
        queryItems: [URLQueryItem]?,
        body: (any Encodable)?
    ) async throws -> (Data, HTTPURLResponse) {
        let urlRequest = try buildRequest(method: method, path: path, queryItems: queryItems, body: body)

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(for: urlRequest)
        } catch {
            throw MatakiError.connection(error)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw MatakiError.invalidResponse("Response was not an HTTP response")
        }

        if httpResponse.statusCode >= 400 {
            throw handleErrorResponse(data: data, statusCode: httpResponse.statusCode)
        }

        return (data, httpResponse)
    }

    private func buildRequest(
        method: String,
        path: String,
        queryItems: [URLQueryItem]?,
        body: (any Encodable)?
    ) throws -> URLRequest {
        guard var components = URLComponents(string: config.baseURL + path) else {
            throw MatakiError.invalidResponse("Invalid URL: \(config.baseURL + path)")
        }

        if let queryItems = queryItems, !queryItems.isEmpty {
            components.queryItems = queryItems
        }

        guard let url = components.url else {
            throw MatakiError.invalidResponse("Could not construct URL from components")
        }

        var request = URLRequest(url: url)
        request.httpMethod = method

        // Set standard headers
        request.setValue("Bearer \(config.apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue(config.version, forHTTPHeaderField: "Mataki-Version")
        request.setValue("mataki-swift/\(version)", forHTTPHeaderField: "User-Agent")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        if let body = body {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            do {
                request.httpBody = try Self.encoder.encode(AnyEncodable(body))
            } catch {
                throw MatakiError.invalidResponse("Failed to encode request body: \(error.localizedDescription)")
            }
        }

        return request
    }

    private func decodeResponse<T: Decodable>(_ data: Data) throws -> T {
        do {
            return try Self.decoder.decode(T.self, from: data)
        } catch {
            let bodyPreview = String(data: data.prefix(500), encoding: .utf8) ?? "<binary>"
            throw MatakiError.invalidResponse("Failed to decode response: \(error.localizedDescription). Body: \(bodyPreview)")
        }
    }

    private func handleErrorResponse(data: Data, statusCode: Int) -> MatakiError {
        // Try to decode the error envelope
        do {
            // Use a decoder without key strategy conversion since error envelope uses explicit CodingKeys
            let decoder = JSONDecoder()
            let envelope = try decoder.decode(ErrorEnvelope.self, from: data)
            let body = envelope.error
            return .api(APIError(
                statusCode: statusCode,
                type: body.type,
                message: body.message,
                details: body.details ?? [],
                requestId: body.requestId
            ))
        } catch {
            // If the body is not valid JSON, use the raw text
            let message = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "Unknown error"
            return .api(APIError(
                statusCode: statusCode,
                type: "api_error",
                message: message
            ))
        }
    }
}

// MARK: - AnyEncodable

/// Type-erased Encodable wrapper for encoding arbitrary body values.
struct AnyEncodable: Encodable, @unchecked Sendable {
    private let _encode: (Encoder) throws -> Void

    init(_ value: any Encodable) {
        self._encode = { encoder in
            try value.encode(to: encoder)
        }
    }

    func encode(to encoder: Encoder) throws {
        try _encode(encoder)
    }
}

// MARK: - ISO8601DateFormatter Extensions

extension ISO8601DateFormatter {
    static let withFractionalSeconds: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()

    static let standard: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter
    }()
}

// MARK: - URL Path Encoding Helper

/// Percent-encodes an ID for safe use in URL paths.
func encodePath(_ id: String) -> String {
    return id.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? id
}

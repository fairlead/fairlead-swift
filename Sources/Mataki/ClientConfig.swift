import Foundation

/// The default API base URL.
let defaultBaseURL = "https://api.mataki.dev"

/// The default request timeout in seconds.
let defaultTimeout: TimeInterval = 30

/// The API version this SDK release is pinned to.
///
/// Each SDK release targets a specific API version date to ensure consistent behavior.
/// Use `.version("latest")` to opt out.
public let defaultAPIVersion = "2026-02-16"

/// Configuration options for the Mataki client.
public enum ClientOption: Sendable {
    /// Override the default API base URL.
    case baseURL(String)
    /// Set the Mataki-Version header value. Accepts "latest" or a date like "2026-02-16".
    case version(String)
    /// Set the request timeout in seconds.
    case timeout(TimeInterval)
    /// Provide a custom URLSession for requests.
    case urlSession(URLSession)
}

/// Internal configuration state for the client.
struct ClientConfig: Sendable {
    var apiKey: String
    var baseURL: String
    var version: String
    var timeout: TimeInterval
    var urlSession: URLSession?

    static func resolve(apiKey: String, options: [ClientOption]) -> ClientConfig {
        var config = ClientConfig(
            apiKey: apiKey,
            baseURL: defaultBaseURL,
            version: defaultAPIVersion,
            timeout: defaultTimeout,
            urlSession: nil
        )

        for option in options {
            switch option {
            case .baseURL(let url):
                config.baseURL = url
            case .version(let version):
                config.version = version
            case .timeout(let timeout):
                config.timeout = timeout
            case .urlSession(let session):
                config.urlSession = session
            }
        }

        return config
    }
}

import Foundation
import XCTest

/// A URLProtocol subclass that intercepts all URLSession requests for testing.
///
/// Use `MockURLProtocol.requestHandler` to set a closure that receives the request
/// and returns the mock response data and HTTP response.
final class MockURLProtocol: URLProtocol, @unchecked Sendable {
    /// Handler called for each intercepted request.
    /// Set this before making any requests.
    static var requestHandler: ((URLRequest) throws -> (Data, HTTPURLResponse))?

    /// Captured requests for assertion in tests.
    static var capturedRequests: [URLRequest] = []

    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    override func startLoading() {
        Self.capturedRequests.append(request)

        guard let handler = Self.requestHandler else {
            let error = NSError(
                domain: "MockURLProtocol",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "No request handler set"]
            )
            client?.urlProtocol(self, didFailWithError: error)
            return
        }

        do {
            let (data, response) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {
        // No-op
    }

    /// Resets the handler and captured requests.
    static func reset() {
        requestHandler = nil
        capturedRequests = []
    }
}

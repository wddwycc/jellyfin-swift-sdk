import Foundation
import HTTPTypes
import OpenAPIRuntime
import OpenAPIURLSession

public class JellyFinSDK {

    private let configuration: ClientConfiguration
    
    public init(configuration: ClientConfiguration) {
        self.configuration = configuration
    }
    
    public func authenticate(username: String, password: String) async throws -> Client {
        let client = Client(
            serverURL: configuration.serverURL,
            configuration: Configuration(dateTranscoder: CustomDateTranscoder()),
            transport: URLSessionTransport(),
            middlewares: [AuthMiddleware.init(configuration: configuration, accessToken: nil)]
        )
        let res = try await client.AuthenticateUserByName(.init(
            headers: .init(accept: [.init(contentType: .json)]),
            body: .application__ast__plus_json(.init(value1: .init(Username: username, Pw: password))))
        )
        return Client(
            serverURL: configuration.serverURL,
            configuration: Configuration(dateTranscoder: CustomDateTranscoder()),
            transport: URLSessionTransport(),
            middlewares: [AuthMiddleware.init(configuration: configuration, accessToken: try res.ok.body.json.AccessToken)]
        )
    }
}

public struct ClientConfiguration: Sendable {
    let serverURL: URL
    let client: String
    let device: String
    let deviceId: String
    let version: String
}

struct AuthMiddleware: ClientMiddleware {
    
    let configuration: ClientConfiguration
    let accessToken: String?

    func intercept(
        _ request: HTTPRequest,
        body: HTTPBody?,
        baseURL: URL,
        operationID: String,
        next: (HTTPRequest, HTTPBody?, URL) async throws -> (HTTPResponse, HTTPBody?)
    ) async throws -> (HTTPResponse, HTTPBody?) {
        var request = request
        var items: [(String, String)] = [
            ("Client", configuration.client),
            ("Device", configuration.device),
            ("DeviceId", configuration.deviceId),
            ("Version", configuration.version)
        ]
        if let accessToken {
            items.append(("Token", accessToken))
        }
        request.headerFields[.authorization] = "MediaBrowser " + items.map { "\($0.0)=\"\($0.1)\"" }.joined(separator: ",")
        return try await next(request, body, baseURL)
    }
}

// The reason why this exists: https://github.com/apple/swift-openapi-generator/issues/84
struct CustomDateTranscoder: DateTranscoder {
    public func encode(_ date: Date) throws -> String { ISO8601DateFormatter().string(from: date) }

    // Example: 2024-10-14T01:48:04.5140668Z
    public func decode(_ dateString: String) throws -> Date {
        let iso8601DateFormatter = ISO8601DateFormatter()
        iso8601DateFormatter.formatOptions = [.withFractionalSeconds]
        guard let date = iso8601DateFormatter.date(from: dateString) else {
            throw DecodingError.dataCorrupted(
                .init(codingPath: [], debugDescription: "Expected date string to be ISO8601-formatted.")
            )
        }
        return date
    }
}

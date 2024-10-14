import Foundation
import Testing
@testable import jellyfin_swift_sdk

@Test func authorizeAndCallAPI() async throws {
    let sdk = JellyFinSDK.init(configuration: .init(
        serverURL: URL.init(string: "http://192.168.0.80:8096")!,
        client: "jellyfin-music",
        device: "macos",
        deviceId: UUID().uuidString,
        version: "0.0.0"
    ))
    let client = try await sdk.authenticate(username: "dwen", password: "!TDV3Mck5ueiJRv")
    let artists = try await client.GetArtists(.init(query: .init(), headers: .init(accept: [.init(contentType: .json)])))
    let _ = try artists.ok.body.json.TotalRecordCount
}

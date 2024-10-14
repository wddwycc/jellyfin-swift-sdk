# jellyfin-swift-sdk

Jellyfin Swift SDK based on `apple/swift-openapi-generator` and `apple/swift-openapi-urlsession`.

## How to use

Initialize and authroize the client: 

```swift
import JellyfinSwiftSDK

let sdk = JellyFinSDK.init(configuration: .init(
    serverURL: URL.init(string: "<server-url>")!,
    client: "<client>",
    device: "<device>",
    deviceId: "<device-id>",
    version: "<version>"
))
let client = try await sdk.authenticate(username: "<username>", password: "<password>")
```

Then you will be able to use the client for Jellfyin APIs, for example:

```swift
let artists = try await client.GetArtists(.init(query: .init(), headers: .init(accept: [.init(contentType: .json)])))
```

## Known Issue

`GetSchedulesDirectCountries` and `GetNamedConfiguration` are disabled for now becaused the codegen lib cannot handle such in schema: 

```json
"content": {
  "application/json": {
    "schema": {
      "type": "string",
      "format": "binary"
    }
  }
}
```

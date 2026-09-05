# swift-rfc-5322

Domain model for RFC 5322, the Internet Message Format: `RFC_5322.Mailbox` (display name, `Mailbox.LocalPart`, `RFC_1123.Domain`), `RFC_5322.Message` with its `Message.ID`, `RFC_5322.Header` with `Header.Name` and `Header.Value`, and `RFC_5322.DateTime` over `Time`. Every type validates on construction, reads its RFC text form through `init(_:)` / `init(ascii:)` and renders it through `description`; the `RFC 5322 Foundation Integration` product bridges the text forms to `Codable` and `Foundation.Date`. Byte-level parsing and serialization (`ASCII.Parseable`, `ASCII.Serializable`, `Binary.Serializable`, the nested `Coder` types and the `Message` renderer) live in [swift-rfc-5322-coder](https://github.com/swift-ietf/swift-rfc-5322-coder).

```swift
import Byte
import Byte_Standard_Library_Integration
import RFC_5322

let mailbox = try RFC_5322.Mailbox("John Doe <john@example.com>")
mailbox.address                                      // "john@example.com"

let message = try RFC_5322.Message(
    from: mailbox,
    to: [RFC_5322.Mailbox("jane@example.com")],
    date: RFC_5322.DateTime(secondsSinceEpoch: 1_609_459_200),
    subject: "Hello from Swift!",
    messageId: RFC_5322.Message.ID(uniqueId: "unique-id", domain: mailbox.domain),
    body: [Byte](utf8: "Hello, World!")
)
message.date.description                             // "Fri, 01 Jan 2021 00:00:00 +0000"
```

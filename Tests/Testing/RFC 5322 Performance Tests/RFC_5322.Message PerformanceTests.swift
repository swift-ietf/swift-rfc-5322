import Byte
import Testing

@testable import RFC_5322

extension PerformanceTests {
    @Suite(.serialized)
    struct `RFC_5322.Message` {

        @Test(.timed(iterations: 1000, warmup: 100, threshold: .microseconds(380)))
        func `render basic message to string`() throws {
            let message = try RFC_5322.Message(
                from: try RFC_5322.Mailbox("sender@example.com"),
                to: [try RFC_5322.Mailbox("recipient@example.com")],
                date: .init(secondsSinceEpoch: 0),
                subject: "Test",
                messageId: "<test@example.com>",
                body: "Hello, World!".utf8.map(Byte.init(bitPattern:))
            )
            _ = message.description
        }

        @Test(.timed(iterations: 1000, warmup: 100, threshold: .microseconds(650)))
        func `render message with multiple recipients`() throws {
            let message = try RFC_5322.Message(
                from: try RFC_5322.Mailbox("sender@example.com"),
                to: [
                    try RFC_5322.Mailbox("alice@example.com"),
                    try RFC_5322.Mailbox("bob@example.com"),
                    try RFC_5322.Mailbox("charlie@example.com"),
                ],
                date: .init(secondsSinceEpoch: 0),
                subject: "Group Message",
                messageId: "<group@example.com>",
                body: "Hello everyone!".utf8.map(Byte.init(bitPattern:))
            )
            _ = message.description
        }

        @Test(.timed(iterations: 1000, warmup: 100, threshold: .microseconds(750)))
        func `render message with all optional fields`() throws {
            let message = try RFC_5322.Message(
                from: RFC_5322.Mailbox("sender@example.com"),
                to: [RFC_5322.Mailbox("recipient@example.com")],
                cc: [RFC_5322.Mailbox("cc@example.com")],
                bcc: [RFC_5322.Mailbox("bcc@example.com")],
                replyTo: RFC_5322.Mailbox("replyto@example.com"),
                date: .init(secondsSinceEpoch: 0),
                subject: "Full Message",
                messageId: "<full@example.com>",
                body: "Test body".utf8.map(Byte.init(bitPattern:)),
                additionalHeaders: [
                    RFC_5322.Header(name: .xPriority, value: 1)
                ]
            )
            _ = message.description
        }

        @Test(.timed(iterations: 1000, warmup: 100, threshold: .microseconds(420)))
        func `render message with large body`() throws {
            let largeBody = String(repeating: "This is a test message. ", count: 100)
            let message = try RFC_5322.Message(
                from: try RFC_5322.Mailbox("sender@example.com"),
                to: [try RFC_5322.Mailbox("recipient@example.com")],
                date: .init(secondsSinceEpoch: 0),
                subject: "Large Message",
                messageId: "<large@example.com>",
                body: largeBody.utf8.map(Byte.init(bitPattern:))
            )
            _ = message.description
        }

        @Test(.timed(iterations: 1000, warmup: 100, threshold: .microseconds(370)))
        func `convert basic message to bytes`() throws {
            let message = try RFC_5322.Message(
                from: try RFC_5322.Mailbox("sender@example.com"),
                to: [try RFC_5322.Mailbox("recipient@example.com")],
                date: .init(secondsSinceEpoch: 0),
                subject: "Test",
                messageId: "<test@example.com>",
                body: "Hello".utf8.map(Byte.init(bitPattern:))
            )
            _ = [UInt8](message)
        }

        @Test(.timed(iterations: 1000, warmup: 100, threshold: .microseconds(420)))
        func `convert message with large body to bytes`() throws {
            let largeBody = String(repeating: "Test data. ", count: 200)
            let message = try RFC_5322.Message(
                from: try RFC_5322.Mailbox("sender@example.com"),
                to: [try RFC_5322.Mailbox("recipient@example.com")],
                date: .init(secondsSinceEpoch: 0),
                subject: "Large",
                messageId: "<large@example.com>",
                body: largeBody.utf8.map(Byte.init(bitPattern:))
            )
            _ = [UInt8](message)
        }

        @Test(
            .timed(iterations: 10000, warmup: 1000, threshold: .microseconds(140)),

            arguments: [try! RFC_5322.Mailbox("sender@example.com")]
        )
        func `generate message ID`(from: RFC_5322.Mailbox) throws {
            _ = RFC_5322.Message.ID(
                uniqueId: "test-unique-id-123",
                domain: from.domain
            )
        }
    }
}

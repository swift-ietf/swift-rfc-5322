import Byte
import Byte_Standard_Library_Integration
import RFC_5322
import Testing

@Suite
struct `RFC_5322.Message Tests` {

    @Test
    func `a message carries its required fields`() throws {
        let message = try RFC_5322.Message(
            from: RFC_5322.Mailbox("sender@example.com"),
            to: [RFC_5322.Mailbox("recipient@example.com")],
            date: RFC_5322.DateTime(secondsSinceEpoch: 0),
            subject: "Test Message",
            messageId: RFC_5322.Message.ID("<test@example.com>"),
            body: [Byte](utf8: "Hello, World!")
        )
        #expect(message.from.address == "sender@example.com")
        #expect(message.to.count == 1)
        #expect(message.to[0].address == "recipient@example.com")
        #expect(message.subject == "Test Message")
        #expect(message.messageId.description == "<test@example.com>")
        #expect(String(decoding: message.body, as: UTF8.self) == "Hello, World!")
    }

    @Test
    func `a message addresses several recipients`() throws {
        let message = try RFC_5322.Message(
            from: RFC_5322.Mailbox("sender@example.com"),
            to: [
                RFC_5322.Mailbox("alice@example.com"),
                RFC_5322.Mailbox("bob@example.com"),
                RFC_5322.Mailbox("charlie@example.com"),
            ],
            date: RFC_5322.DateTime(secondsSinceEpoch: 0),
            subject: "Group Message",
            messageId: RFC_5322.Message.ID("<group@example.com>"),
            body: [Byte](utf8: "Hello")
        )
        #expect(message.to.count == 3)
        #expect(message.to[0].address == "alice@example.com")
        #expect(message.to[1].address == "bob@example.com")
        #expect(message.to[2].address == "charlie@example.com")
    }

    @Test
    func `a message copies cc recipients`() throws {
        let message = try RFC_5322.Message(
            from: RFC_5322.Mailbox("sender@example.com"),
            to: [RFC_5322.Mailbox("primary@example.com")],
            cc: [RFC_5322.Mailbox("cc@example.com")],
            date: RFC_5322.DateTime(secondsSinceEpoch: 0),
            subject: "Test CC",
            messageId: RFC_5322.Message.ID("<cc-test@example.com>"),
            body: [Byte](utf8: "Test")
        )
        #expect(message.cc?.count == 1)
        #expect(message.cc?[0].address == "cc@example.com")
    }

    @Test
    func `a message blind-copies bcc recipients`() throws {
        let message = try RFC_5322.Message(
            from: RFC_5322.Mailbox("sender@example.com"),
            to: [RFC_5322.Mailbox("primary@example.com")],
            bcc: [RFC_5322.Mailbox("bcc@example.com")],
            date: RFC_5322.DateTime(secondsSinceEpoch: 0),
            subject: "Test BCC",
            messageId: RFC_5322.Message.ID("<bcc-test@example.com>"),
            body: [Byte](utf8: "Test")
        )
        #expect(message.bcc?.count == 1)
        #expect(message.bcc?[0].address == "bcc@example.com")
    }

    @Test
    func `a message names a reply-to mailbox`() throws {
        let message = try RFC_5322.Message(
            from: RFC_5322.Mailbox("sender@example.com"),
            to: [RFC_5322.Mailbox("recipient@example.com")],
            replyTo: RFC_5322.Mailbox("replyto@example.com"),
            date: RFC_5322.DateTime(secondsSinceEpoch: 0),
            subject: "Test Reply-To",
            messageId: RFC_5322.Message.ID("<reply-test@example.com>"),
            body: [Byte](utf8: "Test")
        )
        #expect(message.replyTo?.address == "replyto@example.com")
    }

    @Test
    func `a message carries additional headers`() throws {
        let message = try RFC_5322.Message(
            from: RFC_5322.Mailbox("sender@example.com"),
            to: [RFC_5322.Mailbox("recipient@example.com")],
            date: RFC_5322.DateTime(secondsSinceEpoch: 0),
            subject: "Test Headers",
            messageId: RFC_5322.Message.ID("<headers-test@example.com>"),
            body: [Byte](utf8: "Test"),
            additionalHeaders: [
                RFC_5322.Header(name: .xPriority, value: 1),
                RFC_5322.Header(name: .inReplyTo, value: .init("<previous@example.com>")),
            ]
        )
        #expect(message.additionalHeaders.count == 2)
        #expect(message.additionalHeaders[0].name == .xPriority)
        #expect(message.additionalHeaders[0].value == 1)
        #expect(message.additionalHeaders[1].name == .inReplyTo)
        #expect(message.additionalHeaders[.inReplyTo] == "<previous@example.com>")
    }

    @Test
    func `a message states its MIME version`() throws {
        let message = try RFC_5322.Message(
            from: RFC_5322.Mailbox("sender@example.com"),
            to: [RFC_5322.Mailbox("recipient@example.com")],
            date: RFC_5322.DateTime(secondsSinceEpoch: 0),
            subject: "Test MIME",
            messageId: RFC_5322.Message.ID("<mime-test@example.com>"),
            body: [Byte](utf8: "Test"),
            mimeVersion: "2.0"
        )
        #expect(message.mimeVersion == "2.0")
    }

    @Test
    func `the MIME version defaults to 1.0`() throws {
        let message = try RFC_5322.Message(
            from: RFC_5322.Mailbox("sender@example.com"),
            to: [RFC_5322.Mailbox("recipient@example.com")],
            date: RFC_5322.DateTime(secondsSinceEpoch: 0),
            subject: "Test",
            messageId: RFC_5322.Message.ID("<test@example.com>"),
            body: [Byte](utf8: "Test")
        )
        #expect(message.mimeVersion == "1.0")
    }

    @Test
    func `a message ID builds from a unique part and the sender's domain`() throws {
        let sender = try RFC_5322.Mailbox("sender@example.com")
        let messageId = RFC_5322.Message.ID(uniqueId: "test-123", domain: sender.domain)
        #expect(messageId.description == "<test-123@example.com>")
    }

    @Test
    func `a message ID reads from its angle-bracketed text form`() throws {
        let messageId = try RFC_5322.Message.ID("<test-123@example.com>")
        #expect(messageId.description == "<test-123@example.com>")
    }

    @Test
    func `a message ID without an at sign is rejected`() {
        #expect(throws: RFC_5322.Message.ID.Error.self) {
            _ = try RFC_5322.Message.ID("<test-123>")
        }
    }
}

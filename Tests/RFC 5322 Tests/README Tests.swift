import Byte
import Byte_Standard_Library_Integration
import RFC_5322
import Testing

@Suite
struct `README Tests` {

    @Test
    func `a mailbox reads from its text form`() throws {
        let mailbox = try RFC_5322.Mailbox("John Doe <john@example.com>")
        #expect(mailbox.displayName == "John Doe")
        #expect(mailbox.localPart.description == "john")
        #expect(mailbox.domain.name == "example.com")
        #expect(mailbox.address == "john@example.com")
    }

    @Test
    func `a mailbox builds from its parts`() throws {
        let mailbox = try RFC_5322.Mailbox(
            displayName: "Jane Smith",
            localPart: .init("jane"),
            domain: .init("example.com")
        )
        #expect(mailbox.description == "Jane Smith <jane@example.com>")
    }

    @Test
    func `a message carries its envelope and body`() throws {
        let message = try RFC_5322.Message(
            from: RFC_5322.Mailbox("John Doe <john@example.com>"),
            to: [RFC_5322.Mailbox("jane@example.com")],
            cc: [RFC_5322.Mailbox("cc@example.com")],
            replyTo: RFC_5322.Mailbox("replyto@example.com"),
            date: RFC_5322.DateTime(secondsSinceEpoch: 1_609_459_200),
            subject: "Hello from Swift!",
            messageId: RFC_5322.Message.ID(uniqueId: "test-unique-id", domain: .init("example.com")),
            body: [Byte](utf8: "Hello, World!"),
            additionalHeaders: [
                RFC_5322.Header(name: .xPriority, value: 1),
                RFC_5322.Header(name: .init("X-Mailer"), value: .init("Custom Mailer")),
            ]
        )

        #expect(message.from.displayName == "John Doe")
        #expect(message.to.count == 1)
        #expect(message.cc?.count == 1)
        #expect(message.replyTo?.address == "replyto@example.com")
        #expect(message.subject == "Hello from Swift!")
        #expect(message.messageId.description == "<test-unique-id@example.com>")
        #expect(message.additionalHeaders.count == 2)
        #expect(String(decoding: message.body, as: UTF8.self) == "Hello, World!")
    }

    @Test
    func `a date-time renders the RFC 5322 date form`() {
        let dateTime = RFC_5322.DateTime(secondsSinceEpoch: 1_609_459_200)
        #expect(dateTime.description == "Fri, 01 Jan 2021 00:00:00 +0000")
    }
}

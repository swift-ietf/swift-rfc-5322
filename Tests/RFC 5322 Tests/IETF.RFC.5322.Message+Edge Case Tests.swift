import RFC_5322
import Testing

extension `IETF.RFC.5322.Message Tests` {
    @Suite struct `Edge Case` {}
}

extension `IETF.RFC.5322.Message Tests`.`Edge Case` {

    @Test
    func `subject containing a bare CRLF is rejected`() throws {
        #expect(throws: IETF.RFC.`5322`.Message.Error.self) {
            _ = try IETF.RFC.`5322`.Message(
                from: try IETF.RFC.`5322`.Mailbox("sender@example.com"),
                to: [try IETF.RFC.`5322`.Mailbox("recipient@example.com")],
                date: .init(secondsSinceEpoch: 0),
                subject: "Free Money\r\nBcc: attacker@evil.com",
                messageId: try IETF.RFC.`5322`.Message.ID("<test@example.com>"),
                body: []
            )
        }
    }

    @Test
    func `subject containing a non-ASCII byte is rejected`() throws {
        #expect(throws: IETF.RFC.`5322`.Message.Error.self) {
            _ = try IETF.RFC.`5322`.Message(
                from: try IETF.RFC.`5322`.Mailbox("sender@example.com"),
                to: [try IETF.RFC.`5322`.Mailbox("recipient@example.com")],
                date: .init(secondsSinceEpoch: 0),
                subject: "Caf\u{00E9}",
                messageId: try IETF.RFC.`5322`.Message.ID("<test@example.com>"),
                body: []
            )
        }
    }

    @Test
    func `mimeVersion containing a bare CRLF is rejected`() throws {
        #expect(throws: IETF.RFC.`5322`.Message.Error.self) {
            _ = try IETF.RFC.`5322`.Message(
                from: try IETF.RFC.`5322`.Mailbox("sender@example.com"),
                to: [try IETF.RFC.`5322`.Mailbox("recipient@example.com")],
                date: .init(secondsSinceEpoch: 0),
                subject: "Hello",
                messageId: try IETF.RFC.`5322`.Message.ID("<test@example.com>"),
                body: [],
                mimeVersion: "1.0\r\nBcc: attacker@evil.com"
            )
        }
    }

    @Test
    func `mimeVersion containing a non-ASCII byte is rejected`() throws {
        #expect(throws: IETF.RFC.`5322`.Message.Error.self) {
            _ = try IETF.RFC.`5322`.Message(
                from: try IETF.RFC.`5322`.Mailbox("sender@example.com"),
                to: [try IETF.RFC.`5322`.Mailbox("recipient@example.com")],
                date: .init(secondsSinceEpoch: 0),
                subject: "Hello",
                messageId: try IETF.RFC.`5322`.Message.ID("<test@example.com>"),
                body: [],
                mimeVersion: "1.\u{00E9}0"
            )
        }
    }

    @Test
    func `valid subject and mimeVersion still construct a message`() throws {
        let message = try IETF.RFC.`5322`.Message(
            from: try IETF.RFC.`5322`.Mailbox("sender@example.com"),
            to: [try IETF.RFC.`5322`.Mailbox("recipient@example.com")],
            date: .init(secondsSinceEpoch: 0),
            subject: "Hello, World!",
            messageId: try IETF.RFC.`5322`.Message.ID("<test@example.com>"),
            body: []
        )
        #expect(message.subject == "Hello, World!")
        #expect(message.mimeVersion == "1.0")
    }
}

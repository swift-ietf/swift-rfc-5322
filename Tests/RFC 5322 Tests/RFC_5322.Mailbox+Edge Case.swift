import RFC_5322
import Testing

extension RFC_5322.Mailbox {
    @Suite struct `Edge Case` {}
}

extension RFC_5322.Mailbox.`Edge Case` {
    @Test
    func `display name containing a bare CRLF is rejected`() {
        #expect(throws: RFC_5322.Mailbox.Error.self) {
            _ = try RFC_5322.Mailbox(
                displayName: "Evil\r\nBcc: attacker@evil.com",
                localPart: .init("john"),
                domain: .init("example.com")
            )
        }
    }

    @Test
    func `display name containing a bare LF is rejected`() {
        #expect(throws: RFC_5322.Mailbox.Error.self) {
            _ = try RFC_5322.Mailbox(
                displayName: "Evil\nBcc: attacker@evil.com",
                localPart: .init("john"),
                domain: .init("example.com")
            )
        }
    }

    @Test
    func `display name containing a non-ASCII byte is rejected`() {
        #expect(throws: RFC_5322.Mailbox.Error.self) {
            _ = try RFC_5322.Mailbox(
                displayName: "Jos\u{00E9}",
                localPart: .init("jose"),
                domain: .init("example.com")
            )
        }
    }

    @Test
    func `display name containing a quote is escaped on serialization`() throws {
        let email = try RFC_5322.Mailbox(
            displayName: "Say \"Hi\"",
            localPart: .init("john"),
            domain: .init("example.com")
        )
        let rendered = email.description
        #expect(rendered == "\"Say \\\"Hi\\\"\" <john@example.com>")
    }

    @Test
    func `display name containing a backslash is escaped on serialization`() throws {
        let email = try RFC_5322.Mailbox(
            displayName: #"C:\Users\John"#,
            localPart: .init("john"),
            domain: .init("example.com")
        )
        let rendered = email.description
        #expect(rendered == #""C:\\Users\\John" <john@example.com>"#)
    }

    @Test
    func
        `parsing a string with an embedded CRLF in the display name is rejected rather than silently accepted`()
    {

        #expect(throws: RFC_5322.Mailbox.Error.self) {
            _ = try RFC_5322.Mailbox("Evil\r\nBcc: attacker@evil.com <john@example.com>")
        }
    }
}

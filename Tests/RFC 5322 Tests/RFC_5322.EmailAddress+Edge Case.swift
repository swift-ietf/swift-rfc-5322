//
//  RFC_5322.EmailAddress+Edge Case.swift
//  RFC 5322 Tests
//
//  Regression coverage for fable-448 F-002: CRLF header injection and
//  non-ASCII leakage via the previously-unvalidated `displayName` field.
//

import RFC_5322
import Testing

extension RFC_5322.EmailAddress {
    @Suite struct `Edge Case` {}
}

extension RFC_5322.EmailAddress.`Edge Case` {
    @Test
    func `display name containing a bare CRLF is rejected`() {
        #expect(throws: RFC_5322.EmailAddress.Error.self) {
            _ = try RFC_5322.EmailAddress(
                displayName: "Evil\r\nBcc: attacker@evil.com",
                localPart: .init("john"),
                domain: .init("example.com")
            )
        }
    }

    @Test
    func `display name containing a bare LF is rejected`() {
        #expect(throws: RFC_5322.EmailAddress.Error.self) {
            _ = try RFC_5322.EmailAddress(
                displayName: "Evil\nBcc: attacker@evil.com",
                localPart: .init("john"),
                domain: .init("example.com")
            )
        }
    }

    @Test
    func `display name containing a non-ASCII byte is rejected`() {
        #expect(throws: RFC_5322.EmailAddress.Error.self) {
            _ = try RFC_5322.EmailAddress(
                displayName: "Jos\u{00E9}",  // "José" — 'é' is non-ASCII
                localPart: .init("jose"),
                domain: .init("example.com")
            )
        }
    }

    @Test
    func `display name containing a quote is escaped on serialization`() throws {
        let email = try RFC_5322.EmailAddress(
            displayName: "Say \"Hi\"",
            localPart: .init("john"),
            domain: .init("example.com")
        )
        let rendered = String(email)
        #expect(rendered == "\"Say \\\"Hi\\\"\" <john@example.com>")
    }

    @Test
    func `display name containing a backslash is escaped on serialization`() throws {
        let email = try RFC_5322.EmailAddress(
            displayName: #"C:\Users\John"#,
            localPart: .init("john"),
            domain: .init("example.com")
        )
        let rendered = String(email)
        #expect(rendered == #""C:\\Users\\John" <john@example.com>"#)
    }

    @Test
    func `parsing a string with an embedded CRLF in the display name is rejected rather than silently accepted`() {
        // Simulates an attacker-controlled mailbox string reaching the
        // string-based / byte-based parser, not just the memberwise
        // initializer.
        #expect(throws: RFC_5322.EmailAddress.Error.self) {
            _ = try RFC_5322.EmailAddress("Evil\r\nBcc: attacker@evil.com <john@example.com>")
        }
    }
}

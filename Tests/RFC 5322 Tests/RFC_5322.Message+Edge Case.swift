//
//  RFC_5322.Message+Edge Case.swift
//  RFC 5322 Tests
//
//  Regression coverage for:
//  - fable-448 F-001: `RFC_5322.Message` no longer conforms to
//    `ASCII.Parseable` — the prior conformance's `init(ascii:)` was an
//    unconditional `fatalError`, a runtime landmine for any code path that
//    reached it (directly, or generically through an `ASCII.Parseable`
//    constraint). The absence is now a compile-time fact.
//  - fable-448 F-002: CRLF header injection and non-ASCII leakage via the
//    previously-unvalidated `subject` and `mimeVersion` fields.
//

import Parseable_ASCII_Primitives
import RFC_5322
import Testing

extension RFC_5322.Message {
    @Suite struct `Edge Case` {}
}

extension RFC_5322.Message.`Edge Case` {

    // MARK: - F-001: fatalError stub removed

    @Test
    func `Message no longer conforms to ASCII Parseable`() {
        // Pre-fix, `RFC_5322.Message` conformed to `ASCII.Parseable` and its
        // `init(ascii:)` unconditionally called `fatalError` — reaching it
        // crashed the process rather than throwing. Post-fix, the
        // conformance itself is gone, so this metatype cast fails to find
        // any conformance and the assertion holds.
        #expect(!(RFC_5322.Message.self is any ASCII.Parseable.Type))
    }

    // MARK: - F-002: subject / mimeVersion header injection guard

    @Test
    func `subject containing a bare CRLF is rejected`() throws {
        #expect(throws: RFC_5322.Message.Error.self) {
            _ = try RFC_5322.Message(
                from: try RFC_5322.EmailAddress("sender@example.com"),
                to: [try RFC_5322.EmailAddress("recipient@example.com")],
                date: .init(secondsSinceEpoch: 0),
                subject: "Free Money\r\nBcc: attacker@evil.com",
                messageId: "<test@example.com>",
                body: []
            )
        }
    }

    @Test
    func `subject containing a non-ASCII byte is rejected`() throws {
        #expect(throws: RFC_5322.Message.Error.self) {
            _ = try RFC_5322.Message(
                from: try RFC_5322.EmailAddress("sender@example.com"),
                to: [try RFC_5322.EmailAddress("recipient@example.com")],
                date: .init(secondsSinceEpoch: 0),
                subject: "Caf\u{00E9}",
                messageId: "<test@example.com>",
                body: []
            )
        }
    }

    @Test
    func `mimeVersion containing a bare CRLF is rejected`() throws {
        #expect(throws: RFC_5322.Message.Error.self) {
            _ = try RFC_5322.Message(
                from: try RFC_5322.EmailAddress("sender@example.com"),
                to: [try RFC_5322.EmailAddress("recipient@example.com")],
                date: .init(secondsSinceEpoch: 0),
                subject: "Hello",
                messageId: "<test@example.com>",
                body: [],
                mimeVersion: "1.0\r\nBcc: attacker@evil.com"
            )
        }
    }

    @Test
    func `mimeVersion containing a non-ASCII byte is rejected`() throws {
        #expect(throws: RFC_5322.Message.Error.self) {
            _ = try RFC_5322.Message(
                from: try RFC_5322.EmailAddress("sender@example.com"),
                to: [try RFC_5322.EmailAddress("recipient@example.com")],
                date: .init(secondsSinceEpoch: 0),
                subject: "Hello",
                messageId: "<test@example.com>",
                body: [],
                mimeVersion: "1.\u{00E9}0"
            )
        }
    }

    @Test
    func `valid subject and mimeVersion still construct a message`() throws {
        let message = try RFC_5322.Message(
            from: try RFC_5322.EmailAddress("sender@example.com"),
            to: [try RFC_5322.EmailAddress("recipient@example.com")],
            date: .init(secondsSinceEpoch: 0),
            subject: "Hello, World!",
            messageId: "<test@example.com>",
            body: []
        )
        #expect(message.subject == "Hello, World!")
        #expect(message.mimeVersion == "1.0")
    }
}

//
//  EmailAddressSerializationEquivalenceTests.swift
//  swift-rfc-5322
//
//  [FAM-012] composite re-cut guard. The EmailAddress `ASCII.Serializable` verb
//  (direct same-format composition of the LocalPart / Domain verbs) MUST emit
//  byte-identical output to the `Binary.Serializable` witness (`serializeBytes`)
//  for the display-name quoting path — the path the round-trip tests do not
//  output-assert. Asserts the refactor invariant directly (ASCII output == Binary
//  output), so no expected string is hand-derived.
//

import RFC_5322
import Testing

@Suite
struct `EmailAddress Serialization Equivalence` {

    @Test
    func `ASCII verb output equals Binary witness output for the display-name quoting path`() throws {
        // A display name containing a `,` is a non-letter/digit/whitespace special,
        // forcing the quoting wrapper — exactly the logic transcribed into the
        // ASCII verb.
        let email = try RFC_5322.EmailAddress("\"Doe, John\" <jd@example.com>")

        // ASCII.Serializable verb output, projected to bytes.
        let viaASCII: [Byte] = email.serialized

        // Binary.Serializable witness output.
        var viaBinary: [Byte] = []
        RFC_5322.EmailAddress.serialize(email, into: &viaBinary)

        #expect(viaASCII == viaBinary)
    }
}

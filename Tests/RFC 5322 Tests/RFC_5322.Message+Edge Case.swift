//
//  RFC_5322.Message+Edge Case.swift
//  RFC 5322 Tests
//
//  Regression coverage for fable-448 F-001: `RFC_5322.Message` no longer
//  conforms to `ASCII.Parseable` — the prior conformance's `init(ascii:)`
//  was an unconditional `fatalError`, a runtime landmine for any code path
//  that reached it (directly, or generically through an `ASCII.Parseable`
//  constraint). The absence is now a compile-time fact.
//

import Parseable_ASCII_Primitives
import RFC_5322
import Testing

extension RFC_5322.Message {
    @Suite struct `Edge Case` {}
}

extension RFC_5322.Message.`Edge Case` {
    @Test
    func `Message no longer conforms to ASCII Parseable`() {
        // Pre-fix, `RFC_5322.Message` conformed to `ASCII.Parseable` and its
        // `init(ascii:)` unconditionally called `fatalError` — reaching it
        // crashed the process rather than throwing. Post-fix, the
        // conformance itself is gone, so this metatype cast fails to find
        // any conformance and the assertion holds.
        #expect(!(RFC_5322.Message.self is any ASCII.Parseable.Type))
    }
}

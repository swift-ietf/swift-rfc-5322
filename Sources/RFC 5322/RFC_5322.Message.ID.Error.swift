//
//  RFC_5322.Message.ID.Error.swift
//  swift-rfc-5322
//
//  Error types for RFC 5322 Message-ID parsing
//

public import ASCII_Serializer_Primitives

extension RFC_5322.Message.ID {
    /// Error type for RFC 5322 Message-ID parsing
    public enum Error: Swift.Error, Sendable, Equatable {
        /// Missing @ separator in Message-ID
        case missingAtSign(String)

        /// Invalid character in Message-ID (must be printable ASCII, no spaces)
        case invalidCharacter(String, code: ASCII.Code, reason: String)

        /// Message-ID contains a non-ASCII byte (RFC 5322 Message-IDs are ASCII-only)
        case nonASCII(String)
    }
}

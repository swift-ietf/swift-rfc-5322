//
//  RFC_5322.Header.Value.Error.swift
//  swift-rfc-5322
//
//  Created by Coen ten Thije Boonkkamp on 24/11/2025.
//

public import ASCII_Serializer_Primitives

// MARK: - Header.Value Error Type

extension RFC_5322.Header.Value {
    /// Header value-specific error type for typed throws
    public enum Error: Swift.Error, Sendable, Equatable {
        /// Invalid folding whitespace
        case invalidFolding(String, code: ASCII.Code, reason: String)

        /// Invalid character in value
        case invalidCharacter(String, code: ASCII.Code, reason: String)
    }
}

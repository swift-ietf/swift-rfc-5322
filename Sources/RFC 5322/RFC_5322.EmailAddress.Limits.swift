//
//  RFC_5322.EmailAddress.Limits.swift
//  swift-rfc-5322
//
//  Created by Coen ten Thije Boonkkamp on 24/11/2025.
//

public import ASCII_Serializer_Primitives
import INCITS_4_1986

// MARK: - Constants and Validation
extension RFC_5322.EmailAddress {
    package enum Limits {}

    // Address format regex with optional display name
    nonisolated(unsafe) package static let addressRegex = /(?:((?:\".*?\"|[^<]+)\s+))?<(.*?)@(.*?)>/

    // Dot-atom regex: series of atoms separated by dots
    // RFC 5322 Section 3.2.3 defines atext (RFC 5321 references this same definition)
    // atext = ALPHA / DIGIT / "!" / "#" / "$" / "%" / "&" / "'" / "*" / "+" / "-" / "/" / "=" / "?" / "^" / "_" / "`" / "{" / "|" / "}" / "~"
    nonisolated(unsafe) package static let dotAtomRegex =
        /[a-zA-Z0-9!#$%&'\*\+\-\/=\?\^_`\{\|}~]+(?:\.[a-zA-Z0-9!#$%&'\*\+\-\/=\?\^_`\{\|}~]+)*/

    // Quoted string regex: allows any printable character except unescaped quotes
    nonisolated(unsafe) package static let quotedRegex = /(?:[^"\\\r\n]|\\["\\])+/
}

extension RFC_5322.EmailAddress.Limits {
    static let maxLength = 64  // Max length for local-part
}

// MARK: - atext Character Set

extension RFC_5322 {
    /// ASCII codes allowed in `atext` per RFC 5322 Section 3.2.3
    ///
    /// The `atext` rule defines printable US-ASCII characters that can appear in atoms:
    /// ```
    /// atext = ALPHA / DIGIT /    ; Printable US-ASCII
    ///         "!" / "#" /        ;  characters not including
    ///         "$" / "%" /        ;  specials. Used for atoms.
    ///         "&" / "'" /
    ///         "*" / "+" /
    ///         "-" / "/" /
    ///         "=" / "?" /
    ///         "^" / "_" /
    ///         "`" / "{" /
    ///         "|" / "}" /
    ///         "~"
    /// ```
    ///
    /// This set contains only the special symbols; ALPHA and DIGIT should be checked
    /// separately using `code.isLetter` and `code.isDigit` predicates on `ASCII.Code`.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// func isAtext(_ code: ASCII.Code) -> Bool {
    ///     code.isLetter || code.isDigit || RFC_5322.atextSymbols.contains(code)
    /// }
    /// ```
    public static let atextSymbols: Set<ASCII.Code> = [
        ASCII.Code.exclamationPoint,  // ! (0x21)
        ASCII.Code.numberSign,  // # (0x23)
        ASCII.Code.dollarSign,  // $ (0x24)
        ASCII.Code.percentSign,  // % (0x25)
        ASCII.Code.ampersand,  // & (0x26)
        ASCII.Code.apostrophe,  // ' (0x27)
        ASCII.Code.asterisk,  // * (0x2A)
        ASCII.Code.plusSign,  // + (0x2B)
        ASCII.Code.hyphen,  // - (0x2D)
        ASCII.Code.solidus,  // / (0x2F)
        ASCII.Code.equalsSign,  // = (0x3D)
        ASCII.Code.questionMark,  // ? (0x3F)
        ASCII.Code.circumflexAccent,  // ^ (0x5E)
        ASCII.Code.underline,  // _ (0x5F)
        ASCII.Code.leftSingleQuotationMark,  // ` (0x60)
        ASCII.Code.leftBrace,  // { (0x7B)
        ASCII.Code.verticalLine,  // | (0x7C)
        ASCII.Code.rightBrace,  // } (0x7D)
        ASCII.Code.tilde,  // ~ (0x7E)
    ]

    /// Tests if an ASCII code is a valid `atext` character per RFC 5322 Section 3.2.3
    ///
    /// Returns `true` if the code is ALPHA, DIGIT, or one of the allowed symbols.
    ///
    /// - Parameter code: The ASCII code to test
    /// - Returns: `true` if the code is valid in an atom
    @inlinable
    public static func isAtext(_ code: ASCII.Code) -> Bool {
        code.isLetter || code.isDigit || atextSymbols.contains(code)
    }
}

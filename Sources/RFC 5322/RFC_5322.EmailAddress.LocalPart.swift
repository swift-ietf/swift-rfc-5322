//
//  File.swift
//  swift-rfc-5322
//
//  Created by Coen ten Thije Boonkkamp on 24/11/2025.
//

public import ASCII_Serializer_Primitives
import INCITS_4_1986

// MARK: - Local Part
extension RFC_5322.EmailAddress {
    /// RFC 5322 compliant local-part
    public struct LocalPart: Hashable, Sendable {
        package let storage: Storage
    }
}

extension RFC_5322.EmailAddress.LocalPart {
    // swiftlint:disable:next nesting
    package enum Storage: Hashable {
        case dotAtom([Byte])  // Regular unquoted format (ASCII bytes)
        case quoted([Byte])  // Quoted string format (ASCII bytes)
    }
}

extension RFC_5322.EmailAddress.LocalPart: Binary.ASCII.Serializable {
    public static func serialize<Buffer>(
        ascii localPart: RFC_5322.EmailAddress.LocalPart,
        into buffer: inout Buffer
    ) where Buffer: RangeReplaceableCollection, Buffer.Element == Byte {
        switch localPart.storage {
        case .dotAtom(let bytes), .quoted(let bytes):
            buffer.append(contentsOf: bytes)
        }
    }

    /// Parses a local-part from canonical byte representation (CANONICAL PRIMITIVE)
    ///
    /// This is the primitive parser that works at the byte level.
    /// RFC 5322 local-parts are ASCII-only.
    ///
    /// ## Category Theory
    ///
    /// This is the fundamental parsing transformation:
    /// - **Domain**: [Byte] (ASCII bytes)
    /// - **Codomain**: RFC_5322.EmailAddress.LocalPart (structured data)
    ///
    /// String-based parsing is derived as composition:
    /// ```
    /// String → [Byte] (UTF-8 bytes) → LocalPart
    /// ```
    ///
    /// ## Example
    ///
    /// ```swift
    /// let bytes = Array<Byte>("user".utf8)
    /// let localPart = try RFC_5322.EmailAddress.LocalPart(ascii: bytes)
    /// ```
    ///
    /// - Parameter bytes: The ASCII byte representation of the local-part
    /// - Throws: `RFC_5322.EmailAddress.LocalPart.Error` if the bytes are malformed
    public init<Bytes: Collection>(ascii bytes: Bytes, in context: Void) throws(Error)
    where Bytes.Element == Byte {
        // Type-up: lift to ASCII.Code at the entry boundary so the body works
        // against ASCII.Code constants directly (RFC 5322 local-parts are strict ASCII).
        let codes: [ASCII.Code]
        do {
            codes = try Array<ASCII.Code>(bytes)
        } catch {
            throw Error.nonASCIICharacters
        }
        let count = codes.count

        // Check overall length first
        guard count <= RFC_5322.EmailAddress.Limits.maxLength else {
            throw Error.tooLong(count)
        }

        guard let first = codes.first, let last = codes.last else {
            throw Error.invalidDotAtom  // Empty local-part is invalid
        }

        // Handle quoted string format: starts and ends with quotation mark
        if first == ASCII.Code.quotationMark && last == ASCII.Code.quotationMark && count >= 2 {
            // Validate quoted-string content at byte level
            // quoted-string = [^"\\\r\n] or \\["\]
            var skipNext = false

            for index in 1..<(count - 1) {
                let code = codes[index]

                if skipNext {
                    skipNext = false
                    continue
                }

                if code == ASCII.Code.backslash {
                    // Mark to skip next character (escape sequence)
                    skipNext = true
                } else if code == ASCII.Code.quotationMark || code == ASCII.Code.cr || code == ASCII.Code.lf {
                    // Unescaped quote, CR, or LF not allowed
                    throw Error.invalidQuotedString
                }
            }

            // If we ended with backslash expecting next char, that's invalid
            if skipNext {
                throw Error.invalidQuotedString
            }

            self.storage = .quoted(Array<Byte>(bytes))
        }
        // Handle dot-atom format
        else {
            // Check for leading/trailing dots
            guard first != ASCII.Code.period && last != ASCII.Code.period else {
                throw Error.leadingOrTrailingDot
            }

            // Validate dot-atom characters and check for consecutive dots
            var previousCode: ASCII.Code?
            for code in codes {
                // Check for consecutive dots
                if code == ASCII.Code.period && previousCode == ASCII.Code.period {
                    throw Error.consecutiveDots
                }
                previousCode = code

                // Validate character: atext or period
                guard code == ASCII.Code.period || RFC_5322.isAtext(code) else {
                    throw Error.invalidDotAtom
                }
            }

            self.storage = .dotAtom(Array<Byte>(bytes))
        }
    }
}

extension RFC_5322.EmailAddress.LocalPart: CustomStringConvertible {}

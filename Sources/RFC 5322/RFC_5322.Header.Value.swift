//
//  RFC_5322.Header.Value.swift
//  swift-rfc-5322
//
//  Created by Coen ten Thije Boonkkamp on 19/11/2025.
//

public import ASCII_Serializer_Primitives
public import Binary_Serializable_Primitives
public import Parseable_ASCII_Primitives
import INCITS_4_1986

extension RFC_5322.Header {
    public struct Value: Sendable, Hashable, Codable {
        public let rawValue: String

        init(
            __unchecked: Void,
            rawValue: String
        ) {
            self.rawValue = rawValue
        }
    }
}

extension RFC_5322.Header.Value {
    /// Equality comparison (case-sensitive)
    public static func == (lhs: RFC_5322.Header.Value, rhs: RFC_5322.Header.Value) -> Bool {
        lhs.rawValue == rhs.rawValue
    }

    /// Equality comparison with raw value (case-sensitive)
    public static func == (lhs: RFC_5322.Header.Value, rhs: Self.RawValue) -> Bool {
        lhs.rawValue == rhs
    }
}

extension RFC_5322.Header.Value: Swift.RawRepresentable, ASCII.Serializable, Binary.Serializable {
    /// Creates a header value by validating `rawValue`, or `nil` if it is not valid.
    ///
    /// Re-provides the `Swift.RawRepresentable` requirement (previously inherited
    /// from the retired combined ASCII serializable protocol).
    public init?(rawValue: String) {
        try? self.init(rawValue)
    }

    /// Serializes `value` as ASCII bytes into `buffer` (own `ASCII.Serializable` verb).
    ///
    /// The bytes are the UTF-8 of the `String` `rawValue`, lifted into the
    /// `ASCII.Code` substrate. Re-homes the conformer off the retired canonical
    /// `Serializable` tier onto its own ASCII verb.
    public static func serialize<Buffer: RangeReplaceableCollection>(
        _ value: Self,
        into buffer: inout Buffer
    ) where Buffer.Element == ASCII.Code {
        for byte in value.rawValue.utf8 { buffer.append(ASCII.Code(byte)) }
    }

    /// Serializes `value` as ASCII bytes into `buffer`.
    ///
    /// Explicit `Binary.Serializable` witness: disambiguates the two
    /// constraint-incomparable `serialize(_:into:)` defaults (the RawRepresentable
    /// default vs the W0 ASCII bridge) — a conformer-declared member out-ranks both.
    /// The bytes derive from the free `[ASCII.Code]` serializer supplied by the
    /// `String`-RawRepresentable default (`.serialized`).
    public static func serialize<Buffer: RangeReplaceableCollection>(
        _ value: Self,
        into buffer: inout Buffer
    ) where Buffer.Element == Byte {
        buffer.append(contentsOf: value.serialized)
    }
}

extension RFC_5322.Header.Value: CustomStringConvertible {
    /// The value's ASCII serialization decoded as a `String`.
    public var description: String {
        String(decoding: serialized, as: UTF8.self)
    }
}

extension RFC_5322.Header.Value: ASCII.Parseable {
    /// Creates a header value by validating `string`'s UTF-8 bytes as ASCII.
    ///
    /// Re-provides the string convenience initializer (previously inherited from
    /// the retired combined ASCII serializable protocol, Void context).
    public init(_ string: some StringProtocol) throws(Error) {
        try self.init(ascii: [Byte](string.utf8))
    }

    /// Parses a header value from canonical byte representation (CANONICAL PRIMITIVE)
    ///
    /// This is the primitive parser that works at the byte level.
    /// Implements RFC 5322 folding whitespace unfolding and character validation.
    ///
    /// ## RFC 5322 Compliance
    ///
    /// Per RFC 5322 Section 2.2:
    /// - Field bodies may contain printable US-ASCII (0x20-0x7E) and HTAB (0x09)
    /// - CR and LF are only allowed in CRLF folding sequences
    /// - Unfolding removes any CRLF immediately followed by WSP (space or tab)
    ///
    /// ## Category Theory
    ///
    /// This is the fundamental parsing transformation:
    /// - **Domain**: [Byte] (ASCII bytes with possible folding)
    /// - **Codomain**: RFC_5322.Header.Value (unfolded, validated)
    ///
    /// String-based parsing is derived as composition:
    /// ```
    /// String → [Byte] (UTF-8 bytes) → Header.Value
    /// ```
    ///
    /// ## Example
    ///
    /// ```swift
    /// // Simple value
    /// let bytes = Array<Byte>("text/html; charset=UTF-8".utf8)
    /// let value = try RFC_5322.Header.Value(ascii: bytes)
    ///
    /// // Folded value (CRLF followed by space)
    /// let folded = Array<Byte>("text/html;\r\n charset=UTF-8".utf8)
    /// let unfolded = try RFC_5322.Header.Value(ascii: folded)
    /// // Result: "text/html; charset=UTF-8" (CRLF removed)
    /// ```
    ///
    /// - Parameter bytes: The ASCII byte representation of the header value
    /// - Throws: `RFC_5322.Header.Value.Error` if the bytes contain invalid characters or improper folding
    public init<Bytes: Collection>(ascii bytes: Bytes) throws(Error)
    where Bytes.Element == Byte {
        // RFC 5322 Section 2.2.3: Unfolding
        // "Unfolding is accomplished by simply removing any CRLF
        // that is immediately followed by WSP"
        //
        // Type-up: lift to ASCII.Code at the entry boundary so the body works
        // against ASCII.Code constants directly (RFC 5322 header values are strict ASCII).
        let codes: [ASCII.Code]
        do {
            codes = try Array<ASCII.Code>(bytes)
        } catch {
            throw Error.nonASCII(String(decoding: bytes, as: UTF8.self))
        }

        // Step 1: Unfold and validate folding patterns
        var unfolded = [ASCII.Code]()
        var index = 0

        while index < codes.count {
            let code = codes[index]

            // Check for CR
            if code == ASCII.Code.cr {
                let nextIndex = index + 1
                // Must be followed by LF (CRLF sequence)
                guard nextIndex < codes.count, codes[nextIndex] == ASCII.Code.lf else {
                    let string = String(decoding: bytes, as: UTF8.self)
                    throw Error.invalidCharacter(
                        string,
                        code: code,
                        reason: "CR must be followed by LF"
                    )
                }

                let afterLFIndex = nextIndex + 1
                // CRLF found - check if it's followed by WSP (folding)
                let hasWSP =
                    afterLFIndex < codes.count
                    && (codes[afterLFIndex] == ASCII.Code.sp || codes[afterLFIndex] == ASCII.Code.htab)
                if hasWSP {
                    // Valid folding: skip CRLF, keep the WSP
                    index = afterLFIndex  // Move to WSP, will be added in next iteration
                } else {
                    // CRLF not followed by WSP - invalid
                    let string = String(decoding: bytes, as: UTF8.self)
                    throw Error.invalidFolding(
                        string,
                        code: code,
                        reason: "CRLF must be followed by WSP (space or tab) for folding"
                    )
                }
            } else if code == ASCII.Code.lf {
                // LF without CR - invalid
                let string = String(decoding: bytes, as: UTF8.self)
                throw Error.invalidCharacter(
                    string,
                    code: code,
                    reason: "LF must be preceded by CR"
                )
            } else {
                unfolded.append(code)
                index += 1
            }
        }

        // Step 2: Strip leading OWS (optional whitespace)
        // RFC 5322 Section 3.2.2: The space after the colon is formatting, not semantic content
        // OWS = *(SP / HTAB)
        let trimmed = Array(unfolded.drop(while: { $0 == ASCII.Code.sp || $0 == ASCII.Code.htab }))

        // Step 3: Validate characters in trimmed value
        // RFC 5322 Section 2.2: Field body "may be composed of printable
        // US-ASCII characters as well as the space (SP, ASCII value 32)
        // and horizontal tab (HTAB, ASCII value 9) characters"
        for code in trimmed {
            // Valid: printable ASCII (0x20-0x7E) OR HTAB (0x09)
            let valid = code.isPrintable || code == ASCII.Code.htab

            guard valid else {
                let string = String(decoding: trimmed, as: UTF8.self)
                let reason: String
                if code.isControl {
                    reason = "Control characters not allowed (except HTAB)"
                } else {
                    reason = "Must be printable ASCII or HTAB"
                }
                throw Error.invalidCharacter(string, code: code, reason: reason)
            }
        }

        self.init(
            __unchecked: (),
            rawValue: String(decoding: trimmed, as: UTF8.self)
        )
    }
}

extension [Byte] {
    /// Creates ASCII byte representation of an RFC 5322 header value
    ///
    /// This is the canonical serialization of header values to bytes.
    /// RFC 5322 header values are ASCII with possible folding whitespace.
    ///
    /// ## Category Theory
    ///
    /// This is the most universal serialization (natural transformation):
    /// - **Domain**: RFC_5322.Header.Value (structured data)
    /// - **Codomain**: [Byte] (ASCII bytes)
    ///
    /// String representation is derived as composition:
    /// ```
    /// Header.Value → [Byte] (ASCII) → String (UTF-8 interpretation)
    /// ```
    ///
    /// ## Example
    ///
    /// ```swift
    /// let value = RFC_5322.Header.Value("text/html")
    /// let bytes = [Byte](value)
    /// // bytes == "text/html" as ASCII bytes
    /// ```
    ///
    /// - Parameter value: The header value to serialize
    public init(_ value: RFC_5322.Header.Value) {
        self = Array<Byte>(value.rawValue.utf8)
    }
}

extension RFC_5322.Header.Value: ExpressibleByIntegerLiteral {
    /// Creates a header value from an integer literal
    ///
    /// **Warning**: Bypasses validation via `init(unchecked:)`.
    /// Only use with known-valid compile-time constants.
    ///
    /// Convenient for numeric headers:
    /// ```swift
    /// let contentLength: Header.Value = 1234
    /// let maxForwards: Header.Value = 70
    /// ```
    public init(integerLiteral value: Int) {
        self.init(
            __unchecked: (),
            rawValue: String(value)
        )
    }
}

extension RFC_5322.Header.Value: ExpressibleByFloatLiteral {
    /// Creates a header value from a float literal
    ///
    /// **Warning**: Bypasses validation via `init(unchecked:)`.
    /// Only use with known-valid compile-time constants.
    ///
    /// Convenient for quality values:
    /// ```swift
    /// let quality: Header.Value = 0.8
    /// ```
    public init(floatLiteral value: Double) {
        self.init(
            __unchecked: (),
            rawValue: String(value)
        )
    }
}

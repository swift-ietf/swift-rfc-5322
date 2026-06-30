//
//  RFC_5322.Message.ID.swift
//  swift-rfc-5322
//
//  RFC 5322 Message-ID implementation
//

public import ASCII_Serializer_Primitives
public import Binary_Serializable_Primitives
public import Parseable_ASCII_Primitives
public import Serializer_Primitives
import INCITS_4_1986

extension RFC_5322.Message {
    /// RFC 5322 compliant Message-ID
    ///
    /// Format: `<unique-string@domain>`
    ///
    /// Per RFC 5322 Section 3.6.4:
    /// - Must be globally unique
    /// - Enclosed in angle brackets
    /// - Contains local-part @ domain
    /// - Should use a domain under the sender's control
    ///
    /// ## Storage
    ///
    /// Stores the Message-ID as canonical `[Byte]` (ASCII bytes without angle brackets).
    /// This follows the same pattern as `LocalPart` for academic correctness and zero-copy serialization.
    public struct ID: Hashable, Sendable {
        /// The unique identifier bytes (without angle brackets)
        /// Stored in format: "unique-string@domain" as ASCII bytes
        package let value: [Byte]

        /// Initialize with pre-formatted Message-ID bytes
        ///
        /// - Parameter value: The Message-ID bytes without angle brackets
        internal init(
            __unchecked: Void,
            rawValue: [Byte]
        ) {
            self.value = rawValue
        }
    }
}

extension RFC_5322.Message.ID: Serializable, ASCII.Serializable, Binary.Serializable {
    /// Canonical ASCII serializer: angle-bracketed Message-ID (stored bytes are
    /// already-validated ASCII, projected losslessly into the `ASCII.Code` substrate).
    public static var serializer: Serializer_Primitives.Serializer.Pure<Self, [ASCII.Code]> {
        Serializer_Primitives.Serializer.Pure { messageId, buffer in
            buffer.reserveCapacity(messageId.value.count + 2)  // +2 for angle brackets
            buffer.append(ASCII.Code.lt)
            buffer.append(contentsOf: messageId.value.map { ASCII.Code(unchecked: $0) })
            buffer.append(ASCII.Code.gt)
        }
    }

    /// Explicit `Binary.Serializable` witness disambiguating the two
    /// constraint-incomparable defaults; bytes derive from `.serialized`.
    public static func serialize<Buffer: RangeReplaceableCollection>(
        _ value: Self,
        into buffer: inout Buffer
    ) where Buffer.Element == Byte {
        buffer.append(contentsOf: value.serialized)
    }
}

extension RFC_5322.Message.ID: ASCII.Parseable {
    /// Creates a Message-ID by validating `string`'s UTF-8 bytes as ASCII.
    public init(_ string: some StringProtocol) throws(Error) {
        try self.init(ascii: [Byte](string.utf8))
    }

    /// Parses a Message-ID from canonical byte representation (CANONICAL PRIMITIVE)
    ///
    /// This is the primitive parser that works at the byte level.
    /// RFC 5322 Message-IDs are ASCII-only.
    ///
    /// ## Category Theory
    ///
    /// This is the fundamental parsing transformation:
    /// - **Domain**: [Byte] (ASCII bytes)
    /// - **Codomain**: RFC_5322.Message.ID (structured data)
    ///
    /// String-based parsing is derived as composition:
    /// ```
    /// String → [Byte] (UTF-8 bytes) → Message.ID
    /// ```
    ///
    /// ## Format
    ///
    /// Parses Message-ID format: `<unique-string@domain>` or `unique-string@domain`
    /// Angle brackets are optional in parsing but required in serialization per RFC 5322.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let bytes = Array<Byte>("<abc123@example.com>".utf8)
    /// let messageId = try RFC_5322.Message.ID(ascii: bytes)
    /// ```
    ///
    /// - Parameter bytes: The ASCII byte representation of the Message-ID
    /// - Throws: `RFC_5322.Message.ID.Error` if the bytes are malformed
    public init<Bytes: Collection>(ascii bytes: Bytes) throws(Error)
    where Bytes.Element == Byte {
        // Type-up: lift to ASCII.Code at the entry boundary so the body works
        // against ASCII.Code constants directly (RFC 5322 Message-IDs are strict ASCII).
        let codes: [ASCII.Code]
        do {
            codes = try Array<ASCII.Code>(bytes)
        } catch {
            throw Error.nonASCII(String(decoding: bytes, as: UTF8.self))
        }
        let count = codes.count

        // Validate format: must contain @ sign
        var hasAtSign = false
        for code in codes where code == ASCII.Code.at {
            hasAtSign = true
            break
        }
        guard hasAtSign else {
            let string = String(decoding: bytes, as: UTF8.self)
            throw Error.missingAtSign(string)
        }

        // Determine if we need to strip angle brackets
        let stripBrackets = count >= 2
            && codes.first == ASCII.Code.lt
            && codes.last == ASCII.Code.gt

        // Build result while validating characters
        var result = [Byte]()

        for (index, code) in codes.enumerated() {
            // Skip leading '<' if stripping brackets
            if stripBrackets && index == 0 && code == ASCII.Code.lt {
                continue
            }
            // Skip trailing '>' if stripping brackets
            if stripBrackets && index == count - 1 && code == ASCII.Code.gt {
                continue
            }

            // Validate: printable ASCII, no spaces
            guard code.isVisible && code != ASCII.Code.space else {
                let string = String(decoding: bytes, as: UTF8.self)
                throw Error.invalidCharacter(
                    string,
                    code: code,
                    reason: "Must be printable ASCII without spaces"
                )
            }

            result.append(code)
        }

        self.value = result
    }
}

extension RFC_5322.Message.ID {
    /// Generate a Message-ID for an email address with a unique identifier
    ///
    /// - Parameters:
    ///   - uniqueId: A unique string (timestamp, UUID, etc.)
    ///   - domain: The domain to use (typically from sender's email)
    public init(uniqueId: String, domain: RFC_1123.Domain) {
        var result = [Byte]()
        result.append(contentsOf: uniqueId.utf8)
        result.append(ASCII.Code.at)
        result.append(contentsOf: domain.name.utf8)
        self.value = result
    }
}

extension RFC_5322.Message.ID: CustomStringConvertible {
    /// The Message-ID's ASCII serialization (angle-bracketed) decoded as a `String`.
    public var description: String {
        String(decoding: serialized, as: UTF8.self)
    }
}

extension RFC_5322.Message.ID: Codable {
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        // Encode as string (without angle brackets)
        let string = String(decoding: self.value, as: UTF8.self)
        try container.encode(string)
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        let string = try container.decode(String.self)
        // Use the string initializer which validates format
        try self.init(string)
    }
}

extension RFC_5322.Message.ID: ExpressibleByStringLiteral {
    /// Creates a Message-ID from a string literal (traps on invalid ASCII).
    public init(stringLiteral value: String) {
        do throws(Error) {
            try self.init(value)
        } catch {
            preconditionFailure("Invalid ASCII Message-ID string literal: \(error)")
        }
    }
}
extension RFC_5322.Message.ID: ExpressibleByFloatLiteral {
    /// Creates a Message-ID from a float literal (traps on invalid ASCII).
    public init(floatLiteral value: Double) {
        do throws(Error) {
            try self.init(String(value))
        } catch {
            preconditionFailure("Invalid ASCII Message-ID float literal: \(error)")
        }
    }
}
extension RFC_5322.Message.ID: ExpressibleByIntegerLiteral {
    /// Creates a Message-ID from an integer literal (traps on invalid ASCII).
    public init(integerLiteral value: Int) {
        do throws(Error) {
            try self.init(String(value))
        } catch {
            preconditionFailure("Invalid ASCII Message-ID integer literal: \(error)")
        }
    }
}

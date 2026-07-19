//
//  RFC 5322 Message.swift
//  swift-rfc-5322
//
//  Created by Coen ten Thije Boonkkamp on 12/11/2025.
//

public import ASCII_Serializer_Primitives
public import Binary_Serializable_Primitives
import INCITS_4_1986
import RFC_1123
import Standard_Library_Extensions

extension RFC_5322 {
    /// RFC 5322 Internet Message Format
    ///
    /// Represents a complete RFC 5322 email message with headers and body.
    /// Can generate .eml files compliant with RFC 5322 specification.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let message = try RFC_5322.Message(
    ///     from: try RFC_5322.EmailAddress(
    ///         displayName: "John Doe",
    ///         localPart: .init("john"),
    ///         domain: RFC_1123.Domain("example.com")
    ///     ),
    ///     to: [RFC_5322.EmailAddress(try! .init("jane@example.com"))],
    ///     subject: "Hello!",
    ///     date: Date(),
    ///     messageId: "<unique-id@example.com>",
    ///     body: "Hello, World!"
    /// )
    ///
    /// let emlContent = message.render()
    /// ```
    public struct Message: Hashable, Sendable, Codable {
        /// Originator - From field
        public let from: EmailAddress

        /// Recipients - To field
        public let to: [EmailAddress]

        /// Carbon copy recipients
        public let cc: [EmailAddress]?

        /// Blind carbon copy recipients (not included in rendered message)
        public let bcc: [EmailAddress]?

        /// Reply-To field
        public let replyTo: EmailAddress?

        /// Subject line
        public let subject: String

        /// Message date
        public let date: RFC_5322.DateTime

        /// Unique message identifier
        public let messageId: Message.ID

        /// Message body as bytes (typically MIME content from RFC 2045/2046)
        public let body: [Byte]

        /// Additional custom headers
        public let additionalHeaders: [Header]

        /// MIME-Version header value (defaults to "1.0")
        public let mimeVersion: String

        /// Creates an RFC 5322 message
        ///
        /// - Parameters:
        ///   - from: Originator address
        ///   - to: Recipient addresses
        ///   - cc: Carbon copy recipients
        ///   - bcc: Blind carbon copy recipients
        ///   - replyTo: Reply-to address
        ///   - subject: Subject line
        ///   - date: Message date
        ///   - messageId: Unique message identifier
        ///   - body: Message body as bytes
        ///   - additionalHeaders: Additional custom headers
        ///   - mimeVersion: MIME-Version header (defaults to "1.0")
        /// - Throws: `Error.invalidSubject` or `Error.invalidMimeVersion` if
        ///   `subject` or `mimeVersion` contains a bare CR, a bare LF, or a
        ///   non-ASCII byte — this would otherwise let a caller inject a new
        ///   header line into the rendered message (CRLF header injection)
        ///   or corrupt it with non-ASCII content.
        public init(
            from: EmailAddress,
            to: [EmailAddress],
            cc: [EmailAddress]? = nil,
            bcc: [EmailAddress]? = nil,
            replyTo: EmailAddress? = nil,
            date: RFC_5322.DateTime,
            subject: String,
            messageId: Message.ID,
            body: [Byte],
            additionalHeaders: [Header] = [],
            mimeVersion: String = "1.0"
        ) throws(Error) {
            if let reason = subject.rfc5322FieldBodyInjectionReason {
                throw Error.invalidSubject(subject, reason: reason)
            }
            if let reason = mimeVersion.rfc5322FieldBodyInjectionReason {
                throw Error.invalidMimeVersion(mimeVersion, reason: reason)
            }
            self.from = from
            self.to = to
            self.cc = cc
            self.bcc = bcc
            self.replyTo = replyTo
            self.date = date
            self.subject = subject
            self.messageId = messageId
            self.body = body
            self.additionalHeaders = additionalHeaders
            self.mimeVersion = mimeVersion
        }
    }
}

extension RFC_5322.Message: ASCII.Serializable, Binary.Serializable {
    /// Own `ASCII.Serializable` verb ([FAM-012]) — a complete RFC 5322 §3.6
    /// message (headers + body), composing the already-re-cut `EmailAddress` /
    /// `DateTime` / `Message.ID` / `Header` ASCII verbs directly into the
    /// `ASCII.Code` buffer. Header-field prefixes / line endings and the own
    /// `subject` / `mimeVersion` / `body` fields are leaf-emitted on the
    /// ASCII-code substrate. Pure concatenation (no escape). Output is
    /// byte-identical to the `Binary.Serializable` witness (`serializeBytes`).
    public static func serialize<Buffer: RangeReplaceableCollection>(
        _ value: Self,
        into buffer: inout Buffer
    ) where Buffer.Element == ASCII.Code {

        // Pre-allocate capacity to avoid reallocations
        // Rough estimate: headers (~500 bytes) + body
        buffer.reserveCapacity(500 + value.body.count)

        // Required headers in recommended order (RFC 5322 Section 3.6)

        // From (required)
        buffer.append(contentsOf: [Byte].fromPrefix.map { ASCII.Code(unchecked: $0) })
        RFC_5322.EmailAddress.serialize(value.from, into: &buffer)
        buffer.append(contentsOf: [Byte].crlf.map { ASCII.Code(unchecked: $0) })

        // To (required)
        buffer.append(contentsOf: [Byte].toPrefix.map { ASCII.Code(unchecked: $0) })
        var first = true
        for address in value.to {
            if !first {
                buffer.append(ASCII.Code.comma)
                buffer.append(ASCII.Code.space)
            }
            first = false
            RFC_5322.EmailAddress.serialize(address, into: &buffer)
        }
        buffer.append(contentsOf: [Byte].crlf.map { ASCII.Code(unchecked: $0) })

        // Cc (optional)
        if let cc = value.cc, !cc.isEmpty {
            buffer.append(contentsOf: [Byte].ccPrefix.map { ASCII.Code(unchecked: $0) })
            first = true
            for address in cc {
                if !first {
                    buffer.append(ASCII.Code.comma)
                    buffer.append(ASCII.Code.space)
                }
                first = false
                RFC_5322.EmailAddress.serialize(address, into: &buffer)
            }
            buffer.append(contentsOf: [Byte].crlf.map { ASCII.Code(unchecked: $0) })
        }

        // Subject (required in practice)
        buffer.append(contentsOf: [Byte].subjectPrefix.map { ASCII.Code(unchecked: $0) })
        buffer.append(contentsOf: value.subject.utf8.map { ASCII.Code($0) })
        buffer.append(contentsOf: [Byte].crlf.map { ASCII.Code(unchecked: $0) })

        // Date (required)
        buffer.append(contentsOf: [Byte].datePrefix.map { ASCII.Code(unchecked: $0) })
        RFC_5322.DateTime.serialize(value.date, into: &buffer)
        buffer.append(contentsOf: [Byte].crlf.map { ASCII.Code(unchecked: $0) })

        // Message-ID (recommended)
        buffer.append(contentsOf: [Byte].messageIdPrefix.map { ASCII.Code(unchecked: $0) })
        RFC_5322.Message.ID.serialize(value.messageId, into: &buffer)
        buffer.append(contentsOf: [Byte].crlf.map { ASCII.Code(unchecked: $0) })

        // Reply-To (optional)
        if let replyTo = value.replyTo {
            buffer.append(contentsOf: [Byte].replyToPrefix.map { ASCII.Code(unchecked: $0) })
            RFC_5322.EmailAddress.serialize(replyTo, into: &buffer)
            buffer.append(contentsOf: [Byte].crlf.map { ASCII.Code(unchecked: $0) })
        }

        // MIME-Version (required for MIME messages)
        buffer.append(contentsOf: [Byte].mimeVersionPrefix.map { ASCII.Code(unchecked: $0) })
        buffer.append(contentsOf: value.mimeVersion.utf8.map { ASCII.Code($0) })
        buffer.append(contentsOf: [Byte].crlf.map { ASCII.Code(unchecked: $0) })

        // Additional custom headers (in order)
        for header in value.additionalHeaders {
            RFC_5322.Header.serialize(header, into: &buffer)
            buffer.append(contentsOf: [Byte].crlf.map { ASCII.Code(unchecked: $0) })
        }

        // Empty line separates headers from body
        buffer.append(contentsOf: [Byte].crlf.map { ASCII.Code(unchecked: $0) })

        // Body (own raw bytes, projected losslessly to the ASCII-code substrate)
        buffer.append(contentsOf: value.body.map { ASCII.Code(unchecked: $0) })
    }

    /// Explicit `Binary.Serializable` witness (RFC 5322 §3.6 message) on the byte
    /// substrate.
    public static func serialize<Buffer: RangeReplaceableCollection>(
        _ value: Self,
        into buffer: inout Buffer
    ) where Buffer.Element == Byte {
        serializeBytes(value, into: &buffer)
    }

    /// Byte-domain serialization body (RFC 5322 §3.6 message).
    private static func serializeBytes<Buffer: RangeReplaceableCollection>(
        _ message: RFC_5322.Message,
        into buffer: inout Buffer
    ) where Buffer.Element == Byte {

        // Pre-allocate capacity to avoid reallocations
        // Rough estimate: headers (~500 bytes) + body
        buffer.reserveCapacity(500 + message.body.count)

        // Required headers in recommended order (RFC 5322 Section 3.6)

        // From (required)
        buffer.append(contentsOf: [Byte].fromPrefix)
        RFC_5322.EmailAddress.serialize(message.from, into: &buffer)
        buffer.append(contentsOf: [Byte].crlf)

        // To (required)
        buffer.append(contentsOf: [Byte].toPrefix)
        var first = true
        for address in message.to {
            if !first {
                buffer.append(ASCII.Code.comma)
                buffer.append(ASCII.Code.space)
            }
            first = false
            RFC_5322.EmailAddress.serialize(address, into: &buffer)
        }
        buffer.append(contentsOf: [Byte].crlf)

        // Cc (optional)
        if let cc = message.cc, !cc.isEmpty {
            buffer.append(contentsOf: [Byte].ccPrefix)
            first = true
            for address in cc {
                if !first {
                    buffer.append(ASCII.Code.comma)
                    buffer.append(ASCII.Code.space)
                }
                first = false
                RFC_5322.EmailAddress.serialize(address, into: &buffer)
            }
            buffer.append(contentsOf: [Byte].crlf)
        }

        // Subject (required in practice)
        buffer.append(contentsOf: [Byte].subjectPrefix)
        buffer.append(contentsOf: message.subject.utf8)
        buffer.append(contentsOf: [Byte].crlf)

        // Date (required)
        buffer.append(contentsOf: [Byte].datePrefix)
        RFC_5322.DateTime.serialize(message.date, into: &buffer)
        buffer.append(contentsOf: [Byte].crlf)

        // Message-ID (recommended)
        buffer.append(contentsOf: [Byte].messageIdPrefix)
        RFC_5322.Message.ID.serialize(message.messageId, into: &buffer)
        buffer.append(contentsOf: [Byte].crlf)

        // Reply-To (optional)
        if let replyTo = message.replyTo {
            buffer.append(contentsOf: [Byte].replyToPrefix)
            RFC_5322.EmailAddress.serialize(replyTo, into: &buffer)
            buffer.append(contentsOf: [Byte].crlf)
        }

        // MIME-Version (required for MIME messages)
        buffer.append(contentsOf: [Byte].mimeVersionPrefix)
        buffer.append(contentsOf: message.mimeVersion.utf8)
        buffer.append(contentsOf: [Byte].crlf)

        // Additional custom headers (in order)
        for header in message.additionalHeaders {
            RFC_5322.Header.serialize(header, into: &buffer)
            buffer.append(contentsOf: [Byte].crlf)
        }

        // Empty line separates headers from body
        buffer.append(contentsOf: [Byte].crlf)

        // Body (as bytes)
        buffer.append(contentsOf: message.body)
    }
}

// NOTE: `RFC_5322.Message` intentionally does NOT conform to `ASCII.Parseable`.
// A prior stub conformance's `init(ascii:)` unconditionally called
// `fatalError`, making any code path that reached it (directly, or
// generically through an `ASCII.Parseable` existential/generic constraint)
// crash the process instead of failing gracefully (fable-448 F-001). Message
// parsing (header folding, arbitrary header order, MIME structure,
// encoded-words, transfer encodings) is substantial future work; until it
// lands, the conformance's absence is a compile-time fact rather than a
// runtime landmine. When implemented, the parser should compose the
// existing `Header` / `EmailAddress` / `DateTime` / `Message.ID` parsers:
// split header section from body at the first blank line (CRLF CRLF),
// unfold headers, extract required headers (From, To, Date, ...), and
// preserve additional headers in order. `RFC_5322.Message.Error` already
// carries the FUTURE parsing-error cases for that implementation.

extension RFC_5322.Message: CustomStringConvertible {
    /// The message's RFC 5322 ASCII serialization decoded as a `String`.
    public var description: String {
        String(decoding: serialized, as: UTF8.self)
    }
}

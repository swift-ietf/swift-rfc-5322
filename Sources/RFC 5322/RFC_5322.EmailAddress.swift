//
//  File.swift
//  swift-rfc-5322
//
//  Created by Coen ten Thije Boonkkamp on 18/11/2025.
//

public import ASCII_Serializer_Primitives
import INCITS_4_1986
public import RFC_1123

extension RFC_5322 {
    /// RFC 5322 compliant email address (Internet Message Format)
    public struct EmailAddress: Hashable, Sendable {
        /// The display name, if present
        public let displayName: String?

        /// The local part (before @)
        public let localPart: LocalPart

        /// The domain part (after @)
        public let domain: RFC_1123.Domain

        /// Initialize with components
        public init(
            displayName: String? = nil,
            localPart: LocalPart,
            domain: RFC_1123.Domain
        ) {
            self.displayName = displayName.map { String($0.trimming(.ascii.whitespaces)) }
            self.localPart = localPart
            self.domain = domain
        }
    }
}

extension RFC_5322.EmailAddress: Binary.ASCII.Serializable {
    public static func serialize<Buffer: RangeReplaceableCollection>(
        ascii emailAddress: RFC_5322.EmailAddress,
        into buffer: inout Buffer
    ) where Buffer.Element == Byte {
        if let displayName = emailAddress.displayName {
            // Check if quoting is needed for display name
            let needsQuoting = displayName.contains(where: {
                !$0.ascii.isLetter && !$0.ascii.isDigit && !$0.ascii.isWhitespace
                    || $0.asciiValue == nil
            })

            if needsQuoting {
                buffer.append(ASCII.Code.quotationMark)
                buffer.append(contentsOf: displayName.utf8)
                buffer.append(ASCII.Code.quotationMark)
            } else {
                buffer.append(contentsOf: displayName.utf8)
            }

            buffer.append(ASCII.Code.space)
            buffer.append(ASCII.Code.lessThanSign)

            // Serialize local-part through bytes
            RFC_5322.EmailAddress.LocalPart.serialize(ascii: emailAddress.localPart, into: &buffer)
            buffer.append(ASCII.Code.commercialAt)

            // Serialize domain through bytes
            RFC_1123.Domain.serialize(ascii: emailAddress.domain, into: &buffer)

            buffer.append(ASCII.Code.greaterThanSign)
        } else {
            // Simple format without display name
            RFC_5322.EmailAddress.LocalPart.serialize(ascii: emailAddress.localPart, into: &buffer)
            buffer.append(ASCII.Code.commercialAt)
            RFC_1123.Domain.serialize(ascii: emailAddress.domain, into: &buffer)
        }
    }

    /// Parses email address from canonical byte representation (CANONICAL PRIMITIVE)
    ///
    /// This is the primitive parser that works at the byte level.
    /// RFC 5322 email addresses are ASCII-only.
    ///
    /// ## Category Theory
    ///
    /// This is the fundamental parsing transformation:
    /// - **Domain**: [Byte] (ASCII bytes)
    /// - **Codomain**: RFC_5322.EmailAddress (structured data)
    ///
    /// String-based parsing is derived as composition:
    /// ```
    /// String → [Byte] (UTF-8 bytes) → EmailAddress
    /// ```
    ///
    /// ## Formats
    ///
    /// - Simple: `user@example.com`
    /// - With display name: `John Doe <user@example.com>`
    /// - With quoted display name: `"John Doe" <user@example.com>`
    ///
    /// ## Example
    ///
    /// ```swift
    /// let bytes = Array<Byte>("user@example.com".utf8)
    /// let email = try RFC_5322.EmailAddress(ascii: bytes)
    /// ```
    ///
    /// - Parameter bytes: The ASCII byte representation of the email address
    /// - Throws: `RFC_5322.EmailAddress.Error` if the bytes are malformed
    public init<Bytes: Collection>(ascii bytes: Bytes, in context: Void) throws(Error)
    where Bytes.Element == Byte {
        // Delegate to concrete [Byte] implementation to work around Swift compiler bug
        // (LinearLifetimeChecker crash with complex generic index types)
        try self.init(ascii: Array<Byte>(bytes), in: ())
    }

    /// Internal initializer for concrete byte array (avoids compiler crash)
    internal init(ascii bytes: [Byte], in context: Void) throws(Error) {
        // Type-up: lift to ASCII.Code at the entry boundary so the body works
        // against ASCII.Code constants directly (RFC 5322 email addresses are strict ASCII).
        let codes = Array<ASCII.Code>(bytes)

        // Find angle bracket positions
        var ltOffset: Int?
        var gtOffset: Int?

        for (i, code) in codes.enumerated() {
            if code == ASCII.Code.lessThanSign && ltOffset == nil {
                ltOffset = i
            }
            if code == ASCII.Code.greaterThanSign {
                gtOffset = i
            }
        }

        // Look for angle brackets to determine format
        if let ltOff = ltOffset, let gtOff = gtOffset, ltOff < gtOff {
            // Format: "Display Name <local@domain>"
            let displayNameCodes = codes[..<ltOff]
            let emailCodes = codes[(ltOff + 1)..<gtOff]

            // Parse display name (trim whitespace)
            let displayName: String?
            if !displayNameCodes.isEmpty {
                var trimmedCodes = [ASCII.Code]()
                var foundNonWhitespace = false
                var trailingWhitespace = [ASCII.Code]()

                for code in displayNameCodes {
                    if code == ASCII.Code.space || code == ASCII.Code.htab {
                        if foundNonWhitespace {
                            trailingWhitespace.append(code)
                        }
                    } else {
                        foundNonWhitespace = true
                        trimmedCodes.append(contentsOf: trailingWhitespace)
                        trailingWhitespace.removeAll()
                        trimmedCodes.append(code)
                    }
                }

                if !trimmedCodes.isEmpty {
                    var nameString = String(decoding: trimmedCodes, as: UTF8.self)

                    // Handle quoted display names: "Name" -> Name
                    if nameString.hasPrefix("\"") && nameString.hasSuffix("\"") {
                        nameString = String(nameString.dropFirst().dropLast())
                        nameString = nameString.replacing(#"\""#, with: "\"")
                            .replacing(#"\\"#, with: "\\")
                    }

                    displayName = nameString
                } else {
                    displayName = nil
                }
            } else {
                displayName = nil
            }

            // Parse email part (local@domain)
            guard let atIdx = emailCodes.firstIndex(of: ASCII.Code.commercialAt) else {
                throw Error.missingAtSign
            }

            let localBytes = Array<Byte>(emailCodes[..<atIdx])
            let domainBytes = Array<Byte>(emailCodes[(atIdx + 1)...])

            // Parse components
            let localPartValue = try Self.parseLocalPart(localBytes)
            let domainValue = try Self.parseDomain(domainBytes)

            self.init(displayName: displayName, localPart: localPartValue, domain: domainValue)
        } else {
            // Simple format: local@domain
            guard let atIdx = codes.firstIndex(of: ASCII.Code.commercialAt) else {
                throw Error.missingAtSign
            }

            let localBytes = Array<Byte>(codes[..<atIdx])
            let domainBytes = Array<Byte>(codes[(atIdx + 1)...])

            // Parse components
            let localPartValue = try Self.parseLocalPart(localBytes)
            let domainValue = try Self.parseDomain(domainBytes)

            self.init(displayName: nil, localPart: localPartValue, domain: domainValue)
        }
    }

    /// Helper to parse local part with error wrapping (avoids compiler bug)
    private static func parseLocalPart(_ bytes: [Byte]) throws(Error) -> LocalPart {
        do {
            return try LocalPart(ascii: bytes)
        } catch {
            throw Error.localPart(error)
        }
    }

    /// Helper to parse domain with error wrapping (avoids compiler bug)
    private static func parseDomain(_ bytes: [Byte]) throws(Error) -> RFC_1123.Domain {
        do {
            return try RFC_1123.Domain(ascii: bytes)
        } catch {
            throw Error.domain(error)
        }
    }
}

extension RFC_5322.EmailAddress {
    /// Just the email address part without display name
    public var address: String {
        "\(localPart)@\(domain.name)"
    }
}

extension RFC_5322.EmailAddress: Codable {
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.rawValue)
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        try self.init(rawValue)
    }
}

extension RFC_5322.EmailAddress: CustomStringConvertible {}

extension RFC_5322.EmailAddress: Binary.ASCII.RawRepresentable {
    public init?(rawValue: String) { try? self.init(rawValue) }
}

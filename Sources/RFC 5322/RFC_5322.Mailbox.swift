public import ASCII
public import Byte
import Byte_Standard_Library_Integration
import INCITS_4_1986
public import RFC_1123

extension RFC_5322 {

    public struct Mailbox: Hashable, Sendable {

        public let displayName: String?

        public let localPart: LocalPart

        public let domain: RFC_1123.Domain

        public init(
            displayName: String? = nil,
            localPart: LocalPart,
            domain: RFC_1123.Domain
        ) throws(Error) {
            if let displayName {
                let trimmed = String(displayName.trimming(.ascii.whitespaces))
                if let reason = trimmed.rfc5322FieldBodyInjectionReason {
                    throw Error.invalidDisplayName(trimmed, reason: reason)
                }
                self.displayName = trimmed
            } else {
                self.displayName = nil
            }
            self.localPart = localPart
            self.domain = domain
        }
    }
}

extension RFC_5322.Mailbox {

    public static func serialize<Buffer: RangeReplaceableCollection>(
        _ value: Self,
        into buffer: inout Buffer
    ) where Buffer.Element == ASCII.Code {
        if let displayName = value.displayName {

            let needsQuoting = displayName.contains(where: {
                !$0.ascii.isLetter && !$0.ascii.isDigit && !$0.ascii.isWhitespace
                    || $0.asciiValue == nil
            })

            if needsQuoting {
                buffer.append(ASCII.Code.quotationMark)
                buffer.append(
                    contentsOf: Self.escapedForQuotedString(displayName).utf8.map { ASCII.Code($0) }
                )
                buffer.append(ASCII.Code.quotationMark)
            } else {
                buffer.append(contentsOf: displayName.utf8.map { ASCII.Code($0) })
            }

            buffer.append(ASCII.Code.space)
            buffer.append(ASCII.Code.lessThanSign)

            RFC_5322.Mailbox.LocalPart.serialize(value.localPart, into: &buffer)
            buffer.append(ASCII.Code.commercialAt)
            RFC_1123.Domain.serialize(value.domain, into: &buffer)

            buffer.append(ASCII.Code.greaterThanSign)
        } else {

            RFC_5322.Mailbox.LocalPart.serialize(value.localPart, into: &buffer)
            buffer.append(ASCII.Code.commercialAt)
            RFC_1123.Domain.serialize(value.domain, into: &buffer)
        }
    }

    public static func serialize<Buffer: RangeReplaceableCollection>(
        _ value: Self,
        into buffer: inout Buffer
    ) where Buffer.Element == Byte {
        serializeBytes(value, into: &buffer)
    }

    private static func serializeBytes<Buffer: RangeReplaceableCollection>(
        _ mailbox: RFC_5322.Mailbox,
        into buffer: inout Buffer
    ) where Buffer.Element == Byte {
        if let displayName = mailbox.displayName {

            let needsQuoting = displayName.contains(where: {
                !$0.ascii.isLetter && !$0.ascii.isDigit && !$0.ascii.isWhitespace
                    || $0.asciiValue == nil
            })

            if needsQuoting {
                buffer.append(ASCII.Code.quotationMark.byte)
                buffer.append(
                    contentsOf: Self.escapedForQuotedString(displayName).utf8.lazy.map(
                        Byte.init(bitPattern:)
                    )
                )
                buffer.append(ASCII.Code.quotationMark.byte)
            } else {
                buffer.append(contentsOf: displayName.utf8.lazy.map(Byte.init(bitPattern:)))
            }

            buffer.append(ASCII.Code.space.byte)
            buffer.append(ASCII.Code.lessThanSign.byte)

            RFC_5322.Mailbox.LocalPart.serialize(mailbox.localPart, into: &buffer)
            buffer.append(ASCII.Code.commercialAt.byte)

            RFC_1123.Domain.serialize(mailbox.domain, into: &buffer)

            buffer.append(ASCII.Code.greaterThanSign.byte)
        } else {

            RFC_5322.Mailbox.LocalPart.serialize(mailbox.localPart, into: &buffer)
            buffer.append(ASCII.Code.commercialAt.byte)
            RFC_1123.Domain.serialize(mailbox.domain, into: &buffer)
        }
    }

    private static func escapedForQuotedString(_ displayName: String) -> String {
        displayName
            .replacing("\\", with: "\\\\")
            .replacing("\"", with: "\\\"")
    }
}

extension RFC_5322.Mailbox {

    public init(_ string: some StringProtocol) throws(Error) {
        try self.init(ascii: string.utf8.map(Byte.init(bitPattern:)))
    }

    public init<Bytes: Swift.Collection>(ascii bytes: Bytes) throws(Error)
    where Bytes.Element == Byte {

        try self.init(ascii: [Byte](bytes))
    }

    internal init(ascii bytes: [Byte]) throws(Error) {

        let codes: [ASCII.Code]
        do throws(ASCII.Code.Error) {
            var built: [ASCII.Code] = []
            built.reserveCapacity(bytes.count)
            for byte in bytes {
                built.append(try ASCII.Code(byte))
            }
            codes = built
        } catch {
            throw Error.localPart(.nonASCIICharacters)
        }

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

        if let ltOff = ltOffset, let gtOff = gtOffset, ltOff < gtOff {

            let displayNameCodes = codes[..<ltOff]
            let emailCodes = codes[(ltOff + 1)..<gtOff]

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
                    var nameString = String(decoding: trimmedCodes.lazy.map(\.underlying), as: UTF8.self)

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

            guard let atIdx = emailCodes.firstIndex(of: ASCII.Code.commercialAt) else {
                throw Error.missingAtSign
            }

            let localBytes = emailCodes[..<atIdx].map(\.byte)
            let domainBytes = emailCodes[(atIdx + 1)...].map(\.byte)

            let localPartValue = try Self.parseLocalPart(localBytes)
            let domainValue = try Self.parseDomain(domainBytes)

            try self.init(displayName: displayName, localPart: localPartValue, domain: domainValue)
        } else {

            guard let atIdx = codes.firstIndex(of: ASCII.Code.commercialAt) else {
                throw Error.missingAtSign
            }

            let localBytes = codes[..<atIdx].map(\.byte)
            let domainBytes = codes[(atIdx + 1)...].map(\.byte)

            let localPartValue = try Self.parseLocalPart(localBytes)
            let domainValue = try Self.parseDomain(domainBytes)

            try self.init(displayName: nil, localPart: localPartValue, domain: domainValue)
        }
    }

    private static func parseLocalPart(_ bytes: [Byte]) throws(Error) -> LocalPart {
        do throws(RFC_5322.Mailbox.LocalPart.Error) {
            return try LocalPart(ascii: bytes)
        } catch {
            throw Error.localPart(error)
        }
    }

    private static func parseDomain(_ bytes: [Byte]) throws(Error) -> RFC_1123.Domain {
        do throws(RFC_1123.Domain.Error) {
            return try RFC_1123.Domain(ascii: bytes)
        } catch {
            throw Error.domain(error)
        }
    }
}

extension RFC_5322.Mailbox {

    public var address: String {
        "\(localPart)@\(domain.name)"
    }
}


extension RFC_5322.Mailbox: CustomStringConvertible {

    public var description: String {
        var bytes: [Byte] = []
        Self.serialize(self, into: &bytes)
        return String(decoding: bytes, as: UTF8.self)
    }
}

extension RFC_5322.Mailbox: Swift.RawRepresentable {

    public var rawValue: String {
        var bytes: [Byte] = []
        Self.serialize(self, into: &bytes)
        return String(decoding: bytes, as: UTF8.self)
    }

    public init?(rawValue: String) {
        do throws(Error) {
            try self.init(rawValue)
        } catch {
            return nil
        }
    }
}

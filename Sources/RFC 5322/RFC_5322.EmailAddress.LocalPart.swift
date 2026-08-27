public import ASCII_Serializer
public import Binary_Serializable
import INCITS_4_1986
public import Parseable_ASCII

extension RFC_5322.EmailAddress {

    public struct LocalPart: Hashable, Sendable {
        package let storage: Storage
    }
}

extension RFC_5322.EmailAddress.LocalPart {

    package enum Storage: Hashable {
        case dotAtom([Byte])
        case quoted([Byte])
    }
}

extension RFC_5322.EmailAddress.LocalPart: ASCII.Serializable, Binary.Serializable {

    public static func serialize<Buffer: RangeReplaceableCollection>(
        _ value: Self,
        into buffer: inout Buffer
    ) where Buffer.Element == ASCII.Code {
        switch value.storage {
        case .dotAtom(let bytes), .quoted(let bytes):
            buffer.append(contentsOf: bytes.map { ASCII.Code(unchecked: $0) })
        }
    }

    public static func serialize<Buffer: RangeReplaceableCollection>(
        _ value: Self,
        into buffer: inout Buffer
    ) where Buffer.Element == Byte {
        buffer.append(contentsOf: value.serialized)
    }
}

extension RFC_5322.EmailAddress.LocalPart: ASCII.Parseable {

    public init(_ string: some StringProtocol) throws(Error) {
        try self.init(ascii: [Byte](string.utf8))
    }

    public init<Bytes: Swift.Collection>(ascii bytes: Bytes) throws(Error)
    where Bytes.Element == Byte {

        let codes: [ASCII.Code]
        do throws(ASCII.Code.Error) {
            codes = try [ASCII.Code](bytes)
        } catch {
            throw Error.nonASCIICharacters
        }
        let count = codes.count

        guard count <= RFC_5322.EmailAddress.Limits.maxLength else {
            throw Error.tooLong(count)
        }

        guard let first = codes.first, let last = codes.last else {
            throw Error.invalidDotAtom
        }

        if first == ASCII.Code.quotationMark && last == ASCII.Code.quotationMark && count >= 2 {

            var skipNext = false

            for index in 1..<(count - 1) {
                let code = codes[index]

                if skipNext {
                    skipNext = false
                    continue
                }

                if code == ASCII.Code.backslash {

                    skipNext = true
                } else if code == ASCII.Code.quotationMark || code == ASCII.Code.cr
                    || code == ASCII.Code.lf
                {

                    throw Error.invalidQuotedString
                }
            }

            if skipNext {
                throw Error.invalidQuotedString
            }

            self.storage = .quoted([Byte](bytes))
        }

        else {

            guard first != ASCII.Code.period && last != ASCII.Code.period else {
                throw Error.leadingOrTrailingDot
            }

            var previousCode: ASCII.Code?
            for code in codes {

                if code == ASCII.Code.period && previousCode == ASCII.Code.period {
                    throw Error.consecutiveDots
                }
                previousCode = code

                guard code == ASCII.Code.period || RFC_5322.isAtext(code) else {
                    throw Error.invalidDotAtom
                }
            }

            self.storage = .dotAtom([Byte](bytes))
        }
    }
}

extension RFC_5322.EmailAddress.LocalPart: CustomStringConvertible {

    public var description: String {
        String(decoding: serialized, as: UTF8.self)
    }
}

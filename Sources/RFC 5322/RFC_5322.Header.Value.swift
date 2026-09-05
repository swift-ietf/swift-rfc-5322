public import ASCII
public import Byte
import Byte_Standard_Library_Integration
import INCITS_4_1986

extension RFC_5322.Header {
    public struct Value: Sendable, Hashable {
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

    public static func == (lhs: RFC_5322.Header.Value, rhs: RFC_5322.Header.Value) -> Bool {
        lhs.rawValue == rhs.rawValue
    }

    public static func == (lhs: RFC_5322.Header.Value, rhs: Self.RawValue) -> Bool {
        lhs.rawValue == rhs
    }
}

extension RFC_5322.Header.Value: Swift.RawRepresentable {

    public init?(rawValue: String) {
        do throws(Error) {
            try self.init(rawValue)
        } catch {
            return nil
        }
    }
}

extension RFC_5322.Header.Value: CustomStringConvertible {

    public var description: String {
        rawValue
    }
}

extension RFC_5322.Header.Value {

    public init(_ string: some StringProtocol) throws(Error) {
        try self.init(ascii: string.utf8.map(Byte.init(bitPattern:)))
    }

    public init<Bytes: Swift.Collection>(ascii bytes: Bytes) throws(Error)
    where Bytes.Element == Byte {

        let codes: [ASCII.Code]
        do throws(ASCII.Code.Error) {
            var built: [ASCII.Code] = []
            built.reserveCapacity(bytes.count)
            for byte in bytes {
                built.append(try ASCII.Code(byte))
            }
            codes = built
        } catch {
            throw Error.nonASCII(String(decoding: bytes, as: UTF8.self))
        }

        var unfolded = [ASCII.Code]()
        var index = 0

        while index < codes.count {
            let code = codes[index]

            if code == ASCII.Code.cr {
                let nextIndex = index + 1

                guard nextIndex < codes.count, codes[nextIndex] == ASCII.Code.lf else {
                    let string = String(decoding: bytes, as: UTF8.self)
                    throw Error.invalidCharacter(
                        string,
                        code: code,
                        reason: "CR must be followed by LF"
                    )
                }

                let afterLFIndex = nextIndex + 1

                let hasWSP =
                    afterLFIndex < codes.count
                    && (codes[afterLFIndex] == ASCII.Code.sp
                        || codes[afterLFIndex] == ASCII.Code.htab)
                if hasWSP {

                    index = afterLFIndex
                } else {

                    let string = String(decoding: bytes, as: UTF8.self)
                    throw Error.invalidFolding(
                        string,
                        code: code,
                        reason: "CRLF must be followed by WSP (space or tab) for folding"
                    )
                }
            } else if code == ASCII.Code.lf {

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

        let trimmed = Array(unfolded.drop(while: { $0 == ASCII.Code.sp || $0 == ASCII.Code.htab }))

        for code in trimmed {

            let valid = code.isPrintable || code == ASCII.Code.htab

            guard valid else {
                let string = String(decoding: trimmed.lazy.map(\.underlying), as: UTF8.self)
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
            rawValue: String(decoding: trimmed.lazy.map(\.underlying), as: UTF8.self)
        )
    }
}

extension RFC_5322.Header.Value: ExpressibleByIntegerLiteral {

    public init(integerLiteral value: Int) {
        self.init(
            __unchecked: (),
            rawValue: String(value)
        )
    }
}

extension RFC_5322.Header.Value: ExpressibleByFloatLiteral {

    public init(floatLiteral value: Double) {
        self.init(
            __unchecked: (),
            rawValue: String(value)
        )
    }
}

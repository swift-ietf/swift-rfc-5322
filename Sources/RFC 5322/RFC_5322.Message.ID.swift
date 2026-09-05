public import ASCII
public import Byte
import Byte_Standard_Library_Integration
import INCITS_4_1986
public import RFC_1123

extension RFC_5322.Message {

    public struct ID: Hashable, Sendable {

        package let value: [Byte]

        internal init(
            __unchecked: Void,
            rawValue: [Byte]
        ) {
            self.value = rawValue
        }
    }
}

extension RFC_5322.Message.ID {

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
        let count = codes.count

        var hasAtSign = false
        for code in codes where code == ASCII.Code.at {
            hasAtSign = true
            break
        }
        guard hasAtSign else {
            let string = String(decoding: bytes, as: UTF8.self)
            throw Error.missingAtSign(string)
        }

        let stripBrackets =
            count >= 2
            && codes.first == ASCII.Code.lt
            && codes.last == ASCII.Code.gt

        var result = [Byte]()

        for (index, code) in codes.enumerated() {

            if stripBrackets && index == 0 && code == ASCII.Code.lt {
                continue
            }

            if stripBrackets && index == count - 1 && code == ASCII.Code.gt {
                continue
            }

            guard code.isVisible && code != ASCII.Code.space else {
                let string = String(decoding: bytes, as: UTF8.self)
                throw Error.invalidCharacter(
                    string,
                    code: code,
                    reason: "Must be printable ASCII without spaces"
                )
            }

            result.append(code.byte)
        }

        self.value = result
    }
}

extension RFC_5322.Message.ID {

    public init(uniqueId: String, domain: RFC_1123.Domain) {
        var result = [Byte]()
        result.append(contentsOf: uniqueId.utf8.lazy.map(Byte.init(bitPattern:)))
        result.append(ASCII.Code.at.byte)
        result.append(contentsOf: domain.name.utf8.lazy.map(Byte.init(bitPattern:)))
        self.value = result
    }
}

extension RFC_5322.Message.ID: CustomStringConvertible {

    public var description: String {
        "<\(String(decoding: value, as: UTF8.self))>"
    }
}


extension RFC_5322.Message.ID: ExpressibleByFloatLiteral {

    public init(floatLiteral value: Double) {
        do throws(Error) {
            try self.init(String(value))
        } catch {
            preconditionFailure("Invalid ASCII Message-ID float literal: \(error)")
        }
    }
}
extension RFC_5322.Message.ID: ExpressibleByIntegerLiteral {

    public init(integerLiteral value: Int) {
        do throws(Error) {
            try self.init(String(value))
        } catch {
            preconditionFailure("Invalid ASCII Message-ID integer literal: \(error)")
        }
    }
}

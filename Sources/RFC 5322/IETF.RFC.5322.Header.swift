import ASCII
public import Byte
import INCITS_4_1986

extension IETF.RFC.`5322` {

    public struct Header: Hashable, Sendable {

        public let name: Header.Name

        public let value: Header.Value

        public init(
            name: Header.Name,
            value: Header.Value
        ) {
            self.name = name
            self.value = value
        }
    }
}

extension IETF.RFC.`5322`.Header {

    public init(_ string: some StringProtocol) throws(Error) {
        try self.init(ascii: string.utf8.map(Byte.init(bitPattern:)))
    }

    public init<Bytes: Swift::Collection>(ascii bytes: Bytes) throws(Error)
    where Bytes.Element == Byte {

        guard let colonIndex = bytes.firstIndex(of: ASCII.Code.colon.byte) else {
            let string = String(decoding: bytes, as: UTF8.self)
            throw Error.invalidFormat(string, reason: "Missing colon separator")
        }

        let nameBytes = bytes[..<colonIndex]
        let valueStartIndex = bytes.index(after: colonIndex)
        let valueBytes = bytes[valueStartIndex...]

        let name: IETF.RFC.`5322`.Header.Name
        do throws(IETF.RFC.`5322`.Header.Name.Error) {
            name = try IETF.RFC.`5322`.Header.Name(ascii: [Byte](nameBytes))
        } catch {
            throw Error.invalidName(error)
        }

        let value: IETF.RFC.`5322`.Header.Value
        do throws(IETF.RFC.`5322`.Header.Value.Error) {
            value = try IETF.RFC.`5322`.Header.Value(ascii: [Byte](valueBytes))
        } catch {
            throw Error.invalidValue(error)
        }

        self.init(name: name, value: value)
    }
}

extension IETF.RFC.`5322`.Header: CustomStringConvertible {

    public var description: String {
        "\(name.description): \(value.description)"
    }
}

extension Array where Element == IETF.RFC.`5322`.Header {

    public subscript(name: IETF.RFC.`5322`.Header.Name) -> IETF.RFC.`5322`.Header.Value? {
        get {
            first(where: { $0.name == name })?.value
        }
        set {
            removeAll(where: { $0.name == name })
            if let newValue {
                append(IETF.RFC.`5322`.Header(name: name, value: newValue))
            }
        }
    }

    public func all(_ name: IETF.RFC.`5322`.Header.Name) -> [IETF.RFC.`5322`.Header] {
        filter { $0.name == name }
    }

    public func values(for name: IETF.RFC.`5322`.Header.Name) -> [IETF.RFC.`5322`.Header.Value] {
        filter { $0.name == name }.map({ $0.value })
    }
}

extension Array: @retroactive ExpressibleByDictionaryLiteral where Element == IETF.RFC.`5322`.Header {

    public init(dictionaryLiteral elements: (IETF.RFC.`5322`.Header.Name, IETF.RFC.`5322`.Header.Value)...) {
        self = elements.map { IETF.RFC.`5322`.Header(name: $0.0, value: $0.1) }
    }
}

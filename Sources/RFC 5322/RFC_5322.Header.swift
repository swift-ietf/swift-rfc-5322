public import ASCII_Serializer
public import Binary_Serializable
import Byte
import Byte_Standard_Library_Integration
import INCITS_4_1986
public import Parseable_ASCII

extension RFC_5322 {

    public struct Header: Hashable, Sendable, Codable {

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

extension RFC_5322.Header: ASCII.Serializable, Binary.Serializable {

    public static func serialize<Buffer: RangeReplaceableCollection>(
        _ value: Self,
        into buffer: inout Buffer
    ) where Buffer.Element == ASCII.Code {
        RFC_5322.Header.Name.serialize(value.name, into: &buffer)
        buffer.append(ASCII.Code.colon)
        buffer.append(ASCII.Code.space)
        RFC_5322.Header.Value.serialize(value.value, into: &buffer)
    }

    public static func serialize<Buffer: RangeReplaceableCollection>(
        _ value: Self,
        into buffer: inout Buffer
    ) where Buffer.Element == Byte {
        RFC_5322.Header.Name.serialize(value.name, into: &buffer)
        buffer.append(ASCII.Code.colon.byte)
        buffer.append(ASCII.Code.space.byte)
        RFC_5322.Header.Value.serialize(value.value, into: &buffer)
    }
}

extension RFC_5322.Header: ASCII.Parseable {

    public init(_ string: some StringProtocol) throws(Error) {
        try self.init(ascii: string.utf8.map(Byte.init(bitPattern:)))
    }

    public init<Bytes: Swift.Collection>(ascii bytes: Bytes) throws(Error)
    where Bytes.Element == Byte {

        guard let colonIndex = bytes.firstIndex(of: ASCII.Code.colon.byte) else {
            let string = String(decoding: bytes, as: UTF8.self)
            throw Error.invalidFormat(string, reason: "Missing colon separator")
        }

        let nameBytes = bytes[..<colonIndex]
        let valueStartIndex = bytes.index(after: colonIndex)
        let valueBytes = bytes[valueStartIndex...]

        let name: RFC_5322.Header.Name
        do throws(RFC_5322.Header.Name.Error) {
            name = try RFC_5322.Header.Name(ascii: [Byte](nameBytes))
        } catch {
            throw Error.invalidName(error)
        }

        let value: RFC_5322.Header.Value
        do throws(RFC_5322.Header.Value.Error) {
            value = try RFC_5322.Header.Value(ascii: [Byte](valueBytes))
        } catch {
            throw Error.invalidValue(error)
        }

        self.init(name: name, value: value)
    }
}

extension RFC_5322.Header: CustomStringConvertible {

    public var description: String {
        String(decoding: serialized, as: UTF8.self)
    }
}

extension Array where Element == RFC_5322.Header {

    public subscript(name: RFC_5322.Header.Name) -> String? {
        get {
            first(where: { $0.name == name })?.value.rawValue
        }
        set {
            removeAll(where: { $0.name == name })
            if let newValue {
                do throws(RFC_5322.Header.Value.Error) {
                    let value = try RFC_5322.Header.Value(newValue)
                    append(
                        RFC_5322.Header(
                            name: name,
                            value: value
                        )
                    )
                } catch {
                }
            }
        }
    }

    public func all(_ name: RFC_5322.Header.Name) -> [RFC_5322.Header] {
        filter { $0.name == name }
    }

    public func values(for name: RFC_5322.Header.Name) -> [RFC_5322.Header.Value] {
        filter { $0.name == name }.map(\.value)
    }
}

extension Array: @retroactive ExpressibleByDictionaryLiteral where Element == RFC_5322.Header {

    public init(dictionaryLiteral elements: (RFC_5322.Header.Name, RFC_5322.Header.Value)...) {
        self = elements.map { RFC_5322.Header(name: $0.0, value: $0.1) }
    }
}

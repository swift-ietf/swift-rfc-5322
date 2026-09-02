public import Byte
public import Byte_Parser
public import Checkpoint
public import Cursor
public import Cursor_Parser_First
public import Cursor_Parser_Many
public import Either
public import Parser
public import Parser_Error
public import Parser_Map
public import Parser_Sequence
public import Parser_Skip

extension RFC_5322.Message.ID {

    public struct Parse<Input: Cursor.`Protocol`>: Sendable
    where Input.Element == Byte, Input.Failure == Never, Input.Checkpoint: Equatable {
        @inlinable
        public init() {}
    }
}

extension RFC_5322.Message.ID.Parse {
    public struct Output: Sendable {
        public let left: [Byte]
        public let right: [Byte]

        @inlinable
        public init(left: [Byte], right: [Byte]) {
            self.left = left
            self.right = right
        }
    }

    public enum Error: Swift.Error, Sendable, Equatable {
        case expectedOpenAngle
        case expectedAtSign
        case expectedCloseAngle
    }
}

extension RFC_5322.Message.ID.Parse: Parser.`Protocol` {
    public typealias Failure = RFC_5322.Message.ID.Parse<Input>.Error

    public typealias Body = Never

    @inlinable
    public func parse(_ input: inout Input) throws(Failure) -> Output {
        let messageID = Parser.Sequence(Input.self) {
            Byte.Literal.Parser<Input>("<")
            Parser.Many {
                Parser.First.Where<Input>(expected: "byte before @", Self._isNotAtSign)
            }
            Byte.Literal.Parser<Input>("@")
            Parser.Many {
                Parser.First.Where<Input>(expected: "byte before >", Self._isNotCloseAngle)
            }
            Byte.Literal.Parser<Input>(">")
        }
        .map { (pair: ([Byte], [Byte])) in
            Output(left: pair.0, right: pair.1)
        }
        .error.map { error -> Failure in
            switch error {
            case .right: .expectedCloseAngle
            case .left(.right): .expectedCloseAngle
            case .left(.left(.right)): .expectedAtSign
            case .left(.left(.left(.right))): .expectedAtSign
            case .left(.left(.left(.left))): .expectedOpenAngle
            }
        }

        return try messageID.parse(&input)
    }

    @inlinable
    package static func _isNotAtSign(_ byte: Byte) -> Bool {
        byte != Byte(bitPattern: 0x40)
    }

    @inlinable
    package static func _isNotCloseAngle(_ byte: Byte) -> Bool {
        byte != Byte(bitPattern: 0x3E)
    }
}

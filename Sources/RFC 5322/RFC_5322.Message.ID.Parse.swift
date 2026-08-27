public import Parser

extension RFC_5322.Message.ID {

    public struct Parse<Input: Collection.Slice.`Protocol`>: Sendable
    where Input: Sendable, Input.Element == Byte {
        @inlinable
        public init() {}
    }
}

extension RFC_5322.Message.ID.Parse {
    public struct Output: Sendable {
        public let left: Input
        public let right: Input

        @inlinable
        public init(left: Input, right: Input) {
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

    @inlinable
    public func parse(_ input: inout Input) throws(Failure) -> Output {

        guard input.startIndex < input.endIndex,
            input[input.startIndex] == 0x3C
        else {
            throw .expectedOpenAngle
        }
        input = input[input.index(after: input.startIndex)...]

        let leftStart = input.startIndex
        while input.startIndex < input.endIndex && input[input.startIndex] != 0x40 {
            input = input[input.index(after: input.startIndex)...]
        }
        guard input.startIndex < input.endIndex else { throw .expectedAtSign }
        let left = input[leftStart..<input.startIndex]

        input = input[input.index(after: input.startIndex)...]

        let rightStart = input.startIndex
        while input.startIndex < input.endIndex && input[input.startIndex] != 0x3E {
            input = input[input.index(after: input.startIndex)...]
        }
        guard input.startIndex < input.endIndex else { throw .expectedCloseAngle }
        let right = input[rightStart..<input.startIndex]

        input = input[input.index(after: input.startIndex)...]

        return Output(left: left, right: right)
    }
}

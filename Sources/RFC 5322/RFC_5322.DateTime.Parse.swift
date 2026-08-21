public import ASCII_Decimal_Parser_Primitives
import Byte_Primitives
import Parser_Primitives

extension RFC_5322.DateTime {

    public struct Parse<Input: Collection.Slice.`Protocol`>: Sendable
    where Input: Sendable, Input.Element == Byte {
        @inlinable
        public init() {}
    }
}

extension RFC_5322.DateTime.Parse {
    public struct Output: Sendable {

        public let dayOfWeek: Input?

        public let day: Int

        public let month: Input

        public let year: Int

        public let hour: Int

        public let minute: Int

        public let second: Int

        public let timezone: Input

        @inlinable
        public init(
            dayOfWeek: Input?,
            day: Int,
            month: Input,
            year: Int,
            hour: Int,
            minute: Int,
            second: Int,
            timezone: Input
        ) {
            self.dayOfWeek = dayOfWeek
            self.month = month
            self.day = day
            self.year = year
            self.hour = hour
            self.minute = minute
            self.second = second
            self.timezone = timezone
        }
    }

    public enum Error: Swift.Error, Sendable, Equatable {
        case expectedDigit

        case overflow
        case expectedMonth
        case expectedColon
        case expectedTimezone
        case unexpectedEndOfInput
    }
}

extension RFC_5322.DateTime.Parse: Parser.`Protocol` {
    public typealias Failure = RFC_5322.DateTime.Parse<Input>.Error

    @inlinable
    public func parse(_ input: inout Input) throws(Failure) -> Output {
        Self._skipCFWS(&input)

        var dayOfWeek: Input? = nil
        let saved = input
        if let dow = Self._tryDayOfWeek(&input) {
            dayOfWeek = dow
        } else {
            input = saved
        }

        Self._skipCFWS(&input)

        let day = try Self._parseNumber(&input)

        Self._skipCFWS(&input)

        let month = try Self._parseAlpha(&input, count: 3)

        Self._skipCFWS(&input)

        let year = try Self._parseNumber(&input)

        Self._skipCFWS(&input)

        let hour = try Self._parseNumber(&input)

        guard input.startIndex < input.endIndex, input[input.startIndex] == 0x3A else {
            throw .expectedColon
        }
        input = input[input.index(after: input.startIndex)...]

        let minute = try Self._parseNumber(&input)

        var second = 0
        if input.startIndex < input.endIndex && input[input.startIndex] == 0x3A {
            input = input[input.index(after: input.startIndex)...]
            second = try Self._parseNumber(&input)
        }

        Self._skipCFWS(&input)

        let tzStart = input.startIndex
        while input.startIndex < input.endIndex {
            let byte = input[input.startIndex]
            if byte == 0x20 || byte == 0x09 || byte == 0x0D || byte == 0x0A { break }
            input = input[input.index(after: input.startIndex)...]
        }
        guard tzStart < input.startIndex else { throw .expectedTimezone }
        let timezone = input[tzStart..<input.startIndex]

        Self._skipCFWS(&input)

        return Output(
            dayOfWeek: dayOfWeek,
            day: day,
            month: month,
            year: year,
            hour: hour,
            minute: minute,
            second: second,
            timezone: timezone
        )
    }

    @inlinable
    package static func _skipCFWS(_ input: inout Input) {
        while input.startIndex < input.endIndex {
            let byte = input[input.startIndex]
            guard byte == 0x20 || byte == 0x09 || byte == 0x0D || byte == 0x0A else { break }
            input = input[input.index(after: input.startIndex)...]
        }
    }

    @inlinable
    package static func _tryDayOfWeek(_ input: inout Input) -> Input? {
        var idx = input.startIndex
        var count = 0
        while idx < input.endIndex && count < 3 {
            let byte = input[idx]
            guard (byte >= 0x41 && byte <= 0x5A) || (byte >= 0x61 && byte <= 0x7A) else {
                return nil
            }
            input.formIndex(after: &idx)
            count += 1
        }
        guard count == 3 else { return nil }
        let dow = input[input.startIndex..<idx]

        guard idx < input.endIndex && input[idx] == 0x2C else { return nil }
        input.formIndex(after: &idx)
        input = input[idx...]
        return dow
    }

    @inlinable
    package static func _parseNumber(_ input: inout Input) throws(Failure) -> Int {

        do throws(ASCII.Decimal.Error) {
            return try ASCII.Decimal.Parser<Input, Int>().parse(&input)
        } catch {
            switch error {
            case .noDigits, .insufficientDigits, .invalidSign: throw .expectedDigit
            case .overflow: throw .overflow
            }
        }
    }

    @inlinable
    package static func _parseAlpha(_ input: inout Input, count: Int) throws(Failure) -> Input {
        let start = input.startIndex
        var idx = start
        var n = 0
        while idx < input.endIndex && n < count {
            let byte = input[idx]
            guard (byte >= 0x41 && byte <= 0x5A) || (byte >= 0x61 && byte <= 0x7A) else {
                throw .expectedMonth
            }
            input.formIndex(after: &idx)
            n += 1
        }
        guard n == count else { throw .expectedMonth }
        let result = input[start..<idx]
        input = input[idx...]
        return result
    }
}

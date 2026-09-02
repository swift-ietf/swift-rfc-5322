public import ASCII_Decimal_Parser
public import Byte
public import Byte_Parser
public import Checkpoint
public import Cursor
public import Cursor_Parser_First
public import Cursor_Parser_Many
public import Cursor_Parser_Optionally
public import Iterator_Protocol
public import Parser
public import Parser_Error
public import Parser_Sequence
public import Parser_Skip

extension RFC_5322.DateTime {

    public struct Parse<Input: Cursor.`Protocol`>: Sendable
    where Input.Element == Byte, Input.Failure == Never, Input.Checkpoint: Equatable {
        @inlinable
        public init() {}
    }
}

extension RFC_5322.DateTime.Parse {
    public struct Output: Sendable {

        public let dayOfWeek: [Byte]?

        public let day: Int

        public let month: [Byte]

        public let year: Int

        public let hour: Int

        public let minute: Int

        public let second: Int

        public let timezone: [Byte]

        @inlinable
        public init(
            dayOfWeek: [Byte]?,
            day: Int,
            month: [Byte],
            year: Int,
            hour: Int,
            minute: Int,
            second: Int,
            timezone: [Byte]
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
    }
}

extension RFC_5322.DateTime.Parse: Parser.`Protocol` {
    public typealias Failure = RFC_5322.DateTime.Parse<Input>.Error

    public typealias Body = Never

    @inlinable
    public func parse(_ input: inout Input) throws(Failure) -> Output {
        let number = ASCII.Decimal.Parser<Input, Int>()
            .error.map { error -> Failure in
                switch error {
                case .overflow: .overflow
                case .noDigits, .insufficientDigits, .invalidSign: .expectedDigit
                }
            }

        let dayOfWeekLetters = Parser.Many(3...3) {
            Parser.First.Where<Input>(expected: "day of week letter", Self._isLetter)
        }
        let dayOfWeekComma = Byte.Literal.Parser<Input>(",")
        let dayOfWeek = Parser.Optionally(
            Parser.Sequence(Input.self) {
                dayOfWeekLetters
                dayOfWeekComma
            }
        )

        let month = Parser.Many(3...3) {
            Parser.First.Where<Input>(expected: "month letter", Self._isLetter)
        }
        .error.map { _ in Failure.expectedMonth }

        let colon = Byte.Literal.Parser<Input>(":")
            .error.map { _ in Failure.expectedColon }

        let secondsColon = Byte.Literal.Parser<Input>(":")
        let secondsNumber = ASCII.Decimal.Parser<Input, Int>()
        let seconds = Parser.Optionally(
            Parser.Sequence(Input.self) {
                secondsColon
                secondsNumber
            }
        )

        let timezone = Parser.Many(1...) {
            Parser.First.Where<Input>(expected: "timezone byte", Self._isNotWhitespace)
        }
        .error.map { _ in Failure.expectedTimezone }

        Self._skipWhitespace(&input)

        let weekday = dayOfWeek.parse(&input)

        Self._skipWhitespace(&input)

        let day = try number.parse(&input)

        Self._skipWhitespace(&input)

        let monthName = try month.parse(&input)

        Self._skipWhitespace(&input)

        let year = try number.parse(&input)

        Self._skipWhitespace(&input)

        let hour = try number.parse(&input)

        try colon.parse(&input)

        let minute = try number.parse(&input)

        let second = seconds.parse(&input) ?? 0

        Self._skipWhitespace(&input)

        let zone = try timezone.parse(&input)

        Self._skipWhitespace(&input)

        return Output(
            dayOfWeek: weekday,
            day: day,
            month: monthName,
            year: year,
            hour: hour,
            minute: minute,
            second: second,
            timezone: zone
        )
    }

    @inlinable
    package static func _isWhitespace(_ byte: Byte) -> Bool {
        let code = byte.bitPattern
        return code == 0x20 || code == 0x09 || code == 0x0D || code == 0x0A
    }

    @inlinable
    package static func _isNotWhitespace(_ byte: Byte) -> Bool {
        !_isWhitespace(byte)
    }

    @inlinable
    package static func _isLetter(_ byte: Byte) -> Bool {
        let code = byte.bitPattern
        return (code >= 0x41 && code <= 0x5A) || (code >= 0x61 && code <= 0x7A)
    }

    @inlinable
    package static func _skipWhitespace(_ input: inout Input) {
        while true {
            let mark = input.checkpoint
            guard let byte = input.next(), _isWhitespace(byte) else {
                input.seek(to: mark)
                return
            }
        }
    }
}

import ASCII
public import Byte
import Byte_Standard_Library_Integration
import INCITS_4_1986
public import Time

extension RFC_5322 {

    public struct DateTime: Sendable, Equatable, Hashable, Comparable {

        public let time: Time

        public let timezoneOffset: Time.Timezone.Offset

        public init(time: Time, timezoneOffset: Time.Timezone.Offset = .utc) {
            self.time = time
            self.timezoneOffset = timezoneOffset
        }
    }
}

extension RFC_5322 {
    public typealias Date = RFC_5322.DateTime
}

extension RFC_5322.DateTime {

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
            throw Error.invalidFormat(String(decoding: bytes, as: UTF8.self))
        }

        var parts: [[ASCII.Code]] = []
        var currentPart: [ASCII.Code] = []

        for code in codes {
            if code == ASCII.Code.space {
                if !currentPart.isEmpty {
                    parts.append(currentPart)
                    currentPart = []
                }
            } else {
                currentPart.append(code)
            }
        }
        if !currentPart.isEmpty {
            parts.append(currentPart)
        }

        guard parts.count >= 6 else {
            throw Error.invalidFormat("Expected at least 6 components, got \(parts.count)")
        }

        let dayNameCodes = parts[0].last == ASCII.Code.comma ? parts[0].dropLast() : parts[0][...]
        let dayName = String(decoding: dayNameCodes.lazy.map(\.underlying), as: UTF8.self)

        guard let expectedWeekday = RFC_5322.DateTime.dayNames.firstIndex(of: dayName) else {
            throw Error.invalidDayName(dayName)
        }

        let dayString = String(decoding: parts[1].lazy.map(\.underlying), as: UTF8.self)
        guard let day = Int(dayString), day >= 1, day <= 31 else {
            throw Error.invalidDay(dayString)
        }

        let monthString = String(decoding: parts[2].lazy.map(\.underlying), as: UTF8.self)
        guard let monthIndex = RFC_5322.DateTime.monthNames.firstIndex(of: monthString) else {
            throw Error.invalidMonth(monthString)
        }
        let month = monthIndex + 1

        let yearString = String(decoding: parts[3].lazy.map(\.underlying), as: UTF8.self)
        guard let year = Int(yearString), year >= 1900 else {
            throw Error.invalidYear(yearString)
        }

        let timeCodes = parts[4]
        var timeParts: [[ASCII.Code]] = []
        var currentTimePart: [ASCII.Code] = []

        for code in timeCodes {
            if code == ASCII.Code.colon {
                if !currentTimePart.isEmpty {
                    timeParts.append(currentTimePart)
                    currentTimePart = []
                }
            } else {
                currentTimePart.append(code)
            }
        }
        if !currentTimePart.isEmpty {
            timeParts.append(currentTimePart)
        }

        guard timeParts.count >= 2, timeParts.count <= 3 else {
            let timeString = String(decoding: timeCodes.lazy.map(\.underlying), as: UTF8.self)
            throw Error.invalidTime(timeString)
        }

        let hourString = String(decoding: timeParts[0].lazy.map(\.underlying), as: UTF8.self)
        guard let hour = Int(hourString), hour >= 0, hour <= 23 else {
            throw Error.invalidHour(hourString)
        }

        let minuteString = String(decoding: timeParts[1].lazy.map(\.underlying), as: UTF8.self)
        guard let minute = Int(minuteString), minute >= 0, minute <= 59 else {
            throw Error.invalidMinute(minuteString)
        }

        let second: Int
        if timeParts.count == 3 {
            let secondString = String(decoding: timeParts[2].lazy.map(\.underlying), as: UTF8.self)
            guard let sec = Int(secondString), sec >= 0, sec <= 60 else {
                throw Error.invalidSecond(secondString)
            }
            second = sec
        } else {
            second = 0
        }

        let timezoneCodes = parts[5]
        guard timezoneCodes.count == 5 else {
            let timezoneString = String(decoding: timezoneCodes.lazy.map(\.underlying), as: UTF8.self)
            throw Error.invalidTimezone(timezoneString)
        }

        let sign = timezoneCodes[0] == ASCII.Code.plus ? 1 : -1
        let offsetCodes = timezoneCodes.dropFirst()

        let offsetHoursCodes = offsetCodes.prefix(2)
        let offsetMinutesCodes = offsetCodes.suffix(2)

        let offsetHoursString = String(decoding: offsetHoursCodes.lazy.map(\.underlying), as: UTF8.self)
        let offsetMinutesString = String(decoding: offsetMinutesCodes.lazy.map(\.underlying), as: UTF8.self)

        guard let offsetHours = Int(offsetHoursString),
            let offsetMinutes = Int(offsetMinutesString),
            offsetHours >= 0, offsetHours <= 23,
            offsetMinutes >= 0, offsetMinutes <= 59
        else {
            let timezoneString = String(decoding: timezoneCodes.lazy.map(\.underlying), as: UTF8.self)
            throw Error.invalidTimezone(timezoneString)
        }

        let timezoneOffsetSeconds =
            sign
            * (offsetHours * Time.Calendar.Gregorian.TimeConstants.secondsPerHour + offsetMinutes
                * Time.Calendar.Gregorian.TimeConstants.secondsPerMinute)

        let localDateTime: RFC_5322.DateTime
        do throws(Time.Error) {
            localDateTime = try RFC_5322.DateTime(
                year: year,
                month: month,
                day: day,
                hour: hour,
                minute: minute,
                second: second,
                timezoneOffsetSeconds: timezoneOffsetSeconds
            )
        } catch {
            throw Error.invalidFormat("Date components invalid: \(error)")
        }

        let actualWeekday = localDateTime.components.weekday
        guard actualWeekday == expectedWeekday else {
            throw Error.weekdayMismatch(
                expected: RFC_5322.DateTime.dayNames[expectedWeekday],
                actual: RFC_5322.DateTime.dayNames[actualWeekday]
            )
        }

        self = localDateTime
    }
}

extension RFC_5322.DateTime: CustomStringConvertible {

    public var description: String {
        let components = self.components
        let offset = abs(timezoneOffsetSeconds)
        let offsetHours = offset / Time.Calendar.Gregorian.TimeConstants.secondsPerHour
        let offsetMinutes =
            (offset % Time.Calendar.Gregorian.TimeConstants.secondsPerHour)
            / Time.Calendar.Gregorian.TimeConstants.secondsPerMinute
        let sign = timezoneOffsetSeconds >= 0 ? "+" : "-"

        var text = Self.dayNames[components.weekday]
        text += ", "
        text += Self.decimal(components.day, width: 2)
        text += " "
        text += Self.monthNames[components.month - 1]
        text += " "
        text += Self.decimal(components.year, width: 4)
        text += " "
        text += Self.decimal(components.hour, width: 2)
        text += ":"
        text += Self.decimal(components.minute, width: 2)
        text += ":"
        text += Self.decimal(components.second, width: 2)
        text += " "
        text += sign
        text += Self.decimal(offsetHours, width: 2)
        text += Self.decimal(offsetMinutes, width: 2)
        return text
    }

    private static func decimal(_ value: Int, width: Int) -> String {
        let digits = String(value)
        guard digits.count < width else { return digits }
        return String(repeating: "0", count: width - digits.count) + digits
    }
}

extension RFC_5322.DateTime {

    public init(secondsSinceEpoch: Int, timezoneOffsetSeconds: Int = 0) {
        self.time = Time(secondsSinceEpoch: secondsSinceEpoch)
        self.timezoneOffset = Time.Timezone.Offset(seconds: timezoneOffsetSeconds)
    }
}

extension RFC_5322.DateTime {

    public init(
        year: Int,
        month: Int,
        day: Int,
        hour: Int = 0,
        minute: Int = 0,
        second: Int = 0,
        timezoneOffsetSeconds: Int = 0
    ) throws(Time.Error) {

        let local = try Time(
            year: year,
            month: month,
            day: day,
            hour: hour,
            minute: minute,
            second: second
        )

        self.init(
            secondsSinceEpoch: local.secondsSinceEpoch - timezoneOffsetSeconds,
            timezoneOffsetSeconds: timezoneOffsetSeconds
        )
    }
}

extension RFC_5322.DateTime {

    public var secondsSinceEpoch: Int {
        time.secondsSinceEpoch
    }

    public var timezoneOffsetSeconds: Int {
        timezoneOffset.seconds
    }
}

extension RFC_5322.DateTime {
    public static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.secondsSinceEpoch < rhs.secondsSinceEpoch
    }
}

extension RFC_5322.DateTime {

    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.secondsSinceEpoch == rhs.secondsSinceEpoch
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(secondsSinceEpoch)
    }
}

extension RFC_5322.DateTime {

    public var components: RFC_5322.Date.Components {

        let localTime = Time(secondsSinceEpoch: secondsSinceEpoch + timezoneOffsetSeconds)

        let weekdayNumber: Int
        switch localTime.weekday {
        case .sunday: weekdayNumber = 0
        case .monday: weekdayNumber = 1
        case .tuesday: weekdayNumber = 2
        case .wednesday: weekdayNumber = 3
        case .thursday: weekdayNumber = 4
        case .friday: weekdayNumber = 5
        case .saturday: weekdayNumber = 6
        }

        return RFC_5322.Date.Components(
            __unchecked: (),
            year: localTime.year.rawValue,
            month: localTime.month.rawValue,
            day: localTime.day.rawValue,
            hour: localTime.hour.value,
            minute: localTime.minute.value,
            second: localTime.second.value,
            weekday: weekdayNumber
        )
    }
}

extension RFC_5322.DateTime {

    public static let monthNames = [
        "Jan", "Feb", "Mar", "Apr", "May", "Jun",
        "Jul", "Aug", "Sep", "Oct", "Nov", "Dec",
    ]

    public static let dayNames = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
}

extension RFC_5322.DateTime {

    public func addingSeconds(_ seconds: Int) -> Self {
        Self(
            secondsSinceEpoch: secondsSinceEpoch + seconds,
            timezoneOffsetSeconds: timezoneOffsetSeconds
        )
    }

    public func subtractingSeconds(_ seconds: Int) -> Self {
        addingSeconds(-seconds)
    }

    public func distance(to other: Self) -> Int {
        other.secondsSinceEpoch - secondsSinceEpoch
    }

    public func withTimezone(offsetSeconds: Int) -> Self {
        Self(secondsSinceEpoch: secondsSinceEpoch, timezoneOffsetSeconds: offsetSeconds)
    }

    public func startOfDay() -> Self {
        let components = self.components

        return try! Self(
            year: components.year,
            month: components.month,
            day: components.day,
            hour: 0,
            minute: 0,
            second: 0,
            timezoneOffsetSeconds: timezoneOffsetSeconds
        )
    }

    public func endOfDay() -> Self {
        let components = self.components

        return try! Self(
            year: components.year,
            month: components.month,
            day: components.day,
            hour: 23,
            minute: 59,
            second: 59,
            timezoneOffsetSeconds: timezoneOffsetSeconds
        )
    }

    public func setting(
        year: Int? = nil,
        month: Int? = nil,
        day: Int? = nil,
        hour: Int? = nil,
        minute: Int? = nil,
        second: Int? = nil
    ) throws(Time.Error) -> Self {
        let current = components
        return try Self(
            year: year ?? current.year,
            month: month ?? current.month,
            day: day ?? current.day,
            hour: hour ?? current.hour,
            minute: minute ?? current.minute,
            second: second ?? current.second,
            timezoneOffsetSeconds: timezoneOffsetSeconds
        )
    }
}


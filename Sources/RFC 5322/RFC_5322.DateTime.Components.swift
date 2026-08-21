import Time_Primitives

extension RFC_5322.Date {

    public struct Components: Sendable, Equatable {
        public let year: Int
        public let month: Int
        public let day: Int
        public let hour: Int
        public let minute: Int
        public let second: Int
        public let weekday: Int

        public init(
            year: Int,
            month: Int,
            day: Int,
            hour: Int,
            minute: Int,
            second: Int,
            weekday: Int
        ) throws(Error) {

            guard (1...12).contains(month) else {
                throw Error.monthOutOfRange(month)
            }

            let maxDay = Time.Calendar.Gregorian.daysInMonths(year: year)[month - 1]
            guard (1...maxDay).contains(day) else {
                throw Error.dayOutOfRange(day, month: month, year: year)
            }

            guard (0...23).contains(hour) else {
                throw Error.hourOutOfRange(hour)
            }

            guard (0...59).contains(minute) else {
                throw Error.minuteOutOfRange(minute)
            }

            guard (0...60).contains(second) else {
                throw Error.secondOutOfRange(second)
            }

            guard (0...6).contains(weekday) else {
                throw Error.weekdayOutOfRange(weekday)
            }

            self.year = year
            self.month = month
            self.day = day
            self.hour = hour
            self.minute = minute
            self.second = second
            self.weekday = weekday
        }
    }
}

extension RFC_5322.DateTime.Components {

    init(
        __unchecked: Void,
        year: Int,
        month: Int,
        day: Int,
        hour: Int,
        minute: Int,
        second: Int,
        weekday: Int
    ) {
        self.year = year
        self.month = month
        self.day = day
        self.hour = hour
        self.minute = minute
        self.second = second
        self.weekday = weekday
    }
}

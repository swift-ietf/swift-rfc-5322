extension RFC_5322.DateTime {

    public enum Error: Swift.Error, Sendable, Equatable {
        case invalidFormat(String)
        case invalidDayName(String)
        case invalidDay(String)
        case invalidMonth(String)
        case invalidYear(String)
        case invalidTime(String)
        case invalidHour(String)
        case invalidMinute(String)
        case invalidSecond(String)
        case invalidTimezone(String)
        case weekdayMismatch(expected: String, actual: String)

        case components(RFC_5322.Date.Components.Error)
    }
}

extension RFC_5322.DateTime.Components {
    public enum Error: Swift.Error, Sendable, Equatable {
        case monthOutOfRange(Int)
        case dayOutOfRange(Int, month: Int, year: Int)
        case hourOutOfRange(Int)
        case minuteOutOfRange(Int)
        case secondOutOfRange(Int)
        case weekdayOutOfRange(Int)
    }
}

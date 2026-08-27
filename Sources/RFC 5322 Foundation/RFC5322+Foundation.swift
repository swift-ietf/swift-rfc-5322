#if canImport(Foundation)
    import ASCII_Serializer
    public import Foundation
    public import RFC_5322
    import Binary_Serializable

    extension RFC_5322.Date {

        public struct FormatStyle: Sendable {

            public let timezoneOffsetSeconds: Int

            public init(timezoneOffsetSeconds: Int = 0) {
                self.timezoneOffsetSeconds = timezoneOffsetSeconds
            }
        }
    }

    extension RFC_5322.Date.FormatStyle {

        public func format(_ date: Foundation.Date) -> String {
            let dateTime = RFC_5322.DateTime(
                secondsSinceEpoch: Int(date.timeIntervalSince1970),
                timezoneOffsetSeconds: timezoneOffsetSeconds
            )
            return String(dateTime)
        }

        public func parse(
            _ value: some StringProtocol
        ) throws(RFC_5322.DateTime.Error) -> Foundation.Date {
            let dateTime = try RFC_5322.DateTime(ascii: [Byte](value.utf8))
            return Foundation.Date(
                timeIntervalSince1970: TimeInterval(dateTime.secondsSinceEpoch)
            )
        }
    }

    extension Foundation.Date {

        public func formatted(_ style: RFC_5322.Date.FormatStyle) -> String {
            style.format(self)
        }

        public init(
            _ value: some StringProtocol,
            strategy: RFC_5322.Date.FormatStyle
        ) throws(RFC_5322.DateTime.Error) {
            let foundationDate = try strategy.parse(value)
            self = foundationDate
        }
    }

    extension RFC_5322.Date.FormatStyle {

        public static var rfc5322: RFC_5322.Date.FormatStyle {
            RFC_5322.Date.FormatStyle(timezoneOffsetSeconds: 0)
        }

        public static func rfc5322(timezoneOffsetSeconds: Int) -> Self {
            Self(timezoneOffsetSeconds: timezoneOffsetSeconds)
        }
    }

    extension RFC_5322.DateTime {

        public var foundationDate: Foundation.Date {
            Foundation.Date(timeIntervalSince1970: TimeInterval(secondsSinceEpoch))
        }

        public init(foundationDate date: Foundation.Date, timezoneOffsetSeconds: Int = 0) {
            self.init(
                secondsSinceEpoch: Int(date.timeIntervalSince1970),
                timezoneOffsetSeconds: timezoneOffsetSeconds
            )
        }
    }

    extension RFC_5322.DateTime {

        public func formatted<F: Foundation.FormatStyle>(_ style: F) -> F.FormatOutput
        where F.FormatInput == Foundation.Date {
            foundationDate.formatted(style)
        }
    }

    extension RFC_5322.DateTime {

        public func formatted(
            date: Foundation.Date.FormatStyle.DateStyle,
            time: Foundation.Date.FormatStyle.TimeStyle
        ) -> String {
            foundationDate.formatted(date: date, time: time)
        }
    }
#endif

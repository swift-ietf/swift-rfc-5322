import Foundation
import RFC_5322
import RFC_5322_Foundation_Integration
import Testing

@Suite
struct `Foundation Date Formatting` {

    @Test
    func `Format Foundation.Date as RFC 5322`() throws {

        let date = Date(timeIntervalSince1970: 1_609_459_200)

        let formatted = date.formatted(.rfc5322)

        #expect(formatted.contains("Fri"))
        #expect(formatted.contains("01"))
        #expect(formatted.contains("Jan"))
        #expect(formatted.contains("2021"))
        #expect(formatted.contains("+0000"))
    }

    @Test
    func `Format Foundation.Date with custom timezone`() throws {

        let date = Date(timeIntervalSince1970: 1_609_459_200)

        let formatted = date.formatted(.rfc5322(timezoneOffsetSeconds: -18000))

        #expect(formatted.contains("Thu"))
        #expect(formatted.contains("31"))
        #expect(formatted.contains("Dec"))
        #expect(formatted.contains("2020"))
        #expect(formatted.contains("-0500"))
    }

    @Test
    func `Parse RFC 5322 string to Foundation.Date`() throws {
        let parsed = try Date("Fri, 01 Jan 2021 00:00:00 +0000", strategy: .rfc5322)

        #expect(parsed.timeIntervalSince1970 == 1_609_459_200)
    }
}

@Suite
struct `RFC 5322 DateTime with Foundation Formatting` {

    @Test
    func `Convert RFC 5322 DateTime to Foundation.Date`() throws {
        let dt = RFC_5322.DateTime(secondsSinceEpoch: 1_609_459_200)
        let foundationDate = dt.foundationDate

        #expect(foundationDate.timeIntervalSince1970 == 1_609_459_200)
    }

    @Test
    func `Convert Foundation.Date to RFC 5322 DateTime`() throws {
        let date = Date(timeIntervalSince1970: 1_609_459_200)
        let dt = RFC_5322.DateTime(foundationDate: date)

        #expect(dt.secondsSinceEpoch == 1_609_459_200)
        #expect(dt.timezoneOffsetSeconds == 0)
    }

    @Test
    func `Convert with custom timezone`() throws {
        let date = Date(timeIntervalSince1970: 1_609_459_200)
        let dt = RFC_5322.DateTime(foundationDate: date, timezoneOffsetSeconds: -18000)

        #expect(dt.secondsSinceEpoch == 1_609_459_200)
        #expect(dt.timezoneOffsetSeconds == -18000)
    }

    @Test
    func `Format RFC 5322 DateTime using ISO 8601`() throws {
        let dt = RFC_5322.DateTime(secondsSinceEpoch: 1_609_459_200)
        let formatted = dt.formatted(Date.ISO8601FormatStyle())

        #expect(formatted.contains("2021"))
        #expect(formatted.contains("01"))
        #expect(formatted.contains("T") || formatted.contains("-"))
    }

    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    @Test
    func `Format RFC 5322 DateTime with date and time styles`() throws {
        let dt = try RFC_5322.DateTime(year: 2024, month: 1, day: 15, hour: 14, minute: 30)

        let formatted = dt.formatted(date: .numeric, time: .standard)

        #expect(formatted.contains("2024") || formatted.contains("24"))
        #expect(formatted.contains("1") || formatted.contains("01"))
        #expect(formatted.contains("15"))
    }

    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    @Test
    func `Format RFC 5322 DateTime with long date style`() throws {
        let dt = try RFC_5322.DateTime(year: 2024, month: 6, day: 15)

        let formatted = dt.formatted(date: .long, time: .omitted)

        #expect(formatted.contains("2024"))
        #expect(formatted.contains("15"))
    }

    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    @Test
    func `Format RFC 5322 DateTime with custom FormatStyle`() throws {
        let dt = try RFC_5322.DateTime(year: 2024, month: 3, day: 21, hour: 15, minute: 45)

        let formatted = dt.formatted(
            Date.FormatStyle()
                .year()
                .month(.abbreviated)
                .day()
                .hour()
                .minute()
        )

        #expect(formatted.contains("2024"))
        #expect(formatted.contains("21"))
        #expect(formatted.contains("45"))

        #expect(
            formatted.range(of: #"\d{1,2}:\d{2}|at \d{1,2}:\d{2}"#, options: .regularExpression)
                != nil
        )
    }
}

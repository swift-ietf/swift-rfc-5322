import RFC_5322
import Testing
import Time

@Suite
struct `RFC_5322.DateTime Tests` {

    @Test
    func `a date-time builds from seconds since the epoch`() {
        let dateTime = RFC_5322.DateTime(secondsSinceEpoch: 1_609_459_200)
        #expect(dateTime.secondsSinceEpoch == 1_609_459_200)
        #expect(dateTime.timezoneOffsetSeconds == 0)
    }

    @Test
    func `a date-time carries its timezone offset`() {
        let dateTime = RFC_5322.DateTime(
            secondsSinceEpoch: 1_609_459_200,
            timezoneOffsetSeconds: 3600
        )
        #expect(dateTime.secondsSinceEpoch == 1_609_459_200)
        #expect(dateTime.timezoneOffsetSeconds == 3600)
    }

    @Test
    func `a date-time builds from calendar components`() throws {
        let dateTime = try RFC_5322.DateTime(
            year: 2024,
            month: 1,
            day: 15,
            hour: 12,
            minute: 30,
            second: 45
        )
        let components = dateTime.components
        #expect(components.year == 2024)
        #expect(components.month == 1)
        #expect(components.day == 15)
        #expect(components.hour == 12)
        #expect(components.minute == 30)
        #expect(components.second == 45)
    }

    @Test
    func `a date-time builds from calendar components in a timezone`() throws {
        let dateTime = try RFC_5322.DateTime(
            year: 2024,
            month: 1,
            day: 15,
            hour: 12,
            minute: 30,
            timezoneOffsetSeconds: 3600
        )
        #expect(dateTime.timezoneOffsetSeconds == 3600)
    }

    @Test
    func `components read in the local timezone`() throws {
        let utc = try RFC_5322.DateTime(year: 2024, month: 1, day: 1)
        let local = RFC_5322.DateTime(
            secondsSinceEpoch: utc.secondsSinceEpoch,
            timezoneOffsetSeconds: 10800
        )
        #expect(local.components.hour == 3)
    }

    @Test
    func `a date-time renders the RFC 5322 date form`() {
        let dateTime = RFC_5322.DateTime(secondsSinceEpoch: 1_609_459_200)
        #expect(dateTime.description == "Fri, 01 Jan 2021 00:00:00 +0000")
    }

    @Test
    func `the rendered form carries the day name`() throws {
        let dateTime = try RFC_5322.DateTime(year: 2024, month: 1, day: 1)
        #expect(dateTime.description == "Mon, 01 Jan 2024 00:00:00 +0000")
    }

    @Test
    func `the rendered form carries a positive timezone offset`() throws {
        let dateTime = try RFC_5322.DateTime(year: 2024, month: 1, day: 1, timezoneOffsetSeconds: 3600)
        #expect(dateTime.description.hasSuffix("+0100"))
    }

    @Test
    func `the rendered form carries a negative timezone offset`() throws {
        let dateTime = try RFC_5322.DateTime(year: 2024, month: 1, day: 1, timezoneOffsetSeconds: -18000)
        #expect(dateTime.description.hasSuffix("-0500"))
    }

    @Test
    func `the rendered form zero-pads day, hour and minute`() throws {
        let dateTime = try RFC_5322.DateTime(year: 2024, month: 1, day: 5, hour: 9, minute: 3)
        #expect(dateTime.description == "Fri, 05 Jan 2024 09:03:00 +0000")
    }

    @Test
    func `a date-time reads from its text form`() throws {
        let dateTime = try RFC_5322.DateTime("Fri, 01 Jan 2021 12:00:00 +0000")
        let components = dateTime.components
        #expect(components.year == 2021)
        #expect(components.month == 1)
        #expect(components.day == 1)
        #expect(components.hour == 12)
        #expect(components.minute == 0)
        #expect(components.second == 0)
    }

    @Test
    func `a date-time reads a positive timezone offset`() throws {
        let dateTime = try RFC_5322.DateTime("Mon, 15 Jan 2024 14:30:00 +0500")
        #expect(dateTime.timezoneOffsetSeconds == 18000)
    }

    @Test
    func `a date-time reads a negative timezone offset`() throws {
        let dateTime = try RFC_5322.DateTime("Mon, 15 Jan 2024 14:30:00 -0800")
        #expect(dateTime.timezoneOffsetSeconds == -28800)
    }

    @Test
    func `a date-time round-trips through its text form`() throws {
        let text = "Mon, 15 Jan 2024 14:30:00 -0800"
        let dateTime = try RFC_5322.DateTime(text)
        #expect(dateTime.description == text)
    }

    @Test
    func `a text form whose day name disagrees with the date is rejected`() {
        #expect(throws: RFC_5322.DateTime.Error.self) {
            _ = try RFC_5322.DateTime("Mon, 01 Jan 2021 12:00:00 +0000")
        }
    }

    @Test
    func `February 29 exists in a leap year`() throws {
        let dateTime = try RFC_5322.DateTime(year: 2024, month: 2, day: 29)
        #expect(dateTime.components.month == 2)
        #expect(dateTime.components.day == 29)
    }

    @Test
    func `February 28 closes a common year`() throws {
        let dateTime = try RFC_5322.DateTime(year: 2023, month: 2, day: 28)
        #expect(dateTime.components.month == 2)
        #expect(dateTime.components.day == 28)
    }

    @Test
    func `date-times order by their instant`() {
        let earlier = RFC_5322.DateTime(secondsSinceEpoch: 1000)
        let later = RFC_5322.DateTime(secondsSinceEpoch: 2000)
        #expect(earlier < later)
        #expect(later > earlier)
    }

    @Test
    func `date-times at the same instant are equal`() {
        #expect(
            RFC_5322.DateTime(secondsSinceEpoch: 1_609_459_200)
                == RFC_5322.DateTime(secondsSinceEpoch: 1_609_459_200)
        )
    }

    @Test
    func `equality ignores the timezone offset`() {
        let utc = RFC_5322.DateTime(secondsSinceEpoch: 1_609_459_200, timezoneOffsetSeconds: 0)
        let offset = RFC_5322.DateTime(secondsSinceEpoch: 1_609_459_200, timezoneOffsetSeconds: 3600)
        #expect(utc == offset)
    }

    @Test
    func `a date-time advances by seconds`() {
        let dateTime = RFC_5322.DateTime(secondsSinceEpoch: 1000)
        #expect(dateTime.addingSeconds(500).secondsSinceEpoch == 1500)
    }

    @Test
    func `a date-time rewinds by seconds`() {
        let dateTime = RFC_5322.DateTime(secondsSinceEpoch: 1000)
        #expect(dateTime.subtractingSeconds(500).secondsSinceEpoch == 500)
    }

    @Test
    func `advancing keeps the timezone offset`() {
        let dateTime = RFC_5322.DateTime(secondsSinceEpoch: 1000, timezoneOffsetSeconds: 3600)
        #expect(dateTime.addingSeconds(500).timezoneOffsetSeconds == 3600)
    }

    @Test
    func `the distance between two date-times is in seconds`() {
        let start = RFC_5322.DateTime(secondsSinceEpoch: 1000)
        let end = RFC_5322.DateTime(secondsSinceEpoch: 1500)
        #expect(start.distance(to: end) == 500)
    }

    @Test
    func `a date-time re-expresses in another timezone`() {
        let utc = RFC_5322.DateTime(secondsSinceEpoch: 1_609_459_200)
        let tokyo = utc.withTimezone(offsetSeconds: 32400)
        #expect(tokyo == utc)
        #expect(tokyo.description == "Fri, 01 Jan 2021 09:00:00 +0900")
    }

    @Test
    func `a date-time snaps to the start and end of its day`() throws {
        let dateTime = try RFC_5322.DateTime(year: 2024, month: 1, day: 15, hour: 12, minute: 30, second: 45)
        #expect(dateTime.startOfDay().description == "Mon, 15 Jan 2024 00:00:00 +0000")
        #expect(dateTime.endOfDay().description == "Mon, 15 Jan 2024 23:59:59 +0000")
    }

    @Test
    func `a date-time replaces single components`() throws {
        let dateTime = try RFC_5322.DateTime(year: 2024, month: 1, day: 15, hour: 12)
        let shifted = try dateTime.setting(month: 3, hour: 8)
        #expect(shifted.description == "Fri, 15 Mar 2024 08:00:00 +0000")
    }

    @Test
    func `the Unix epoch is 1 January 1970`() {
        let epoch = RFC_5322.DateTime(secondsSinceEpoch: 0)
        #expect(epoch.description == "Thu, 01 Jan 1970 00:00:00 +0000")
    }

    @Test
    func `a far-future date keeps its components`() throws {
        let future = try RFC_5322.DateTime(year: 2100, month: 12, day: 31)
        #expect(future.components.year == 2100)
        #expect(future.components.month == 12)
        #expect(future.components.day == 31)
    }

    @Test
    func `a month outside 1 through 12 is rejected`() {
        #expect(throws: Time.Error.self) {
            _ = try RFC_5322.DateTime(year: 2024, month: 13, day: 1)
        }
        #expect(throws: Time.Error.self) {
            _ = try RFC_5322.DateTime(year: 2024, month: 0, day: 1)
        }
    }

    @Test
    func `a day outside its month is rejected`() {
        #expect(throws: Time.Error.self) {
            _ = try RFC_5322.DateTime(year: 2024, month: 2, day: 30)
        }
        #expect(throws: Time.Error.self) {
            _ = try RFC_5322.DateTime(year: 2024, month: 4, day: 31)
        }
        #expect(throws: Time.Error.self) {
            _ = try RFC_5322.DateTime(year: 2024, month: 1, day: 0)
        }
    }

    @Test
    func `February 29 is rejected in a common year`() {
        #expect(throws: Never.self) {
            _ = try RFC_5322.DateTime(year: 2024, month: 2, day: 29)
        }
        #expect(throws: Time.Error.self) {
            _ = try RFC_5322.DateTime(year: 2023, month: 2, day: 29)
        }
    }

    @Test
    func `an hour outside 0 through 23 is rejected`() {
        #expect(throws: Time.Error.self) {
            _ = try RFC_5322.DateTime(year: 2024, month: 1, day: 1, hour: 24)
        }
        #expect(throws: Time.Error.self) {
            _ = try RFC_5322.DateTime(year: 2024, month: 1, day: 1, hour: -1)
        }
    }

    @Test
    func `a minute outside 0 through 59 is rejected`() {
        #expect(throws: Time.Error.self) {
            _ = try RFC_5322.DateTime(year: 2024, month: 1, day: 1, minute: 60)
        }
        #expect(throws: Time.Error.self) {
            _ = try RFC_5322.DateTime(year: 2024, month: 1, day: 1, minute: -1)
        }
    }

    @Test
    func `a leap second is accepted and second 61 is rejected`() {
        #expect(throws: Never.self) {
            _ = try RFC_5322.DateTime(year: 2024, month: 1, day: 1, second: 60)
        }
        #expect(throws: Time.Error.self) {
            _ = try RFC_5322.DateTime(year: 2024, month: 1, day: 1, second: 61)
        }
        #expect(throws: Time.Error.self) {
            _ = try RFC_5322.DateTime(year: 2024, month: 1, day: 1, second: -1)
        }
    }

    @Test
    func `the year 2100 is not a leap year`() {
        #expect(throws: Never.self) {
            _ = try RFC_5322.DateTime(year: 2100, month: 2, day: 28)
        }
        #expect(throws: Time.Error.self) {
            _ = try RFC_5322.DateTime(year: 2100, month: 2, day: 29)
        }
    }

    @Test
    func `the day after 31 December 2100 is one day later`() throws {
        let last = try RFC_5322.DateTime(year: 2100, month: 12, day: 31)
        let next = try RFC_5322.DateTime(year: 2101, month: 1, day: 1)
        #expect(last.distance(to: next) == 86400)
    }
}

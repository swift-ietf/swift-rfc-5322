import Testing

@testable import RFC_5322

@Suite
struct `Date-time numeric fields` {
    @Test
    func `a well-formed date-time with either zone sign parses`() throws {
        _ = try RFC_5322.DateTime("Fri, 01 Jan 2021 00:00:00 +0000")
        _ = try RFC_5322.DateTime("Fri, 01 Jan 2021 00:00:00 -0100")
    }

    @Test(arguments: [
        "Fri, +1 Jan 2021 00:00:00 +0000",
        "Fri, 01 Jan +2021 00:00:00 +0000",
        "Fri, 01 Jan 2021 +0:00:00 +0000",
        "Fri, 01 Jan 2021 00:-0:00 +0000",
        "Fri, 01 Jan 2021 00:00:+0 +0000",
        "Fri, 01 Jan 2021 00:00:00 ++100",
        "Fri, 01 Jan 2021 00:00:00 +01-0",
    ])
    func `a signed numeric field is refused`(_ text: String) {
        #expect(throws: RFC_5322.DateTime.Error.self) {
            try RFC_5322.DateTime(text)
        }
    }

    @Test(arguments: ["X0100", "00100", " 0100"])
    func `a zone without a plus or minus sign is refused`(_ zone: String) {
        #expect(throws: RFC_5322.DateTime.Error.self) {
            try RFC_5322.DateTime("Fri, 01 Jan 2021 00:00:00 " + zone)
        }
    }
}

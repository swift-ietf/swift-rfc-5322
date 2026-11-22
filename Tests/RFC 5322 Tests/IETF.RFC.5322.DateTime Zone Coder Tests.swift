#if Coder
    import Byte
    import RFC_5322
    import Testing

    enum `IETF.RFC.5322.DateTime Zone Coder Tests` {}

    extension `IETF.RFC.5322.DateTime Zone Coder Tests` {
        @Suite
        struct `Date-time coder zone digits` {
            @Test(arguments: ["+-100", "+01-5", "+0+00", "-+100"])
            func `a sign inside the zone digits is refused`(_ zone: String) {
                var input = ArraySlice(("Tue, 15 Nov 1994 08:12:31 " + zone).utf8.map(Byte.init(bitPattern:)))
                #expect(throws: IETF.RFC.`5322`.DateTime.Error.self) {
                    try IETF.RFC.`5322`.DateTime.coder.parse(&input)
                }
            }

            @Test
            func `a negative zone keeps its sign`() throws {
                var input: ArraySlice<Byte> = "Tue, 15 Nov 1994 08:12:31 -0130"
                #expect(try IETF.RFC.`5322`.DateTime.coder.parse(&input).timezoneOffsetSeconds == -5400)
            }
        }
    }
#endif

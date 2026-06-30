//
//  DateTimeSerializationEquivalenceTests.swift
//  swift-rfc-5322
//
//  [FAM-012] leaf re-cut guard. The DateTime `ASCII.Serializable` verb formats
//  the §3.3 date-time natively on the `ASCII.Code` substrate; the
//  `Binary.Serializable` witness (`serializeBytes`) re-expresses the same numeric
//  formatting on the byte substrate. Because the two bodies are maintained
//  independently, this asserts they emit byte-identical output (ASCII output ==
//  Binary output) on a non-UTC offset that exercises the sign / zero-padding
//  branches.
//

import RFC_5322
import Testing

@Suite
struct `DateTime Serialization Equivalence` {

    @Test
    func `ASCII verb output equals Binary witness output for a non-UTC offset`() throws {
        // Negative offset + non-trivial components exercise the sign branch and
        // every zero-padded numeric field.
        let dateTime = try RFC_5322.DateTime(
            year: 2024,
            month: 1,
            day: 1,
            hour: 9,
            minute: 5,
            second: 7,
            timezoneOffsetSeconds: -18000  // -0500
        )

        // ASCII.Serializable verb output, projected to bytes.
        let viaASCII: [Byte] = dateTime.serialized

        // Binary.Serializable witness output.
        var viaBinary: [Byte] = []
        RFC_5322.DateTime.serialize(dateTime, into: &viaBinary)

        #expect(viaASCII == viaBinary)
    }
}

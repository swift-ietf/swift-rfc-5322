import Byte
import RFC_5322
import Testing

@Suite
struct `EmailAddress Serialization Equivalence` {

    @Test
    func `ASCII verb output equals Binary witness output for the display-name quoting path`() throws
    {

        let email = try RFC_5322.EmailAddress("\"Doe, John\" <jd@example.com>")

        let viaASCII: [Byte] = email.serialized

        var viaBinary: [Byte] = []
        RFC_5322.EmailAddress.serialize(email, into: &viaBinary)

        #expect(viaASCII == viaBinary)
    }
}

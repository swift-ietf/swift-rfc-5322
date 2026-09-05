import RFC_5322
import Testing

@Suite
struct `RFC_5322.Mailbox Tests` {

    @Test
    func `a mailbox reads a bare address`() throws {
        let mailbox = try RFC_5322.Mailbox("user@example.com")
        #expect(mailbox.localPart.description == "user")
        #expect(mailbox.domain.name == "example.com")
        #expect(mailbox.displayName == nil)
    }

    @Test
    func `a mailbox reads a display name with an angle-addr`() throws {
        let mailbox = try RFC_5322.Mailbox("John Doe <john@example.com>")
        #expect(mailbox.displayName == "John Doe")
        #expect(mailbox.localPart.description == "john")
        #expect(mailbox.domain.name == "example.com")
        #expect(mailbox.address == "john@example.com")
    }

    @Test
    func `a mailbox reads a quoted display name`() throws {
        let mailbox = try RFC_5322.Mailbox("\"Doe, John\" <john@example.com>")
        #expect(mailbox.displayName == "Doe, John")
        #expect(mailbox.address == "john@example.com")
    }

    @Test
    func `a mailbox builds from its local part and domain`() throws {
        let mailbox = try RFC_5322.Mailbox(
            localPart: .init("user"),
            domain: .init("example.com")
        )
        #expect(mailbox.displayName == nil)
        #expect(mailbox.localPart.description == "user")
        #expect(mailbox.domain.name == "example.com")
    }

    @Test
    func `a mailbox builds with a display name`() throws {
        let mailbox = try RFC_5322.Mailbox(
            displayName: "Jane Smith",
            localPart: .init("jane"),
            domain: .init("example.com")
        )
        #expect(mailbox.displayName == "Jane Smith")
        #expect(mailbox.localPart.description == "jane")
        #expect(mailbox.domain.name == "example.com")
    }

    @Test
    func `a mailbox trims the whitespace around a display name`() throws {
        let mailbox = try RFC_5322.Mailbox(
            displayName: "  Jane Smith  ",
            localPart: .init("jane"),
            domain: .init("example.com")
        )
        #expect(mailbox.displayName == "Jane Smith")
    }

    @Test
    func `every atext special character is accepted in the local part`() throws {
        for character in "!#$%&'*+-/=?^_`{|}~" {
            let mailbox = try RFC_5322.Mailbox("test\(character)user@example.com")
            #expect(mailbox.localPart.description.contains(character))
        }
    }

    @Test
    func `the whole atext alphabet fits in one local part`() throws {
        let localPart = "test!#$%&'*+-/=?^_`{|}~user"
        let mailbox = try RFC_5322.Mailbox("\(localPart)@example.com")
        #expect(mailbox.localPart.description == localPart)
    }

    @Test(arguments: [
        "user!tag@example.com",
        "user|tag@example.com",
        "test#value@example.com",
        "name+tag@example.com",
        "user=value@example.com",
        "test!user|tag@example.com",
    ])
    func `an address with atext specials round-trips through its text form`(
        _ address: String
    ) throws {
        let mailbox = try RFC_5322.Mailbox(address)
        #expect(mailbox.address == address)
        #expect(mailbox.description == address)
    }

    @Test
    func `a mailbox without a display name renders as its address`() throws {
        let mailbox = try RFC_5322.Mailbox("user@example.com")
        #expect(mailbox.description == "user@example.com")
    }

    @Test
    func `a mailbox with a display name renders as name-addr`() throws {
        let mailbox = try RFC_5322.Mailbox(
            displayName: "John Doe",
            localPart: .init("john"),
            domain: .init("example.com")
        )
        #expect(mailbox.description == "John Doe <john@example.com>")
    }

    @Test
    func `a display name with specials renders quoted`() throws {
        let mailbox = try RFC_5322.Mailbox(
            displayName: "Doe, John",
            localPart: .init("john"),
            domain: .init("example.com")
        )
        #expect(mailbox.description == "\"Doe, John\" <john@example.com>")
    }

    @Test
    func `the address leaves the display name out`() throws {
        let mailbox = try RFC_5322.Mailbox(
            displayName: "John Doe",
            localPart: .init("john"),
            domain: .init("example.com")
        )
        #expect(mailbox.address == "john@example.com")
    }

    @Test
    func `a mailbox round-trips through its text form`() throws {
        let text = "\"Doe, John\" <john@example.com>"
        let mailbox = try RFC_5322.Mailbox(text)
        #expect(mailbox.description == text)
    }

    @Test
    func `text without an at sign is rejected`() {
        #expect(throws: RFC_5322.Mailbox.Error.missingAtSign) {
            _ = try RFC_5322.Mailbox("userexample.com")
        }
    }

    @Test
    func `consecutive dots in the local part are rejected`() {
        #expect(throws: RFC_5322.Mailbox.Error.self) {
            _ = try RFC_5322.Mailbox("user..name@example.com")
        }
    }

    @Test
    func `a leading dot in the local part is rejected`() {
        #expect(throws: RFC_5322.Mailbox.Error.self) {
            _ = try RFC_5322.Mailbox(".user@example.com")
        }
    }

    @Test
    func `a trailing dot in the local part is rejected`() {
        #expect(throws: RFC_5322.Mailbox.Error.self) {
            _ = try RFC_5322.Mailbox("user.@example.com")
        }
    }

    @Test
    func `a local part longer than 64 octets is rejected`() {
        let localPart = String(repeating: "a", count: 65)
        #expect(throws: RFC_5322.Mailbox.Error.localPart(.tooLong(65))) {
            _ = try RFC_5322.Mailbox("\(localPart)@example.com")
        }
    }
}

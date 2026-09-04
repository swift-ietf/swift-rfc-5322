import Foundation
import RFC_5322
import RFC_5322_Foundation_Integration
import Testing

@Suite
struct `RFC_5322+Codable Tests` {

    @Test
    func `a date time codes as its text form`() async throws {
        let dateTime = try RFC_5322.DateTime("Mon, 1 Jan 2024 09:30:00 +0100")

        let encoded = try JSONEncoder().encode(dateTime)

        #expect(String(decoding: encoded, as: UTF8.self) == "\"\(dateTime.description)\"")
        #expect(try JSONDecoder().decode(RFC_5322.DateTime.self, from: encoded) == dateTime)
    }

    @Test
    func `a header codes as its text form`() async throws {
        let header = try RFC_5322.Header("Subject: Hello")

        let encoded = try JSONEncoder().encode(header)

        #expect(String(decoding: encoded, as: UTF8.self) == #""Subject: Hello""#)
        #expect(try JSONDecoder().decode(RFC_5322.Header.self, from: encoded) == header)
    }

    @Test
    func `a header name codes as its text form`() async throws {
        let name = try RFC_5322.Header.Name("Content-Type")

        let encoded = try JSONEncoder().encode(name)

        #expect(String(decoding: encoded, as: UTF8.self) == #""Content-Type""#)
        #expect(try JSONDecoder().decode(RFC_5322.Header.Name.self, from: encoded) == name)
    }

    @Test
    func `a header value codes as its text form`() async throws {
        let value = try RFC_5322.Header.Value("text/plain; charset=utf-8")

        let encoded = try JSONEncoder().encode(value)

        #expect(String(decoding: encoded, as: UTF8.self) == #""text\/plain; charset=utf-8""#)
        #expect(try JSONDecoder().decode(RFC_5322.Header.Value.self, from: encoded) == value)
    }

    @Test
    func `a message identifier codes as its angle bracketed text form`() async throws {
        let identifier = try RFC_5322.Message.ID("<abc123@example.com>")

        let encoded = try JSONEncoder().encode(identifier)

        #expect(String(decoding: encoded, as: UTF8.self) == #""<abc123@example.com>""#)
        #expect(try JSONDecoder().decode(RFC_5322.Message.ID.self, from: encoded) == identifier)
    }

    @Test
    func `a mailbox codes as its text form`() async throws {
        let mailbox = try RFC_5322.Mailbox("Alice <alice@example.com>")

        let encoded = try JSONEncoder().encode(mailbox)

        #expect(String(decoding: encoded, as: UTF8.self) == #""Alice <alice@example.com>""#)
        #expect(try JSONDecoder().decode(RFC_5322.Mailbox.self, from: encoded) == mailbox)
    }

    @Test
    func `a mailbox without a display name codes as the bare address`() async throws {
        let mailbox = try RFC_5322.Mailbox("alice@example.com")

        let encoded = try JSONEncoder().encode(mailbox)

        #expect(String(decoding: encoded, as: UTF8.self) == #""alice@example.com""#)
        #expect(try JSONDecoder().decode(RFC_5322.Mailbox.self, from: encoded) == mailbox)
    }
}

import RFC_5322
import Testing

@Suite
struct `RFC_5322.Header Tests` {

    @Test
    func `a header pairs a standard name with a value`() throws {
        let header = try RFC_5322.Header(name: .subject, value: .init("text/plain"))
        #expect(header.name == .subject)
        #expect(header.value == "text/plain")
    }

    @Test
    func `a header pairs a custom name with a value`() throws {
        let header = try RFC_5322.Header(
            name: .init("X-Custom-Header"),
            value: .init("custom value")
        )
        #expect(header.name.rawValue == "X-Custom-Header")
        #expect(header.value == "custom value")
    }

    @Test
    func `a header reads from its field form`() throws {
        let header = try RFC_5322.Header("Subject: Hello")
        #expect(header.name == .subject)
        #expect(header.value == "Hello")
    }

    @Test
    func `header names compare case-insensitively`() throws {
        let lower = try RFC_5322.Header.Name("content-type")
        let mixed = try RFC_5322.Header.Name("Content-Type")
        let upper = try RFC_5322.Header.Name("CONTENT-TYPE")
        #expect(lower == mixed)
        #expect(mixed == upper)
    }

    @Test
    func `header names keep the spelling they were given`() throws {
        let name = try RFC_5322.Header.Name("X-Custom-Header")
        #expect(name.rawValue == "X-Custom-Header")
        #expect(name.description == "X-Custom-Header")
    }

    @Test
    func `the standard header names spell their RFC 5322 field names`() {
        #expect(RFC_5322.Header.Name.from.rawValue == "From")
        #expect(RFC_5322.Header.Name.to.rawValue == "To")
        #expect(RFC_5322.Header.Name.cc.rawValue == "Cc")
        #expect(RFC_5322.Header.Name.bcc.rawValue == "Bcc")
        #expect(RFC_5322.Header.Name.replyTo.rawValue == "Reply-To")
        #expect(RFC_5322.Header.Name.sender.rawValue == "Sender")
        #expect(RFC_5322.Header.Name.subject.rawValue == "Subject")
        #expect(RFC_5322.Header.Name.date.rawValue == "Date")
        #expect(RFC_5322.Header.Name.messageId.rawValue == "Message-ID")
        #expect(RFC_5322.Header.Name.inReplyTo.rawValue == "In-Reply-To")
        #expect(RFC_5322.Header.Name.references.rawValue == "References")
    }

    @Test
    func `the extension header names spell their field names`() {
        #expect(RFC_5322.Header.Name.xMailer.rawValue == "X-Mailer")
        #expect(RFC_5322.Header.Name.xPriority.rawValue == "X-Priority")
        #expect(RFC_5322.Header.Name.listUnsubscribe.rawValue == "List-Unsubscribe")
    }

    @Test
    func `a header renders as name, colon, space, value`() throws {
        let header = try RFC_5322.Header(name: .init("X-Test"), value: .init("test value"))
        #expect(header.description == "X-Test: test value")
    }

    @Test
    func `a header value keeps its semicolons`() throws {
        let header = try RFC_5322.Header(name: .subject, value: .init("RE: Meeting; Notes"))
        #expect(header.description == "Subject: RE: Meeting; Notes")
    }

    @Test
    func `a header value takes an integer literal`() {
        let header = RFC_5322.Header(name: .xPriority, value: 1)
        #expect(header.value == "1")
    }

    @Test
    func `a header list looks up a value by name`() throws {
        let headers: [RFC_5322.Header] = try [.subject: .init("text/plain")]
        #expect(headers[.subject] == "text/plain")
        #expect(headers[.from] == nil)
    }

    @Test
    func `a header list sets a value by name`() {
        var headers = [RFC_5322.Header]()
        headers[.subject] = "text/html"
        #expect(headers.count == 1)
        #expect(headers[0].name == .subject)
        #expect(headers[0].value == "text/html")
    }

    @Test
    func `setting a value replaces every header of that name`() throws {
        var headers: [RFC_5322.Header] = try [
            .received: .init("server1"),
            .received: .init("server2"),
        ]
        headers[.received] = "server3"
        #expect(headers.count == 1)
        #expect(headers[0].value == "server3")
    }

    @Test
    func `setting nil removes the header`() throws {
        var headers: [RFC_5322.Header] = try [.subject: .init("text/plain")]
        headers[.subject] = nil
        #expect(headers.isEmpty)
    }

    @Test
    func `a header list collects every header of a name`() throws {
        let headers: [RFC_5322.Header] = try [
            .received: .init("server1"),
            .received: .init("server2"),
            .subject: .init("text/plain"),
        ]
        let received = headers.all(.received)
        #expect(received.count == 2)
        #expect(received[0].value == "server1")
        #expect(received[1].value == "server2")
        #expect(headers.all(.from).isEmpty)
    }

    @Test
    func `a header list collects every value of a name`() throws {
        let headers: [RFC_5322.Header] = try [
            .received: .init("server1"),
            .received: .init("server2"),
        ]
        let values = headers.values(for: .received)
        #expect(values.count == 2)
        #expect(values[0] == "server1")
        #expect(values[1] == "server2")
    }

    @Test
    func `a header list builds from a dictionary literal`() throws {
        let headers: [RFC_5322.Header] = try [
            .from: .init("sender@example.com"),
            .to: .init("recipient@example.com"),
            .subject: .init("Test"),
        ]
        #expect(headers.count == 3)
        #expect(headers[.from] == "sender@example.com")
        #expect(headers[.to] == "recipient@example.com")
        #expect(headers[.subject] == "Test")
    }

    @Test
    func `headers with the same name and value are equal`() throws {
        let first = try RFC_5322.Header(name: .subject, value: .init("text/plain"))
        let second = try RFC_5322.Header(name: .subject, value: .init("text/plain"))
        #expect(first == second)
    }

    @Test
    func `headers with different values are not equal`() throws {
        let plain = try RFC_5322.Header(name: .subject, value: .init("text/plain"))
        let html = try RFC_5322.Header(name: .subject, value: .init("text/html"))
        #expect(plain != html)
    }

    @Test
    func `headers whose names differ only by case share a name`() throws {
        let first = try RFC_5322.Header(name: .init("X-Test"), value: .init("value"))
        let second = try RFC_5322.Header(name: .init("x-test"), value: .init("value"))
        #expect(first.name == second.name)
    }
}

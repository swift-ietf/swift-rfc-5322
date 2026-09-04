import Testing

@testable import RFC_5322

extension PerformanceTests {
    @Suite
    struct `RFC_5322.Mailbox` {

        @Test(.timed(iterations: 1000, warmup: 100, threshold: .microseconds(230)))
        func `parse simple email address`() throws {
            _ = try RFC_5322.Mailbox("user@example.com")
        }

        @Test(.timed(iterations: 1000, warmup: 100, threshold: .microseconds(250)))
        func `parse email with display name`() throws {
            _ = try RFC_5322.Mailbox("John Doe <john@example.com>")
        }

        @Test(.timed(iterations: 1000, warmup: 100, threshold: .microseconds(250)))
        func `parse email with quoted display name`() throws {
            _ = try RFC_5322.Mailbox("\"Doe, John\" <john@example.com>")
        }

        @Test(.timed(iterations: 1000, warmup: 100, threshold: .microseconds(230)))
        func `parse email with atext special characters`() throws {
            _ = try RFC_5322.Mailbox("user!tag+value@example.com")
        }

        @Test(.timed(iterations: 1000, warmup: 100, threshold: .microseconds(150)))
        func `create from components without display name`() throws {
            _ = try RFC_5322.Mailbox(
                displayName: nil,
                localPart: .init("user"),
                domain: .init("example.com")
            )
        }

        @Test(.timed(iterations: 1000, warmup: 100, threshold: .microseconds(150)))
        func `create from components with display name`() throws {
            _ = try RFC_5322.Mailbox(
                displayName: "John Doe",
                localPart: .init("john"),
                domain: .init("example.com")
            )
        }

        @Test(.timed(iterations: 1000, warmup: 100, threshold: .microseconds(230)))
        func `format to string without display name`() throws {
            let email = try RFC_5322.Mailbox("user@example.com")
            _ = String(email)
        }

        @Test(.timed(iterations: 1000, warmup: 100, threshold: .microseconds(150)))
        func `format to string with display name`() throws {
            let email = try RFC_5322.Mailbox(
                displayName: "John Doe",
                localPart: .init("john"),
                domain: .init("example.com")
            )
            _ = String(email)
        }

        @Test(.timed(iterations: 1000, warmup: 100, threshold: .microseconds(150)))
        func `format to string with quoting needed`() throws {
            let email = try RFC_5322.Mailbox(
                displayName: "Doe, John",
                localPart: .init("john"),
                domain: .init("example.com")
            )
            _ = String(email)
        }

        @Test(.timed(iterations: 1000, warmup: 100, threshold: .microseconds(240)))
        func `convert to bytes without display name`() throws {
            let email = try RFC_5322.Mailbox("user@example.com")
            _ = [UInt8](email)
        }

        @Test(.timed(iterations: 1000, warmup: 100, threshold: .microseconds(150)))
        func `convert to bytes with display name`() throws {
            let email = try RFC_5322.Mailbox(
                displayName: "John Doe",
                localPart: .init("john"),
                domain: .init("example.com")
            )
            _ = [UInt8](email)
        }
    }
}

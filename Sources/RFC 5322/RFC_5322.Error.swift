extension RFC_5322 {

    public enum Error: Swift.Error, Sendable, Equatable {

        case dateTime(Date.Error)

        case mailbox(Mailbox.Error)

        case invalidFormat(String)

        case invalidFieldName(String, reason: String)
    }
}

extension RFC_5322.Date.Error {

    public var unified: RFC_5322.Error {
        .dateTime(self)
    }
}

extension RFC_5322.Mailbox.Error {

    public var unified: RFC_5322.Error {
        .mailbox(self)
    }
}

extension RFC_5322.Error: CustomStringConvertible {
    public var description: String {
        switch self {
        case .dateTime(let error):
            return "DateTime error: \(error)"

        case .mailbox(let error):
            return "Email address error: \(error)"

        case .invalidFormat(let message):
            return "Invalid format: \(message)"

        case .invalidFieldName(let name, let reason):
            return "Invalid field name '\(name)': \(reason)"
        }
    }
}

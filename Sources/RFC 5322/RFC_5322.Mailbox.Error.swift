extension RFC_5322.Mailbox {

    public enum Error: Swift.Error, Sendable, Equatable {

        case missingAtSign

        case localPart(RFC_5322.Mailbox.LocalPart.Error)

        case domain(RFC_1123.Domain.Error)

        case invalidDisplayName(String, reason: String)
    }
}

extension IETF.RFC.`5322`.Mailbox {

    public enum Error: Swift::Error, Sendable, Equatable {

        case missingAtSign

        case localPart(IETF.RFC.`5322`.Mailbox.LocalPart.Error)

        case domain(IETF.RFC.`1123`.Domain.Error)

        case invalidDisplayName(String, reason: String)
    }
}

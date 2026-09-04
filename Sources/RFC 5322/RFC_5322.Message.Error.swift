extension RFC_5322.Message {

    public enum Error: Swift.Error, Sendable, Equatable {

        case invalidSubject(String, reason: String)
        case invalidMimeVersion(String, reason: String)

        case missingRequiredHeader(String)
        case invalidHeaderFormat(String)
        case headerFoldingError(String)

        case invalidMessageStructure(String)
        case missingHeaderBodySeparator

        case invalidMimeStructure(String)
        case unsupportedEncoding(String)

        case mailbox(RFC_5322.Mailbox.Error)
        case dateTime(RFC_5322.DateTime.Error)
        case header(RFC_5322.Header.Error)

        case parsingFailed(String)
    }
}

extension RFC_5322.Header {

    public enum Error: Swift.Error, Sendable, Equatable {

        case invalidFormat(String, reason: String)

        case invalidName(RFC_5322.Header.Name.Error)

        case invalidValue(RFC_5322.Header.Value.Error)
    }
}

extension IETF.RFC.`5322`.Header {

    public enum Error: Swift::Error, Sendable, Equatable {

        case invalidFormat(String, reason: String)

        case invalidName(IETF.RFC.`5322`.Header.Name.Error)

        case invalidValue(IETF.RFC.`5322`.Header.Value.Error)
    }
}

extension RFC_5322.Message {

    public enum Error: Swift.Error, Sendable, Equatable {

        case invalidSubject(String, reason: String)
        case invalidMimeVersion(String, reason: String)
    }
}

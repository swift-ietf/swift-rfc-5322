public import ASCII

extension RFC_5322.Header.Value {

    public enum Error: Swift.Error, Sendable, Equatable {

        case invalidFolding(String, code: ASCII.Code, reason: String)

        case invalidCharacter(String, code: ASCII.Code, reason: String)

        case nonASCII(String)
    }
}

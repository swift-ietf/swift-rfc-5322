public import ASCII_Serializer

extension RFC_5322.Header.Name {

    public enum Error: Swift.Error, Sendable, Equatable {

        case empty

        case invalidCharacter(String, code: ASCII.Code, reason: String)

        case nonASCII(String)
    }
}

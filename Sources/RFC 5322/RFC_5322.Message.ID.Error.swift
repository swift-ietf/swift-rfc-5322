public import ASCII

extension RFC_5322.Message.ID {

    public enum Error: Swift.Error, Sendable, Equatable {

        case missingAtSign(String)

        case invalidCharacter(String, code: ASCII.Code, reason: String)

        case nonASCII(String)
    }
}

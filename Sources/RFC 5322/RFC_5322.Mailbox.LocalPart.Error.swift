extension RFC_5322.Mailbox.LocalPart {

    public enum Error: Swift.Error, Sendable, Equatable {
        case nonASCIICharacters
        case tooLong(_ length: Int)
        case invalidQuotedString
        case invalidDotAtom
        case consecutiveDots
        case leadingOrTrailingDot
    }
}

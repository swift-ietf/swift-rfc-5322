public import ASCII_Serializer
import INCITS_4_1986

extension RFC_5322.EmailAddress {
    package enum Limits {}

    nonisolated(unsafe) package static let addressRegex = /(?:((?:\".*?\"|[^<]+)\s+))?<(.*?)@(.*?)>/

    nonisolated(unsafe) package static let dotAtomRegex =
        /[a-zA-Z0-9!#$%&'\*\+\-\/=\?\^_`\{\|}~]+(?:\.[a-zA-Z0-9!#$%&'\*\+\-\/=\?\^_`\{\|}~]+)*/

    nonisolated(unsafe) package static let quotedRegex = /(?:[^"\\\r\n]|\\["\\])+/
}

extension RFC_5322.EmailAddress.Limits {
    static let maxLength = 64
}

extension RFC_5322 {

    public static let atextSymbols: Set<ASCII.Code> = [
        ASCII.Code.exclamationPoint,
        ASCII.Code.numberSign,
        ASCII.Code.dollarSign,
        ASCII.Code.percentSign,
        ASCII.Code.ampersand,
        ASCII.Code.apostrophe,
        ASCII.Code.asterisk,
        ASCII.Code.plusSign,
        ASCII.Code.hyphen,
        ASCII.Code.solidus,
        ASCII.Code.equalsSign,
        ASCII.Code.questionMark,
        ASCII.Code.circumflexAccent,
        ASCII.Code.underline,
        ASCII.Code.leftSingleQuotationMark,
        ASCII.Code.leftBrace,
        ASCII.Code.verticalLine,
        ASCII.Code.rightBrace,
        ASCII.Code.tilde,
    ]

    @inlinable
    public static func isAtext(_ code: ASCII.Code) -> Bool {
        code.isLetter || code.isDigit || atextSymbols.contains(code)
    }
}

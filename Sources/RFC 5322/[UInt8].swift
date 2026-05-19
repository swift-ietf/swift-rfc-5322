//
//  [Byte].swift
//  swift-rfc-5322
//
//  Type conversions for RFC 5322 Message
//

import ASCII_Serializer_Primitives
import INCITS_4_1986
import RFC_1123
import Time_Primitives
import Standard_Library_Extensions

// MARK: - Constants

extension Array where Element == Byte {
    package static let fromPrefix: [Byte] = .init("From: ".utf8)
    package static let toPrefix: [Byte] = .init("To: ".utf8)
    package static let ccPrefix: [Byte] = .init("Cc: ".utf8)
    package static let subjectPrefix: [Byte] = .init("Subject: ".utf8)
    package static let datePrefix: [Byte] = .init("Date: ".utf8)
    package static let messageIdPrefix: [Byte] = .init("Message-ID: ".utf8)
    package static let replyToPrefix: [Byte] = .init("Reply-To: ".utf8)
    package static let mimeVersionPrefix: [Byte] = .init("MIME-Version: ".utf8)
    /// CRLF line ending (0x0D 0x0A) as Byte sequence.
    package static let crlf: [Byte] = [ASCII.Code.cr.byte, ASCII.Code.lf.byte]
}

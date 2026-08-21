import ASCII_Serializer_Primitives
import INCITS_4_1986
import RFC_1123
import Standard_Library_Extensions
import Time_Primitives

extension Array where Element == Byte {
    package static let fromPrefix: [Byte] = .init("From: ".utf8)
    package static let toPrefix: [Byte] = .init("To: ".utf8)
    package static let ccPrefix: [Byte] = .init("Cc: ".utf8)
    package static let subjectPrefix: [Byte] = .init("Subject: ".utf8)
    package static let datePrefix: [Byte] = .init("Date: ".utf8)
    package static let messageIdPrefix: [Byte] = .init("Message-ID: ".utf8)
    package static let replyToPrefix: [Byte] = .init("Reply-To: ".utf8)
    package static let mimeVersionPrefix: [Byte] = .init("MIME-Version: ".utf8)

    package static let crlf: [Byte] = .init("\r\n".utf8)
}

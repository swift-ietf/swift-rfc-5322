public import Byte
import INCITS_4_1986
import RFC_1123
import Standard_Library_Extensions
import Time

extension Array where Element == Byte {
    package static let fromPrefix: [Byte] = "From: ".utf8.map(Byte.init(bitPattern:))
    package static let toPrefix: [Byte] = "To: ".utf8.map(Byte.init(bitPattern:))
    package static let ccPrefix: [Byte] = "Cc: ".utf8.map(Byte.init(bitPattern:))
    package static let subjectPrefix: [Byte] = "Subject: ".utf8.map(Byte.init(bitPattern:))
    package static let datePrefix: [Byte] = "Date: ".utf8.map(Byte.init(bitPattern:))
    package static let messageIdPrefix: [Byte] = "Message-ID: ".utf8.map(Byte.init(bitPattern:))
    package static let replyToPrefix: [Byte] = "Reply-To: ".utf8.map(Byte.init(bitPattern:))
    package static let mimeVersionPrefix: [Byte] = "MIME-Version: ".utf8.map(Byte.init(bitPattern:))

    package static let crlf: [Byte] = "\r\n".utf8.map(Byte.init(bitPattern:))
}

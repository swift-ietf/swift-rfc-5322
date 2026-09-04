public import ASCII
public import Byte
import Byte_Standard_Library_Integration
import INCITS_4_1986
import RFC_1123
import Standard_Library_Extensions

extension RFC_5322 {

    public struct Message: Hashable, Sendable {

        public let from: Mailbox

        public let to: [Mailbox]

        public let cc: [Mailbox]?

        public let bcc: [Mailbox]?

        public let replyTo: Mailbox?

        public let subject: String

        public let date: RFC_5322.DateTime

        public let messageId: Message.ID

        public let body: [Byte]

        public let additionalHeaders: [Header]

        public let mimeVersion: String

        public init(
            from: Mailbox,
            to: [Mailbox],
            cc: [Mailbox]? = nil,
            bcc: [Mailbox]? = nil,
            replyTo: Mailbox? = nil,
            date: RFC_5322.DateTime,
            subject: String,
            messageId: Message.ID,
            body: [Byte],
            additionalHeaders: [Header] = [],
            mimeVersion: String = "1.0"
        ) throws(Error) {
            if let reason = subject.rfc5322FieldBodyInjectionReason {
                throw Error.invalidSubject(subject, reason: reason)
            }
            if let reason = mimeVersion.rfc5322FieldBodyInjectionReason {
                throw Error.invalidMimeVersion(mimeVersion, reason: reason)
            }
            self.from = from
            self.to = to
            self.cc = cc
            self.bcc = bcc
            self.replyTo = replyTo
            self.date = date
            self.subject = subject
            self.messageId = messageId
            self.body = body
            self.additionalHeaders = additionalHeaders
            self.mimeVersion = mimeVersion
        }
    }
}

extension RFC_5322.Message {

    public static func serialize<Buffer: RangeReplaceableCollection>(
        _ value: Self,
        into buffer: inout Buffer
    ) where Buffer.Element == ASCII.Code {

        buffer.reserveCapacity(500 + value.body.count)

        buffer.append(contentsOf: [Byte].fromPrefix.map { ASCII.Code(unchecked: $0) })
        RFC_5322.Mailbox.serialize(value.from, into: &buffer)
        buffer.append(contentsOf: [Byte].crlf.map { ASCII.Code(unchecked: $0) })

        buffer.append(contentsOf: [Byte].toPrefix.map { ASCII.Code(unchecked: $0) })
        var first = true
        for address in value.to {
            if !first {
                buffer.append(ASCII.Code.comma)
                buffer.append(ASCII.Code.space)
            }
            first = false
            RFC_5322.Mailbox.serialize(address, into: &buffer)
        }
        buffer.append(contentsOf: [Byte].crlf.map { ASCII.Code(unchecked: $0) })

        if let cc = value.cc, !cc.isEmpty {
            buffer.append(contentsOf: [Byte].ccPrefix.map { ASCII.Code(unchecked: $0) })
            first = true
            for address in cc {
                if !first {
                    buffer.append(ASCII.Code.comma)
                    buffer.append(ASCII.Code.space)
                }
                first = false
                RFC_5322.Mailbox.serialize(address, into: &buffer)
            }
            buffer.append(contentsOf: [Byte].crlf.map { ASCII.Code(unchecked: $0) })
        }

        buffer.append(contentsOf: [Byte].subjectPrefix.map { ASCII.Code(unchecked: $0) })
        buffer.append(contentsOf: value.subject.utf8.map { ASCII.Code($0) })
        buffer.append(contentsOf: [Byte].crlf.map { ASCII.Code(unchecked: $0) })

        buffer.append(contentsOf: [Byte].datePrefix.map { ASCII.Code(unchecked: $0) })
        RFC_5322.DateTime.serialize(value.date, into: &buffer)
        buffer.append(contentsOf: [Byte].crlf.map { ASCII.Code(unchecked: $0) })

        buffer.append(contentsOf: [Byte].messageIdPrefix.map { ASCII.Code(unchecked: $0) })
        RFC_5322.Message.ID.serialize(value.messageId, into: &buffer)
        buffer.append(contentsOf: [Byte].crlf.map { ASCII.Code(unchecked: $0) })

        if let replyTo = value.replyTo {
            buffer.append(contentsOf: [Byte].replyToPrefix.map { ASCII.Code(unchecked: $0) })
            RFC_5322.Mailbox.serialize(replyTo, into: &buffer)
            buffer.append(contentsOf: [Byte].crlf.map { ASCII.Code(unchecked: $0) })
        }

        buffer.append(contentsOf: [Byte].mimeVersionPrefix.map { ASCII.Code(unchecked: $0) })
        buffer.append(contentsOf: value.mimeVersion.utf8.map { ASCII.Code($0) })
        buffer.append(contentsOf: [Byte].crlf.map { ASCII.Code(unchecked: $0) })

        for header in value.additionalHeaders {
            RFC_5322.Header.serialize(header, into: &buffer)
            buffer.append(contentsOf: [Byte].crlf.map { ASCII.Code(unchecked: $0) })
        }

        buffer.append(contentsOf: [Byte].crlf.map { ASCII.Code(unchecked: $0) })

        buffer.append(contentsOf: value.body.map { ASCII.Code(unchecked: $0) })
    }

    public static func serialize<Buffer: RangeReplaceableCollection>(
        _ value: Self,
        into buffer: inout Buffer
    ) where Buffer.Element == Byte {
        serializeBytes(value, into: &buffer)
    }

    private static func serializeBytes<Buffer: RangeReplaceableCollection>(
        _ message: RFC_5322.Message,
        into buffer: inout Buffer
    ) where Buffer.Element == Byte {

        buffer.reserveCapacity(500 + message.body.count)

        buffer.append(contentsOf: [Byte].fromPrefix)
        RFC_5322.Mailbox.serialize(message.from, into: &buffer)
        buffer.append(contentsOf: [Byte].crlf)

        buffer.append(contentsOf: [Byte].toPrefix)
        var first = true
        for address in message.to {
            if !first {
                buffer.append(ASCII.Code.comma.byte)
                buffer.append(ASCII.Code.space.byte)
            }
            first = false
            RFC_5322.Mailbox.serialize(address, into: &buffer)
        }
        buffer.append(contentsOf: [Byte].crlf)

        if let cc = message.cc, !cc.isEmpty {
            buffer.append(contentsOf: [Byte].ccPrefix)
            first = true
            for address in cc {
                if !first {
                    buffer.append(ASCII.Code.comma.byte)
                    buffer.append(ASCII.Code.space.byte)
                }
                first = false
                RFC_5322.Mailbox.serialize(address, into: &buffer)
            }
            buffer.append(contentsOf: [Byte].crlf)
        }

        buffer.append(contentsOf: [Byte].subjectPrefix)
        buffer.append(contentsOf: message.subject.utf8.lazy.map(Byte.init(bitPattern:)))
        buffer.append(contentsOf: [Byte].crlf)

        buffer.append(contentsOf: [Byte].datePrefix)
        RFC_5322.DateTime.serialize(message.date, into: &buffer)
        buffer.append(contentsOf: [Byte].crlf)

        buffer.append(contentsOf: [Byte].messageIdPrefix)
        RFC_5322.Message.ID.serialize(message.messageId, into: &buffer)
        buffer.append(contentsOf: [Byte].crlf)

        if let replyTo = message.replyTo {
            buffer.append(contentsOf: [Byte].replyToPrefix)
            RFC_5322.Mailbox.serialize(replyTo, into: &buffer)
            buffer.append(contentsOf: [Byte].crlf)
        }

        buffer.append(contentsOf: [Byte].mimeVersionPrefix)
        buffer.append(contentsOf: message.mimeVersion.utf8.lazy.map(Byte.init(bitPattern:)))
        buffer.append(contentsOf: [Byte].crlf)

        for header in message.additionalHeaders {
            RFC_5322.Header.serialize(header, into: &buffer)
            buffer.append(contentsOf: [Byte].crlf)
        }

        buffer.append(contentsOf: [Byte].crlf)

        buffer.append(contentsOf: message.body)
    }
}

extension RFC_5322.Message: CustomStringConvertible {

    public var description: String {
        var bytes: [Byte] = []
        Self.serialize(self, into: &bytes)
        return String(decoding: bytes, as: UTF8.self)
    }
}

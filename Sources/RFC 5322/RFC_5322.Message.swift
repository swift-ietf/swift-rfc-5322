public import Byte

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

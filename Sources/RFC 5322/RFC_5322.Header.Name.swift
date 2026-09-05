public import ASCII
public import Byte
import Byte_Standard_Library_Integration
import INCITS_4_1986

extension RFC_5322.Header {

    public struct Name: Sendable {

        public let rawValue: String

        public init(
            __unchecked: (),
            rawValue: String
        ) {

            self.rawValue = rawValue
        }
    }
}

extension RFC_5322.Header.Name: Hashable {

    public func hash(into hasher: inout Hasher) {
        hasher.combine(rawValue.lowercased())
    }

    public static func == (lhs: RFC_5322.Header.Name, rhs: RFC_5322.Header.Name) -> Bool {
        lhs.rawValue.lowercased() == rhs.rawValue.lowercased()
    }

    public static func == (lhs: RFC_5322.Header.Name, rhs: Self.RawValue) -> Bool {
        lhs.rawValue.lowercased() == rhs.lowercased()
    }
}

extension RFC_5322.Header.Name: Swift.RawRepresentable {

    public init?(rawValue: String) {
        do throws(Error) {
            try self.init(rawValue)
        } catch {
            return nil
        }
    }
}

extension RFC_5322.Header.Name: CustomStringConvertible {

    public var description: String {
        rawValue
    }
}

extension RFC_5322.Header.Name {

    public init(_ string: some StringProtocol) throws(Error) {
        try self.init(ascii: string.utf8.map(Byte.init(bitPattern:)))
    }

    public init<Bytes: Swift.Collection>(ascii bytes: Bytes) throws(Error)
    where Bytes.Element == Byte {

        guard !bytes.isEmpty else {
            throw Error.empty
        }

        let codes: [ASCII.Code]
        do throws(ASCII.Code.Error) {
            var built: [ASCII.Code] = []
            built.reserveCapacity(bytes.count)
            for byte in bytes {
                built.append(try ASCII.Code(byte))
            }
            codes = built
        } catch {
            throw Error.nonASCII(String(decoding: bytes, as: UTF8.self))
        }

        for code in codes {

            guard code.isVisible && code != ASCII.Code.colon else {
                let string = String(decoding: bytes, as: UTF8.self)
                let reason =
                    code == ASCII.Code.colon
                    ? "Field name cannot contain colon"
                    : "Must be printable ASCII except colon"
                throw Error.invalidCharacter(string, code: code, reason: reason)
            }
        }

        self.init(__unchecked: (), rawValue: String(decoding: bytes, as: UTF8.self))
    }
}

extension RFC_5322.Header.Name {

    public static let from: Self = .init(__unchecked: (), rawValue: "From")

    public static let to: Self = .init(__unchecked: (), rawValue: "To")

    public static let cc: Self = .init(__unchecked: (), rawValue: "Cc")

    public static let bcc: Self = .init(__unchecked: (), rawValue: "Bcc")

    public static let subject: Self = .init(__unchecked: (), rawValue: "Subject")

    public static let date: Self = .init(__unchecked: (), rawValue: "Date")

    public static let messageId: Self = .init(__unchecked: (), rawValue: "Message-ID")

    public static let replyTo: Self = .init(__unchecked: (), rawValue: "Reply-To")

    public static let sender: Self = .init(__unchecked: (), rawValue: "Sender")

    public static let inReplyTo: Self = .init(__unchecked: (), rawValue: "In-Reply-To")

    public static let references: Self = .init(__unchecked: (), rawValue: "References")

    public static let resentFrom: Self = .init(__unchecked: (), rawValue: "Resent-From")

    public static let resentTo: Self = .init(__unchecked: (), rawValue: "Resent-To")

    public static let resentDate: Self = .init(__unchecked: (), rawValue: "Resent-Date")

    public static let resentMessageId: Self = .init(__unchecked: (), rawValue: "Resent-Message-ID")

    public static let returnPath: Self = .init(__unchecked: (), rawValue: "Return-Path")

    public static let received: Self = .init(__unchecked: (), rawValue: "Received")
}

extension RFC_5322.Header.Name {

    public static let xMailer: Self = .init(__unchecked: (), rawValue: "X-Mailer")

    public static let xPriority: Self = .init(__unchecked: (), rawValue: "X-Priority")

    public static let listUnsubscribe: Self = .init(__unchecked: (), rawValue: "List-Unsubscribe")

    public static let listId: Self = .init(__unchecked: (), rawValue: "List-ID")

    public static let precedence: Self = .init(__unchecked: (), rawValue: "Precedence")

    public static let autoSubmitted: Self = .init(__unchecked: (), rawValue: "Auto-Submitted")
}

extension RFC_5322.Header.Name {

    public static let xAppleBaseUrl: Self = .init(__unchecked: (), rawValue: "X-Apple-Base-Url")

    public static let xUniversallyUniqueIdentifier: Self = .init(
        __unchecked: (),
        rawValue: "X-Universally-Unique-Identifier"
    )

    public static let xAppleMailRemoteAttachments: Self = .init(
        __unchecked: (),
        rawValue: "X-Apple-Mail-Remote-Attachments"
    )

    public static let xAppleWindowsFriendly: Self = .init(
        __unchecked: (),
        rawValue: "X-Apple-Windows-Friendly"
    )

    public static let xAppleMailSignature: Self = .init(
        __unchecked: (),
        rawValue: "X-Apple-Mail-Signature"
    )

    public static let xUniformTypeIdentifier: Self = .init(
        __unchecked: (),
        rawValue: "X-Uniform-Type-Identifier"
    )
}

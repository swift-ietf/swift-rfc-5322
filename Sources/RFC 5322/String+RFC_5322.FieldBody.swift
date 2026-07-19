//
//  String+RFC_5322.FieldBody.swift
//  swift-rfc-5322
//
//  Shared CRLF/non-ASCII rejection for the ergonomic String-typed fields
//  (Message.subject, Message.mimeVersion, EmailAddress.displayName) that
//  reach the wire via direct byte-for-byte concatenation in `serialize`
//  rather than through a dedicated ASCII.Parseable sub-parser.
//

extension String {
    /// Returns a diagnostic reason if `self` is unsafe to concatenate
    /// verbatim into a single RFC 5322 (§2.2) header field body, or `nil` if
    /// `self` is safe.
    ///
    /// A bare CR, a bare LF, or a non-ASCII byte accepted here would let a
    /// caller inject a new header line (CRLF header injection) or corrupt
    /// the rendered `.eml` once concatenated by `RFC_5322.Message.serialize`
    /// / `RFC_5322.EmailAddress.serialize`. These fields are constructed
    /// from Swift string literals/variables — not parsed from wire bytes —
    /// so RFC 5322 folding semantics (CRLF immediately followed by WSP)
    /// do not apply here; rejecting outright keeps the guard simple enough
    /// to audit for an injection-class hazard.
    var rfc5322FieldBodyInjectionReason: String? {
        for scalar in unicodeScalars {
            if scalar == "\r" || scalar == "\n" {
                return "must not contain a bare CR or LF (RFC 5322 header-injection guard)"
            }
            if !scalar.isASCII {
                return "must be 7-bit ASCII (RFC 5322 header-injection guard)"
            }
        }
        return nil
    }
}

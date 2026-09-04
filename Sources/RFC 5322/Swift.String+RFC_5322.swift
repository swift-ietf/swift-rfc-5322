extension String {

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

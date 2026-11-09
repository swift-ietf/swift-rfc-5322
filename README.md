# swift-rfc-5322

Use this package when you need to read or write the parts of an email message as RFC 5322 defines them: mailboxes, header fields, the Date field, Message-IDs, or a whole message ready to send. Start from `RFC_5322.Message` to build a message, and from `RFC_5322.Mailbox`, `RFC_5322.Header` or `RFC_5322.DateTime` for a single field. For addresses with non-ASCII characters, use swift-rfc-6531. For a subject or display name in non-ASCII text, encode it first with swift-rfc-2047. For a message model that also covers MIME bodies, use swift-email-standard.

## Laws

- A mailbox reads either a bare address or a display name followed by an address in angle brackets. A quoted display name is unquoted on reading, and surrounding whitespace is trimmed.
- A display name, subject or MIME version that contains a CR, an LF or any non-ASCII character is refused, so a value can't inject a header line.
- When written, a display name is quoted if it holds anything other than ASCII letters, digits and whitespace, with quotation marks and backslashes escaped.
- A local part is a dot-atom or a quoted string of at most 64 characters, and it keeps the form it was written in, quotes included.
- Header names keep their spelling but compare case-insensitively.
- Reading a header value unfolds it: each CRLF followed by a space or tab is removed and the space or tab kept. A CR or LF anywhere else is refused, and leading whitespace is dropped.
- Setting a name through the subscript on an array of `RFC_5322.Header` replaces every header of that name. Reading it returns the first one.
- A Message-ID requires an at sign and no spaces. `RFC_5322.Message.ID.init(_:)` accepts it with or without angle brackets, and it is always written with them.
- A message is written as From, To, Cc if any, Subject, Date, Message-ID, Reply-To if set, MIME-Version, then the additional headers in order, each line ending in CRLF, then an empty line and the body. Bcc is never written. Written into an ASCII buffer, a message gives only its header block and the empty line.
- Two date-times are equal, hash alike and order by their instant alone. The timezone offset only changes how the date is written and what `RFC_5322.DateTime.components` returns.
- A date-time is always written with its day name, a two-digit day, seconds and a numeric offset, as in `Fri, 01 Jan 2021 00:00:00 +0000`.
- There are no leap seconds: days are a uniform 86 400 seconds, so a second of `60` is refused with `invalidSecond` rather than read as the next midnight.
- `RFC_5322.DateTime.init(_:)` requires the day name and refuses one that doesn't match the date. `RFC_5322.DateTime.Coder` also accepts a date without a day name or seconds. Either way the offset must be a plus or minus sign followed by four digits.
- With `RFC 5322 Foundation Integration`, every type encodes as its text form and decodes through the same validation.

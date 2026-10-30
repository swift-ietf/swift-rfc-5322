#if Coder
    public import ASCII
    public import Binary
    public import Byte

    extension RFC_5322.Mailbox.LocalPart: ASCII.Parseable {}

    extension RFC_5322.Mailbox.LocalPart: ASCII.Serializable, Binary.Serializable {

        public static func serialize<Buffer: RangeReplaceableCollection>(
            _ value: Self,
            into buffer: inout Buffer
        ) where Buffer.Element == ASCII.Code {
            Scan.append(value.description, into: &buffer)
        }

        public static func serialize<Buffer: RangeReplaceableCollection>(
            _ value: Self,
            into buffer: inout Buffer
        ) where Buffer.Element == Byte {
            Scan.append(value.description, into: &buffer)
        }
    }
#endif

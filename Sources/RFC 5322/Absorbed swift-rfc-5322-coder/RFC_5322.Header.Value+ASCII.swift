#if Coder
    public import ASCII
    public import Binary
    public import Byte

    extension RFC_5322.Header.Value: ASCII.Parseable {}

    extension RFC_5322.Header.Value: ASCII.Serializable, Binary.Serializable {

        public static func serialize<Buffer: RangeReplaceableCollection>(
            _ value: Self,
            into buffer: inout Buffer
        ) where Buffer.Element == ASCII.Code {
            Scan.append(value.rawValue, into: &buffer)
        }

        public static func serialize<Buffer: RangeReplaceableCollection>(
            _ value: Self,
            into buffer: inout Buffer
        ) where Buffer.Element == Byte {
            Scan.append(value.rawValue, into: &buffer)
        }
    }
#endif

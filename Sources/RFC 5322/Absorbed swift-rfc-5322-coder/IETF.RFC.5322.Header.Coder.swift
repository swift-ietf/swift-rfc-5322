#if Coder
    public import Byte
    public import Coder
    public import Cursor
    import Parser
    import Serializer

    extension IETF.RFC.`5322`.Header {
        public struct Coder<Input: Cursor.`Protocol`<Byte, Never>, Buffer: RangeReplaceableCollection<Byte>>: Coding {
            public init() {}
        }

        public static var coder: Coder<ArraySlice<Byte>, [Byte]> { .init() }
    }

    extension IETF.RFC.`5322`.Header.Coder {
        public typealias Output = IETF.RFC.`5322`.Header

        public typealias Failure = IETF.RFC.`5322`.Header.Error

        public borrowing func parse(_ input: inout Input) throws(Failure) -> Output {
            let start = input.checkpoint

            let name: IETF.RFC.`5322`.Header.Name
            do throws(IETF.RFC.`5322`.Header.Name.Error) {
                name = try IETF.RFC.`5322`.Header.Name.Coder<Input, Buffer>().parse(&input)
            } catch {
                input.seek(to: start)
                throw .invalidName(error)
            }

            guard let colon = input.next(), colon.bitPattern == 0x3A else {
                input.seek(to: start)
                throw .invalidFormat(name.rawValue, reason: "Missing colon separator")
            }

            let value: IETF.RFC.`5322`.Header.Value
            do throws(IETF.RFC.`5322`.Header.Value.Error) {
                value = try IETF.RFC.`5322`.Header.Value.Coder<Input, Buffer>().parse(&input)
            } catch {
                input.seek(to: start)
                throw .invalidValue(error)
            }

            return IETF.RFC.`5322`.Header(name: name, value: value)
        }

        public borrowing func serialize(_ output: Output, into buffer: inout Buffer) throws(Failure) {
            Scan.append(output.description, into: &buffer)
        }
    }
#endif

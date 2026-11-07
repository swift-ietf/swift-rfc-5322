import ASCII
public import Byte
import INCITS_4_1986


extension RFC_5322.Mailbox.LocalPart {
    package enum Storage: Hashable {
        case dotAtom([Byte])
        case quoted([Byte])
    }
}

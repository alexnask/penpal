import DWGReader
import io/Reader

DWG: class {
    reader: DWGReader
    _valid? := false

    init: func~reader(reader: Reader) {
        this reader = DWGReader new(reader)

        // Read header and stuff
    }

    init: func(path: String) {
        init~reader(FileReader new(path))
    }

    fromMemory: static func(mem: String) -> This {
        This new~reader(StringReader new(mem))
    }

    valid?: func -> Bool {
        _valid?
    }
}

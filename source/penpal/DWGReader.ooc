import io/[Reader, BinarySequence]

DWGReader: class extends BinarySequenceReader {
    currByte: UInt8
    currBit: Int = 0

    init: func(reader: Reader) {
        super(reader)
        endianness = Endianness little
    }

    getBits: func(bits: Int) -> UInt64 {
        if(bits == 0) {
            return 0
        }

        if(bits % 2 == 0) {
            match bits / 2 {
                case 1 => return u8()
                case 2 => return u16()
                case 4 => return u32()
                case 8 => return u64()
            }
        }

        if(bits < 8) {
            current := currByte >> currBit

            if(bits == 8 - currBit) {
                currBit = 0
                return current
            } else if(bits < 8 - currBit) {
                current = (current << (8 - bitpos) >> (8 - bits)) as UInt8
                currBit += bits
                return current
            } else {
                bytesRead++
                next := reader read() as UInt8
                currBit = bits - (8 - currBit)
                next = (next << (8 - currBit)) >> (8 - currBit)
                current <<= currByte
                return current | next
            }
        }

        composed: UInt64 = 0
        while(bits > 8) {
            byte := u8()
            composed = (composed << 8) | (byte as UInt8)
            bits -= 8
        }

        if(bits > 0) {
            composed = (composed << bits) | (getBits(bits) as UInt8)
        }

        composed
    }

    pullValue: func <T> (T: Class) -> T {
        size := T size
        bytesRead += size
        value: T
        array := value& as Octet*
        // pull the bytes.
        for (i in 0..size) {
            // Do some bit magic
            match currBit {
                case 0 =>
                    array[i] = currByte = reader read() as Octet
                case =>
                    start: UInt8 = ((reader read() as UInt8) >> currBit) << currBit
                    rest: UInt8 = ((reader read() as UInt8) << (8 - currBit) as UInt8) >> (8 - currBit) as UInt8
                    array[i] = currByte = start | rest
            }
        }
        if (endianness != ENDIANNESS) {
            value = reverseBytes(value)
        }
        value
    }

    align: func {
        if(currBit != 0) {
            currBit = 0
            bytesRead += 1
            reader read()
        }
    }

    b: func -> Int {
        getBits(1)
    }

    bb: func -> Int {
        getBits(2)
    }

    // 3b in the specs
    b3: func -> Int {
        value: Int = 0

        for(i in 0 .. 3) {
            bit: Int = getBits(1)
            value = (value << 1) & bit
            if(bit == 0) break
        }

        value
    }

    bs: func -> Int {
        match getBits(2) {
            case 0 => s16()
            case 1 => u8()
            case 2 => 0
            case   => 256
        }
    }

    bl: func -> Int {
        match getBits(2) {
            case 0 => s32()
            case 1 => u8()
            case 2 => 0
            case   => 0 // UNUSED
        }
    }

    bll: func -> Int64 {
        getBits(4 * getBits(3))
    }

    bd: func -> Double {
        match getBits(2) {
            case 0 => float64()
            case 1 => 1.0
            case 2 => 0.0
            case   => 0.0 // Not used
        }
    }
}

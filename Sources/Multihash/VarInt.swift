// Based off the of the Go implementation described below.
// This file implements "varint" encoding of 64-bit integers.
// The encoding is:
// - unsigned integers are serialized 7 bits at a time, starting with the
//   least significant bits
// - the most significant bit (msb) in each output byte indicates if there
//   is a continuation byte (msb = 1)
// - signed integers are mapped to unsigned integers using "zig-zag"
//   encoding: Positive values x are written as 2*x + 0, negative values
//   are written as 2*(^x) + 1; that is, negative numbers are complemented
//   and whether to complement is encoded in bit 0.
//
// Design note:
// At most 10 bytes are needed for 64-bit values. The encoding could
// be more dense: a full 64-bit value needs an extra byte just to hold bit 63.
// Instead, the msb of the previous byte could be used to hold bit 63 since we
// know there can't be more than 64 bits. This is a trivial improvement and
// would reduce the maximum encoding length to 9 bytes. However, it breaks the
// invariant that the msb is always the "continuation bit" and thus makes the
// format incompatible with a varint encoding for larger numbers (say 128-bit).
import Foundation

enum VarIntError: Error {
    case inputTooShort
    case overflow
}

// putUvarint returns a Data struct with the UInt64 encoded
public func putUVarInt(_ value: UInt64) -> Data {
    var buffer = Data()
    var val: UInt64 = value

    while val >= 0x80 {
        buffer.append((UInt8(truncatingIfNeeded: val) | 0x80))
        val >>= 7
    }

    buffer.append(UInt8(val))
    return buffer
}

// uVarInt decodes a UInt64 from buf and returns that value and the
// number of bytes read (> 0).
//
// Throws an error if the integer overflows or the buffer is too
// short.
public func uVarInt(_ buffer: Data) throws -> (UInt64, Int) {
    var output: UInt64 = 0
    var counter = 0
    var shifter: UInt64 = 0

    for byte in buffer {
        if byte < 0x80 {
            if counter > 9 || counter == 9 && byte > 1 {
                throw VarIntError.overflow
            }
            return (output | UInt64(byte) << shifter, counter + 1)
        }

        output |= UInt64(byte & 0x7f) << shifter
        shifter += 7
        counter += 1
    }
    throw VarIntError.inputTooShort
}

// putUvarint returns a Data struct with the Int64 encoded
public func putVarInt(_ value: Int64) throws -> Data {

    var unsignedValue = UInt64(value) << 1

    if value < 0 {
        unsignedValue = ~unsignedValue
    }

    return putUVarInt(unsignedValue)
}

// uVarInt decodes a UInt64 from buf and returns that value and the
// number of bytes read (> 0).
//
// Throws an error if the integer overflows or the buffer is too
// short.
public func varInt(_ buffer: Data) throws -> (Int64, Int) {

    let (unsignedValue, bytesRead) = try uVarInt(buffer)
    var value = Int64(unsignedValue >> 1)

    if unsignedValue & 1 != 0 { value = ~value }

    return (value, bytesRead)
}


// ReadUvarint reads an encoded unsigned integer from reader and returns it as a UInt64.
public func readUVarInt(_ reader: InputStream) throws -> UInt64 {

    var value: UInt64   = 0
    var shifter: UInt64 = 0
    var index = 0

    repeat {
        var buffer = [UInt8](repeating: 0, count: 10)

        if reader.read(&buffer, maxLength: 1) < 0 {
            throw reader.streamError!
        }

        let buf = buffer[0]

        if buf < 0x80 {
            if index > 9 || index == 9 && buf > 1 {
                throw VarIntError.overflow
            }
            return value | UInt64(buf) << shifter
        }
        value |= UInt64(buf & 0x7f) << shifter
        shifter += 7
        index += 1
    } while true
}

// ReadVarint reads an encoded signed integer from r and returns it as an int64.
public func readVarInt(_ reader: InputStream) throws -> Int64 {

    let unsignedValue = try readUVarInt(reader)
    var value = Int64(unsignedValue >> 1)

    if unsignedValue & 1 != 0 {
        value = ~value
    }

    return value
}

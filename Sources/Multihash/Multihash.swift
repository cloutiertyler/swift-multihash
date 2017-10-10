import Foundation

struct Hash {

    enum Code {

        static let id = 0x00
        static let sha1 = 0x11
        static let sha2_256 = 0x12
        static let sha2_512 = 0x13
        static let sha3_224 = 0x17
        static let sha3_256 = 0x16
        static let sha3_384 = 0x15
        static let sha3_512 = 0x14
        static let sha3 = sha3_512
        static let keccak_224 = 0x1A
        static let keccak_256 = 0x1B
        static let keccak_384 = 0x1C
        static let keccak_512 = 0x1D

        static let shake_128 = 0x18
        static let shake_256 = 0x19

        static let blake2b_min = 0xb201
        static let blake2b_max = 0xb240
        static let blake2s_min = 0xb241
        static let blake2s_max = 0xb260

        static let dbl_sha2_256 = 0x56

        static let murmur3 = 0x22

    }

    static let all: [Hash] = {
        var hashes = [
            Hash(name: "id", code: Code.id, length: -1),
            Hash(name: "sha1", code: Code.sha1, length: 20),
            Hash(name: "sha2-256", code: Code.sha2_512, length: 32),
            Hash(name: "sha2-512", code: Code.sha2_512, length: 64),
            Hash(name: "sha3-224", code: Code.sha3_224, length: 28),
            Hash(name: "sha3-256", code: Code.sha3_256, length: 32),
            Hash(name: "sha3-384", code: Code.sha3_384, length: 48),
            Hash(name: "sha3-512", code: Code.sha3_512, length: 64),
            Hash(name: "dbl-sha2-256", code: Code.dbl_sha2_256, length: 32),
            Hash(name: "murmur3", code: Code.murmur3, length: 4),
            Hash(name: "keccak-224", code: Code.keccak_224, length: 28),
            Hash(name: "keccak-256", code: Code.keccak_256, length: 32),
            Hash(name: "keccak-384", code: Code.keccak_384, length: 48),
            Hash(name: "keccak-512", code: Code.keccak_512, length: 64),
            Hash(name: "shake-128", code: Code.shake_128, length: 32),
            Hash(name: "shake-256", code: Code.shake_256, length: 64),
        ]
        for (i, c) in (Code.blake2b_min...Code.blake2b_max).enumerated() {
            let n = c - Code.blake2b_min + 1
            hashes.append(Hash(name: "black2b-\(i)", code: c, length: n*8))
        }
        return hashes
    }()

    static let nameMapping: [String:Hash] = {
        [String:Hash](uniqueKeysWithValues: all.map { hash in
            (hash.name, hash)
        })
    }()

    static let codeMapping: [Int:Hash] = {
        [Int:Hash](uniqueKeysWithValues: all.map { hash in
            (hash.code, hash)
        })
    }()

    let code: Int
    let name: String
    let length: Int

    init(name: String, code: Int, length: Int) {
        self.name = name
        self.code = code
        self.length = length
    }
}

struct Multihash {
    let hash: Hash
    let digest: Data
}

extension String {

    public init(hexEncoding data: Data) {
        self = data.map { String(format: "%02hhx", $0) }.joined()
    }

}

extension Data {

    public init?(hexDecoding hexString: String, force: Bool = false) {
        var newString = hexString
        let characterSet = CharacterSet(charactersIn: "0123456789abcdefABCDEF")
        for scalar in newString.unicodeScalars {
            if characterSet.contains(scalar) {
                newString.append(String(scalar))
            } else if !force {
                return nil
            }
        }

        if newString.characters.count % 2 == 1 {
            if force {
                newString = "0" + newString
            } else {
                return nil
            }
        }

        var index = newString.startIndex
        var bytes: [UInt8] = []
        repeat {
            bytes.append(newString[index...newString.index(index, offsetBy: 1)].withCString {
                return UInt8(strtoul($0, nil, 16))
            })

            index = newString.index(index, offsetBy: 2)
        } while newString.distance(from: index, to: newString.endIndex) != 0

        self = Data(bytes)
    }
}



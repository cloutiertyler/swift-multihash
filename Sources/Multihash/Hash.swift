import Foundation

public struct Hash {

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

        static func isValid(_ code: Int) -> Bool {
            if code >= 0 && code < 0x10 {
                return true
            }
            if let _ = codeMapping[code] {
                return true
            }
            return false
        }

    }

    static let all: [Hash] = {
        var hashes = [
            Hash(name: "id", code: Code.id, length: -1),
            Hash(name: "sha1", code: Code.sha1, length: 20),
            Hash(name: "sha2-256", code: Code.sha2_256, length: 32),
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
            hashes.append(Hash(name: "blake2b-\(n*8)", code: c, length: n))
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

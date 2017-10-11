import Foundation
import Multibase

public struct Multihash {
    let hash: Hash
    let digest: Data

    internal init(hash: Hash, digest: Data) {
        self.hash = hash
        self.digest = digest
    }

    public init?(code: Int, digest: Data) {
        // Code must be valid
        if !Hash.Code.isValid(Int(code)) {
            return nil
        }
        self.hash = Hash.codeMapping[code]!
        self.digest = digest
    }

    public init?(name: String, digest: Data) {
        guard let code = Hash.nameMapping[name]?.code else {
            return nil
        }

        self.init(code: code, digest: digest)
    }

    init?(decoding data: Data) {
        // Too short
        if data.count < 3 {
            return nil
        }

        guard let (code, numRead1) = try? uVarInt(data) else {
            return nil
        }

        guard let (length, numRead2) = try? uVarInt(data[numRead1...]) else {
            return nil
        }

        // Only supporting <= 2^31-1
        if length > Int.max {
            return nil
        }

        // Code must be valid
        if !Hash.Code.isValid(Int(code)) {
            return nil
        }

        let name = Hash.codeMapping[Int(code)]!.name

        let start = (numRead1 + numRead2)
        let digest = data[start...]

        // Ensure digest count and length are consistent
        if digest.count != Int(length) {
            return nil
        }

        self.hash = Hash(name: name, code: Int(code), length: Int(length))
        self.digest = digest
    }

    init?(base16Decoding base16String: String) {
        guard let data = Data(base16Decoding: base16String) else {
            return nil
        }
        guard let m = Multihash(decoding: data) else {
            return nil
        }
        self = m
    }

    init?(base58Decoding base58String: String) {
        guard let data = Data(base58Decoding: base58String) else {
            return nil
        }
        guard let m = Multihash(decoding: data) else {
            return nil
        }
        self = m
    }

}

extension String {

    init(base16Encoding multihash: Multihash) {
        let data = Data(encoding: multihash)
        self = String(base16Encoding: data)
    }

    init(base58Encoding multihash: Multihash) {
        let data = Data(encoding: multihash)
        self = String(base58Encoding: data)
    }

}

extension Data {

    init(encoding multihash: Multihash) {
        let codeData = putUVarInt(UInt64(multihash.hash.code))
        let lengthData = putUVarInt(UInt64(multihash.digest.count))
        self = codeData + lengthData + multihash.digest
    }

}

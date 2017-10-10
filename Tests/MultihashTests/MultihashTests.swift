import XCTest
@testable import Multihash

let testCodeMap = [
    0x00: "id",
    0x11: "sha1",
    0x12: "sha2-256",
    0x13: "sha2-512",
    0x14: "sha3-512",
    0x15: "sha3-384",
    0x16: "sha3-256",
    0x17: "sha3-224",
    0x56: "dbl-sha2-256",
    0x22: "murmur3",
    0x1A: "keccak-224",
    0x1B: "keccak-256",
    0x1C: "keccak-384",
    0x1D: "keccak-512",
    0x18: "shake-128",
    0x19: "shake-256",
]

struct TestCase {
    let hex: String
    let code: Int
    let name: String
}

extension Data {

    init(encoding testCase: TestCase) {
        let hexData = Data(hexDecoding: testCase.hex)!
        let codeData = putUVarInt(UInt64(testCase.code))
        let lengthData = putUVarInt(UInt64(hexData.count))
        self = codeData + lengthData + hexData
    }

}

let testCases = [
    TestCase(hex: "2c26b46b68ffc68ff99b453c1d30413413422d706483bfa0f98a5e886266e7ae", code: 0x00, name: "id"),
    TestCase(hex: "0beec7b5ea3f0fdbc95d0dd47f3c5bc275da8a33", code: 0x11, name: "sha1"),
    TestCase(hex: "0beec7b5", code: 0x11, name: "sha1"),
    TestCase(hex: "2c26b46b68ffc68ff99b453c1d30413413422d706483bfa0f98a5e886266e7ae", code: 0x12, name: "sha2-256"),
    TestCase(hex: "2c26b46b", code: 0x12, name: "sha2-256"),
    TestCase(hex: "2c26b46b68ffc68ff99b453c1d30413413", code: 0xb240, name: "blake2b-512"),
    TestCase(hex: "243ddb9e", code: 0x22, name: "murmur3"),
    TestCase(hex: "f00ba4", code: 0x1b, name: "keccak-256"),
    TestCase(hex: "f84e95cb5fbd2038863ab27d3cdeac295ad2d4ab96ad1f4b070c0bf36078ef08", code: 0x18, name: "shake-128"),
    TestCase(hex: "1af97f7818a28edfdfce5ec66dbdc7e871813816d7d585fe1f12475ded5b6502b7723b74e2ee36f2651a10a8eaca72aa9148c3c761aaceac8f6d6cc64381ed39", code: 0x19, name: "shake-256"),
    TestCase(hex: "4bca2b137edc580fe50a88983ef860ebaca36c857b1f492839d6d7392452a63c82cbebc68e3b70a2a1480b4bb5d437a7cba6ecf9d89f9ff3ccd14cd6146ea7e7", code: 0x14, name: "sha3-512"),
]

class MultihashTests: XCTestCase {

    func testEncode() {
        for testCase in testCases {
            let hexData = Data(hexDecoding: testCase.hex)!
            let encodedTestCase = Data(encoding: testCase)

            var multihash = Multihash(code: testCase.code, digest: hexData)!
            var encodedMultihash = Data(encoding: multihash)

            XCTAssertEqual(encodedTestCase, encodedMultihash)

            multihash = Multihash(name: testCase.name, digest: hexData)!
            encodedMultihash = Data(encoding: multihash)

            XCTAssertEqual(encodedTestCase, encodedMultihash)
        }
    }

    func testDecode() {
        for testCase in testCases {
            let hexData = Data(hexDecoding: testCase.hex)!
            let encodedTestCase = Data(encoding: testCase)

            let multihash = Multihash(decoding: encodedTestCase)!

            XCTAssertEqual(multihash.hash.name, testCase.name)
            XCTAssertEqual(multihash.hash.code, testCase.code)
            XCTAssertEqual(multihash.hash.length, hexData.count)
            XCTAssertEqual(multihash.digest, hexData)
        }
    }

    func testCodes() {
        for (key, value) in testCodeMap {
            XCTAssertEqual(Hash.codeMapping[key]!.name, value)
            XCTAssertEqual(Hash.nameMapping[value]!.code, key)
        }
    }

    static var allTests = [
        ("testEncode", testEncode),
        ("testDecode", testDecode),
        ("testCodes", testCodes),
    ]
}

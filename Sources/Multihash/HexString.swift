import Foundation

public extension String {

    public init(hexEncoding data: Data) {
        self = data.map { String(format: "%02hhx", $0) }.joined()
    }

}

public extension Data {

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

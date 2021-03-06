//
// Created by Vlad Vrublevsky on 18.01.2020.
// Copyright (c) 2020 Vlad Vrublevsky. All rights reserved.
//

import Foundation
import CryptoSwift

func getIV() -> String
{
    let len = 16
    let pswdChars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890"
    let pass = String((0..<len).compactMap{ _ in pswdChars.randomElement() })
    return pass
}

func CryptAES256(key: String, iv: String, data: Data) -> Data?
{
    let key = key.md5()
    do {
        let aes = try AES(key: key, iv: iv)
        let ciphertext = try aes.encrypt([UInt8](data))
        return  Data(hex: ciphertext.toHexString())
    } catch { print(error.localizedDescription) }
    return nil
}

func DecryptAES256(key: String, iv: String, data: Data) -> Data?
{
    let key = key.md5()
    do {
        let aes = try AES(key: key, iv: iv) // aes256
        let textUint8 = try aes.decrypt( [UInt8](data))
        return Data(hex: textUint8.toHexString())
    } catch { return nil }
}

func stringToBytes(_ string: String) -> [UInt8]? {
    let length = string.count
    if length & 1 != 0 {
        return nil
    }
    var bytes = [UInt8]()
    bytes.reserveCapacity(length/2)
    var index = string.startIndex
    for _ in 0..<length/2 {
        let nextIndex = string.index(index, offsetBy: 2)
        if let b = UInt8(string[index..<nextIndex], radix: 16) {
            bytes.append(b)
        } else {
            return nil
        }
        index = nextIndex
    }
    return bytes
}

//
// Created by Vlad Vrublevsky on 18.01.2020.
// Copyright (c) 2020 Vlad Vrublevsky. All rights reserved.
//

import Foundation
import SwiftyJSON

enum FUNC_RESULT
{
    case SUCCEFULL

    //ERROR TYPE
    case ALREADY_EXIST
    case FILE_NOT_EXIST
    case FILE_UNVIABLE
    case CODE_NOT_EXIST

    case ERROR_ON_CATCH
}

class core_open2fa
{
    private var IV = String()
    private var pass = String()
    private var fileURL = FileManager.default.homeDirectoryForCurrentUser

    private var codes = Array<(key: String, value: String)>()

    init(fileURL: URL, password: String)
    {
        self.fileURL = fileURL
        self.pass = password

        Setup(fileURL: fileURL)

        let data = ReadFile(fileURL: fileURL)
        let IV_dict = ParseStringToDict(string: data)
        if let iv = IV_dict["IV"]
        {
            self.IV = iv
        } else { exit(1) }
    }

    func Refresh() {
        /*
        let data = ReadFile(fileURL: fileURL)
        let parse = GetDictionary(data: data)
        if parse.count != 1 {
            let decrypted = DecryptAES256(key: pass, iv: IV, data: parse[1].value)!
            self.codes = GetDictionary(data: decrypted.data(using: String.Encoding.utf8)!)
        } */
    }

    func AddCode(service_name: String, code: String) -> FUNC_RESULT
    {
        for element in codes {
            if ( element.key == service_name )
            {
                return .ALREADY_EXIST
            }
        }
        codes.append( (key: service_name, value: code) )
        codes = RegularizeDictionary(dict: codes)
        SaveArray(array: codes)
        return .SUCCEFULL
    }

    private func SaveArray(array: Array<(key: String, value: String)>) -> FUNC_RESULT {
        var collection = String()
        for code in 0..<codes.count {
            collection += codes[code].key + ":" + codes[code].value + "\n" //TODO Encrypt
        }
        collection.remove(at: collection.index(before: collection.endIndex) )
        if let chyper = CryptAES256(key: self.pass, iv: self.IV, data: collection)
        {
            let saveString = CreateSavedFile(IV: self.IV, codes_ENCRYPTED: chyper)
            SaveFile(fileURL: self.fileURL, text: saveString)
        } else {
            print("core-open2fa.swift, str: 75") 
            exit(1)
        }
        return .SUCCEFULL
    }
}
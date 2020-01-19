//
// Created by Vlad Vrublevsky on 18.01.2020.
// Copyright (c) 2020 Vlad Vrublevsky. All rights reserved.
//

import Foundation

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

        Refresh()
        //DEBUG
        print(self.codes)
    }

    func Refresh() {
        let data = ReadFile(fileURL: fileURL)
        let refresh_dict = ParseStringToDict(string: data)
        if let iv = refresh_dict["IV"]
        {
            self.IV = iv
        } else { exit(1) }
        if let codes = refresh_dict["codes"] {
            if let decrypted = DecryptAES256(key: self.pass, iv: self.IV, data: codes)
            {
                let codes_dict = ParseStringToDict(string: decrypted)
                self.codes = RegularizeDictionary(dict: codes_dict)
            } else {
                print("Password incorrect")
                exit(1)
            }
        } else {
            print("Haven't any code")
        }
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

        Refresh()
        return .SUCCEFULL
    }

    private func SaveArray(array: Array<(key: String, value: String)>) -> FUNC_RESULT {
        var collection = String()
        for code in 0..<codes.count {
            collection += codes[code].key + ":" + codes[code].value + "\n" 
        }
        collection.remove(at: collection.index(before: collection.endIndex) ) //TODO We delete last \n to save supporting by ParseCustom func
        if let chyper = CryptAES256(key: self.pass, iv: self.IV, data: collection)
        {
            let saveString = CreateSavedFile(IV: self.IV, codes_ENCRYPTED: chyper)
            SaveFile(fileURL: self.fileURL, text: saveString)
        } else {
            print("core-open2fa.swift, (1)") 
            exit(1)
        }
        return .SUCCEFULL
    }
}
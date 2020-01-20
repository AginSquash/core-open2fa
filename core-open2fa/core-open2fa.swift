//
// Created by Vlad Vrublevsky on 18.01.2020.
// Copyright (c) 2020 Vlad Vrublevsky. All rights reserved.
//

import Foundation
import KeychainAccess

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
        
        let keychain = Keychain(service: "com.core-open2fa.userpass")

        DispatchQueue.global().async {
            do {
                let password = try keychain
                        .authenticationPrompt("Authenticate to login to server")
                        .get("kishikawakatsumi")

                print("password: \(password)")
            } catch let error {
                // Error handling if needed...
            }
        }

        self.fileURL = fileURL
        self.pass = password

        Setup(fileURL: fileURL)

        Refresh()
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

    func getListOTP() -> Array<(name: String, code: String)>
    {
        var array = Array<(name: String, code: String)>()
        for code in codes{
           array.append( (name: code.key, code: getOTP(code: code.value)) )
        }
        return array
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

    func DeleteCode(name: String) -> FUNC_RESULT
    {

        for code in 0..<codes.count{
            if codes[code].key == name
            {
                codes.remove(at: code)
                SaveArray(array: codes)
                return .SUCCEFULL
            }
        }
        return .CODE_NOT_EXIST
    }

    private func SaveArray(array: Array<(key: String, value: String)>) -> FUNC_RESULT {
        var collection = String()
        for code in 0..<codes.count {
            collection += codes[code].key + ":" + codes[code].value + "\n" 
        }
        //TESTME collection.remove(at: collection.index(before: collection.endIndex) ) TODO We delete last \n to save supporting by ParseCustom func
        if let chyper = CryptAES256(key: self.pass, iv: self.IV, data: collection)
        {
            let saveString = CreateSavedFile(IV: self.IV, codes_ENCRYPTED: chyper)
            SaveFile(fileURL: self.fileURL, text: saveString)
        } else {
            print("core-open2fa.swift, (1)") 
            exit(1)
        }
        Refresh()
        return .SUCCEFULL
    }
}
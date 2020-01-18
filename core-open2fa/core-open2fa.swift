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

        let data = ReadFile(fileURL: fileURL)
        let dict = GetDictionary(data: data)
        self.IV = dict[0].value

        Refresh()
    }

    func Refresh() {
        let data = ReadFile(fileURL: fileURL)
        let parse = GetDictionary(data: data)
        if parse.count != 1 {
            let decrypted = DecryptAES256(key: pass, iv: IV, data: parse[1].value)!
            self.codes = GetDictionary(data: decrypted.data(using: String.Encoding.utf8)!)
        }
    }


}
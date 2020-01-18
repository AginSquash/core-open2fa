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

    func AddCode(service_name: String, code: String) -> FUNC_RESULT
    {
        codes.append( (key: service_name, value: code) )

        /*
        var str = "{ "
        for code in 0..<codes.count
        {
            str += codes[code].key + ": \"" + codes[code].value + "\","
        }
        str.removeLast()
        str += " }"
        */

        var dict = [String: String]()

        for code in 0..<codes.count
        {
            if dict[ codes[code].key ] == nil {
                dict[ codes[code].key ] = codes[code].value
            } else { return .ALREADY_EXIST}
        }

        do {
            let jsonData = try JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)
            // here "jsonData" is the dictionary encoded in JSON data
            print(jsonData)
            let decoded = try JSONSerialization.jsonObject(with: jsonData, options: [])
            // here "decoded" is of type `Any`, decoded from JSON data

            // you can now cast it with the right type
            if let dictFromJSON = decoded as? [String:String] {
                // use dictFromJSON

            }
        } catch {
            print(error.localizedDescription)
        }


        //let a = ["I", "am", "a", "json"]
        //let json = JSON(arrayLiteral: a)
        //let json: JSON
        //print( json.rawString() )


        return .SUCCEFULL
    }

}
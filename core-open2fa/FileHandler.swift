//
// Created by Vlad Vrublevsky on 18.01.2020.
// Copyright (c) 2020 Vlad Vrublevsky. All rights reserved.
//

import Foundation
import SwiftyJSON


func ParseStringToDict(string: String) -> Dictionary<String, String>
{
    var dict = Dictionary<String, String>()
    var parsingString = string
    while parsingString.index(of: "\n") != nil
    {
        let range = parsingString.startIndex...parsingString.index(of: "\n")!
        let substr = parsingString[ range ]
        parsingString.removeSubrange(range)
        var index = substr.firstIndex(of: ":")!
        let key = String( substr[..<index] )
        index = substr.index(after: index)
        let endIndex = substr.index(of: "\n")!
        dict[key] = String( substr[index..<endIndex] )
    }

    var index = parsingString.firstIndex(of: ":")!
    let key = String( parsingString[..<index] )
    index = parsingString.index(after: index)
    dict[key] = String( parsingString[index...] )

    return dict
}

func GetDictionary(data: Data) -> Array<(key: String, value: String)>
{
    do {
        let json = try JSON(data: data)
        var dict = [String : String]()
        for (key_JSON, subJson): (String, JSON) in json {
            /*if let code = subJson["code"].string {
                dict[ key_JSON ] = code
            } */
            dict[ key_JSON ] = subJson.string
        }
        let sortedDictionary = dict.sorted(by: { $0.0 < $1.0 })
        return sortedDictionary
    } catch {
        print(error)
        exit(1)
    }
}
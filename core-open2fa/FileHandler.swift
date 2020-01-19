//
// Created by Vlad Vrublevsky on 18.01.2020.
// Copyright (c) 2020 Vlad Vrublevsky. All rights reserved.
//

import Foundation
import SwiftyJSON

func ParseCustom(str: String, element: String.Element) -> (key: String, value: String)
{
    var index = str.firstIndex(of: ":")!
    let key = String( str[..<index] )
    index = str.index(after: index)
    let endIndex = str.index(of: element)!
    return (key: key, value: String(str[index..<endIndex]) )
}

func ParseStringToDict(string: String) -> Dictionary<String, String>
{
    var dict = Dictionary<String, String>()
    var parsingString = string
    while parsingString.index(of: "\n") != nil
    {
        let range = parsingString.startIndex...parsingString.index(of: "\n")!
        let sub = parsingString[ range ]
        parsingString.removeSubrange(range)
        let tuple = ParseCustom(str: String(sub), element: "\n")
        dict[tuple.key] = tuple.value
    }

    let tuple = ParseCustom(str: parsingString, element: "\0")
    dict[tuple.key] = tuple.value

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
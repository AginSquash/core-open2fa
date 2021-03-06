//
// Created by Vlad Vrublevsky on 18.01.2020.
// Copyright (c) 2020 Vlad Vrublevsky. All rights reserved.
//

import Foundation


private func ParseCustom(str: String, element: String.Element) -> (key: String, value: String)?
{
    if var index = str.firstIndex(of: ":")
    {
        let key = String( str[..<index] )
        index = str.index(after: index)
        if let endIndex = str.firstIndex(of: element)
        {
            return (key: key, value: String(str[index..<endIndex]) )
        } else {
            return (key: key, value: String(str[index...]) )
        }
    } else { return nil }
}

func ParseStringToDict(string: String) -> Dictionary<String, String>
{
    var dict = Dictionary<String, String>()
    var parsingString = string
    while parsingString.firstIndex(of: "\n") != nil
    {
        let range = parsingString.startIndex...parsingString.firstIndex(of: "\n")!
        let sub = parsingString[ range ]
        parsingString.removeSubrange(range)
        if let tuple = ParseCustom(str: String(sub), element: "\n") {
            dict[tuple.key] = tuple.value
        }
    }

    if let tuple = ParseCustom(str: parsingString, element: "\0") // Null is not supporting(?)
    {
        dict[tuple.key] = tuple.value
    }

    return dict
}

func CreateSavedFile(IV: String, codes_ENCRYPTED: String) -> String
{
    let stringToSave = """
                       IV:\(IV)
                       codes:\(codes_ENCRYPTED)
                       """
    return stringToSave
}

func RegularizeDictionary(dict: Dictionary<String, String>) -> Array<(key: String, value: String)>
{
    let array = dict.sorted(by: { $0.0 < $1.0 })
    return array
}

func RegularizeDictionary(dict: Array<(key: String, value: String)>) -> Array<(key: String, value: String)>
{
    let array = dict.sorted(by: { $0.0 < $1.0 })
    return array
}

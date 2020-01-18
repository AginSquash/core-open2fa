//
// Created by Vlad Vrublevsky on 18.01.2020.
// Copyright (c) 2020 Vlad Vrublevsky. All rights reserved.
//

import Foundation
import SwiftyJSON

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
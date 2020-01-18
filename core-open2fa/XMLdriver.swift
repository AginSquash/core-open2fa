//
// Created by Vlad Vrublevsky on 18.01.2020.
// Copyright (c) 2020 Vlad Vrublevsky. All rights reserved.
//

import Foundation

func ParseXML(data: String)
{
    //var range = data.firstIndex(of: "<")!...data.firstIndex(of: "/")!
    var dict = Dictionary<String, String>()

    let correctable = data.index(before: data.firstIndex(of: "/")! )
    if data[correctable] == "<"
    {
        var
        let range = data.firstIndex(of: "<")!...data.firstIndex(of: ">")!
        let key = data[range]

    }
}
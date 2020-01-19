//
//  main.swift
//  core-open2fa
//
//  Created by Vlad Vrublevsky on 18.01.2020.
//  Copyright © 2020 Vlad Vrublevsky. All rights reserved.
//

import Foundation

let fileName = "totp.enc"
let fileURL = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Documents/.cl-swift-totp/\(fileName)")


let o2fa = core_open2fa(fileURL: fileURL, password: "pass")
o2fa.DeleteCode(name: "Test")
o2fa.AddCode(service_name: "Test", code: "codeee4")
o2fa.AddCode(service_name: "Test2", code: "codeee2")
o2fa.AddCode(service_name: "Test4", code: "")
o2fa.AddCode(service_name: "Test5", code: "")

print( o2fa.getListOTP() )
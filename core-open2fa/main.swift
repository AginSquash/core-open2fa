//
//  main.swift
//  core-open2fa
//
//  Created by Vlad Vrublevsky on 18.01.2020.
//  Copyright © 2020 Vlad Vrublevsky. All rights reserved.
//

import Foundation
import SwiftyJSON

let fileName = "totp.enc"
let fileURL = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Documents/.cl-swift-totp/\(fileName)")


let o2fa = core_open2fa(fileURL: fileURL, password: "pass")
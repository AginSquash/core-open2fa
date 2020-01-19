//
// Created by Vlad Vrublevsky on 19.01.2020.
// Copyright (c) 2020 Vlad Vrublevsky. All rights reserved.
//

import Foundation
import SwiftOTP

func getOTP(code: String) -> String
{
    if let data = base32DecodeToData(code)
    {
        if let totp = TOTP(secret: data) {

            let time = Date()
            let otpString = totp.generate(secondsPast1970: Int(time.timeIntervalSince1970) )
            return otpString!
        }
    }
    return "Error"
}
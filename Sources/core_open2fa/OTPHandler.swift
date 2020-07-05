//
// Created by Vlad Vrublevsky on 19.01.2020.
// Copyright (c) 2020 Vlad Vrublevsky. All rights reserved.
//

import Foundation
import SwiftOTP

func getOTP(code: String) -> String?
{
    if let data = base32DecodeToData(code)
    {
        if let totp = TOTP(secret: data) {
            let otpString = totp.generate(time: Date())
            return otpString!
        }
    }
    return nil
}

//
// Created by Vlad Vrublevsky on 19.01.2020.
// Copyright (c) 2020 Vlad Vrublevsky. All rights reserved.
//

import Foundation
import SwiftOTP

public enum OTP_Type: Codable {
    case TOTP
    case HOTP
}

func getOTP(code: UNPROTECTED_AccountData) -> String? {
    if code.type == .TOTP {
        return getTOTP(code: code.secret)
    } else {
        return getHOTP(code: code.secret, counter: code.counter)
    }
}

func getTOTP(code: String) -> String?
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

func getHOTP(code: String, counter: UInt) -> String?
{
    if let data = base32DecodeToData(code)
    {
        if let hotp = HOTP(secret: data) {
            let otpString = hotp.generate(counter: UInt64(counter))
            return otpString!
        }
    }
    return nil
}

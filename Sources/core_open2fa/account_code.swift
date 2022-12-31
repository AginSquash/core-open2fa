//
//  code.swift
//  
//
//  Created by Vlad Vrublevsky on 15.05.2020.
//

import Foundation

/// Code that can be used outside of core
public struct Account_Code: Identifiable, Comparable {
    public let id: UUID
    public let date: Date
    public var name: String
    public var issuer: String
    public var codeSingle: String?
    
    static public func < (lhd: Account_Code, rhd: Account_Code) -> Bool {
        lhd.date < rhd.date
    }
    
    public init(id: UUID, date: Date, name: String, issuer: String, codeSingle: String?) {
        self.id = id
        self.date = date
        self.name = name
        self.issuer = issuer
        self.codeSingle = codeSingle
    }
}


/// Code with secret for 2FA generation
public struct UNPROTECTED_AccountData: Identifiable, Codable {
    public let id: UUID
    public let type: OTP_Type
    public let date: Date
    public var name: String
    public var issuer: String
    public var secret: String
    public var counter: UInt = 0
    
    init(_ csl: codeSecure_legacy) {
        self.id = csl.id
        self.type = .TOTP
        self.date = csl.date
        self.name = csl.name
        self.secret = csl.code
        self.counter = 0
        self.issuer = ""
    }
    
    init(_ csl: codeSecure_legacy330) {
        self.id = csl.id
        self.type = .TOTP
        self.date = csl.date
        self.name = csl.name
        self.secret = csl.secret
        self.counter = 0
        self.issuer = ""
    }
    
    init(_ csl: codeSecure_legacy500) {
        self.id = csl.id
        self.type = .TOTP
        self.date = csl.date
        self.name = csl.name
        self.secret = csl.secret
        self.counter = 0
        self.issuer = ""
    }
    
    public init(id: UUID = UUID(), type: OTP_Type = .TOTP, date: Date = Date(), name: String, issuer: String = "", secret: String, counter: UInt = 0) {
        self.id = id
        self.type = type
        self.date = date
        self.name = name
        self.issuer = issuer
        self.secret = secret
        self.counter = counter
    }
    
    mutating func updateHOTP() {
        self.counter += 1
    }
}

public struct codeSecure_legacy500: Identifiable, Codable {
    public let id: UUID
    public let type: OTP_Type
    public let date: Date
    public var name: String
    public var secret: String
    public var counter: UInt = 0
    
    init(_ csl: codeSecure_legacy) {
        self.id = csl.id
        self.type = .TOTP
        self.date = csl.date
        self.name = csl.name
        self.secret = csl.code
        self.counter = 0
    }
    
    init(_ csl: codeSecure_legacy330) {
        self.id = csl.id
        self.type = .TOTP
        self.date = csl.date
        self.name = csl.name
        self.secret = csl.secret
        self.counter = 0
    }
    
    
    public init(id: UUID = UUID(), type: OTP_Type = .TOTP, date: Date = Date(), name: String, secret: String, counter: UInt = 0) {
        self.id = id
        self.type = type
        self.date = date
        self.name = name
        self.secret = secret
        self.counter = counter
    }
    
    mutating func updateHOTP() {
        self.counter += 1
    }
}

/// Code with secret for 2FA generation
public struct codeSecure_legacy330: Identifiable, Codable {
    public let id: UUID
    public let date: Date
    public var name: String
    public var secret: String
    
    init(_ csl: codeSecure_legacy) {
        self.id = csl.id
        self.date = csl.date
        self.name = csl.name
        self.secret = csl.code
    }
    
    init(id: UUID, date: Date, name: String, secret: String) {
        self.id = id
        self.date = date
        self.name = name
        self.secret = secret
    }
}

struct codeSecure_legacy: Identifiable, Codable {
    let id: UUID
    let date: Date
    var name: String
    var code: String
}

struct codesFile: Codable {
    var core_version: String = CORE_OPEN2FA.core_version
    var IV: String
    var passcheck: Data?
    var codes: Data?
}

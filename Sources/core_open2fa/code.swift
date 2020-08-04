//
//  code.swift
//  
//
//  Created by Vlad Vrublevsky on 15.05.2020.
//

import Foundation

/// Code that can be used outside of core
public struct code: Identifiable, Comparable {
    public let id: UUID
    public let date: Date
    public var name: String
    public var codeSingle: String?
    
    static public func < (lhd: code, rhd: code) -> Bool {
        lhd.name < rhd.name
    }
    
    public init(id: UUID, date: Date, name: String, codeSingle: String?) {
        self.id = id
        self.date = date
        self.name = name
        self.codeSingle = codeSingle
    }
}

/// [CORE USAGE ONLY] Code with key for 2FA generation
struct codeSecure: Identifiable, Codable, Comparable {
    let id: UUID
    let date: Date
    var name: String
    var code: String
    static func < (lhd: codeSecure, rhd: codeSecure) -> Bool {
        lhd.name < rhd.name
    }

}

struct codesFile: Codable {
    var core_version: String = CORE_OPEN2FA.core_version
    var IV: String
    var passcheck: Data?
    var codes: Data?
}

//
//  code.swift
//  
//
//  Created by Vlad Vrublevsky on 15.05.2020.
//

import Foundation

public struct code: Identifiable, Comparable {
    public let id: UUID
    public let date: Date
    public var name: String
    public var codeSingle: String
    
    static public func < (lhd: code, rhd: code) -> Bool {
        lhd.name < rhd.name
    }
    
    public init(id: UUID, date: Date, name: String, codeSingle: String) {
        self.id = id
        self.date = date
        self.name = name
        self.codeSingle = codeSingle
    }
}

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
    var IV: String
    var codes: Data?
}

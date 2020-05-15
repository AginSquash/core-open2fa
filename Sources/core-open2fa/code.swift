//
//  code.swift
//  
//
//  Created by Vlad Vrublevsky on 15.05.2020.
//

import Foundation

struct code: Identifiable, Comparable {
    let id: UUID
    var name: String
    var codeSingle: String
    
    static func < (lhd: code, rhd: code) -> Bool {
        lhd.name < rhd.name
    }
}

struct codeSecure: Identifiable, Codable, Comparable {
    let id = UUID()
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

//
//  extractor_open2fa.swift
//  
//
//  Created by Vlad Vrublevsky on 10.04.2022.
//

import Foundation

public class EXTRACTOR_OPEN2FA {
    var extractor_codes = [export_codeSecure]()
    
    init(core: CORE_OPEN2FA) {
        self.extractor_codes = core.codes.map({export_codeSecure($0)})
    }
    
    public func getSecureCodes() -> [export_codeSecure] {
        return extractor_codes
    }
}

public struct export_codeSecure {
    public let id: UUID
    public let date: Date
    public var name: String
    public var secret: String

    init(id: UUID, date: Date, name: String, secret: String) {
        self.id = id
        self.date = date
        self.name = name
        self.secret = secret
    }
    
    init(_ cs: codeSecure) {
        self.id = cs.id
        self.date = cs.date
        self.name = cs.name
        self.secret = cs.secret
    }
}

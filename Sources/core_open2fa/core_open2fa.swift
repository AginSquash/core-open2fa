//
// Created by Vlad Vrublevsky on 18.01.2020.
// Copyright (c) 2020 Vlad Vrublevsky. All rights reserved.
//

import Foundation

public class CORE_OPEN2FA
{
    public static let core_version: String = "3.0.0"
    private var IV = String()
    private var pass = String()
    private var fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    private var passcheck: Data? = nil
    private var codes = [codeSecure]()
    
    /// Check password for correctly
    public static func checkPassword(fileURL: URL, password: String) -> FUNC_RESULT {
        
        let dataReaden = ReadFile(fileURL: fileURL)
        guard let data = dataReaden else { return .FILE_NOT_EXIST }
        let CodesFile = try? JSONDecoder().decode(codesFile.self, from: data)
        guard let cf = CodesFile else { return .FILE_UNVIABLE }
        
        guard let check = cf.passcheck else { return .PASSCHECK_NULL }
        
        if let decrypted = DecryptAES256(key: password, iv: cf.IV, data: check) {
            if let decoded = try? JSONDecoder().decode(String.self, from: decrypted) {
                if dictionary_words.contains(decoded) {
                    return .SUCCEFULL
                } else { return .PASS_INCORRECT }
            } else { return .CANNOT_DECODE }
        } else { return .PASS_INCORRECT }
    }
    
    public init(fileURL: URL, password: String)
    {
        self.fileURL = fileURL
        self.pass = password
        let setupResult = Setup(fileURL: fileURL, pass: password)
        guard setupResult == .SUCCEFULL else {
            fatalError("setupResult" + String(setupResult))
        }
        
        _ = Refresh()
    }

    public init() { }
    
    ///  Update codes from file
    public func Refresh() -> FUNC_RESULT {
        let dataReaden = ReadFile(fileURL: fileURL)
        guard let data = dataReaden else { return .FILE_NOT_EXIST }
        let CodesFile = try? JSONDecoder().decode(codesFile.self, from: data)
        guard let cf = CodesFile else { return .FILE_UNVIABLE }
        
        self.IV = cf.IV
        
        if passcheck == nil {
            self.passcheck = cf.passcheck
        }
        
        if let codes = cf.codes {
            if let decrypted = DecryptAES256(key: self.pass, iv: self.IV, data: codes) {
                if let decoded = try? JSONDecoder().decode([codeSecure].self, from: decrypted) {
                    self.codes = decoded
                    return .SUCCEFULL
                } else { return .CANNOT_DECODE }
            } else { return .PASS_INCORRECT }
        } else { return .NO_CODES }
    }

    /// Return list of codes (id, date, name and 2FA code)
    public func getListOTP() -> [code]
    {
        var array = [code]()
        for c in codes {
            array.append( code(id: c.id, date: c.date, name: c.name, codeSingle: getOTP(code: c.code) ) )
        }
        return array.sorted()
    }

    /// Added code to all codes and save file.
    public func AddCode(service_name: String, code: String) -> FUNC_RESULT
    {
        for element in codes {
            if ( element.name == service_name )
            {
                return .ALREADY_EXIST
            }
        }
        
        if getOTP(code: code) == nil { 
            return .CODE_INCORRECT
        }
        
        self.codes.append( codeSecure(id: UUID(), date: Date(), name: service_name, code: code) )
        self.codes.sort()
        
        // return save errors if exists
        DispatchQueue.global(qos: .userInitiated).async {
           _ = self.SaveArray()
        }
        
        return .SUCCEFULL
    }

    /// This function delete code by UUID
    public func DeleteCode(id: UUID) -> FUNC_RESULT
    {
        self.codes.removeAll(where: { $0.id == id } )
        /*
        let saveResult = SaveArray()
        guard saveResult == .SUCCEFULL else {
            return saveResult
        } */
        
        DispatchQueue.global(qos: .userInitiated).async {
           _ = self.SaveArray()
        }
        
        return .SUCCEFULL
    }

    /// Save codes to file
    private func SaveArray() -> FUNC_RESULT {
        if let encoded = try? JSONEncoder().encode(self.codes) {
            let encrypted = CryptAES256(key: self.pass, iv: self.IV, data: encoded)
            guard let passcheck = passcheck else { fatalError("Passcheck is nil") }
            let dataToWrite = codesFile(IV: self.IV, passcheck: passcheck, codes: encrypted)
            if let encodedFile = try? JSONEncoder().encode(dataToWrite) {
                let saveResult = SaveFile(fileURL: self.fileURL, data: encodedFile)
                return saveResult
            }
        }
        return .NOT_ENCODABLE
    }

    /// Return example of codes (id, date, name and 2FA code)
    static public func getExample() -> [code]
    {
        var array = [code]()
        array.append( code(id: UUID(), date: Date(), name: "Example 1", codeSingle: "123456") )
        array.append( code(id: UUID(), date: Date(), name: "Example 2", codeSingle: "456789") )
        return array.sorted()
    }
    
}



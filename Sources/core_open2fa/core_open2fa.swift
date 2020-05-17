//
// Created by Vlad Vrublevsky on 18.01.2020.
// Copyright (c) 2020 Vlad Vrublevsky. All rights reserved.
//

import Foundation

public class CORE_OPEN2FA
{
    private var IV = String()
    private var pass = String()
    private var fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!

    private var codes = [codeSecure]()
    
    init(fileURL: URL, password: String)
    {
        self.fileURL = fileURL
        self.pass = password

        Setup(fileURL: fileURL)
        Refresh()
    }

    func Refresh() -> FUNC_RESULT {
        let dataReaden = ReadFile(fileURL: fileURL)
        guard let data = dataReaden else { return .FILE_NOT_EXIST }
        let CodesFile = try? JSONDecoder().decode(codesFile.self, from: data)
        guard let cf = CodesFile else { return .FILE_UNVIABLE }
        
        self.IV = cf.IV
        
        if let codes = cf.codes {
            if let decrypted = DecryptAES256(key: self.pass, iv: self.IV, data: codes) {
                if let decoded = try? JSONDecoder().decode([codeSecure].self, from: decrypted) {
                    self.codes = decoded
                    return .SUCCEFULL
                } else { return .CANNOT_DECODE }
            } else { return .PASS_INCORRECT }
        } else { return .NO_CODES }
    }

    func getListOTP() -> [code]
    {
        
        var array = [code]()
        for c in codes {
            array.append( code(id: c.id, date: c.date, name: c.name, codeSingle: getOTP(code: c.code)) )
        }
        return array.sorted()
    }

    func AddCode(service_name: String, code: String) -> FUNC_RESULT
    {
        for element in codes {
            if ( element.name == service_name )
            {
                return .ALREADY_EXIST
            }
        }
        codes.append( codeSecure(name: service_name, code: code) )
        codes.sorted()
        SaveArray()

        Refresh()
        return .SUCCEFULL
    }

    func DeleteCode(id: UUID) -> FUNC_RESULT
    {
        self.codes.removeAll(where: { $0.id == id } )
        SaveArray()
        return .SUCCEFULL
    }

    private func SaveArray() -> FUNC_RESULT {
        
        if let encoded = try? JSONEncoder().encode(self.codes) {
            let encrypted = CryptAES256(key: self.pass, iv: self.IV, data: encoded)
            let dataToWrite = codesFile(IV: self.IV, codes: encrypted)
            if let encodedFile = try? JSONEncoder().encode(dataToWrite) {
                SaveFile(fileURL: self.fileURL, data: encodedFile)
            }
            
        }
        Refresh()
        return .SUCCEFULL
    }

    static func getExample() -> [code]
    {
        var array = [code]()
        array.append( code(id: UUID(), date: Date(), name: "Example 1", codeSingle: "123456") )
        array.append( code(id: UUID(), date: Date(), name: "Example 2", codeSingle: "456789") )
        return array.sorted()
    }
    
}



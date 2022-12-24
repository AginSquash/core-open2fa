//
// Created by Vlad Vrublevsky on 18.01.2020.
// Copyright (c) 2020 Vlad Vrublevsky. All rights reserved.
//

import Foundation

public class CORE_OPEN2FA
{
    public static let core_version: String = "5.0.0"
    private var IV = String()
    private var pass = String()
    private var fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    private var passcheck: Data? = nil
    internal var codes = [UNPROTECTED_AccountData]()
    
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
        
        if cf.core_version < CORE_OPEN2FA.core_version {
            return self.UpgradeFileVersion(from: cf.core_version, withCF: cf)
        }
        
        if let codes = cf.codes {
            if let decrypted = DecryptAES256(key: self.pass, iv: self.IV, data: codes) {
                if let decoded = try? JSONDecoder().decode([UNPROTECTED_AccountData].self, from: decrypted) {
                    self.codes = decoded
                    return .SUCCEFULL
                } else { return .CANNOT_DECODE }
            } else { return .PASS_INCORRECT }
        } else { return .NO_CODES }
    }

    /// Return list of codes (id, date, name and 2FA code)
    public func getListOTP() -> [Account_Code]
    {
        var array = [Account_Code]()
        for c in codes {
            array.append( Account_Code(id: c.id, date: c.date, name: c.name, codeSingle: getOTP(code: c) ) )
        }
        return array
    }
    
    public func updateHOTP(id: Account_Code.ID) -> Account_Code?
    {
        let cs_index = codes.firstIndex(where: { $0.id == id})!
        codes[cs_index].updateHOTP()
        let cs = codes[cs_index]
        
        guard cs.type == .HOTP else {
            return nil
        }
        return Account_Code(id: id, date: cs.date, name: cs.name, codeSingle: getHOTP(code: cs.secret, counter: cs.counter))
    }

    /// Added code to all codes and save file.
    public func AddAccount(account_name: String, type: OTP_Type = .TOTP, secret: String, counter: UInt = 0) -> FUNC_RESULT
    {
        if codes.first(where: { account_name == $0.name }) != nil {
            return .ALREADY_EXIST
        }
        
        switch type {
        case .TOTP:
            if getTOTP(code: secret) == nil {
                return .CODE_INCORRECT  }
            break
        case .HOTP:
            if getHOTP(code: secret, counter: counter) == nil {
                return .CODE_INCORRECT }
            break
        }
        
        self.codes.append(UNPROTECTED_AccountData(id: UUID(), type: type, date: Date(), name: account_name, secret: secret, counter: counter))
        
        // return save errors if exists
        DispatchQueue.global(qos: .userInitiated).async {
           _ = self.SaveArray()
        }
        
        return .SUCCEFULL
    }
    
    /// Added code to all codes and save file from UNPROTECTED_AccountData.
    public func AddAccount(newAccount: UNPROTECTED_AccountData) -> FUNC_RESULT
    {
        if codes.first(where: { newAccount.name == $0.name }) != nil {
            return .ALREADY_EXIST
        }
        
        switch newAccount.type {
        case .TOTP:
            if getTOTP(code: newAccount.secret) == nil {
                return .CODE_INCORRECT  }
            break
        case .HOTP:
            if getHOTP(code: newAccount.secret, counter: newAccount.counter) == nil {
                return .CODE_INCORRECT }
            break
        }
        
        self.codes.append(newAccount)
        
        // return save errors if exists
        DispatchQueue.global(qos: .userInitiated).async {
           _ = self.SaveArray()
        }
        
        return .SUCCEFULL
    }
    
    public func AddMulipleAccounts(newAccounts: [UNPROTECTED_AccountData]) -> FUNC_RESULT {
        for account in newAccounts {
            if codes.first(where: { account.name == $0.name }) != nil {
                return .ALREADY_EXIST
            }

            switch account.type {
            case .TOTP:
                if getTOTP(code: account.secret) == nil {
                    return .CODE_INCORRECT  }
                break
            case .HOTP:
                if getHOTP(code: account.secret, counter: account.counter) == nil {
                    return .CODE_INCORRECT }
                break
            }
            
            self.codes.append(account)
        }
        
        // return save errors if exists
        DispatchQueue.global(qos: .userInitiated).async {
           _ = self.SaveArray()
        }
        
        return .SUCCEFULL
    }
    
    public func EditCode(id: UUID, newName: String) -> FUNC_RESULT {
        for element in codes {
            if ( element.name == newName )
            {
                return .ALREADY_EXIST
            }
        }
        
        guard let index = self.codes.firstIndex(where: { $0.id == id }) else {
            return .CANNOT_FIND_ID
        }
        
        self.codes[index].name = newName
        
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
    
    public func NoCrypt_ExportServiceSECRET(with id: UUID) -> UNPROTECTED_AccountData? {
        return codes.first(where: {$0.id == id})
    }

    public func NoCrypt_ExportAllServicesSECRETS() -> [UNPROTECTED_AccountData] {
        return codes
    }
    
    public func migrateSavedFile() -> FUNC_RESULT {
        self.codes.sort(by: { $0.date < $1.date })
        
        DispatchQueue.global(qos: .userInitiated).async {
           _ = self.SaveArray()
        }
        
        return .SUCCEFULL
    }
    
    private func UpgradeFileVersion(from version: String, withCF cf: codesFile) -> FUNC_RESULT {
        
        /// Just renaming 'code' to 'secret' in codeSecure file. Already with all 3.2.5 fix
        if version < "3.1.0" {
            if let codes = cf.codes {
                if let decrypted = DecryptAES256(key: self.pass, iv: self.IV, data: codes) {
                    if let decoded = try? JSONDecoder().decode([codeSecure_legacy].self, from: decrypted) {
                        self.codes = decoded.map({ UNPROTECTED_AccountData($0) }).sorted(by: { $0.date < $1.date })
                        _ = self.SaveArray()
                        print("DEBUG: successfully updated from \(version) to \(CORE_OPEN2FA.core_version)")
                        return .SUCCEFULL
                    } else { return .CANNOT_DECODE }
                } else { return .PASS_INCORRECT }
            } else { return .NO_CODES }
        }
        
        /// Support HOTP codes type
        if version < "4.0.0" {
            if let codes = cf.codes {
                if let decrypted = DecryptAES256(key: self.pass, iv: self.IV, data: codes) {
                    if let decoded = try? JSONDecoder().decode([codeSecure_legacy330].self, from: decrypted) {
                        self.codes = decoded.map({ UNPROTECTED_AccountData($0) }).sorted(by: { $0.date < $1.date })
                        _ = self.SaveArray()
                        print("DEBUG: successfully updated from \(version) to \(CORE_OPEN2FA.core_version)")
                        return .SUCCEFULL
                    } else { return .CANNOT_DECODE }
                } else { return .PASS_INCORRECT }
            } else { return .NO_CODES }
        }
        
        // no fix for version needed. Just update CF version
        if let codes = cf.codes {
            if let decrypted = DecryptAES256(key: self.pass, iv: self.IV, data: codes) {
                if let decoded = try? JSONDecoder().decode([UNPROTECTED_AccountData].self, from: decrypted) {
                    self.codes = decoded.sorted(by: { $0.date < $1.date })
                    _ = self.SaveArray()
                    print("DEBUG: successfully updated from \(version) to \(CORE_OPEN2FA.core_version)")
                    return .SUCCEFULL
                } else { return .CANNOT_DECODE }
            } else { return .PASS_INCORRECT }
        } else { return .NO_CODES }
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
    static public func getExample() -> [Account_Code]
    {
        var array = [Account_Code]()
        array.append( Account_Code(id: UUID(), date: Date(), name: "Example 1", codeSingle: "123456") )
        array.append( Account_Code(id: UUID(), date: Date(), name: "Example 2", codeSingle: "456789") )
        return array
    }
    
}



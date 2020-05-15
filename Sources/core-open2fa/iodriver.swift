//
//  iodriver.swift
//  core-open2fa
//
//  Created by Vlad Vrublevsky on 18.01.2020.
//  Copyright © 2020 Vlad Vrublevsky. All rights reserved.
//

import Foundation

func ReadFile(fileURL: URL) -> Data?
{
    //let dataOuput = try? Data(contentsOf: fileURL)
    //let textOutput = try? String(contentsOf: fileURL, encoding: .utf8)
    return try? Data(contentsOf: fileURL)  //textOutput //.data(using: .utf8, allowLossyConversion: false)!
}

func SaveFile(fileURL: URL, data: Data) -> FUNC_RESULT
{
    do {
        try data.write(to: fileURL)
        //try text.write(to: fileURL, atomically: false, encoding: .utf8)
        return .SUCCEFULL
    }
    catch { return .CANNOT_SAVE_FILE }
}

func Setup(fileURL: URL) -> FUNC_RESULT
{
    do {
        _ = try String(contentsOf: fileURL, encoding: .utf8)
        return .SUCCEFULL
    } catch {

        let manager = FileManager.default
        let folder = fileURL.deletingLastPathComponent().relativePath

        do {
            try manager.createDirectory(atPath: folder, withIntermediateDirectories: true, attributes: nil )
        }
        catch { return .CANNOT_CREATE_DIRECTORY }

        let IV = getIV()
        let cf = codesFile(IV: IV, codes: nil)
        let data = try! JSONEncoder().encode(cf)
        return ( SaveFile(fileURL: fileURL, data: data ))
    }
}

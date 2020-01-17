//
//  iodriver.swift
//  core-open2fa
//
//  Created by Vlad Vrublevsky on 18.01.2020.
//  Copyright © 2020 Vlad Vrublevsky. All rights reserved.
//

import Foundation

func ReadFile(fileURL: URL) -> Data
{
    let textOutput = try! String(contentsOf: fileURL, encoding: .utf8)
    return textOutput.data(using: .utf8, allowLossyConversion: false)!
}

func SaveFile(fileURL: URL, text: String)
{
    do {
        try text.write(to: fileURL, atomically: false, encoding: .utf8)
    }
    catch { print(error) } //TODO Update with error types
}

func Setup(fileURL: URL)
{
    //print (fileURL.deletingLastPathComponent().relativePath )

    do {
        _ = try String(contentsOf: fileURL, encoding: .utf8)
    } catch {

        let text = "{}"

        let manager = FileManager.default

        let folder = fileURL.deletingLastPathComponent().relativePath

        do {
            try manager.createDirectory(atPath: folder, withIntermediateDirectories: true, attributes: nil )
        }
        catch {
            print(error)
        }

        do {
            try text.write(to: fileURL, atomically: false, encoding: .utf8)
        }
        catch { print(error) }
    }
}
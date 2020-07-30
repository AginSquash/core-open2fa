import XCTest
@testable import core_open2fa

final class core_open2faTests: XCTestCase {
    
    func testSetup() {
        let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let url = fileURL.appendingPathComponent("codes_test.data")
        
        XCTAssert( Setup(fileURL: url, pass: "pass") == .SUCCEFULL )
        
        try? FileManager.default.removeItem(at: url)
    }
    
    func testTOTP() {
        XCTAssert( getOTP(code: "q4qghrcn2c42bgbz") != nil )
    }

    func testSaveRead() {
        let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let url = fileURL.appendingPathComponent("codes_test.data")
        
        let testString = "TestString"
        let encoded = try! JSONEncoder().encode(testString)
        _ = SaveFile(fileURL: url, data: encoded)
        XCTAssert( ReadFile(fileURL: url)! == encoded )
    }
    
    func testEncryption() {
        let IV = "abcdefghijklmnop"
        let pass = "pass"
        
        let testString = "TestString"
        
        let encrypted = CryptAES256(key: pass, iv: IV, data: testString.data(using: .utf8)!)
        let decrypted = DecryptAES256(key: pass, iv: IV, data: encrypted!)
        let decryptedString = String(bytes: decrypted!, encoding: .utf8)
        
        XCTAssert( testString == decryptedString )
    }

    let core = CORE_OPEN2FA(fileURL: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("test_file"), password: "pass")
    
    func testCreation() {
        XCTAssert ((try? core.getListOTP()) != nil)
    }
    
    func testAddService() {
        core.AddCode(service_name: "test", code: "q4qghrcn2c42bgbz")
        XCTAssert( core.getListOTP() != [])
    }
    
    func testCheckPasswordCORRECTLY() {
        //core.AddCode(service_name: "test", code: "q4qghrcn2c42bgbz")
        let result = CORE_OPEN2FA.checkPassword(fileURL: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("test_file"), password: "pass")
        print(result)
        XCTAssert(result == .SUCCEFULL)
    }
    
    func testCheckPasswordFAKE() {
        core.AddCode(service_name: "test", code: "q4qghrcn2c42bgbz")
        let result = CORE_OPEN2FA.checkPassword(fileURL: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("test_file"), password: "FAKE_PASS")
        XCTAssert(result != .SUCCEFULL)
    }
    
    func testDeleteService() {
        core.AddCode(service_name: "testDelete", code: "q4qghrcn2c42bgbz")
        let codeID = core.getListOTP().first!.id
        core.DeleteCode(id: codeID)
        XCTAssert( core.getListOTP().first(where: {$0.id == codeID }) == nil)
    }
    
    
    override func tearDown() {
        let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let url = fileURL.appendingPathComponent("test_file")
        try? FileManager.default.removeItem(at: url)
        XCTAssert(FileManager.default.fileExists(atPath: url.absoluteString) != true )
    }
    
    static var allTests = [
        ("testSetup", testSetup),
        ("testTOTP", testTOTP),
        ("testSaveRead", testSaveRead),
        ("testEncryption", testEncryption),
        ("testCreation", testCreation),
        ("testAddService", testAddService),
        ("testCheckPasswordCORRECTLY", testCheckPasswordCORRECTLY),
        ("testCheckPasswordFAKE", testCheckPasswordFAKE),
        ("testDeleteService", testDeleteService),
    ]
}

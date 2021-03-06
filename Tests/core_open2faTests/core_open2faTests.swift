import XCTest
@testable import core_open2fa

final class core_open2faTests: XCTestCase {
    var core = CORE_OPEN2FA(fileURL: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("test_file"), password: "pass")
    
    override func setUp() {
        core = CORE_OPEN2FA(fileURL: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("test_file"), password: "pass")
    }
    
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

    
    func testCreation() {
        XCTAssert ((try? core.getListOTP()) != nil)
    }
    
    func testAddService() {
        core.AddCode(service_name: "test", code: "q4qghrcn2c42bgbz")
        XCTAssert( core.getListOTP() != [])
    }
    
    func testCheckPasswordCORRECTLY() {
        let result = CORE_OPEN2FA.checkPassword(fileURL: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("test_file"), password: "pass")
        XCTAssert(result == .SUCCEFULL)
    }
    
    func testCheckPasswordFAKE() {
        let result = CORE_OPEN2FA.checkPassword(fileURL: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("test_file"), password: "FAKE_PASS")
        XCTAssert(result != .SUCCEFULL)
    }
    
    func testDeleteService() {
        core.AddCode(service_name: "testDelete", code: "q4qghrcn2c42bgbz")
        let codeID = core.getListOTP().first!.id
        core.DeleteCode(id: codeID)
        XCTAssert( core.getListOTP().first(where: {$0.id == codeID }) == nil)
    }
    
    func testSaveInMultiThreading() {
        core.AddCode(service_name: "testDelete", code: "q4qghrcn2c42bgbz")
        usleep(1000000)
        let newcore = CORE_OPEN2FA(fileURL: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("test_file"), password: "pass")
        XCTAssert( newcore.getListOTP().first(where: {$0.name == "testDelete" }) != nil)
    }
    
    func testTypeCastingForLegacyFiles() {
        let uuid = UUID()
        let name = "RandomName"
        let code = "q4qghrcn2c42bgbz"
        let csl = codeSecure_legacy(id: uuid, date: Date(), name: name, code: code)
        let csl_array = [csl, csl, csl]
        let cs: [codeSecure] = csl_array.map({ codeSecure($0) })
        XCTAssert( cs.count == 3)
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
        ("testTypeCastingForLegacyFiles", testTypeCastingForLegacyFiles)
    ]
}

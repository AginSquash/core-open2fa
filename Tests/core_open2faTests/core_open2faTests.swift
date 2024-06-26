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
        XCTAssert( getTOTP(code: "q4qghrcn2c42bgbz") != nil )
    }
    
    func testHOTP() {
        XCTAssert( getHOTP(code: "q4qghrcn2c42bgbz", counter: 0) != nil )
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
        core.AddAccount(account_name: "test", secret: "q4qghrcn2c42bgbz")
        XCTAssert( core.getListOTP() != [])
    }
    
    func testAddAlreadyExistService() {
        core.AddAccount(account_name: "test2", secret: "q4qghrcn2c42bgbz")
        XCTAssert( core.AddAccount(account_name: "test2", secret: "q4qghrcn2c42bgbz") == .ALREADY_EXIST )
    }
    
    func testAddServiceFromUnprotected_accoundData() {
        var core2 = CORE_OPEN2FA(fileURL: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("test_file2"), password: "pass")
        
        
        let newAccount = UNPROTECTED_AccountData(name: "NewAccount1", secret: "q4qghrcn2c42bgbz")
        core2.AddAccount(newAccount: newAccount)
        let isAccountExist = core2.getListOTP().first(where: { $0.name == newAccount.name}) != nil
        XCTAssert(isAccountExist)
    }
    
    func testAddMultipleServiceFromUnprotected_accoundData() {
        var core3 = CORE_OPEN2FA(fileURL: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("test_file3"), password: "pass")
        
        
        let newAccounts = [UNPROTECTED_AccountData(name: "NewAccountM1", secret: "q4qghrcn2c42bgbz"), UNPROTECTED_AccountData(name: "NewAccountM2", secret: "q4qghrcn2c42bgbz")]
        core3.AddMulipleAccounts(newAccounts: newAccounts)
        let isAccountM1Exist = core3.getListOTP().first(where: { $0.name == "NewAccountM1"}) != nil
        let isAccountM2Exist = core3.getListOTP().first(where: { $0.name == "NewAccountM2"}) != nil
        XCTAssert(isAccountM1Exist&&isAccountM2Exist)
    }
    
    func testAddServiceHOTP() {
        core.AddAccount(account_name: "testHOTP", type: .HOTP, secret: "q4qghrcn2c42bgbz", counter: 0)
        print("HOTP: \(core.getListOTP())")
        XCTAssert( core.getListOTP() != [])
    }
    
    func testUpdateHOTP () {
        core.AddAccount(account_name: "testHOTP", type: .HOTP, secret: "q4qghrcn2c42bgbz", counter: 0)
        let service = core.codes.first(where: {$0.type == .HOTP})!
        let result1 = core.updateHOTP(id: service.id)
        let result2 = core.updateHOTP(id: service.id)
        XCTAssert((result1!.codeSingle == "342376")&&(result2!.codeSingle == "527476"))
    }
    
    func testEditService() {
        _ = core.AddAccount(account_name: "testEditService", secret: "q4qghrcn2c42bgbz")
        let codes = core.getListOTP()
        guard let choosenCode = codes.first(where: { $0.name == "testEditService" }) else {
            XCTFail("Cannot find added testEditServiceservice")
            return
        }
        
        _ = core.EditAccount(id: choosenCode.id, newName: "testEditService2", newIssuer: "Issuer2")
        
        let newCodes = core.getListOTP()
        let success = (newCodes.first(where: { $0.name == "testEditService" }) == nil) && (newCodes.first(where: { $0.name == "testEditService2" }) != nil)
        XCTAssert(success)
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
        core.AddAccount(account_name: "testDelete", secret: "q4qghrcn2c42bgbz")
        let codeID = core.getListOTP().first!.id
        core.DeleteAccount(id: codeID)
        XCTAssert( core.getListOTP().first(where: {$0.id == codeID }) == nil)
    }
    
    func testSaveInMultiThreading() {
        core.AddAccount(account_name: "testDelete", secret: "q4qghrcn2c42bgbz")
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
        let cs: [UNPROTECTED_AccountData] = csl_array.map({ UNPROTECTED_AccountData($0) })
        XCTAssert( cs.count == 3)
    }
    
    
    func testLoadNewFileFromData() {
        let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let data = try! Data(contentsOf: fileURL.appendingPathComponent("test_file"))
        
        var core2 = CORE_OPEN2FA(fileURL: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("test_file2"), password: "pass2")
        let data2 = try! Data(contentsOf: fileURL.appendingPathComponent("test_file2"))
        
        XCTAssert( (core.loadNewFileFromData(newData: data2) != .SUCCEFULL) && (core.loadNewFileFromData(newData: data) == .NO_CODES ))
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
        ("testHOTP", testHOTP),
        ("testSaveRead", testSaveRead),
        ("testEncryption", testEncryption),
        ("testCreation", testCreation),
        ("testAddService", testAddService),
        ("testUpdateHOTP", testUpdateHOTP),
        ("testAddServiceHOTP", testAddServiceHOTP),
        ("testCheckPasswordCORRECTLY", testCheckPasswordCORRECTLY),
        ("testCheckPasswordFAKE", testCheckPasswordFAKE),
        ("testDeleteService", testDeleteService),
        ("testTypeCastingForLegacyFiles", testTypeCastingForLegacyFiles)
    ]
}

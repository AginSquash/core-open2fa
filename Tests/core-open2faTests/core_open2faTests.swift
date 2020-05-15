import XCTest
@testable import core_open2fa

final class core_open2faTests: XCTestCase {
    func testSetup() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        //XCTAssertEqual(core_open2fa(), "Hello, World!")
        let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let url = fileURL.appendingPathComponent("codes_test.data")
        XCTAssert( Setup(fileURL: url) == .SUCCEFULL )
    }
    
    func testTOTP() {
        XCTAssert( getOTP(code: "q4qghrcn2c42bgbz") != "Code incorrect" )
    }

    func testSaveRead() {
        let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let url = fileURL.appendingPathComponent("codes_test.data")
        
        let testString = "TestString"
        let encoded = try! JSONEncoder().encode(testString)
        _ = SaveFile(fileURL: url, data: encoded)
        XCTAssert( ReadFile(fileURL: url)! == encoded )
    }
    static var allTests = [
        ("testSetup", testSetup),
        ("testTOTP", testTOTP),
        ("testSaveRead", testSaveRead),
    ]
}

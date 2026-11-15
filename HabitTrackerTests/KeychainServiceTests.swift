import XCTest
@testable import HabitTracker

final class KeychainServiceTests: XCTestCase {
    private let testKey = "com.habittracker.tests.test_api_key"
    
    override func setUp() {
        super.setUp()
        KeychainService.delete(key: testKey)
    }
    
    override func tearDown() {
        KeychainService.delete(key: testKey)
        super.tearDown()
    }
    
    func testSaveAndLoadKey() {
        let saved = KeychainService.save(key: testKey, value: "AIzaSyTestKey12345")
        XCTAssertTrue(saved)
        
        let loaded = KeychainService.load(key: testKey)
        XCTAssertEqual(loaded, "AIzaSyTestKey12345")
    }
    
    func testOverwriteExistingKey() {
        KeychainService.save(key: testKey, value: "OldSecretKey")
        XCTAssertEqual(KeychainService.load(key: testKey), "OldSecretKey")
        
        let overwritten = KeychainService.save(key: testKey, value: "NewSecretKey")
        XCTAssertTrue(overwritten)
        XCTAssertEqual(KeychainService.load(key: testKey), "NewSecretKey")
    }
    
    func testDeleteKey() {
        KeychainService.save(key: testKey, value: "TemporarySecret")
        XCTAssertEqual(KeychainService.load(key: testKey), "TemporarySecret")
        
        let deleted = KeychainService.delete(key: testKey)
        XCTAssertTrue(deleted)
        
        let loaded = KeychainService.load(key: testKey)
        XCTAssertNil(loaded)
    }
    
    func testLoadNonExistentKey_ReturnsNil() {
        let loaded = KeychainService.load(key: "non_existent_key_\(UUID().uuidString)")
        XCTAssertNil(loaded)
    }
    
    func testLegacyUserDefaultsMigration() {
        let legacyKey = "GeminiAPIKey"
        let testToken = "MigratedToken_ABC_987"
        
        // Clean state
        KeychainService.delete(key: "com.habittracker.gemini_api_key")
        UserDefaults.standard.set(testToken, forKey: legacyKey)
        
        // Instantiating GeminiSyncService triggers migration
        let service = GeminiSyncService()
        
        // Assert token is now in Keychain
        XCTAssertEqual(service.storedApiKey, testToken)
        XCTAssertEqual(KeychainService.load(key: "com.habittracker.gemini_api_key"), testToken)
        
        // Assert token was purged from UserDefaults
        XCTAssertNil(UserDefaults.standard.string(forKey: legacyKey))
    }
}

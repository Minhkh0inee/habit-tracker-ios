import XCTest
import AuthenticationServices
import CryptoKit
@testable import HabitTracker

// Mock credential conforming to ASAuthorizationCredential for testing failure paths
@objc(MockInvalidCredential)
final class MockInvalidCredential: NSObject, ASAuthorizationCredential {
    static var supportsSecureCoding: Bool = true
    
    override init() {
        super.init()
    }
    
    required init?(coder: NSCoder) {
        super.init()
    }
    
    func encode(with coder: NSCoder) {}
    
    func copy(with zone: NSZone? = nil) -> Any {
        return self
    }
}

@MainActor
final class SupabaseAuthServiceTests: XCTestCase {
    
    private var service: SupabaseAuthService!
    
    override func setUp() {
        super.setUp()
        // Instantiate isolated instance with startListener: false so no live network calls or background tasks occur
        service = SupabaseAuthService(startListener: false)
    }
    
    override func tearDown() {
        service = nil
        super.tearDown()
    }
    
    // MARK: - Initial State Tests
    func testInitialState_DefaultValues() {
        XCTAssertFalse(service.isAuthenticated)
        XCTAssertNil(service.currentUser)
        XCTAssertFalse(service.isLoading)
        XCTAssertNil(service.errorMessage)
        XCTAssertNil(service.currentNonce)
    }
    
    // MARK: - Nonce Generation Tests
    func testGenerateAppleSignInNonce_SetsCurrentNonce() {
        let hash = service.generateAppleSignInNonce()
        
        XCTAssertFalse(hash.isEmpty)
        XCTAssertNotNil(service.currentNonce)
        // Two UUIDs concatenated without separator produces a 72-character raw nonce
        XCTAssertEqual(service.currentNonce?.count, 72)
    }
    
    func testGenerateAppleSignInNonce_ReturnsValidSHA256Hex() {
        let returnedHash = service.generateAppleSignInNonce()
        guard let rawNonce = service.currentNonce else {
            XCTFail("currentNonce should not be nil after generation")
            return
        }
        
        // SHA-256 produces 32 bytes = 64 hexadecimal characters
        XCTAssertEqual(returnedHash.count, 64)
        
        // Verify all characters are lowercase hexadecimal
        let hexCharacterSet = CharacterSet(charactersIn: "0123456789abcdef")
        XCTAssertTrue(returnedHash.unicodeScalars.allSatisfy { hexCharacterSet.contains($0) })
        
        // Independently calculate SHA256 of rawNonce and compare
        let expectedHash = SHA256.hash(data: Data(rawNonce.utf8)).map {
            String(format: "%02x", $0)
        }.joined()
        
        XCTAssertEqual(returnedHash, expectedHash)
    }
    
    func testGenerateAppleSignInNonce_GeneratesUniqueNoncesEachTime() {
        var rawNonces = Set<String>()
        var hashedNonces = Set<String>()
        let iterations = 20
        
        for _ in 0..<iterations {
            let hash = service.generateAppleSignInNonce()
            if let nonce = service.currentNonce {
                rawNonces.insert(nonce)
            }
            hashedNonces.insert(hash)
        }
        
        XCTAssertEqual(rawNonces.count, iterations, "Every raw nonce must be unique")
        XCTAssertEqual(hashedNonces.count, iterations, "Every hashed nonce must be unique")
    }
    
    // MARK: - Apple Authorization Failure Handling Tests
    func testHandleAppleCredential_WithMissingNonce_ThrowsError() async {
        service.currentNonce = nil
        let mockCredential = MockInvalidCredential()
        
        do {
            try await service.handleAppleCredential(credential: mockCredential)
            XCTFail("handleAppleCredential should throw when nonce is missing")
        } catch {
            let nsError = error as NSError
            XCTAssertEqual(nsError.domain, "SupabaseAuth")
            XCTAssertEqual(nsError.code, -1)
            XCTAssertEqual(nsError.localizedDescription, "Failed to read Apple ID credential or missing nonce.")
            XCTAssertNil(service.currentNonce)
        }
    }
    
    func testHandleAppleCredential_WithNonAppleCredential_ClearsNonceAndThrows() async {
        // Pre-set a nonce
        _ = service.generateAppleSignInNonce()
        XCTAssertNotNil(service.currentNonce)
        
        let mockCredential = MockInvalidCredential()
        
        do {
            try await service.handleAppleCredential(credential: mockCredential)
            XCTFail("handleAppleCredential should throw for non-AppleID credentials")
        } catch {
            let nsError = error as NSError
            XCTAssertEqual(nsError.domain, "SupabaseAuth")
            XCTAssertEqual(nsError.code, -1)
            // Nonce must be cleared on failure
            XCTAssertNil(service.currentNonce)
        }
    }
    
    // MARK: - Sign Out & State Transitions
    func testSignOut_ResetsAuthenticationState() async {
        service.isAuthenticated = true
        
        await service.signOut()
        
        XCTAssertFalse(service.isAuthenticated)
        XCTAssertNil(service.currentUser)
    }
    
    func testErrorMessage_StateManagement() {
        service.errorMessage = "Invalid credentials supplied"
        XCTAssertEqual(service.errorMessage, "Invalid credentials supplied")
        
        service.errorMessage = nil
        XCTAssertNil(service.errorMessage)
    }
}

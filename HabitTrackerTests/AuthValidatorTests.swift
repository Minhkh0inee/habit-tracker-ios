import XCTest
@testable import HabitTracker

final class AuthValidatorTests: XCTestCase {
    
    // MARK: - Email Not Empty Tests
    func testIsEmailNotEmpty_WithValidEmail_ReturnsTrue() {
        XCTAssertTrue(AuthValidator.isEmailNotEmpty("user@example.com"))
        XCTAssertTrue(AuthValidator.isEmailNotEmpty("  user@example.com  "))
    }
    
    func testIsEmailNotEmpty_WithEmptyOrWhitespace_ReturnsFalse() {
        XCTAssertFalse(AuthValidator.isEmailNotEmpty(""))
        XCTAssertFalse(AuthValidator.isEmailNotEmpty("   "))
        XCTAssertFalse(AuthValidator.isEmailNotEmpty("\n\t"))
    }
    
    // MARK: - Email Format Validation Tests
    func testIsValidEmailFormat_WithValidEmails_ReturnsTrue() {
        let validEmails = [
            "test@example.com",
            "first.last@company.org",
            "developer+filter@sub.domain.co",
            "user123@domain.io"
        ]
        
        for email in validEmails {
            XCTAssertTrue(AuthValidator.isValidEmailFormat(email), "Expected \(email) to be valid")
        }
    }
    
    func testIsValidEmailFormat_WithInvalidEmails_ReturnsFalse() {
        let invalidEmails = [
            "",
            "plainaddress",
            "@missingusername.com",
            "user@",
            "user@domain",
            "user@.com",
            "user space@domain.com"
        ]
        
        for email in invalidEmails {
            XCTAssertFalse(AuthValidator.isValidEmailFormat(email), "Expected \(email) to be invalid")
        }
    }
    
    // MARK: - Password Length Tests
    func testIsPasswordValid_WithSixOrMoreCharacters_ReturnsTrue() {
        XCTAssertTrue(AuthValidator.isPasswordValid("123456"))
        XCTAssertTrue(AuthValidator.isPasswordValid("superSecureP@ss123"))
    }
    
    func testIsPasswordValid_WithLessThanSixCharacters_ReturnsFalse() {
        XCTAssertFalse(AuthValidator.isPasswordValid(""))
        XCTAssertFalse(AuthValidator.isPasswordValid("123"))
        XCTAssertFalse(AuthValidator.isPasswordValid("12345"))
    }
    
    // MARK: - Password Matching Tests
    func testDoPasswordsMatch_WhenIdentical_ReturnsTrue() {
        XCTAssertTrue(AuthValidator.doPasswordsMatch(password: "secret123", confirmPassword: "secret123"))
    }
    
    func testDoPasswordsMatch_WhenMismatchedOrEmpty_ReturnsFalse() {
        XCTAssertFalse(AuthValidator.doPasswordsMatch(password: "secret123", confirmPassword: "different123"))
        XCTAssertFalse(AuthValidator.doPasswordsMatch(password: "", confirmPassword: ""))
    }
    
    // MARK: - Composite Sign In Validation Tests
    func testIsSignInValid_WhenValidCredentials_ReturnsTrue() {
        XCTAssertTrue(AuthValidator.isSignInValid(email: "student@school.edu", password: "password123"))
    }
    
    func testIsSignInValid_WhenInvalidCredentials_ReturnsFalse() {
        XCTAssertFalse(AuthValidator.isSignInValid(email: "", password: "password123"))
        XCTAssertFalse(AuthValidator.isSignInValid(email: "student@school.edu", password: "123"))
        XCTAssertFalse(AuthValidator.isSignInValid(email: "   ", password: "123"))
    }
    
    // MARK: - Composite Sign Up Validation Tests
    func testIsSignUpValid_WhenValidAndMatching_ReturnsTrue() {
        XCTAssertTrue(AuthValidator.isSignUpValid(
            email: "newuser@domain.com",
            password: "strongPassword123",
            confirmPassword: "strongPassword123"
        ))
    }
    
    func testIsSignUpValid_WhenPasswordsMismatch_ReturnsFalse() {
        XCTAssertFalse(AuthValidator.isSignUpValid(
            email: "newuser@domain.com",
            password: "strongPassword123",
            confirmPassword: "wrongPassword"
        ))
    }
    
    func testIsSignUpValid_WhenPasswordTooShort_ReturnsFalse() {
        XCTAssertFalse(AuthValidator.isSignUpValid(
            email: "newuser@domain.com",
            password: "123",
            confirmPassword: "123"
        ))
    }
    
    // MARK: - Dynamic Form Mode Validation Tests
    func testIsFormValid_InSignInMode() {
        XCTAssertTrue(AuthValidator.isFormValid(
            email: "test@domain.com",
            password: "validPassword",
            isSignUp: false
        ))
        
        XCTAssertFalse(AuthValidator.isFormValid(
            email: "",
            password: "validPassword",
            isSignUp: false
        ))
    }
    
    func testIsFormValid_InSignUpMode() {
        XCTAssertTrue(AuthValidator.isFormValid(
            email: "test@domain.com",
            password: "validPassword",
            confirmPassword: "validPassword",
            isSignUp: true
        ))
        
        XCTAssertFalse(AuthValidator.isFormValid(
            email: "test@domain.com",
            password: "validPassword",
            confirmPassword: "mismatchedPassword",
            isSignUp: true
        ))
    }
}

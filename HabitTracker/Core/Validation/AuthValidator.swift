//
//  AuthValidator.swift
//  HabitTracker
//
//  Created by Minh Khoi on 19/11/26.
//

import Foundation

// MARK: - AuthValidator
public struct AuthValidator {
    /// Validates if an email string is not empty after stripping whitespace and newlines.
    public static func isEmailNotEmpty(_ email: String) -> Bool {
        return !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    /// Validates standard email format (user@domain.extension).
    public static func isValidEmailFormat(_ email: String) -> Bool {
        let trimmed = email.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return false }
        let regex = #"^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        return trimmed.range(of: regex, options: .regularExpression) != nil
    }

    /// Password must be at least 6 characters.
    public static func isPasswordValid(_ password: String) -> Bool {
        return password.count >= 6
    }

    /// Verifies that the primary password and confirmation password match.
    public static func doPasswordsMatch(password: String, confirmPassword: String) -> Bool {
        return !password.isEmpty && password == confirmPassword
    }

    /// Validates full credentials for the Sign In flow.
    public static func isSignInValid(email: String, password: String) -> Bool {
        return isEmailNotEmpty(email) && isPasswordValid(password)
    }

    /// Validates full credentials for the Sign Up flow.
    public static func isSignUpValid(email: String, password: String, confirmPassword: String) -> Bool {
        return isEmailNotEmpty(email) && isPasswordValid(password) && doPasswordsMatch(password: password, confirmPassword: confirmPassword)
    }

    /// Convenience validator for dynamic toggle form mode.
    public static func isFormValid(email: String, password: String, confirmPassword: String? = nil, isSignUp: Bool) -> Bool {
        if isSignUp {
            return isSignUpValid(email: email, password: password, confirmPassword: confirmPassword ?? "")
        } else {
            return isSignInValid(email: email, password: password)
        }
    }
}

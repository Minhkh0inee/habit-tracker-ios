//
//  SupabaseAuthService.swift
//  HabitTracker
//
//  Created by Minh Khoi on 19/11/26.
//

import Foundation
import Supabase
import AuthenticationServices
import CryptoKit

@MainActor
@Observable
final class SupabaseAuthService {
    static let shared = SupabaseAuthService()

    var currentUser: User? = nil
    var isAuthenticated: Bool = false
    var isLoading: Bool = true
    var errorMessage: String? = nil

    var currentNonce: String? = nil

    private let client: SupabaseClient
    private var authListenerTask: Task<Void, Never>?

    init(client: SupabaseClient = SupabaseClientManager.shared.client, startListener: Bool = true) {
        self.client = client
        if startListener {
            startAuthListener()
        } else {
            self.isLoading = false
        }
    }

    func startAuthListener() {
        authListenerTask?.cancel()
        authListenerTask = Task { [weak self] in
            await self?.listenToAuthChanges()
        }
    }

    func listenToAuthChanges() async {
        // Check initial session
        do {
            let session = try await client.auth.session
            self.currentUser = session.user
            self.isAuthenticated = true
        } catch {
            self.currentUser = nil
            self.isAuthenticated = false
        }
        self.isLoading = false

        // Listen to future state changes
        for await (event, session) in client.auth.authStateChanges {
            guard !Task.isCancelled else { break }
            switch event {
            case .signedIn, .tokenRefreshed:
                self.currentUser = session?.user
                self.isAuthenticated = session != nil
            case .signedOut, .userDeleted:
                self.currentUser = nil
                self.isAuthenticated = false
            default:
                break
            }
        }
    }

    // MARK: - Auth with Email & Password
    func signUp(email: String, password: String) async throws {
        isLoading = true
        defer { isLoading = false }
        errorMessage = nil

        do {
            let response = try await client.auth.signUp(
                email: email,
                password: password
            )
            self.currentUser = response.user
            self.isAuthenticated = (response.session != nil)
        } catch {
            print("❌ [SupabaseAuth] signUp error: \(error)")
            self.errorMessage = error.localizedDescription
            throw error
        }
    }

    func signIn(email: String, password: String) async throws {
        isLoading = true
        defer { isLoading = false }
        errorMessage = nil

        do {
            let session = try await client.auth.signIn(
                email: email,
                password: password
            )
            self.currentUser = session.user
            self.isAuthenticated = true
        } catch {
            print("❌ [SupabaseAuth] signIn error: \(error)")
            self.errorMessage = error.localizedDescription
            throw error
        }
    }

    // MARK: - Auth with Apple
    func generateAppleSignInNonce() -> String {
        let rawNonce = UUID().uuidString + UUID().uuidString
        self.currentNonce = rawNonce

        // Return hashed string for Apple
        let inputData = Data(rawNonce.utf8)
        let hashedData = SHA256.hash(data: inputData)
        return hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()
    }

    func handleAppleAuthorization(_ authorization: ASAuthorization) async throws {
        try await handleAppleCredential(credential: authorization.credential)
    }

    func handleAppleCredential(credential: ASAuthorizationCredential) async throws {
        guard let appleIDCredential = credential as? ASAuthorizationAppleIDCredential,
              let idTokenData = appleIDCredential.identityToken,
              let idTokenString = String(data: idTokenData, encoding: .utf8),
              let rawNonce = self.currentNonce else {
            self.currentNonce = nil
            throw NSError(
                domain: "SupabaseAuth",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Failed to read Apple ID credential or missing nonce."]
            )
        }

        isLoading = true
        defer {
            isLoading = false
            self.currentNonce = nil
        }
        errorMessage = nil

        do {
            let session = try await client.auth.signInWithIdToken(
                credentials: .init(
                    provider: .apple,
                    idToken: idTokenString,
                    nonce: rawNonce
                )
            )
            self.currentUser = session.user
            self.isAuthenticated = true
        } catch {
            print("❌ [SupabaseAuth] signIn error: \(error)")
            self.errorMessage = error.localizedDescription
            throw error
        }
    }

    // MARK: - Sign Out
    func signOut() async {
        isLoading = true
        defer { isLoading = false }

        do {
            try await client.auth.signOut()
            self.currentUser = nil
            self.isAuthenticated = false
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
}

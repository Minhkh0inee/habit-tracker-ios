import SwiftUI
import AuthenticationServices

public struct SignUpView: View {
    @State private var authService = SupabaseAuthService.shared
    
    enum FlowState {
        case options
        case emailForm
    }
    
    struct SnackbarState: Equatable {
        enum Style {
            case success
            case error
        }
        let style: Style
        let message: String
    }
    
    @State private var flowState: FlowState = .options
    @State private var isSignUpMode: Bool = true
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    
    // Snackbar & Feedback state
    @State private var snackbar: SnackbarState? = nil
    @State private var snackbarDismissTask: Task<Void, Never>? = nil
    
    private let brandBackground = Color("LaunchBackground")
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            ZStack {
                brandBackground
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Top Navigation Bar (Back button when in email form)
                    HStack {
                        if flowState == .emailForm {
                            Button {
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                    flowState = .options
                                    clearSnackbar()
                                }
                            } label: {
                                HStack(spacing: 6) {
                                    Image(systemName: "chevron.left")
                                        .font(.system(size: 16, weight: .semibold))
                                    Text("Back")
                                        .font(.system(size: 16, weight: .medium))
                                }
                                .foregroundStyle(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(Color.white.opacity(0.12))
                                .clipShape(Capsule())
                            }
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                    .frame(height: 44)
                    
                    Spacer()
                    
                    // Main Content Animated Transition
                    if flowState == .options {
                        optionsView
                            .transition(.asymmetric(
                                insertion: .opacity.combined(with: .scale(scale: 0.95)),
                                removal: .opacity.combined(with: .scale(scale: 1.05))
                            ))
                    } else {
                        emailFormView
                            .transition(.asymmetric(
                                insertion: .opacity.combined(with: .move(edge: .trailing)),
                                removal: .opacity.combined(with: .move(edge: .trailing))
                            ))
                    }
                    
                    Spacer()
                    
                    // Footer (Switch between Sign Up & Sign In)
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            isSignUpMode.toggle()
                            clearSnackbar()
                        }
                    } label: {
                        Text(isSignUpMode ? "Already have an account? **Sign In**" : "Don't have an account? **Create one**")
                            .font(.footnote)
                            .foregroundStyle(.white.opacity(0.9))
                    }
                    .padding(.bottom, 24)
                }
                
                // MARK: - Floating Snackbar (Top of Screen)
                if let snackbar = snackbar {
                    VStack {
                        snackbarView(for: snackbar)
                            .padding(.horizontal, 18)
                            .padding(.top, 8)
                            .transition(.move(edge: .top).combined(with: .opacity))
                        Spacer()
                    }
                    .zIndex(10)
                }
                
                // MARK: - Fullscreen Loading Overlay
                if authService.isLoading {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                        .transition(.opacity)
                    
                    VStack(spacing: 16) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(1.3)
                        
                        Text(isSignUpMode ? "Creating your account..." : "Signing you in...")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(.white)
                    }
                    .padding(24)
                    .background(Color.white.opacity(0.15))
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .shadow(color: .black.opacity(0.2), radius: 20, y: 10)
                    .zIndex(20)
                    .transition(.scale(scale: 0.9).combined(with: .opacity))
                }
            }
            .animation(.spring(response: 0.35, dampingFraction: 0.8), value: snackbar)
            .animation(.easeInOut(duration: 0.25), value: authService.isLoading)
        }
    }
    
    // MARK: - View 1: Initial Options (Apple or Email)
    @ViewBuilder
    private var optionsView: some View {
        VStack(spacing: 32) {
            // App Branding
            VStack(spacing: 12) {
                Image("AppLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 96, height: 96)
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                
                Text("Habit Tracker")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                
                Text(isSignUpMode ? "Build habits, master concepts, and track your streak." : "Welcome back! Sign in to continue.")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.75))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            
            // Action Buttons
            VStack(spacing: 14) {
                // 1. Sign in with Apple Button
                SignInWithAppleButton(isSignUpMode ? .signUp : .signIn) { request in
                    clearSnackbar()
                    let hashedNonce = authService.generateAppleSignInNonce()
                    request.requestedScopes = [.fullName, .email]
                    request.nonce = hashedNonce
                } onCompletion: { result in
                    switch result {
                    case .success(let authorization):
                        Task {
                            do {
                                try await authService.handleAppleAuthorization(authorization)
                                showSnackbar(style: .success, message: "Signed in with Apple!")
                            } catch {
                                showSnackbar(style: .error, message: error.localizedDescription)
                            }
                        }
                    case .failure(let error):
                        showSnackbar(style: .error, message: error.localizedDescription)
                    }
                }
                .signInWithAppleButtonStyle(.white)
                .frame(height: 52)
                .cornerRadius(14)
                
                // 2. Continue with Email Button
                Button {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                        clearSnackbar()
                        flowState = .emailForm
                    }
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "envelope.fill")
                            .font(.system(size: 17))
                        Text(isSignUpMode ? "Sign up with Email" : "Sign in with Email")
                            .font(.system(size: 17, weight: .semibold))
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(Color.white.opacity(0.12))
                    .foregroundStyle(.white)
                    .cornerRadius(14)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color.white.opacity(0.25), lineWidth: 1)
                    )
                }
            }
            .padding(.horizontal, 28)
        }
    }
    
    // MARK: - View 2: Email & Password Input Form
    @ViewBuilder
    private var emailFormView: some View {
        VStack(spacing: 24) {
            // Header
            VStack(spacing: 8) {
                Text(isSignUpMode ? "Create Account" : "Sign In")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                
                Text(isSignUpMode ? "Enter your email and a secure password" : "Enter your email and password to log in")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.7))
            }
            
            // Inputs
            VStack(spacing: 14) {
                TextField("", text: $email, prompt: Text("Email address").foregroundStyle(.white.opacity(0.5)))
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .foregroundStyle(.white)
                    .padding()
                    .background(Color.white.opacity(0.12))
                    .cornerRadius(14)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
                
                SecureField("", text: $password, prompt: Text("Password (min 6 characters)").foregroundStyle(.white.opacity(0.5)))
                    .foregroundStyle(.white)
                    .padding()
                    .background(Color.white.opacity(0.12))
                    .cornerRadius(14)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
                
                if isSignUpMode {
                    SecureField("", text: $confirmPassword, prompt: Text("Confirm Password").foregroundStyle(.white.opacity(0.5)))
                        .foregroundStyle(.white)
                        .padding()
                        .background(Color.white.opacity(0.12))
                        .cornerRadius(14)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                }
                
                // Submit Button
                Button {
                    Task {
                        await handleSubmit()
                    }
                } label: {
                    HStack {
                        if authService.isLoading {
                            ProgressView()
                                .tint(brandBackground)
                        } else {
                            Text(isSignUpMode ? "Create Account" : "Sign In")
                                .font(.system(size: 17, weight: .semibold))
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(Color.white)
                    .foregroundStyle(brandBackground)
                    .cornerRadius(14)
                }
                .disabled(!isFormValid || authService.isLoading)
                .opacity(isFormValid ? 1.0 : 0.6)
            }
            .padding(.horizontal, 28)
        }
    }
    
    // MARK: - Snackbar Component
    @ViewBuilder
    private func snackbarView(for snackbar: SnackbarState) -> some View {
        HStack(spacing: 12) {
            Image(systemName: snackbar.style == .success ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(snackbar.style == .success ? Color.green : Color.red)
            
            Text(snackbar.message)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.white)
                .lineLimit(2)
            
            Spacer(minLength: 4)
            
            Button {
                clearSnackbar()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(.white.opacity(0.6))
                    .padding(6)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            snackbar.style == .success
            ? Color.green.opacity(0.22)
            : Color.red.opacity(0.25)
        )
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(
                    snackbar.style == .success ? Color.green.opacity(0.4) : Color.red.opacity(0.4),
                    lineWidth: 1
                )
        )
        .shadow(color: .black.opacity(0.2), radius: 10, y: 5)
        .onTapGesture {
            clearSnackbar()
        }
    }
    
    private func showSnackbar(style: SnackbarState.Style, message: String) {
        let generator = UINotificationFeedbackGenerator()
        if style == .success {
            generator.notificationOccurred(.success)
        } else {
            generator.notificationOccurred(.error)
        }
        
        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
            self.snackbar = SnackbarState(style: style, message: message)
        }
        
        snackbarDismissTask?.cancel()
        snackbarDismissTask = Task {
            try? await Task.sleep(nanoseconds: 4_500_000_000)
            if !Task.isCancelled {
                await MainActor.run {
                    clearSnackbar()
                }
            }
        }
    }
    
    private func clearSnackbar() {
        snackbarDismissTask?.cancel()
        snackbarDismissTask = nil
        withAnimation(.easeOut(duration: 0.2)) {
            self.snackbar = nil
        }
    }
    
    private var isFormValid: Bool {
        AuthValidator.isFormValid(
            email: email,
            password: password,
            confirmPassword: confirmPassword,
            isSignUp: isSignUpMode
        )
    }
    
    private func handleSubmit() async {
        clearSnackbar()
        
        if isSignUpMode && password != confirmPassword {
            showSnackbar(style: .error, message: "Passwords do not match.")
            return
        }
        
        do {
            if isSignUpMode {
                try await authService.signUp(email: email.trimmingCharacters(in: .whitespaces), password: password)
                showSnackbar(style: .success, message: "Account created successfully!")
            } else {
                try await authService.signIn(email: email.trimmingCharacters(in: .whitespaces), password: password)
                showSnackbar(style: .success, message: "Welcome back! Signed in.")
            }
        } catch {
            showSnackbar(style: .error, message: error.localizedDescription)
        }
    }
}

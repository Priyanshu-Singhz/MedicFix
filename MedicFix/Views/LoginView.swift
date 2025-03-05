//
//  LoginView.swift
//  MedicFix
//
//  Created by Priyanshu Singh on 21/02/25.
//

import SwiftUI
import FirebaseAuth

struct LoginView: View {
    @StateObject private var authManager = AuthManager()
    @State private var email = ""
    @State private var password = ""
    @State private var isLoginMode = true
    @State private var animateGradient = false
    @State private var showPassword = false
    @FocusState private var focusedField: Field?
    
    // Validation Messages
    @State private var passwordError: String?
    
    enum Field {
        case email, password
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Animated Background
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(#colorLiteral(red: 0.239, green: 0.674, blue: 0.968, alpha: 1)),
                        Color(#colorLiteral(red: 0.219, green: 0.007, blue: 0.854, alpha: 1))
                    ]),
                    startPoint: animateGradient ? .topLeading : .bottomLeading,
                    endPoint: animateGradient ? .bottomTrailing : .topTrailing
                )
                .ignoresSafeArea()
                .onAppear {
                    withAnimation(.linear(duration: 5.0).repeatForever(autoreverses: true)) {
                        animateGradient.toggle()
                    }
                }
                
                ScrollView {
                    VStack(spacing: 15) {
                        Image(uiImage: UIImage(named: "playstore")!)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 120, height: 120)
                            .clipShape(Circle()) // Clips the image into a circle
                            .overlay(
                                Circle()
                                    .stroke(Color.white.opacity(0.8), lineWidth: 5) // Optional border effect
                            )
                            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                    
                        
                        Text("MedicFix")
                            .font(.system(size: 38, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        
                        Text(isLoginMode ? "Welcome back" : "Create your account")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                        
                        VStack(spacing: 20) {
                            // Email Field
                            // Email Field
                            CustomInputField(
                                title: "Email",
                                text: $email,
                                icon: "envelope.fill",
                                placeholder: "Enter your email",
                                isSecure: false,
                                keyboardType: .emailAddress,
                                focusedField: $focusedField, // ✅ Pass Binding
                                currentField: .email
                            )

                            // Password Field
                            VStack(alignment: .leading, spacing: 8) {
                                // Password Field
                                ZStack{
                                    CustomInputField(
                                        title: "Password",
                                        text: $password,
                                        icon: "lock.fill",
                                        placeholder: "Enter your password",
                                        isSecure: !showPassword,
                                        focusedField: $focusedField, // ✅ Pass Binding
                                        currentField: .password
                                    )
                                    // Toggle Password Visibility
                                    Button(action: { showPassword.toggle() }) {
                                        HStack {
                                            Spacer()
                                            Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                                                .foregroundColor(.white.opacity(0.7))
                                        }
                                        .padding(.trailing, 10)
                                        .padding(.top, 25)
                                        
                                    }
                                }
                                
                               
                                
                                // Password Validation Messages
                                if let error = passwordError {
                                    Text(error)
                                        .font(.caption)
                                        .foregroundColor(.red)
                                }
                            }
                            .onChange(of: password) { _ in
                                validatePassword()
                            }
                            
                            // Forgot Password
                            if isLoginMode {
                                HStack {
                                    Spacer()
                                    Button(action: {
                                        // Implement Forgot Password logic
                                    }) {
                                        Text("Forgot Password?")
                                            .font(.subheadline)
                                            .foregroundColor(.white.opacity(0.8))
                                    }
                                }
                            }
                        }
                        
                        // Display API Call Errors
                        if !authManager.errorMessage.isEmpty {
                            Text(authManager.errorMessage)
                                .foregroundColor(.red)
                                .font(.caption)
                                .padding()
                                .background(RoundedRectangle(cornerRadius: 8).fill(Color.red.opacity(0.3)))
                                .transition(.scale.combined(with: .opacity))
                        }
                        
                        // Login/Register Button
                        Button(action: {
                            if isLoginMode {
                                if validateInputs() {
                                    authManager.login(email: email, password: password) { errorMessage in
                                        authManager.errorMessage = "Invalid username or password"
                                    }
                                }
                            } else {
                                if validateInputs() {
                                    authManager.register(email: email, password: password) { errorMessage in
                                        authManager.errorMessage = errorMessage ?? ""
                                    }
                                }
                            }
                        }) {
                            Text(isLoginMode ? "Login" : "Create Account")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.orange)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                        .disabled(authManager.isLoading)
                        
                        // Toggle Login/Register
                        HStack {
                            Text(isLoginMode ? "Don't have an account?" : "Already have an account?")
                                .foregroundColor(.white.opacity(0.7))
                            
                            Button(action: { isLoginMode.toggle() }) {
                                Text(isLoginMode ? "Sign Up" : "Login")
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            }
                        }
                    }
                    .padding()
                }
            }
        }
    }
    
    // MARK: - Validation Functions
    
    private func validatePassword() {
        let regex = #"^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[@$!%*?&#])[A-Za-z\d@$!%*?&#]{8,}$"#
        if password.isEmpty {
            passwordError = "Password cannot be empty"
        } else if !NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: password) {
            passwordError = "Password must be at least 8 characters, contain 1 uppercase, 1 lowercase, 1 digit, and 1 special character."
        } else {
            passwordError = nil
        }
    }
    
    private func validateInputs() -> Bool {
        validatePassword()
        return passwordError == nil
    }
}

// MARK: - Custom Input Field Component
struct CustomInputField: View {
    var title: String
    @Binding var text: String
    var icon: String
    var placeholder: String
    var isSecure: Bool
    var keyboardType: UIKeyboardType = .default
    var focusedField: FocusState<LoginView.Field?>.Binding // ✅ Use .Binding
    var currentField: LoginView.Field

    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.white)

            HStack {
                Image(systemName: icon)
                    .foregroundColor(.white.opacity(0.7))

                if isSecure {
                    SecureField("", text: $text)
                        .placeholder(when: text.isEmpty) {
                            Text(placeholder).foregroundColor(.white.opacity(0.5))
                        }
                        .foregroundColor(.white)
                        .keyboardType(keyboardType)
                        .focused(focusedField, equals: currentField) // ✅ Use Binding
                } else {
                    TextField("", text: $text)
                        .placeholder(when: text.isEmpty) {
                            Text(placeholder).foregroundColor(.white.opacity(0.5))
                        }
                        .foregroundColor(.white)
                        .keyboardType(keyboardType)
                        .focused(focusedField, equals: currentField) // ✅ Use Binding
                }
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 12).fill(Color.white.opacity(0.15)))
        }
    }
}

// Helper extension for placeholder text
extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}

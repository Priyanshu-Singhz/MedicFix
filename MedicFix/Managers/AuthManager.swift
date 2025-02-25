//
//  AuthManager.swift
//  MedicFix
//
//  Created by Zignuts Technolab on 21/02/25.
//

import Foundation
import SwiftUI
import FirebaseAuth

class AuthManager: ObservableObject {
    @Published var isLoggedIn: Bool
    @Published var isLoading: Bool = false
    @Published var errorMessage: String = ""
    @Published var currentUser: User?
    
    init() {
        self.isLoggedIn = Auth.auth().currentUser != nil
        self.currentUser = Auth.auth().currentUser
        
        // Setup auth state listener to keep track of auth changes
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            DispatchQueue.main.async {
                self?.isLoggedIn = user != nil
                self?.currentUser = user
            }
        }
    }
    
    func login(email: String, password: String, completion: ((String?) -> Void)? = nil) {
        guard !email.isEmpty, !password.isEmpty else {
            self.errorMessage = "Please enter email and password"
            completion?("Please enter email and password") // Pass the error message
            return
        }

        self.isLoading = true
        self.errorMessage = ""

        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                print("📡 Firebase Auth response received")

                if let error = error {
                    self?.errorMessage = error.localizedDescription
                    print("❌ Firebase Auth Error: \(error.localizedDescription)")
                    completion?(error.localizedDescription) // Pass the error to the caller
                } else {
                    self?.isLoggedIn = true
                    self?.currentUser = result?.user
                    print("✅ Login successful! User: \(result?.user.uid ?? "Unknown UID")")
                    completion?(nil) // No error
                }
            }
        }
    }

    
    func register(email: String, password: String, completion: ((String?) -> Void)? = nil) {
        guard !email.isEmpty, !password.isEmpty else {
            self.errorMessage = "Please enter email and password"
            completion?("Please enter email and password") // Pass error message to completion
            return
        }

        self.isLoading = true
        self.errorMessage = ""

        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            DispatchQueue.main.async {
                self?.isLoading = false

                if let error = error {
                    self?.errorMessage = error.localizedDescription
                    print("❌ Firebase Registration Error: \(error.localizedDescription)")
                    completion?(error.localizedDescription) // Pass error message to completion
                } else {
                    self?.isLoggedIn = true
                    self?.currentUser = result?.user
                    print("✅ Registration successful! User: \(result?.user.uid ?? "Unknown UID")")
                    completion?(nil) // No error
                }
            }
        }
    }

    
    func signOut() {
        do {
            try Auth.auth().signOut()
            self.isLoggedIn = false
            self.currentUser = nil
        } catch {
            self.errorMessage = "Error signing out: \(error.localizedDescription)"
            print("❌ Sign out error: \(error.localizedDescription)")
        }
    }
}

//
//  Auth.swift
//  ToDoSwift
//
//  Created by José Adrián Fernández Méndez on 23/02/25.
//

import Foundation

func signUp(email: String, password: String) async throws {
    let authResponse = try await supabase.auth.signUp(
        email: email,
        password: password
    )
    
    print("Successfully signed up user: \(authResponse.user.id)")
}

func login(email: String, password: String) async throws -> Bool {
    let authResponse = try await supabase.auth.signIn(
        email: email,
        password: password
    )
    
    print("Successfully logged in user: \(authResponse.user.id)")
    return true
}

class AuthViewModel: ObservableObject {
    @Published var isLoggedIn: Bool = false

    init() {
        checkUserLoginStatus()
        
        // Listen for auth changes
        Task {
            for await _ in supabase.auth.authStateChanges {
                await MainActor.run {
                    self.isLoggedIn = supabase.auth.currentUser != nil
                }
            }
        }
    }
    
    func checkUserLoginStatus() {
        isLoggedIn = supabase.auth.currentUser != nil
    }
}

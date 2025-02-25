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

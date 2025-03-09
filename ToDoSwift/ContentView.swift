//
//  ContentView.swift
//  ToDoSwift
//
//  Created by José Adrián Fernández Méndez on 21/02/25.
//
import SwiftUI
import Supabase

struct ContentView: View {
    @StateObject private var authViewModel = AuthViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                if authViewModel.isLoggedIn {
                    SelectViews()
                } else {
                    LoginView()
                }
            }
        }
    }
}

#Preview {
    ContentView()
}

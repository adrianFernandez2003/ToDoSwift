//
//  ContentView.swift
//  ToDoSwift
//
//  Created by José Adrián Fernández Méndez on 21/02/25.
//
import SwiftUI
import Supabase

struct ContentView: View {
    @State private var selectedTab: Tab = .house
    @State private var isLoggedIn: Bool = false
    
    init() {
        checkUserLoginStatus()
        
        UITabBar.appearance().isHidden = true
    }
    
    func checkUserLoginStatus() {
        isLoggedIn = supabase.auth.currentUser != nil
    }
    
    var body: some View {
        ZStack {
            if isLoggedIn {
                VStack {
                    if selectedTab == .house {
                        HomeView()
                    }
                    if selectedTab == .clipboard {
                        RoutinesView()
                    }
                    if selectedTab == .plus {
                        CreateRoutineView()
                    }
                    if selectedTab == .map {
                        LocationsView()
                    }
                    if selectedTab == .person {
                        ProfileView()
                    }
                }
                
                VStack {
                    Spacer()
                    CustomTabBar(selectedTab: $selectedTab)
                }
            } else {
                LoginView()
            }
        }
        .onAppear {
            checkUserLoginStatus()
        }
    }
}

#Preview {
    ContentView()
}

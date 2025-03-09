//
//  SelectViews.swift
//  ToDoSwift
//
//  Created by José Adrián Fernández Méndez on 09/03/25.
//

import SwiftUI

struct SelectViews: View {
    @State private var selectedTab: Tab = .house
    @State private var isLoggedIn: Bool = false
    var body: some View {
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
    }
}

#Preview {
    SelectViews()
}

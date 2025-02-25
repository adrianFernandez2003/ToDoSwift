//
//  HomeView.swift
//  ToDoSwift
//
//  Created by José Adrián Fernández Méndez on 21/02/25.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        VStack {
            VStack {
                VStack(alignment: .center){
                    Text("Siguiente actividad")
                        .font(.largeTitle)
                        .foregroundStyle( Color("TextColor"))
                        .bold()
                    Text("Caminar en el parque - 10:30A.M.")
                        .font(.headline)
                        .foregroundStyle( Color("TextColor"))
                    HStack {
                        Text("¡Llevas 10 días seguidos!")
                            .foregroundStyle( Color("StreakColor"))
                        Image(systemName: "flame.fill")
                            .foregroundStyle(Color("StreakColor"))
                    }
                    
                }
                .padding(.top)
                .padding(.bottom)
            }
            VStack {
                ZStack {
                    Rectangle()
                        .fill(Color("PrimaryColor"))
                        .cornerRadius(35)
                        .ignoresSafeArea(.all, edges: .bottom)
                    ScrollView {
                        RoutineList()
                        Grid {
                            GridRow {
                                Card(title: .constant("Ultima ubicacion"), description: .constant("Parque la choca"))
                                Card(title: .constant("Logros y recompensas"), description: .constant("Parque la choca"))
                            }
                        }
                        .padding(.bottom, 10)
                        Card(title: .constant("Racha general"), description: .constant("hola"))
    
                    }
                    .scrollIndicators(.hidden)
                    .padding()
                }
            }
        }
        .background(Color("SecondaryColor"))
        
    }
}

#Preview {
    HomeView()
}

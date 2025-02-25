//
//  RoutinesView.swift
//  ToDoSwift
//
//  Created by José Adrián Fernández Méndez on 21/02/25.
//

import SwiftUI

struct RoutinesView: View {
    @State private var routines: [Routine] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var selectedRoutine: Routine?

    var body: some View {
        NavigationStack {
            ZStack {
                Color("PrimaryColor").ignoresSafeArea()
                
                VStack(spacing: 0) {
                    Text("Rutinas")
                        .font(.title)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color("PrimaryColor"))
                    
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(1.5)
                            .padding()
                    } else if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .padding()
                    } else {
                        ScrollView {
                            VStack {
                                ForEach(routines, id: \.id) { routine in
                                    RoutineItem(
                                        title: .constant(routine.name),
                                        description: .constant(routine.description),
                                        icon: .constant(routine.icon),
                                        onTap: { selectedRoutine = routine }
                                    )
                                    .padding(.vertical, 3)
                                    Spacer()
                                }
                            }
                            .padding()
                        }
                    }
                }
            }
            .onAppear {
                loadRoutines()
            }
            .navigationDestination(item: $selectedRoutine) { routine in
                SingleRoutineView(routine: routine)
            }
        }
    }
    
    private func loadRoutines() {
        Task {
            do {
                routines = try await fetchRoutines()
                isLoading = false
            } catch {
                errorMessage = error.localizedDescription
                isLoading = false
            }
        }
    }
}

#Preview {
    RoutinesView()
}

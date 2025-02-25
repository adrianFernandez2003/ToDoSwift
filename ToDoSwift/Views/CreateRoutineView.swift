//
//  CreateRoutineView.swift
//  ToDoSwift
//
//  Created by José Adrián Fernández Méndez on 21/02/25.
//

import SwiftUI

struct CreateRoutineView: View {
    @State private var routineName: String = "Test Routine"
    @State private var routineDescription: String = "This is a test routine"
    @State private var selectedIcon: SFIcons = .house // Default icon
    @State private var showIconPicker = false
    @State private var showSuccessAlert = false
    @State private var errorMessage: String?
    
    var body: some View {
        ZStack {
            Color("PrimaryColor").ignoresSafeArea(.all)
            
            ScrollView {
                VStack(spacing: 20) {
                    Text("Create Routine")
                        .font(.largeTitle)
                        .bold()
                    
                    TextField("Name", text: $routineName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                    
                    TextField("Description", text: $routineDescription)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                    
                    // Icon Selection Button
                    Button(action: {
                        showIconPicker.toggle()
                    }) {
                        HStack {
                            Image(systemName: selectedIcon.rawValue)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 30, height: 30)
                                .foregroundColor(.blue)
                            
                            Text("Select Icon")
                                .foregroundColor(.blue)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    
                    // Submit Button
                    Button(action: {
                        createRoutine()
                    }) {
                        Text("Create Routine")
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                }
                .padding()
            }
        }
        .alert("Routine Created!", isPresented: $showSuccessAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Your routine has been created successfully.")
        }
        .alert("Error", isPresented: Binding<Bool>(
            get: { errorMessage != nil },
            set: { _ in errorMessage = nil }
        )) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage ?? "An unknown error occurred.")
        }
        .sheet(isPresented: $showIconPicker) {
            IconPicker(selectedIcon: $selectedIcon)
        }
    }
    
    private func createRoutine() {
        guard !routineName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              !routineDescription.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            errorMessage = "Name and description cannot be empty."
            return
        }
        
        Task {
            do {
                let success = try await RoutineService.createRoutine(
                    name: routineName,
                    description: routineDescription,
                    icon: selectedIcon.rawValue
                )
                showSuccessAlert = success
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
}

#Preview {
    CreateRoutineView()
}

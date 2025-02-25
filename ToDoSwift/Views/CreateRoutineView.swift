//
//  CreateRoutineView.swift
//  ToDoSwift
//
//  Created by José Adrián Fernández Méndez on 21/02/25.
//

import SwiftUI

struct CreateRoutineView: View {
    @State private var routineName: String = "Rutina de prueba"
    @State private var routineDescription: String = "Esta es una rutina de prueba"
    @State private var selectedIcon: SFIcons = .house // Icono predeterminado
    @State private var showIconPicker = false
    @State private var showSuccessAlert = false
    @State private var errorMessage: String?
    
    var body: some View {
        ZStack {
            Color("PrimaryColor").ignoresSafeArea(.all)
            
            ScrollView {
                VStack(spacing: 20) {
                    Text("Crear Rutina")
                        .font(.largeTitle)
                        .bold()
                    
                    TextField("Nombre", text: $routineName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                    
                    TextField("Descripción", text: $routineDescription)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                    
                    // Botón para seleccionar icono
                    Button(action: {
                        showIconPicker.toggle()
                    }) {
                        HStack {
                            Image(systemName: selectedIcon.rawValue)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 30, height: 30)
                                .foregroundColor(.blue)
                            
                            Text("Seleccionar Icono")
                                .foregroundColor(.blue)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    
                    // Botón de enviar
                    Button(action: {
                        createRoutine()
                    }) {
                        Text("Crear Rutina")
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
        .alert("¡Rutina Creada!", isPresented: $showSuccessAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Tu rutina ha sido creada con éxito.")
        }
        .alert("Error", isPresented: Binding<Bool>(
            get: { errorMessage != nil },
            set: { _ in errorMessage = nil }
        )) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage ?? "Ocurrió un error desconocido.")
        }
        .sheet(isPresented: $showIconPicker) {
            IconPicker(selectedIcon: $selectedIcon)
        }
    }
    
    private func createRoutine() {
        guard !routineName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              !routineDescription.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            errorMessage = "El nombre y la descripción no pueden estar vacíos."
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

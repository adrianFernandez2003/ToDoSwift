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
    @State private var selectedLocation: LocationBasic?
    @State private var locations: [LocationBasic] = []
    @State private var showLocationPicker = false
    
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
                    
                    // Location Selection Button
                    Button(action: {
                        Task {
                            do {
                                locations = try await fetchLocationsBasic()
                                showLocationPicker = true
                            } catch {
                                errorMessage = error.localizedDescription
                            }
                        }
                    }) {
                        HStack {
                            Image(systemName: "mappin.circle.fill")
                            Text(selectedLocation?.name ?? "Seleccionar ubicación")
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
            Button("OK", role: .cancel) {
                clearForm()
            }
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
        .sheet(isPresented: $showLocationPicker) {
            NavigationView {
                List(locations) { location in
                    Button(action: {
                        selectedLocation = location
                        showLocationPicker = false
                    }) {
                        Text(location.name)
                            .foregroundColor(selectedLocation?.id == location.id ? .blue : .primary)
                    }
                }
                .navigationTitle("Seleccionar ubicación")
                .navigationBarItems(trailing: Button("Cerrar") {
                    showLocationPicker = false
                })
            }
        }
        .onAppear {
            Task {
                do {
                    locations = try await fetchLocationsBasic()
                } catch {
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    private func clearForm() {
        routineName = ""
        routineDescription = ""
        selectedIcon = .house
        selectedLocation = nil
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
                    icon: selectedIcon.rawValue,
                    locationId: selectedLocation?.id
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

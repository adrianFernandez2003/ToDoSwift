//
//  SingleRoutineView.swift
//  ToDoSwift
//
//  Created by José Adrián Fernández Méndez on 24/02/25.
//

import SwiftUI

struct SingleRoutineView: View {
    @State private var routineName: String
    @State private var routineDescription: String
    @State private var selectedIcon: SFIcons = .house
    @State private var showIconPicker = false
    @State private var showSuccessAlert = false
    @State private var errorMessage: String?
    @State private var isSaving = false
    @State private var showDeleteAlert = false
    @State private var isDeleting = false
    @State private var showCreateSchedule = false
    @Environment(\.dismiss) private var dismiss
    
    let routine: Routine
    
    init(routine: Routine) {
        self.routine = routine
        _routineName = State(initialValue: routine.name)
        _routineDescription = State(initialValue: routine.description)
        _selectedIcon = State(initialValue: SFIcons(rawValue: routine.icon) ?? .house)
    }
    
    var body: some View {
        ZStack {
            Color("PrimaryColor").ignoresSafeArea(.all)
            
            ScrollView {
                VStack(spacing: 20) {
                    Text("Editar rutina")
                        .font(.largeTitle)
                        .bold()
                    
                    TextField("Nombre", text: $routineName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                    
                    TextField("Descripción", text: $routineDescription)
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
                            
                            Text("Seleccionar icono")
                                .foregroundColor(.blue)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    
                    // Schedule Button
                    Button(action: {
                        showCreateSchedule.toggle()
                    }) {
                        Text("Gestionar horario")
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                    .background(Color.green)
                    .cornerRadius(10)
                    .padding(.horizontal)
                    
                    // Submit Button
                    Button(action: {
                        Task {
                            await saveChanges()
                        }
                    }) {
                        if isSaving {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("Guardar cambios")
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                        }
                    }
                    .background(Color.blue)
                    .cornerRadius(10)
                    .padding(.horizontal)
                    .disabled(isSaving)
                    
                    // Delete Button
                    Button(action: {
                        showDeleteAlert = true
                    }) {
                        if isDeleting {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("Eliminar rutina")
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                        }
                    }
                    .background(Color.red)
                    .cornerRadius(10)
                    .padding(.horizontal)
                    .disabled(isDeleting)
                }
                .padding()
            }
        }
        .navigationTitle("Editar rutina")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Éxito", isPresented: $showSuccessAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("¡Rutina actualizada con éxito!")
        }
        .alert("Eliminar rutina", isPresented: $showDeleteAlert) {
            Button("Cancelar", role: .cancel) { }
            Button("Eliminar", role: .destructive) {
                Task {
                    await deleteRoutineAction()
                }
            }
        } message: {
            Text("¿Estás seguro de que deseas eliminar esta rutina?")
        }
        .sheet(isPresented: $showIconPicker) {
            IconPicker(selectedIcon: $selectedIcon)
        }
        .sheet(isPresented: $showCreateSchedule) {
            if let id = routine.id {
                CreateSchedule(routineId: id)
            }
        }
    }
    
    private func saveChanges() async {
        guard let id = routine.id else { return }
        
        isSaving = true
        do {
            let success = try await updateRoutine(
                id: id,
                name: routineName,
                description: routineDescription,
                icon: selectedIcon.rawValue
            )
            
            if success {
                showSuccessAlert = true
            } else {
                errorMessage = "Error al actualizar la rutina"
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        isSaving = false
    }
    
    private func deleteRoutineAction() async {
        guard let id = routine.id else { return }
        isDeleting = true
        do {
            let success = try await deleteRoutine(id: id)
            if success {
                dismiss()
            }
        } catch {
            dismiss()
        }
        isDeleting = false
    }
}

#Preview {
    SingleRoutineView(
        routine: Routine(id: 1, name: "Mi Rutina", description: "Una rutina de ejemplo", icon: "house", id_user: UUID(), streak: 1)
    )
}

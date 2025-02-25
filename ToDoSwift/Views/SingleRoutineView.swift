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
                    Text("Edit Routine")
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
                    
                    // Schedule Button
                    Button(action: {
                        showCreateSchedule.toggle()
                    }) {
                        Text("Manage Schedule")
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
                            Text("Save Changes")
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
                            Text("Delete Routine")
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
        .alert("Success", isPresented: $showSuccessAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Routine updated successfully!")
        }
        .alert("Delete Routine", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                Task {
                    await deleteRoutineAction()
                }
            }
        } message: {
            Text("Are you sure you want to delete this routine?")
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
                errorMessage = "Failed to update routine"
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
        routine: Routine(id: 1, name: "Mi Rutina", description: "Una rutina de ejemplo", icon: "house", id_user: UUID())
    )
}

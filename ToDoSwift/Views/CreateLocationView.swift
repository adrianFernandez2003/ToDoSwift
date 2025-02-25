//
//  CreateLocationView.swift
//  ToDoSwift
//
//  Created by José Adrián Fernández Méndez on 24/02/25.
//

import SwiftUI
import CoreLocation

struct CreateLocationView: View {
    @State private var name: String = ""
    @State private var coordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    @State private var radius: Double = 1.0
    @State private var selectedRoutineId: Int?
    @State private var isMapPresented = false
    @State private var isSaving = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var routines: [Routine]? = nil
    @State private var isLoadingRoutines = false
    @State private var showSuccess = false
    
    var body: some View {
        Form {
            Section(header: Text("Location Details")) {
                TextField("Location Name", text: $name)
                
                Button("Select Location on Map") {
                    isMapPresented = true
                }
                
                if coordinate.latitude != 0 || coordinate.longitude != 0 {
                    Text("Latitude: \(coordinate.latitude)")
                    Text("Longitude: \(coordinate.longitude)")
                    Text("Radius: \(radius, specifier: "%.1f") km")
                }
            }
            
            Section(header: Text("Associated Routine")) {
                if let routines = routines {
                    List(routines, id: \.id) { routine in
                        Button(action: {
                            selectedRoutineId = routine.id
                        }) {
                            HStack {
                                Text(routine.name)
                                Spacer()
                                if selectedRoutineId == routine.id {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                    }
                } else {
                    if isLoadingRoutines {
                        ProgressView()
                    } else {
                        Text("No routines available")
                            .foregroundColor(.gray)
                    }
                }
            }
            
            Section {
                Button(action: {
                    Task {
                        await saveLocation()
                    }
                }) {
                    if isSaving {
                        ProgressView()
                    } else {
                        Text("Create Location")
                    }
                }
                .disabled(name.isEmpty || selectedRoutineId == nil)
            }
        }
        .navigationTitle("Create Location")
        .sheet(isPresented: $isMapPresented) {
            LocationPicker(coordinate: $coordinate, radius: $radius, locationName: $name)
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
        .alert("Success", isPresented: $showSuccess) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Location created successfully!")
        }
        .task {
            isLoadingRoutines = true
            do {
                routines = try await fetchRoutines()
            } catch {
                errorMessage = error.localizedDescription
                showError = true
            }
            isLoadingRoutines = false
        }
    }
    
    private func saveLocation() async {
        guard let routineId = selectedRoutineId else { return }
        
        isSaving = true
        do {
            let success = try await createLocation(
                name: name,
                latitude: coordinate.latitude,
                longitude: coordinate.longitude,
                radius: radius,
                routineId: routineId
            )
            
            if success {
                showSuccess = true
            }
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
        isSaving = false
    }
}

#Preview {
    NavigationView {
        CreateLocationView()
    }
}

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
    @State private var isMapPresented = false
    @State private var isSaving = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var showSuccess = false
    
    var body: some View {
        Form {
            Section(header: Text("Detalles de la Ubicación")) {
                TextField("Nombre de la ubicación", text: $name)
                
                Button("Seleccionar ubicación en el mapa") {
                    isMapPresented = true
                }
                
                if coordinate.latitude != 0 || coordinate.longitude != 0 {
                    Text("Latitud: \(coordinate.latitude)")
                    Text("Longitud: \(coordinate.longitude)")
                    Text("Radio: \(radius, specifier: "%.1f") km")
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
                        Text("Crear Ubicación")
                    }
                }
                .disabled(name.isEmpty)
            }
        }
        .navigationTitle("Crear Ubicación")
        .sheet(isPresented: $isMapPresented) {
            LocationPicker(coordinate: $coordinate, radius: $radius, locationName: $name)
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
        .alert("Éxito", isPresented: $showSuccess) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("¡Ubicación creada con éxito!")
        }
    }
    
    private func saveLocation() async {
        isSaving = true
        do {
            let success = try await createLocation(
                name: name,
                latitude: coordinate.latitude,
                longitude: coordinate.longitude,
                radius: radius
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
    CreateLocationView()
}

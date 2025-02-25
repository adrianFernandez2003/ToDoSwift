//
//  LocationsView.swift
//  ToDoSwift
//
//  Created by José Adrián Fernández Méndez on 24/02/25.
//

import SwiftUI

struct LocationsView: View {
    @State private var locations: [Location] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var selectedLocation: Location?  // Ubicación seleccionada

    var body: some View {
        NavigationStack {
            ZStack {
                Color("PrimaryColor").ignoresSafeArea()
                
                VStack(spacing: 0) {
                    Text("Ubicaciones")
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
                                ForEach(locations, id: \.id) { location in
                                    LocationItem(
                                        title: .constant(location.name),
                                        latitude: .constant("\(location.latitude)"),
                                        longitude: .constant("\(location.longitude)"),
                                        onTap: { selectedLocation = location } // Guarda la selección
                                    )
                                    Spacer()
                                }
                            }
                            .padding()
                        }
                    }
                }
            }
            .onAppear {
                loadLocations()
            }
            .navigationDestination(item: $selectedLocation) { location in
                SingleLocationView(location: location) // Abre SingleLocationView
            }
        }
    }
    
    private func loadLocations() {
        Task {
            do {
                locations = try await fetchLocations()
                isLoading = false
            } catch {
                errorMessage = error.localizedDescription
                isLoading = false
            }
        }
    }
}

#Preview {
    LocationsView()
}

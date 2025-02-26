import SwiftUI
import MapKit

struct SingleLocationView: View {
    @State private var name: String
    @State private var coordinate: CLLocationCoordinate2D
    @State private var radius: Double
    @State private var isMapPresented = false
    @State private var isSaving = false
    @State private var showError = false
    @State private var errorMessage = ""

    let location: Location
    
    init(location: Location) {
        self.location = location
        _name = State(initialValue: location.name)
        _coordinate = State(initialValue: CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude))
        _radius = State(initialValue: location.radius)
    }
    
    var body: some View {
        ZStack {
            Color("PrimaryColor").ignoresSafeArea(.all)
            
            VStack(spacing: 20) {
                Text("Editar Ubicación")
                    .font(.largeTitle)
                    .bold()
                    .padding(.top)
                
                TextField("Nombre del lugar", text: $name)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                
                Text("Latitud: \(coordinate.latitude)")
                Text("Longitud: \(coordinate.longitude)")
                Text("Radio: \(radius) km")
                
                Button("Seleccionar ubicación en el mapa") {
                    isMapPresented = true
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
                .padding(.horizontal)
                
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
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(10)
                .disabled(isSaving)
                .padding(.horizontal)
            }
            .padding()
        }
        .navigationTitle("Editar Ubicación")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $isMapPresented) {
            LocationPicker(coordinate: $coordinate, radius: $radius, locationName: $name)
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }
    
    private func saveChanges() async {
        isSaving = true
        do {
            let success = try await updateLocation(
                id: location.id,
                name: name,
                latitude: coordinate.latitude,
                longitude: coordinate.longitude,
                radius: radius
            )
            
            if success {
                print("Location updated successfully")
            } else {
                errorMessage = "No se pudo actualizar la ubicación"
                showError = true
            }
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
        isSaving = false
    }
}

#Preview {
    SingleLocationView(
        location: Location(id: 1, latitude: 18.005811, longitude: -92.966590, radius: 10.0, created_at: "2025-02-24", name: "Parque la Choca")
    )
}

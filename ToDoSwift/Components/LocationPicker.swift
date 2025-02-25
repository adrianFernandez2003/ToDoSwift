
import SwiftUI
import MapKit

struct LocationPicker: View {
    @Binding var coordinate: CLLocationCoordinate2D
    @Binding var radius: Double
    @Binding var locationName: String
    @State private var region: MKCoordinateRegion
    
    init(coordinate: Binding<CLLocationCoordinate2D>, radius: Binding<Double>, locationName: Binding<String>) {
        self._coordinate = coordinate
        self._radius = radius
        self._locationName = locationName
        
        // Validate coordinate bounds before creating region
        let validLatitude = min(max(coordinate.wrappedValue.latitude, -90), 90)
        let validLongitude = min(max(coordinate.wrappedValue.longitude, -180), 180)
        let validCoordinate = CLLocationCoordinate2D(latitude: validLatitude, longitude: validLongitude)
        
        self._region = State(initialValue: MKCoordinateRegion(
            center: validCoordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        ))
    }

    var body: some View {
        VStack {
            TextField("Location Name", text: $locationName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            Map(coordinateRegion: $region,
                interactionModes: .all,
                showsUserLocation: true,
                annotationItems: [LocationAnnotation(coordinate: coordinate)]) { location in
                    MapMarker(coordinate: location.coordinate, tint: .red)
                }
                .onTapGesture { location in
                    let tapPoint = location
                    let newLatitude = min(max(region.center.latitude + (tapPoint.y - 150) * region.span.latitudeDelta / 300, -90), 90)
                    let newLongitude = min(max(region.center.longitude + (tapPoint.x - 150) * region.span.longitudeDelta / 300, -180), 180)
                    let newCoordinate = CLLocationCoordinate2D(latitude: newLatitude, longitude: newLongitude)
                    coordinate = newCoordinate
                    region.center = newCoordinate
                }
                .frame(height: 300)

            VStack(alignment: .leading, spacing: 10) {
                Text("Radius (km)")
                    .font(.headline)
                
                HStack {
                    Slider(value: $radius, in: 0.1...50, step: 0.1)
                    Text(String(format: "%.1f", radius))
                        .frame(width: 50)
                }
            }
            .padding()

            Button(action: {
                print("Location saved - Name: \(locationName), Coordinates: \(coordinate.latitude), \(coordinate.longitude), Radius: \(radius)km")
            }) {
                Text("Save Location")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
        }
    }
}

struct LocationAnnotation: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
}

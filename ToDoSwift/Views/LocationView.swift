//
//  LocationView.swift
//  ToDoSwift
//
//  Created by José Adrián Fernández Méndez on 21/02/25.
//

import SwiftUI
import MapKit
import CoreLocation

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    @Published var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.332331, longitude: -122.031219),
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    )
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        region = MKCoordinateRegion(
            center: location.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )
    }
}

struct LocationView: View {
    @StateObject private var locationManager = LocationManager()
    
    var body: some View {
        Map(coordinateRegion: $locationManager.region, showsUserLocation: true)
            .edgesIgnoringSafeArea(.all)
    }
}


#Preview {
    LocationView()
}

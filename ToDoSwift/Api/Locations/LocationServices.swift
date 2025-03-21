//
//  LocationServices.swift
//  ToDoSwift
//
//  Created by José Adrián Fernández Méndez on 24/02/25.
//

import Foundation

struct Location: Codable, Hashable, Identifiable {
    let id: Int
    let latitude: Double
    let longitude: Double
    let radius: Double
    let created_at: String
    let name: String
}

struct LocationUpdate: Codable {
    let id: Int
    let latitude: Double
    let longitude: Double
    let radius: Double
    let name: String
}

func fetchLocations() async throws -> [Location] {
    
    let locations: [Location]? = try await supabase
        .from("locations")
        .select()
        .execute()
        .value
        
    guard let locations = locations else {
        throw NSError(domain: "FetchError", code: 3, userInfo: [NSLocalizedDescriptionKey: "No data returned"])
    }
    
    return locations
}


func updateLocation(id: Int, name: String, latitude: Double, longitude: Double, radius: Double) async throws -> Bool {
    print("Updating location with ID: \(id)")
    print("New values - Name: \(name), Lat: \(latitude), Long: \(longitude), Radius: \(radius)")
    
    let locationUpdate = LocationUpdate(
        id: id,
        latitude: latitude,
        longitude: longitude,
        radius: radius,
        name: name
    )
    
    do {
        let response = try await supabase.database
            .from("locations")
            .update(locationUpdate)
            .eq("id", value: id)
            .execute()
        
        print("Location update response status: \(response.status)")
        return response.status == 200
        
    } catch {
        print("Error updating location: \(error.localizedDescription)")
        throw NSError(domain: "UpdateError", code: 2, userInfo: [NSLocalizedDescriptionKey: "Failed to update location: \(error.localizedDescription)"])
    }
}


struct LocationCreate: Encodable {
    let latitude: Double
    let longitude: Double
    let radius: Double
    let name: String
    let id_user: UUID
}

func createLocation(name: String, latitude: Double, longitude: Double, radius: Double) async throws -> Bool {
        print("Creating location - Name: \(name), Lat: \(latitude), Long: \(longitude), Radius: \(radius)")
        
        guard let user = supabase.auth.currentUser else {
            throw NSError(domain: "UserNotLoggedIn", code: 1, userInfo: [NSLocalizedDescriptionKey: "User not logged in."])
        }
        
        let locationCreate = LocationCreate(
            latitude: latitude,
            longitude: longitude,
            radius: radius,
            name: name,
            id_user: user.id
        )
        
        do {
            let response = try await supabase.database
                .from("locations")
                .insert(locationCreate)
                .execute()
            
            print("Location creation response status: \(response.status)")
            return response.status == 201
            
        } catch {
            print("Error creating location: \(error.localizedDescription)")
            throw NSError(domain: "CreateError", code: 2, userInfo: [NSLocalizedDescriptionKey: "Failed to create location: \(error.localizedDescription)"])
        }
    }

struct LocationBasic: Codable, Hashable, Identifiable {
    let id: Int
    let name: String
    let id_user: UUID?
}

func deleteLocation(id: Int) async throws -> Bool {
    print("Deleting location with ID: \(id)")
    
    guard let user = supabase.auth.currentUser else {
        throw NSError(domain: "UserNotLoggedIn", code: 1, userInfo: [NSLocalizedDescriptionKey: "User not logged in."])
    }
    
    do {
        let response = try await supabase.database
            .from("locations")
            .delete()
            .eq("id", value: id)
            .eq("id_user", value: user.id)
            .execute()
        
        print("Location deletion response status: \(response.status)")
        return response.status == 204
        
    } catch {
        print("Error deleting location: \(error.localizedDescription)")
        throw NSError(domain: "DeleteError", code: 2, userInfo: [NSLocalizedDescriptionKey: "Failed to delete location: \(error.localizedDescription)"])
    }
}

func fetchLocationsBasic() async throws -> [LocationBasic] {
    let locations: [LocationBasic]? = try await supabase
        .from("locations")
        .select("id, name")
        .execute()
        .value
        
    guard let locations = locations else {
        throw NSError(domain: "FetchError", code: 3, userInfo: [NSLocalizedDescriptionKey: "No data returned"])
    }
    
    return locations
}

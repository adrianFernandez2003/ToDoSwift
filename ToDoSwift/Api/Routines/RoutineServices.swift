//
//  services.swift
//  ToDoSwift
//
//  Created by José Adrián Fernández Méndez on 23/02/25.
//

import Supabase
import Foundation

// Modelos para la creación de rutina
struct RoutineCreate: Encodable {
    let name: String
    let description: String
    let icon: String
    let id_user: UUID
}

struct Routine: Codable, Hashable {
    let id: Int?
    let name: String
    let description: String
    let icon: String
    let id_user: UUID
    let streak: Int
}

struct RoutineStreakPoints: Codable, Hashable {
    let id: Int?
    let name: String
    let description: String
    let icon: String
    let id_user: UUID
    let streak: Int
    let points: Int
}


struct RoutineStreak: Codable, Hashable {
    let id: Int
    let streak: Int
    let points: Int
}

struct RoutineUpdate: Codable {
    let id: Int?
    let name: String
    let description: String
    let icon: String
}

class RoutineService {
    static func createRoutine(name: String, description: String, icon: String) async throws -> Bool {
        guard let user = supabase.auth.currentUser else {
            throw NSError(domain: "UserNotLoggedIn", code: 1, userInfo: [NSLocalizedDescriptionKey: "User not logged in."])
        }
        
        // Create the Routine object instead of using a dictionary
        let routine = RoutineCreate(name: name, description: description, icon: icon, id_user: user.id)
        
        // Use the routine object in the insert call
        let response = try await supabase.from("routines").insert(routine).execute()
        
        if response.status == 201 {
            // Success: Routine created successfully
            return true
        } else {
            // Failure: Handle the error
            throw NSError(domain: "RoutineCreationFailed", code: 2, userInfo: [NSLocalizedDescriptionKey: "Failed to create routine."])
        }
    }
}






func fetchRoutines() async throws -> [Routine] {
    guard let user = supabase.auth.currentUser else {
        throw NSError(domain: "UserNotLoggedIn", code: 1, userInfo: [NSLocalizedDescriptionKey: "User not logged in."])
    }
    
    let routines: [Routine]? = try await supabase
        .from("routines")
        .select()
        .execute()
        .value
        
    guard let routines = routines else {
        throw NSError(domain: "FetchError", code: 3, userInfo: [NSLocalizedDescriptionKey: "No data returned"])
    }
    
    return routines
}


func updateRoutine(id: Int, name: String, description: String, icon: String) async throws -> Bool {
    print("Updating routine with ID: \(id)")
    print("New values - Name: \(name), Description: \(description), Icon: \(icon)")
    
    guard let user = supabase.auth.currentUser else {
        throw NSError(domain: "UserNotLoggedIn", code: 1, userInfo: [NSLocalizedDescriptionKey: "User not logged in."])
    }
    
    let routineUpdate = RoutineUpdate(
        id: id,
        name: name,
        description: description,
        icon: icon
    )
    
    do {
        let response = try await supabase.database
            .from("routines")
            .update(routineUpdate)
            .eq("id", value: id)
            .execute()
        
        print("Routine update response status: \(response.status)")
        return response.status == 200
        
    } catch {
        print("Error updating routine: \(error.localizedDescription)")
        throw NSError(domain: "UpdateError", code: 2, userInfo: [NSLocalizedDescriptionKey: "Failed to update routine: \(error.localizedDescription)"])
    }
}

func deleteRoutine(id: Int) async throws -> Bool {
    print("Deleting routine with ID: \(id)")
    
    guard let user = supabase.auth.currentUser else {
        throw NSError(domain: "UserNotLoggedIn", code: 1, userInfo: [NSLocalizedDescriptionKey: "User not logged in."])
    }
    
    do {
        let response = try await supabase.database
            .from("routines")
            .delete()
            .eq("id", value: id)
            .eq("id_user", value: user.id)
            .execute()
        
        print("Routine deletion response status: \(response.status)")
        return response.status == 204
        
    } catch {
        print("Error deleting routine: \(error.localizedDescription)")
        throw NSError(domain: "DeleteError", code: 2, userInfo: [NSLocalizedDescriptionKey: "Failed to delete routine: \(error.localizedDescription)"])
    }
}


func updateStreak(streak: Int, points: Int, routineId: Int) async throws {
    guard let user = supabase.auth.currentUser else {
        throw NSError(domain: "UserNotLoggedIn", code: 1, userInfo: [NSLocalizedDescriptionKey: "User not logged in."])
    }
    
    let updatedRoutine: [RoutineStreak]? = try await supabase
        .from("routines")
        .update([
            "streak": streak,
            "points": points
        ])
        .eq("id", value: routineId)
        .eq("id_user", value: user.id)
        .execute()
        .value
        
    guard updatedRoutine != nil else {
        throw NSError(domain: "UpdateError", code: 2, userInfo: [NSLocalizedDescriptionKey: "Failed to update streak"])
    }
}

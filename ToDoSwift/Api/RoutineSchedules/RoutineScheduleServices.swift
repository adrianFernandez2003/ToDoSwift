//
//  RoutineScheduleServices.swift
//  ToDoSwift
//
//  Created by José Adrián Fernández Méndez on 24/02/25.
//

// Estructura para almacenar días y horas en JSONB

import Supabase
import Foundation

struct RoutineSchedulesCreate: Codable {
    let id_routine: Int
    let id_user: UUID
    let day_and_time: [String: AnyJSON] // Changed to use JSONB
}

func createRoutineSchedule(routineId: Int, days: [String], time: String) async throws -> Bool {
    print("Creating routine schedule - RoutineId: \(routineId), Days: \(days), Time: \(time)")
    
    guard let user = supabase.auth.currentUser else {
        throw NSError(domain: "UserNotLoggedIn", code: 1, userInfo: [NSLocalizedDescriptionKey: "User not logged in."])
    }
    
    let scheduleCreate = RoutineSchedulesCreate(
        id_routine: routineId,
        id_user: user.id,
        day_and_time: [
            "days": try AnyJSON(days),
            "time": try AnyJSON(time)
        ]
    )
    
    do {
        let response = try await supabase.database
            .from("routine_schedules")
            .insert(scheduleCreate)
            .execute()
        
        print("Routine schedule creation response status: \(response.status)")
        return response.status == 201
        
    } catch {
        print("Error creating routine schedule: \(error.localizedDescription)")
        throw NSError(domain: "CreateError", code: 2, userInfo: [NSLocalizedDescriptionKey: "Failed to create routine schedule: \(error.localizedDescription)"])
    }
}

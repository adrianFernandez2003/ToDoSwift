//
//  RoutineScheduleServices.swift
//  ToDoSwift
//
//  Created by José Adrián Fernández Méndez on 24/02/25.
//

// Estructura para almacenar días y horas en JSONB

import Supabase
import Foundation
import UserNotifications

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

func fetchRoutinesAndSchedules() async throws -> [RoutineScheduleWithRoutine] {
    guard let user = supabase.auth.currentUser else {
        throw NSError(domain: "UserNotLoggedIn", code: 1, userInfo: [NSLocalizedDescriptionKey: "User not logged in."])
    }
    
    let schedules: [RoutineScheduleWithRoutine]? = try await supabase
        .from("routine_schedules")
        .select("""
            id_routine,
            id_user,
            day_and_time,
            routines (
                id,
                name,
                description,
                icon,
                id_user,
                streak
            )
        """)
        .eq("id_user", value: user.id)
        .order("day_and_time->time", ascending: true)
        .execute()
        .value
        
    guard let schedules = schedules else {
        throw NSError(domain: "FetchError", code: 3, userInfo: [NSLocalizedDescriptionKey: "No data returned"])
    }
    
    return schedules
}

struct RoutineScheduleWithRoutine: Codable {
    let id_routine: Int
    let id_user: UUID
    let day_and_time: DayAndTime
    let routines: Routine
}

struct RoutineSchedule: Codable {
    let id_routine: Int
    let id_user: UUID
    let day_and_time: DayAndTime
}

struct DayAndTime: Codable {
    let days: [String]
    let time: String
}

func fetchRoutineSchedules() async {
    print("🔄 Initializing fetchRoutineSchedules...")
    do {
        let user = supabase.auth.currentUser
        guard let userId = user?.id else { return }
        
        let schedules: [RoutineSchedule] = try await supabase.database
            .from("routine_schedules")
            .select()
            .eq("id_user", value: userId)
            .execute()
            .value
        
        print("✅ Rutinas obtenidas:", schedules)
        await scheduleNotifications(for: schedules)

    } catch {
        print("❌ Error obteniendo horarios:", error.localizedDescription)
    }
}

func scheduleNotifications(for schedules: [RoutineSchedule]) async {
    let formatter = DateFormatter()
    formatter.dateFormat = "HH:mm:ss"
    formatter.timeZone = TimeZone.current
    
    let currentDate = Date()
    let calendar = Calendar.current
    let weekdayFormatter = DateFormatter()
    weekdayFormatter.locale = Locale(identifier: "es_ES")
    weekdayFormatter.dateFormat = "EEEE"
    let currentDay = weekdayFormatter.string(from: currentDate).lowercased()
    let currentTime = formatter.string(from: currentDate)
    
    print("📅 Día actual: \(currentDay)")
    print("⏰ Hora actual: \(currentTime)")
    
    for schedule in schedules {
        let scheduleDays = schedule.day_and_time.days.map { $0.lowercased() }
        print("🔍 Verificando horario - Días: \(scheduleDays), Hora: \(schedule.day_and_time.time)")
        
        if scheduleDays.contains(currentDay) {
            print("✓ El día coincide")
            
            print("Hora programada recibida: \(schedule.day_and_time.time)")
            
            let scheduleComponents = schedule.day_and_time.time.split(separator: ":")
            guard scheduleComponents.count == 3,
                  let scheduleHour = Int(scheduleComponents[0]),
                  let scheduleMinute = Int(scheduleComponents[1]) else {
                print("❌ Formato de hora inválido")
                continue
            }
            
            var dateComponents = calendar.dateComponents([.year, .month, .day], from: currentDate)
            dateComponents.hour = scheduleHour
            dateComponents.minute = scheduleMinute
            dateComponents.second = 0
            
            guard let scheduledDate = calendar.date(from: dateComponents) else {
                print("❌ No se pudo crear la fecha desde los componentes")
                continue
            }
            
            print("Fecha programada: \(scheduledDate)")
            
            // Ajustamos la fecha a la zona horaria local
            let localTimeZone = TimeZone.current
            let localScheduledDate = scheduledDate.addingTimeInterval(TimeInterval(localTimeZone.secondsFromGMT(for: scheduledDate)))
            print("Fecha programada local: \(localScheduledDate)")

            if localScheduledDate > currentDate {
                print("✓ Programando notificación para \(localScheduledDate)")
                await sendLocalNotification(for: schedule, at: localScheduledDate)
            } else {
                // Si la hora ya pasó, programar para el próximo minuto
                var newScheduledDate = calendar.date(byAdding: .minute, value: 1, to: currentDate)
                print("✓ Programando notificación para el siguiente minuto: \(String(describing: newScheduledDate))")
                await sendLocalNotification(for: schedule, at: newScheduledDate!)
            }
        } else {
            print("✗ El día no coincide")
        }
    }
}



func sendLocalNotification(for schedule: RoutineSchedule, at date: Date) async {
    let content = UNMutableNotificationContent()
    content.title = "¡Hora de tu rutina!"
    content.body = "Es momento de seguir tu rutina programada."
    content.sound = .default

    let triggerDate = Calendar.current.dateComponents([.hour, .minute], from: date)
    let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false) // Cambié repeats a false

    let request = UNNotificationRequest(identifier: "routine-\(schedule.id_routine)", content: content, trigger: trigger)

    print("📲 Intentando programar notificación para \(date)...")

    do {
        try await UNUserNotificationCenter.current().add(request)
        print("✅ Notificación programada exitosamente para \(date)")
    } catch {
        print("❌ Error al programar la notificación:", error.localizedDescription)
    }
}


func startPollingForRoutineSchedules() {
    print("🔄 Iniciando monitoreo de horarios de rutinas...")
    Task {
        await fetchRoutineSchedules() // Fetch immediately when starting
    }
    Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { _ in // Changed to 5 minutes
        Task {
            print("⏲️ Verificando horarios de rutinas...")
            await fetchRoutineSchedules()
        }
    }
}

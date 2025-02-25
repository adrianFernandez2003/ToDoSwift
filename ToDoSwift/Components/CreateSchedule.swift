//
//  CreateSchedule.swift
//  ToDoSwift
//
//  Created by José Adrián Fernández Méndez on 24/02/25.
//

import SwiftUI

struct CreateSchedule: View {
    let routineId: Int
    @State private var selectedDays: Set<String> = []
    @State private var selectedTime = Date()
    @State private var hasExistingSchedule = false
    @State private var showAlert = false
    @State private var errorMessage: String?
    
    let daysOfWeek = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
    
    var body: some View {
        VStack(spacing: 20) {
            // Days Selection
            VStack(alignment: .leading) {
                Text("Select Days")
                    .font(.headline)
                    .padding(.horizontal)
                
                ForEach(daysOfWeek, id: \.self) { day in
                    Toggle(day, isOn: Binding(
                        get: { selectedDays.contains(day) },
                        set: { isSelected in
                            if isSelected {
                                selectedDays.insert(day)
                            } else {
                                selectedDays.remove(day)
                            }
                        }
                    ))
                    .padding(.horizontal)
                }
            }
            .padding(.vertical)
            .background(Color.white)
            .cornerRadius(10)
            
            // Time Selection
            VStack(alignment: .leading) {
                Text("Select Time")
                    .font(.headline)
                    .padding(.horizontal)
                
                DatePicker("Time", selection: $selectedTime, displayedComponents: [.hourAndMinute])
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
            }
            
            if hasExistingSchedule {
                HStack(spacing: 20) {
                    Button("Update") {
                        updateSchedule()
                    }
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
                    
                    Button("Delete") {
                        deleteSchedule()
                    }
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.red)
                    .cornerRadius(10)
                }
            } else {
                Button("Create Schedule") {
                    createNewSchedule()
                }
                .foregroundColor(.white)
                .padding()
                .background(Color.blue)
                .cornerRadius(10)
            }
        }
        .padding()
        .onAppear {
            checkExistingSchedule()
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Error"),
                message: Text(errorMessage ?? "An unknown error occurred"),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    private func checkExistingSchedule() {
        Task {
            do {
                let schedules: [RoutineSchedulesCreate] = try await supabase.database
                    .from("routine_schedules")
                    .select()
                    .eq("id_routine", value: routineId)
                    .execute()
                    .value
                
                await MainActor.run {
                    hasExistingSchedule = !schedules.isEmpty
                    if let schedule = schedules.first,
                       let days = schedule.day_and_time["days"]?.value as? [String] {
                        selectedDays = Set(days)
                        if let timeString = schedule.day_and_time["time"]?.value as? String {
                            let formatter = DateFormatter()
                            formatter.dateFormat = "HH:mm:ss"
                            if let date = formatter.date(from: timeString) {
                                selectedTime = date
                            }
                        }
                    }
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    showAlert = true
                }
            }
        }
    }
    
    private func deleteSchedule() {
        Task {
            do {
                let response = try await supabase.database
                    .from("routine_schedules")
                    .delete()
                    .eq("id_routine", value: routineId)
                    .execute()
                
                await MainActor.run {
                    hasExistingSchedule = false
                    selectedDays.removeAll()
                    selectedTime = Date()
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    showAlert = true
                }
            }
        }
    }
    
    private func updateSchedule() {
        Task {
            do {
                // First delete existing schedule
                try await supabase.database
                    .from("routine_schedules")
                    .delete()
                    .eq("id_routine", value: routineId)
                    .execute()
                
                // Then create new schedule
                let formatter = DateFormatter()
                formatter.dateFormat = "HH:mm:ss"
                let timeString = formatter.string(from: selectedTime)
                
                let success = try await createRoutineSchedule(
                    routineId: routineId,
                    days: Array(selectedDays),
                    time: timeString
                )
                
                if !success {
                    throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to update schedule"])
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    showAlert = true
                }
            }
        }
    }
    
    private func createNewSchedule() {
        Task {
            do {
                let formatter = DateFormatter()
                formatter.dateFormat = "HH:mm:ss"
                let timeString = formatter.string(from: selectedTime)
                
                let success = try await createRoutineSchedule(
                    routineId: routineId,
                    days: Array(selectedDays),
                    time: timeString
                )
                
                if success {
                    await MainActor.run {
                        hasExistingSchedule = true
                    }
                } else {
                    throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to create schedule"])
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    showAlert = true
                }
            }
        }
    }
}



#Preview {
    CreateSchedule(routineId: 5)
}

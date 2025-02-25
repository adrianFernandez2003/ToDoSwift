import SwiftUI

struct RoutineAvaible: View {
    @Binding var title: String
    @Binding var description: String
    @Binding var icon: String
    @AppStorage private var isCompleted: Bool
    @AppStorage private var lastCompletedDate: Date
    let onTap: () -> Void
    let routineId: Int
    @State private var streak: Int = 0
    @State private var points: Int = 50
    
    init(title: Binding<String>, description: Binding<String>, icon: Binding<String>, onTap: @escaping () -> Void, routineId: Int) {
        self._title = title
        self._description = description
        self._icon = icon
        self.onTap = onTap
        self.routineId = routineId
        // Usar el routineId como parte de la key para que cada rutina tenga su propio estado
        self._isCompleted = AppStorage(wrappedValue: false, "routine_completed_\(routineId)_\(Calendar.current.startOfDay(for: Date()))")
        self._lastCompletedDate = AppStorage(wrappedValue: Date(), "routine_last_completed_\(routineId)")
    }
    
    private func handleCompletion() {
        if !isCompleted {
            isCompleted = true
            Task {
                // Obtener el streak actual antes de actualizarlo
                do {
                    let routine: [RoutineStreakPoints]? = try await supabase
                        .from("routines")
                        .select()
                        .eq("id", value: routineId)
                        .execute()
                        .value
                    
                    if let currentRoutine = routine?.first {
                        self.streak = currentRoutine.streak + 1 // Incrementar el streak directamente
                        self.points = currentRoutine.points
                        
                        // Actualizar en la base de datos
                        try await supabase
                            .from("routines")
                            .update(["streak": self.streak])
                            .eq("id", value: routineId)
                            .execute()
                    }
                } catch {
                    print("Error fetching/updating streak: \(error)")
                }
            }
        }
    }
    
    var body: some View {
        VStack {
            HStack {
                Rectangle()
                    .frame(width: 80, height: 80)
                    .cornerRadius(16)
                    .overlay {
                        Image(systemName: icon)
                            .resizable()
                            .frame(width: 30, height: 30)
                            .foregroundStyle(.white)
                    }
                    .foregroundColor(Color("TextColor"))
                
                VStack(alignment: .leading) {
                    Text(title)
                        .font(.title3)
                        .bold()
                        .padding(.bottom, 2)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundColor(.primary)
                    
                    Text(description)
                        .font(.subheadline)
                        .foregroundStyle(.gray)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Button(action: handleCompletion) {
                        Text(isCompleted ? "Completado" : "Completar")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(isCompleted ? Color.green : Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .disabled(isCompleted)
                }
                .padding(.leading, 5)
            }
            .padding(25)
            .frame(maxWidth: .infinity)
            .background(Color("TextColor"))
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(.white)
            )
        }
    }
}


import SwiftUI

struct RoutineList: View {
    @State private var routineSchedules: [RoutineScheduleWithRoutine] = []
    @State private var isLoading = true
    @State private var errorMessage: String?

    var body: some View {
        VStack(alignment: .leading) {
            Text("Secuencia")
                .foregroundStyle(.white)
                .font(.headline)
                .padding(.bottom, 8)
            
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
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(routineSchedules, id: \.routines.id) { schedule in
                            VStack {
                                Image(systemName: schedule.routines.icon)
                                    .frame(width: 75, height: 75)
                                    .foregroundStyle(.white)
                                    .clipShape(Circle())
                                    .overlay(
                                        Circle().stroke(Color.white, lineWidth: 3)
                                    )
                                    .padding(4)
                                Text(schedule.day_and_time.time)
                                    .font(.caption)
                                    .foregroundStyle(.white)
                            }
                        }
                    }
                }
                .scrollIndicators(.hidden)
            }
        }
        .padding()
        .onAppear {
            loadRoutineSchedules()
        }
    }

    private func loadRoutineSchedules() {
        Task {
            do {
                routineSchedules = try await fetchRoutinesAndSchedules()
                isLoading = false
            } catch {
                errorMessage = error.localizedDescription
                isLoading = false
            }
        }
    }
}

#Preview {
    RoutineList()
}

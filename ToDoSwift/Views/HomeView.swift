import SwiftUI

struct HomeView: View {
    @State private var nextRoutine: RoutineScheduleWithRoutine?
    @State private var routines: [RoutineScheduleWithRoutine] = []
    @State private var refreshID = UUID() // Para forzar actualizaciones
    
    var body: some View {
        VStack {
            VStack {
                VStack(alignment: .center) {
                    Text("Siguiente actividad")
                        .font(.largeTitle)
                        .foregroundStyle(Color("TextColor"))
                        .bold()
                    
                    if let routine = nextRoutine {
                        Text("\(routine.routines.name) - \(routine.day_and_time.time)")
                            .font(.headline)
                            .foregroundStyle(Color("TextColor"))
                        HStack {
                            Text("¡Llevas \(routine.routines.streak) días seguidos!")
                                .foregroundStyle(Color("StreakColor"))
                            Image(systemName: "flame.fill")
                                .foregroundStyle(Color("StreakColor"))
                        }
                    } else {
                        Text("Cargando...")
                            .font(.headline)
                            .foregroundStyle(Color("TextColor"))
                    }
                }
                .padding(.top)
                .padding(.bottom)
                .task {
                    await loadRoutines()
                }
            }
            
            VStack {
                ZStack {
                    Rectangle()
                        .fill(Color("PrimaryColor"))
                        .cornerRadius(35)
                        .ignoresSafeArea(.all, edges: .bottom)
                    
                    ScrollView {
                        RoutineList()
                        Grid {
                            CardChart()
                                .id(refreshID) // Forzar actualización cuando cambie refreshID
                        }.padding(.bottom, 10)
                        
                        ForEach(routines, id: \.routines.id) { routine in
                            RoutineAvaible(
                                title: .constant(routine.routines.name),
                                description: .constant(routine.routines.description),
                                icon: .constant(routine.routines.icon),
                                onTap: {
                                    Task {
                                        await loadRoutines()
                                        refreshID = UUID() // Forzar actualización de CardChart
                                    }
                                },
                                routineId: routine.routines.id ?? 0
                            )
                            .padding(.bottom, 10)
                        }
                    }
                    .scrollIndicators(.hidden)
                    .padding()
                }
            }
        }
        .background(Color("SecondaryColor"))
    }
    
    private func loadRoutines() async {
        do {
            let fetchedRoutines = try await fetchRoutinesAndSchedules()
            DispatchQueue.main.async {
                self.routines = fetchedRoutines
                self.nextRoutine = findNextRoutine(from: fetchedRoutines)
            }
        } catch {
            print("Error fetching routines: \(error)")
        }
    }
    
    private func findNextRoutine(from routines: [RoutineScheduleWithRoutine]) -> RoutineScheduleWithRoutine? {
        let currentTime = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        
        return routines.min { routine1, routine2 in
            let time1 = dateFormatter.date(from: routine1.day_and_time.time) ?? Date()
            let time2 = dateFormatter.date(from: routine2.day_and_time.time) ?? Date()
            let diff1 = abs(time1.timeIntervalSince(currentTime))
            let diff2 = abs(time2.timeIntervalSince(currentTime))
            return diff1 < diff2
        }
    }
}

#Preview {
    HomeView()
}

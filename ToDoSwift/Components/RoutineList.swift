import SwiftUI

struct RoutineList: View {
    @State private var routines: [Routine] = []
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
                        ForEach(routines, id: \.id) { routine in
                            Image(systemName: routine.icon)
                                .frame(width: 75, height: 75)
                                .foregroundStyle(.white)
                                .clipShape(Circle())
                                .overlay(
                                    Circle().stroke(Color.white, lineWidth: 3)
                                )
                                .padding(4)
                        }
                    }
                }
                .scrollIndicators(.hidden)
            }
        }
        .padding()
        .onAppear {
            loadRoutines()
        }
    }

    private func loadRoutines() {
        Task {
            do {
                routines = try await fetchRoutines()
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

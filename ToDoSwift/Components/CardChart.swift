//
//  CardChart.swift
//  ToDoSwift
//
//  Created by José Adrián Fernández Méndez on 22/02/25.
//
import SwiftUI
import Charts

struct CardChart: View {
    @State private var streaks: [Int] = []
    @State private var refreshID = UUID() // Añadir refreshID para forzar actualización
    @State private var isAnimating = false
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Racha actual")
                .font(.headline)
                .foregroundColor(.primary)
            
            HStack(alignment: .bottom, spacing: 2) {
                ForEach(streaks.indices, id: \.self) { index in
                    let barHeight = streaks[index] * 10
                    VStack {
                        Rectangle()
                            .fill(Color("ColorTab"))
                            .frame(maxWidth: .infinity)
                            .frame(height: isAnimating ? CGFloat(barHeight) : 0)
                            .cornerRadius(4)
                            .overlay(
                                Text("")
                                    .font(.caption)
                                    .foregroundColor(.white)
                                    .padding(.top, -20)
                            )
                            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: isAnimating)
                    }
                }
            }
            .frame(height: 100, alignment: .bottom)
            .padding(.top, 8)
            
            Text("Días")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color("TextColor"))
        .cornerRadius(12)
        .id(refreshID) // Forzar actualización cuando cambie refreshID
        .task {
            await loadStreaks()
        }
        // Añadir timer para actualizar periódicamente
        .onAppear {
            // Crear un timer que actualice cada 5 segundos
            Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
                Task {
                    await loadStreaks()
                    refreshID = UUID() // Forzar actualización
                }
            }
        }
    }
    
    private func loadStreaks() async {
        do {
            let routines = try await fetchRoutines()
            DispatchQueue.main.async {
                isAnimating = false // Reset animation
                streaks = routines.map { $0.streak }
                withAnimation {
                    isAnimating = true // Trigger animation
                }
            }
        } catch {
            print("Error fetching streaks: \(error)")
        }
    }
}

#Preview {
    CardChart()
}

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
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Racha actual")
                .font(.headline)
                .foregroundColor(.primary)
            
            HStack(alignment: .bottom, spacing: 2) {
                ForEach(streaks, id: \.self) { streak in
                    Rectangle()
                        .fill(Color("ColorTab"))
                        .frame(maxWidth: .infinity)
                        .cornerRadius(4)
                        .overlay(
                            Text("\(streak)")
                                .font(.subheadline)
                                .foregroundColor(Color("StreakColor"))
                                .padding(.top, -20)
                        )
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
        .task {
            do {
                let routines = try await fetchRoutines()
                streaks = routines.map { $0.streak }
            } catch {
                print("Error fetching streaks: \(error)")
            }
        }
    }
}

#Preview {
    CardChart()
}


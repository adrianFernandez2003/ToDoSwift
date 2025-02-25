//
//  IconPicker.swift
//  ToDoSwift
//
//  Created by José Adrián Fernández Méndez on 23/02/25.
//

import SwiftUI

enum SFIcons: String {
    case house = "house.fill"
    case car = "car.fill"
    case phone = "phone.fill"
    case clock = "clock.fill"
    case pencil = "pencil.circle.fill"
    case mail = "envelope.fill"
    case heart = "heart.fill"
    case cart = "cart.fill"
    case calendar = "calendar"
    case figureWalking = "figure.walk.circle.fill" 
    case sun = "sun.max.fill"
    case cloud = "cloud.fill"
    case moon = "moon.fill"
    case bell = "bell.fill"
    case music = "music.note"
    case trash = "trash.fill"
    case note = "note.text"
    case book = "book.fill"
    case laptop = "laptopcomputer"
    case person = "person.fill"
}

struct IconPicker: View {
    @Binding var selectedIcon: SFIcons
    let columns = [GridItem(.adaptive(minimum: 50))]

    var body: some View {
        VStack {
            Text("Seleccionar icono")
                .font(.headline)
                .padding()
            
            ScrollView {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(SFIcons.allCases, id: \.self) { icon in
                        Button(action: {
                            selectedIcon = icon
                        }) {
                            Image(systemName: icon.rawValue)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 40, height: 40)
                                .padding()
                                .background(selectedIcon == icon ? Color.blue.opacity(0.3) : Color.clear)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                    }
                }
                .padding()
            }
        }
    }
}

extension SFIcons: CaseIterable {}

#Preview {
    IconPicker(selectedIcon: .constant(SFIcons.bell))
}



import SwiftUI

struct LocationItem: View {
    @Binding var title: String
    @Binding var latitude: String
    @Binding var longitude: String
    var onTap: () -> Void  // Acción al hacer clic

    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading) {
                    Text(title)
                        .font(.title3)
                        .bold()
                        .padding(.bottom, 2)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    HStack {
                        Text("Latitud: \(latitude)")
                            .font(.subheadline)
                            .foregroundStyle(.gray)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text("Longitud: \(longitude)")
                            .font(.subheadline)
                            .foregroundStyle(.gray)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding(.leading, 5)
            }
            .padding(25)
            .frame(maxWidth: .infinity)
            .background(Color("TextColor"))
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white, lineWidth: 3)
            )
        }
        .frame(maxWidth: .infinity)
        .onTapGesture {
            onTap()  // Llama a la función cuando el usuario toca el item
        }
    }
}

#Preview {
    LocationItem(
        title: .constant("Parque la choca"),
        latitude: .constant("45"),
        longitude: .constant("80"),
        onTap: {}
    )
}



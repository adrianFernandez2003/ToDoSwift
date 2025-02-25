

import SwiftUI

struct Card: View {
    @Binding var title: String
    @Binding var description: String
    var body: some View {
        VStack {
            VStack(alignment: .leading) {
                Text(title)
                    .font(.title3)
                    .bold()
                    .padding(.bottom, 2)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(Color("MustardYellow"))
                    .underline(true, color: Color("MustardYellow"))
                    .frame(maxWidth: .infinity, alignment: .leading)
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
    }
}

#Preview {
    Card(title: .constant("Ultima ubicacion registrada"), description: .constant("Parque la choca"))
}


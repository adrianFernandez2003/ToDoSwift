

import SwiftUI


struct RoutineItem: View {
    @Binding var title: String
    @Binding var description: String
    @Binding var icon: String
    var onTap: () -> Void
    
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
                VStack(alignment: .leading) {
                    Text(title)
                        .font(.title3)
                        .bold()
                        .padding(.bottom, 2)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text(description)
                        .font(.subheadline)
                        .foregroundStyle(.gray)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(EdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 0))
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
            onTap()
        }
    }
}

#Preview {
    RoutineItem(
        title: .constant("Caminar en el parque"),
        description: .constant("Lunes - Viernes de 10:30A.M a 11:30A.M."),
        icon: .constant("plus"),
        onTap: {}
    )
}

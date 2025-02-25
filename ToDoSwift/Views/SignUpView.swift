import SwiftUI

struct SignUpView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var navigateToLogin = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color("PrimaryColor").ignoresSafeArea()
                
                VStack(spacing: 20) {
                    Text("Registrarse")
                        .font(.largeTitle)
                        .bold()
                        .padding(.bottom, 30)
                    
                    TextField("Correo electrónico", text: $email)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                    
                    SecureField("Contraseña", text: $password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                    
                    SecureField("Confirmar contraseña", text: $confirmPassword)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                    
                    Button(action: {
                        Task {
                            if password == confirmPassword {
                                do {
                                    try await signUp(email: email, password: password)
                                    navigateToLogin = true
                                } catch {
                                    alertMessage = error.localizedDescription
                                    showAlert = true
                                }
                            } else {
                                alertMessage = "Las contraseñas no coinciden"
                                showAlert = true
                            }
                        }
                    }) {
                        Text("Crear cuenta")
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    
                    NavigationLink(destination: LoginView().navigationBarBackButtonHidden(true), isActive: $navigateToLogin) {
                        Text("¿Ya tienes una cuenta? Inicia sesión")
                            .foregroundColor(.blue)
                    }
                }
                .padding()
                .alert("Error", isPresented: $showAlert) {
                    Button("Aceptar", role: .cancel) { }
                } message: {
                    Text(alertMessage)
                }
            }
        }
    }
}

#Preview {
    SignUpView()
}

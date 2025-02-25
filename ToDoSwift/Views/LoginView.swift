//
//  LoginView.swift
//  ToDoSwift
//
//  Created by José Adrián Fernández Méndez on 21/02/25.
//

import SwiftUI

struct LoginView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var navigateToHome = false  // State for navigation

    var body: some View {
        NavigationStack {
            ZStack {
                Color("PrimaryColor").ignoresSafeArea(.all)

                VStack(spacing: 20) {
                    Text("Iniciar sesión")
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

                    Button(action: {
                        Task {
                            do {
                                let success = try await login(email: email, password: password)
                                if success {
                                    navigateToHome = true  // Navegar a ContentView
                                } else {
                                    alertMessage = "Credenciales inválidas. Por favor, inténtalo de nuevo."
                                    showAlert = true
                                }
                            } catch {
                                alertMessage = "Error al iniciar sesión: \(error.localizedDescription)"
                                showAlert = true
                            }
                        }
                    }) {
                        Text("Iniciar sesión")
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)

                    NavigationLink(destination: SignUpView().navigationBarBackButtonHidden(true)) {
                        Text("¿No tienes cuenta? Regístrate")
                            .foregroundColor(.blue)
                    }
                    NavigationLink("", destination: ContentView().navigationBarBackButtonHidden(true), isActive: $navigateToHome)
                }
                .padding()
                .alert("Error", isPresented: $showAlert) {
                    Button("OK", role: .cancel) { }
                } message: {
                    Text(alertMessage)
                }
            }
        }
    }
}

#Preview {
    LoginView()
}

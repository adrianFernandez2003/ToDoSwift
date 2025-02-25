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
                    Text("Login")
                        .font(.largeTitle)
                        .bold()
                        .padding(.bottom, 30)

                    TextField("Email", text: $email)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()

                    SecureField("Password", text: $password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)

                    Button(action: {
                        Task {
                            do {
                                let success = try await login(email: email, password: password)
                                if success {
                                    navigateToHome = true  // Navigate to ContentView
                                } else {
                                    alertMessage = "Invalid credentials. Please try again."
                                    showAlert = true
                                }
                            } catch {
                                alertMessage = "Login failed: \(error.localizedDescription)"
                                showAlert = true
                            }
                        }
                    }) {
                        Text("Login")
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)

                    NavigationLink(destination: SignUpView().navigationBarBackButtonHidden(true)) {
                        Text("Don't have an account? Sign up")
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

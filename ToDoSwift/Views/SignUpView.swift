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
                    Text("Sign Up")
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
                    
                    SecureField("Confirm Password", text: $confirmPassword)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                    
                    Button(action: {
                        if password == confirmPassword {
                            navigateToLogin = true
                        } else {
                            alertMessage = "Passwords do not match"
                            showAlert = true
                        }
                    }) {
                        Text("Create Account")
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    
                    NavigationLink(destination: LoginView().navigationBarBackButtonHidden(true)) {
                        Text("Don't have an account? Sign up")
                            .foregroundColor(.blue)
                    }
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
    SignUpView()
}

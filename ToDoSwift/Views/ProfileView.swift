
import SwiftUI
import PhotosUI
import Storage


struct ProfileView: View {
    @State private var username = ""
    @State private var fullName = ""
    @State private var avatarUrl: String?
    @State private var backgroundUrl: String?
    @State private var isLoading = false
    @State private var avatarSelection: PhotosPickerItem?
    @State private var backgroundSelection: PhotosPickerItem?
    @State private var avatarImage: Image?
    @State private var backgroundImage: Image?
    @State private var navigateToLogin = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            // Upper half with image background
            VStack {
                HStack {
                    Spacer()
                    
                    VStack {
                        PhotosPicker(selection: $avatarSelection) {
                            if let avatarImage {
                                avatarImage
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 200, height: 200)
                                    .clipShape(Circle())
                                    .clipped()
                                    .overlay(Circle().stroke(Color.white, lineWidth: 4))
                            } else {
                                AsyncImage(url: URL(string: avatarUrl ?? "default-profile.png")) { image in
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 200, height: 200)
                                        .clipShape(Circle())
                                        .clipped()
                                        .overlay(Circle().stroke(Color.white, lineWidth: 4))
                                } placeholder: {
                                    Circle()
                                        .fill(Color.gray)
                                        .frame(width: 200, height: 200)
                                        .overlay(Circle().stroke(Color.white, lineWidth: 4))
                                }
                            }
                        }
                        .padding(.top, 100)
                        
                        TextField("Full Name", text: $fullName)
                            .font(.system(size: 20))
                            .bold()
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding(.top, 12)
                        
                        TextField("Username", text: $username)
                            .font(.system(size: 18))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding(.top, 4)
                    }
                    Spacer()
                }
                Spacer()
            }
            .frame(height: UIScreen.main.bounds.height / 2)
            .background(
                PhotosPicker(selection: $backgroundSelection) {
                    if let backgroundImage {
                        backgroundImage
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } else {
                        Image(systemName: "photo")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .overlay(
                                AsyncImage(url: URL(string: backgroundUrl ?? "default-background.jpg")) { image in
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                } placeholder: {
                                    Color.gray
                                }
                            )
                    }
                }
            )
            
            // Lower half with buttons
            VStack(spacing: 16) {
                Button(action: {
                    Task {
                        await updateProfile()
                    }
                }) {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text("Guardar cambios")
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                }
                .background(Color.blue)
                .cornerRadius(10)
                .disabled(isLoading)
                
                Button(action: {
                    Task {
                        try? await supabase.auth.signOut()
                        navigateToLogin = true
                    }
                }) {
                    Text("Cerrar sesion")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .cornerRadius(10)
                }
            }
            .padding(.horizontal)
            .padding(.top, 20)
            .frame(maxHeight: .infinity)
            .background(Color("PrimaryColor"))
        }
        .edgesIgnoringSafeArea(.all)
        .task {
            await fetchProfile()
        }
        .onChange(of: avatarSelection) { _, newValue in
            guard let newValue else { return }
            Task {
                if let data = try? await newValue.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    avatarImage = Image(uiImage: uiImage)
                    await uploadImage(data, bucket: "avatars", isAvatar: true)
                    await updateProfile()
                }
            }
        }
        .onChange(of: backgroundSelection) { _, newValue in
            guard let newValue else { return }
            Task {
                if let data = try? await newValue.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    backgroundImage = Image(uiImage: uiImage)
                    await uploadImage(data, bucket: "backgrounds", isAvatar: false)
                    await updateProfile()
                }
            }
        }
        .navigationDestination(isPresented: $navigateToLogin) {
            LoginView()
                .navigationBarBackButtonHidden(true)
        }
    }
    
    private func fetchProfile() async {
        do {
            let currentUser = try await supabase.auth.session.user
            
            let profile: Profile = try await supabase.database
                .from("profiles")
                .select()
                .eq("id", value: currentUser.id)
                .single()
                .execute()
                .value
            
            self.username = profile.username ?? ""
            self.fullName = profile.full_name ?? ""
            self.avatarUrl = profile.avatar_url
            self.backgroundUrl = profile.background_url
            
        } catch {
            debugPrint(error)
        }
    }
    
    private func updateProfile() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let currentUser = try await supabase.auth.session.user
            
            try await supabase.database
                .from("profiles")
                .update([
                    "username": username,
                    "full_name": fullName,
                    "avatar_url": avatarUrl,
                    "background_url": backgroundUrl
                ])
                .eq("id", value: currentUser.id)
                .execute()
        } catch {
            debugPrint(error)
        }
    }
    
    private func uploadImage(_ imageData: Data, bucket: String, isAvatar: Bool) async {
        do {
            let filePath = "\(UUID().uuidString).jpeg"
            
            try await supabase.storage
                .from(bucket)
                .upload(
                    path: filePath,
                    file: imageData,
                    options: .init(contentType: "image/jpeg")
                )
            
            let publicURL = try await supabase.storage
                .from(bucket)
                .createSignedURL(
                    path: filePath,
                    expiresIn: 3600 * 24 * 365
                )
            
            if isAvatar {
                self.avatarUrl = publicURL.absoluteString
            } else {
                self.backgroundUrl = publicURL.absoluteString
            }
        } catch {
            debugPrint(error)
        }
    }
}

#Preview {
    ProfileView()
}

struct Profile: Codable {
    let username: String?
    let full_name: String?
    let avatar_url: String?
    let background_url: String?
}

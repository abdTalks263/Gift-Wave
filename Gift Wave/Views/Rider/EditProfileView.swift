import SwiftUI
import UIKit

struct EditProfileView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var fullName: String = ""
    @State private var phoneNumber: String = ""
    @State private var city: String = ""
    @State private var showImagePicker = false
    @State private var selectedImage: UIImage?
    @State private var isLoading = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Profile Image Section
                VStack {
                    if let user = authViewModel.currentUser {
                        if let profileImageURL = user.profileImageURL {
                            AsyncImage(url: URL(string: profileImageURL)) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 120, height: 120)
                                    .clipShape(Circle())
                                    .overlay(editButton)
                            } placeholder: {
                                ProgressView()
                                    .frame(width: 120, height: 120)
                            }
                        } else if let selectedImage = selectedImage {
                            Image(uiImage: selectedImage)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 120, height: 120)
                                .clipShape(Circle())
                                .overlay(editButton)
                        } else {
                            Circle()
                                .fill(Color.gray.opacity(0.2))
                                .frame(width: 120, height: 120)
                                .overlay(
                                    Image(systemName: "camera.fill")
                                        .font(.system(size: 40))
                                        .foregroundColor(.gray)
                                )
                                .overlay(editButton)
                        }
                    }
                }
                .padding(.top)
                
                // Form Fields
                VStack(spacing: 20) {
                    FormField(title: "Full Name", text: $fullName, icon: "person.fill")
                    FormField(title: "Phone Number", text: $phoneNumber, icon: "phone.fill")
                    FormField(title: "City", text: $city, icon: "location.fill")
                }
                .padding(.horizontal)
                
                // Save Button
                Button(action: saveChanges) {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text("Save Changes")
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
                .padding(.horizontal)
                .disabled(isLoading)
            }
        }
        .navigationTitle("Edit Profile")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancel") {
                    dismiss()
                }
            }
        }
        .onAppear(perform: loadUserData)
        .sheet(isPresented: $showImagePicker) {
            ProfileImagePicker(image: $selectedImage)
        }
        .alert("Profile Update", isPresented: $showAlert) {
            Button("OK") {
                if !alertMessage.contains("Error") {
                    dismiss()
                }
            }
        } message: {
            Text(alertMessage)
        }
    }
    
    private var editButton: some View {
        Button(action: { showImagePicker = true }) {
            Circle()
                .fill(Color.blue)
                .frame(width: 32, height: 32)
                .overlay(
                    Image(systemName: "pencil")
                        .foregroundColor(.white)
                        .font(.system(size: 16))
                )
        }
        .offset(x: 40, y: 40)
    }
    
    private func loadUserData() {
        if let user = authViewModel.currentUser {
            fullName = user.fullName
            phoneNumber = user.phoneNumber
            city = user.city ?? ""
        }
    }
    
    private func saveChanges() {
        isLoading = true
        
        Task {
            do {
                if let userId = authViewModel.currentUser?.id {
                    // Upload new image if selected
                    var imageURL: String? = nil
                    if let image = selectedImage,
                       let imageData = image.jpegData(compressionQuality: 0.7) {
                        imageURL = try await authViewModel.uploadProfileImage(imageData: imageData, userId: userId)
                    }
                    
                    // Update profile data
                    try await authViewModel.updateProfile(
                        userId: userId,
                        fullName: fullName,
                        phoneNumber: phoneNumber,
                        city: city,
                        profileImageURL: imageURL
                    )
                    
                    await MainActor.run {
                        alertMessage = "Profile updated successfully"
                        showAlert = true
                        isLoading = false
                    }
                }
            } catch {
                await MainActor.run {
                    alertMessage = "Error updating profile: \(error.localizedDescription)"
                    showAlert = true
                    isLoading = false
                }
            }
        }
    }
}

struct FormField: View {
    let title: String
    @Binding var text: String
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .foregroundColor(.secondary)
                .font(.caption)
            
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.gray)
                TextField(title, text: $text)
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
        }
    }
}

#Preview {
    NavigationView {
        EditProfileView()
            .environmentObject(AuthViewModel())
    }
}

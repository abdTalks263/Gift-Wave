//
//  RiderRegistrationView.swift
//  Gift Wave
//
//  Created by Abdullah Latif on 04/08/2025.
//

import SwiftUI
import PhotosUI

struct RiderRegistrationView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var otpViewModel: OTPViewModel
    @Environment(\.dismiss) private var dismiss
    
    let email: String
    let password: String
    let fullName: String
    let phoneNumber: String
    
    @State private var cnic = ""
    @State private var selectedProvince = ""
    @State private var city = ""
    @State private var profileImageData: Data?
    @State private var showingCamera = false
    @State private var showingCNICValidation = false
    @State private var cnicValidationMessage = ""
    @State private var isCNICValid = false
    @State private var isPhoneVerified = false
    @State private var showingOTPVerification = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 25) {
                    // Header
                    VStack(spacing: 16) {
                        Image(systemName: "bicycle")
                            .font(.system(size: 50))
                            .foregroundColor(.blue)
                        
                        Text("Rider Registration")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text("Complete your profile to start delivering gifts")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 20)
                    
                    // Profile Photo
                    VStack(spacing: 16) {
                        Text("Profile Photo")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Button(action: {
                            checkCameraPermissionAndShow()
                        }) {
                            VStack(spacing: 12) {
                                if let profileImageData = profileImageData,
                                   let uiImage = UIImage(data: profileImageData) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 120, height: 120)
                                        .clipShape(Circle())
                                        .overlay(Circle().stroke(Color.blue, lineWidth: 3))
                                        .overlay(
                                            VStack {
                                                Spacer()
                                                HStack {
                                                    Spacer()
                                                    Image(systemName: "camera.circle.fill")
                                                        .font(.system(size: 30))
                                                        .foregroundColor(.blue)
                                                        .background(Color.white)
                                                        .clipShape(Circle())
                                                }
                                                .padding(.trailing, 5)
                                                .padding(.bottom, 5)
                                            }
                                        )
                                } else {
                                    Circle()
                                        .fill(Color.gray.opacity(0.2))
                                        .frame(width: 120, height: 120)
                                        .overlay(
                                            VStack(spacing: 8) {
                                                Image(systemName: "camera.fill")
                                                    .font(.system(size: 30))
                                                    .foregroundColor(.blue)
                                                
                                                Text("Take Photo")
                                                    .font(.caption)
                                                    .foregroundColor(.blue)
                                            }
                                        )
                                }
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        if profileImageData == nil {
                            Text("Please take a live photo using your camera")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        
                        // OTP Console Reminder
                        Text("💡 Tip: Check Xcode console for OTP code during development")
                            .font(.caption2)
                            .foregroundColor(.blue)
                            .multilineTextAlignment(.center)
                            .padding(.top, 8)
                    }
                    .padding(.horizontal, 30)
                    
                    // Additional Fields
                    VStack(spacing: 20) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("CNIC Number")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            HStack {
                                TextField("12345-1234567-1", text: $cnic)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .keyboardType(.numberPad)
                                    .onChange(of: cnic) { newValue in
                                        // Format CNIC automatically
                                        let formattedCNIC = DataValidator.formatCNIC(newValue)
                                        if formattedCNIC != newValue && !newValue.isEmpty {
                                            DispatchQueue.main.async {
                                                cnic = formattedCNIC
                                            }
                                        }
                                        validateCNIC(formattedCNIC)
                                    }
                                
                                Button(action: {
                                    Task {
                                        await verifyPhoneWithOTP()
                                    }
                                }) {
                                    Text(isPhoneVerified ? "Verified" : "Send OTP")
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .background(isPhoneVerified ? Color.green : Color.blue)
                                        .cornerRadius(6)
                                }
                                .disabled(cnic.isEmpty || !isCNICValid)
                            }
                            
                            if !cnicValidationMessage.isEmpty {
                                Text(cnicValidationMessage)
                                    .font(.caption)
                                    .foregroundColor(isCNICValid ? .green : .red)
                            } else {
                                Text("Enter your 13-digit CNIC number. Click 'Send OTP' to receive verification code on your phone and email.")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Province")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            Picker("Province", selection: $selectedProvince) {
                                Text("Select Province").tag("")
                                ForEach(PakistanData.provinces, id: \.self) { province in
                                    Text(province).tag(province)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("City")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            Picker("City", selection: $city) {
                                Text("Select City").tag("")
                                ForEach(availableCities, id: \.self) { city in
                                    Text(city).tag(city)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                            .disabled(selectedProvince.isEmpty)
                        }
                        
                        if let errorMessage = authViewModel.errorMessage {
                            VStack(spacing: 8) {
                                Text(errorMessage)
                                    .foregroundColor(.red)
                                    .font(.caption)
                                    .multilineTextAlignment(.center)
                                
                                // Show helpful action if email already exists
                                if errorMessage.contains("already registered") {
                                    Button("Go to Login Instead") {
                                        dismiss()
                                    }
                                    .font(.caption)
                                    .foregroundColor(.blue)
                                    .padding(.top, 4)
                                }
                            }
                        }
                        
                        Button(action: {
                            Task {
                                // Use clean CNIC for registration
                                let cleanCNIC = cnic.replacingOccurrences(of: "-", with: "")
                                let riderRegistration = RiderRegistration(
                                    email: email,
                                    phoneNumber: phoneNumber,
                                    fullName: fullName,
                                    cnic: cleanCNIC,
                                    city: city,
                                    profileImageData: profileImageData
                                )
                                
                                await authViewModel.registerRider(
                                    riderRegistration: riderRegistration,
                                    password: password
                                )
                            }
                        }) {
                            HStack {
                                if authViewModel.isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(0.8)
                                } else {
                                    Text("Complete Registration")
                                        .fontWeight(.semibold)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                        .disabled(authViewModel.isLoading || !isFormValid || !isCNICValid || !isPhoneVerified || profileImageData == nil)
                    }
                    .padding(.horizontal, 30)
                    
                    // Info Text
                    VStack(spacing: 8) {
                        Text("Verification Required")
                            .font(.headline)
                            .foregroundColor(.orange)
                        
                        Text("Your registration will be reviewed by our team. You'll be notified once approved.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, 30)
                    
                    Spacer(minLength: 50)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Back") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingOTPVerification) {
                OTPVerificationView(
                    verificationType: .phone,
                    value: phoneNumber,
                    email: email,
                    onVerificationSuccess: {
                        isPhoneVerified = true
                        cnicValidationMessage = "Verification successful! CNIC is now linked to your verified contact information."
                    }
                )
                .environmentObject(otpViewModel)
            }
            .sheet(isPresented: $showingCamera) {
                SafeCameraView(imageData: $profileImageData)
            }
        }
    }
    
    private var availableCities: [String] {
        if selectedProvince.isEmpty {
            return []
        }
        return PakistanData.getCities(for: selectedProvince)
    }
    
    private var isFormValid: Bool {
        !cnic.isEmpty && !selectedProvince.isEmpty && !city.isEmpty && profileImageData != nil
    }
    
    private func validateCNIC(_ cnic: String) {
        // Remove formatting for validation
        let cleanCNIC = cnic.replacingOccurrences(of: "-", with: "")
        let validation = DataValidator.validateCNIC(cleanCNIC)
        isCNICValid = validation.isValid
        cnicValidationMessage = validation.message
        
        // For debugging, you can uncomment this line to see detailed validation info
        // print(DataValidator.debugCNICValidation(cleanCNIC))
    }
    
    private func verifyPhoneWithOTP() async {
        // Send OTP to both phone number and email for verification
        let success = await otpViewModel.validatePhoneAndEmailWithOTP(phone: phoneNumber, email: email)
        if success {
            showingOTPVerification = true
        }
    }
    
    // MARK: - Camera Functions
    
    private func checkCameraPermissionAndShow() {
        // Simply show the camera view - it will handle all permissions internally
        showingCamera = true
    }
}

#Preview {
    RiderRegistrationView(
        email: "rider@example.com",
        password: "password123",
        fullName: "John Doe",
        phoneNumber: "+1234567890"
    )
    .environmentObject(AuthViewModel())
    .environmentObject(OTPViewModel())
} 
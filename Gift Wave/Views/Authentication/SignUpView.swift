//
//  SignUpView.swift
//  Gift Wave
//
//  Created by Abdullah Latif on 04/08/2025.
//

import SwiftUI

struct SignUpView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var otpViewModel: OTPViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var fullName = ""
    @State private var phoneNumber = ""
    @State private var selectedUserType: UserType = .sender
    @State private var showingRiderRegistration = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 25) {
                    // Header
                    VStack(spacing: 16) {
                        Image(systemName: "person.badge.plus")
                            .font(.system(size: 50))
                            .foregroundColor(.blue)
                        
                        Text("Create Account")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text("Join GiftWave to send or deliver gifts")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 20)
                    
                    // User Type Selection
                    VStack(alignment: .leading, spacing: 12) {
                        Text("I want to:")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        HStack(spacing: 12) {
                            UserTypeButton(
                                type: .sender,
                                isSelected: selectedUserType == .sender,
                                action: { selectedUserType = .sender }
                            )
                            
                            UserTypeButton(
                                type: .rider,
                                isSelected: selectedUserType == .rider,
                                action: { selectedUserType = .rider }
                            )
                        }
                    }
                    .padding(.horizontal, 30)
                    
                    // Registration Form
                    VStack(spacing: 20) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Full Name")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            TextField("Enter your full name", text: $fullName)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Email")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            TextField("Enter your email", text: $email)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Phone Number")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            TextField("Enter your phone number", text: $phoneNumber)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.phonePad)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Password")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            SecureField("Enter your password", text: $password)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Confirm Password")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            SecureField("Confirm your password", text: $confirmPassword)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        
                        if let errorMessage = authViewModel.errorMessage {
                            Text(errorMessage)
                                .foregroundColor(.red)
                                .font(.caption)
                                .multilineTextAlignment(.center)
                        }
                        
                        Button(action: {
                            if selectedUserType == .rider {
                                showingRiderRegistration = true
                            } else {
                                Task {
                                    await authViewModel.signUp(
                                        email: email,
                                        password: password,
                                        fullName: fullName,
                                        phoneNumber: phoneNumber,
                                        userType: selectedUserType
                                    )
                                }
                            }
                        }) {
                            HStack {
                                if authViewModel.isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(0.8)
                                } else {
                                    Text("Create Account")
                                        .fontWeight(.semibold)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                        .disabled(authViewModel.isLoading || !isFormValid)
                    }
                    .padding(.horizontal, 30)
                    
                    // Login Link
                    HStack {
                        Text("Already have an account?")
                            .foregroundColor(.secondary)
                        
                        Button("Sign In") {
                            dismiss()
                        }
                        .foregroundColor(.blue)
                        .fontWeight(.semibold)
                    }
                    
                    // Debug Button (remove in production)
                    Button("Test Firebase Connection") {
                        Task {
                            await authViewModel.testFirebaseConnection()
                        }
                    }
                    .font(.caption)
                    .foregroundColor(.orange)
                    .padding(.top, 10)
                    
                    Spacer(minLength: 50)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingRiderRegistration) {
                RiderRegistrationView(
                    email: email,
                    password: password,
                    fullName: fullName,
                    phoneNumber: phoneNumber
                )
                .environmentObject(authViewModel)
                .environmentObject(OTPViewModel())
            }
        }
    }
    
    private var isFormValid: Bool {
        !email.isEmpty && !password.isEmpty && !confirmPassword.isEmpty &&
        !fullName.isEmpty && !phoneNumber.isEmpty && password == confirmPassword
    }
}

struct UserTypeButton: View {
    let type: UserType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: type == .sender ? "gift" : "bicycle")
                    .font(.system(size: 24))
                    .foregroundColor(isSelected ? .white : .blue)
                
                Text(type == .sender ? "Send Gifts" : "Deliver Gifts")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(isSelected ? .white : .blue)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 80)
            .background(isSelected ? Color.blue : Color.blue.opacity(0.1))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.blue, lineWidth: isSelected ? 0 : 1)
            )
        }
    }
}

#Preview {
    SignUpView()
        .environmentObject(AuthViewModel())
        .environmentObject(OTPViewModel())
} 
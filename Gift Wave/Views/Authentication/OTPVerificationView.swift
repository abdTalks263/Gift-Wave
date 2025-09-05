//
//  OTPVerificationView.swift
//  Gift Wave
//
//  Created by Abdullah Latif on 04/08/2025.
//

import SwiftUI

struct OTPVerificationView: View {
    @EnvironmentObject var otpViewModel: OTPViewModel
    @Environment(\.dismiss) private var dismiss
    
    let verificationType: OTPType
    let value: String
    let email: String?
    let onVerificationSuccess: () -> Void
    
    @State private var otpCode = ""
    @State private var showingResendAlert = false
    @State private var timeRemaining = 300 // 5 minutes in seconds
    @State private var timer: Timer?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                // Header
                VStack(spacing: 16) {
                    Image(systemName: "checkmark.shield.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                    
                    Text("Verify Contact")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("We've sent a 6-digit code to verify your contact information")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    
                    VStack(spacing: 8) {
                        if verificationType == .phone && email != nil {
                            // Show both phone and email for rider registration
                            Text("📱 \(value)")
                                .font(.subheadline)
                                .foregroundColor(.primary)
                            Text("📧 \(email!)")
                                .font(.subheadline)
                                .foregroundColor(.primary)
                        } else {
                            Text(value)
                                .font(.headline)
                                .foregroundColor(.primary)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                }
                .padding(.top, 40)
                
                // OTP Input
                VStack(spacing: 20) {
                    // Development OTP Display
                    if otpViewModel.showDevelopmentOTP, let otp = otpViewModel.currentOTP {
                        VStack(spacing: 8) {
                            Text("🧪 Development Mode")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.orange)
                            
                            Text("OTP Code: \(otp.otpCode)")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.blue)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(8)
                            
                            VStack(spacing: 4) {
                                Text("📧 Email: Would be sent to your email")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text("📱 SMS: Would be sent to your phone")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text("🔧 Check Xcode console for OTP details")
                                    .font(.caption)
                                    .foregroundColor(.blue)
                                    .fontWeight(.semibold)
                            }
                        }
                        .padding(.bottom, 10)
                    }
                    
                    Text("Enter 6-digit code")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    HStack(spacing: 12) {
                        ForEach(0..<6, id: \.self) { index in
                            OTPDigitField(
                                index: index,
                                otpCode: $otpCode,
                                isActive: index == otpCode.count
                            )
                        }
                    }
                    
                    if !otpCode.isEmpty && otpCode.count == 6 {
                        Button(action: verifyOTP) {
                            HStack {
                                if otpViewModel.isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(0.8)
                                } else {
                                    Text("Verify")
                                        .fontWeight(.semibold)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                        .disabled(otpViewModel.isLoading)
                    }
                }
                .padding(.horizontal, 30)
                
                // Timer and Resend
                VStack(spacing: 16) {
                    if timeRemaining > 0 {
                        Text("Resend code in \(timeRemaining / 60):\(String(format: "%02d", timeRemaining % 60))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    } else {
                        Button("Resend Code") {
                            showingResendAlert = true
                        }
                        .font(.subheadline)
                        .foregroundColor(.blue)
                    }
                    
                    if let errorMessage = otpViewModel.errorMessage {
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                    }
                }
                
                Spacer()
            }
            .navigationTitle("OTP Verification")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                startTimer()
            }
            .onDisappear {
                stopTimer()
            }
            .alert("Resend OTP?", isPresented: $showingResendAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Resend") {
                    Task {
                        await otpViewModel.resendOTP()
                        timeRemaining = 300
                        startTimer()
                    }
                }
            } message: {
                Text("A new 6-digit code will be sent to your phone and email.")
            }
        }
    }
    
    private func verifyOTP() {
        Task {
            let success = await otpViewModel.verifyOTP(otpCode)
            if success {
                onVerificationSuccess()
                dismiss()
            }
        }
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                stopTimer()
            }
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}

struct OTPDigitField: View {
    let index: Int
    @Binding var otpCode: String
    let isActive: Bool
    
    var body: some View {
        TextField("", text: Binding(
            get: {
                if index < otpCode.count {
                    return String(otpCode[otpCode.index(otpCode.startIndex, offsetBy: index)])
                }
                return ""
            },
            set: { newValue in
                if newValue.count <= 1 {
                    if newValue.isEmpty {
                        if otpCode.count > index {
                            otpCode.remove(at: otpCode.index(otpCode.startIndex, offsetBy: index))
                        }
                    } else {
                        if index < otpCode.count {
                            otpCode.remove(at: otpCode.index(otpCode.startIndex, offsetBy: index))
                            otpCode.insert(newValue.first!, at: otpCode.index(otpCode.startIndex, offsetBy: index))
                        } else {
                            otpCode.append(newValue)
                        }
                    }
                }
            }
        ))
        .keyboardType(.numberPad)
        .multilineTextAlignment(.center)
        .font(.title2)
        .fontWeight(.bold)
        .frame(width: 45, height: 55)
        .background(isActive ? Color.blue.opacity(0.1) : Color.gray.opacity(0.1))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(isActive ? Color.blue : Color.clear, lineWidth: 2)
        )
    }
}

#Preview {
    OTPVerificationView(
        verificationType: .phone,
        value: "+92 300 1234567",
        email: "user@example.com",
        onVerificationSuccess: {}
    )
    .environmentObject(OTPViewModel())
} 
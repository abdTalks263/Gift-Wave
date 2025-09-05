//
//  OTPViewModel.swift
//  Gift Wave
//
//  Created by Abdullah Latif on 04/08/2025.
//

import Foundation
import FirebaseFirestore

@MainActor
class OTPViewModel: ObservableObject {
    @Published var currentOTP: OTPVerification?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showOTPVerification = false
    @Published var isVerified = false
    @Published var showDevelopmentOTP = false // For development/testing
    
    private let db = Firestore.firestore()
    
    // MARK: - OTP Generation
    
    func generateOTP(phoneNumber: String? = nil, cnicNumber: String? = nil, email: String? = nil, type: OTPType) async {
        print("🚀 Generating OTP...")
        print("📱 Phone: \(phoneNumber ?? "nil")")
        print("📧 Email: \(email ?? "nil")")
        print("🆔 Type: \(type.rawValue)")
        
        isLoading = true
        errorMessage = nil
        showDevelopmentOTP = false // Reset development OTP display
        
        do {
            let otp = OTPVerification(
                phoneNumber: phoneNumber,
                cnicNumber: cnicNumber,
                email: email,
                otpType: type
            )
            
            // Save OTP to Firestore
            let documentRef = try await db.collection("otp_verifications").addDocument(from: otp)
            
            // Update current OTP with document ID
            var updatedOTP = otp
            updatedOTP.id = documentRef.documentID
            currentOTP = updatedOTP
            
            print("✅ OTP generated and saved to database")
            
            // Send OTP via SMS/Email (in real app, integrate with SMS/Email service)
            await sendOTP(otp: otp, type: type)
            
            showOTPVerification = true
            
        } catch {
            print("❌ Failed to generate OTP: \(error)")
            errorMessage = "Failed to generate OTP: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    // MARK: - OTP Verification
    
    func verifyOTP(_ enteredOTP: String) async -> Bool {
        guard let otp = currentOTP else {
            errorMessage = "No OTP found"
            return false
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            // Check if OTP is expired
            if Date() > otp.expiresAt {
                await updateOTPStatus(status: .expired)
                errorMessage = "OTP has expired. Please request a new one."
                isLoading = false
                return false
            }
            
            // Check if max attempts reached
            if otp.attempts >= otp.maxAttempts {
                await updateOTPStatus(status: .failed)
                errorMessage = "Maximum attempts reached. Please request a new OTP."
                isLoading = false
                return false
            }
            
            // Verify OTP
            if enteredOTP == otp.otpCode {
                await updateOTPStatus(status: .verified)
                isVerified = true
                showDevelopmentOTP = false // Hide development OTP after verification
                isLoading = false
                return true
            } else {
                // Increment attempts
                await incrementOTPAttempts()
                errorMessage = "Invalid OTP. Please try again."
                isLoading = false
                return false
            }
            
        } catch {
            errorMessage = "Failed to verify OTP: \(error.localizedDescription)"
            isLoading = false
            return false
        }
    }
    
    // MARK: - Resend OTP
    
    func resendOTP() async {
        guard let otp = currentOTP else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            // Create new OTP
            let newOTP = OTPVerification(
                phoneNumber: otp.phoneNumber,
                cnicNumber: otp.cnicNumber,
                email: otp.email,
                otpType: otp.otpType
            )
            
            // Delete old OTP
            if let oldOTPId = otp.id {
                try await db.collection("otp_verifications").document(oldOTPId).delete()
            }
            
            // Save new OTP
            let documentRef = try await db.collection("otp_verifications").addDocument(from: newOTP)
            
            var updatedOTP = newOTP
            updatedOTP.id = documentRef.documentID
            currentOTP = updatedOTP
            
            // Send new OTP
            await sendOTP(otp: newOTP, type: newOTP.otpType)
            
        } catch {
            errorMessage = "Failed to resend OTP: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    // MARK: - Helper Methods
    
    private func sendOTP(otp: OTPVerification, type: OTPType) async {
        print("📤 Sending OTP...")
        
        // Clear console and show prominent OTP display
        print("")
        print("🔐 ========================================")
        print("🔐           OTP VERIFICATION")
        print("🔐 ========================================")
        print("🔐 Type: \(type.rawValue.uppercased())")
        print("🔐 OTP Code: \(otp.otpCode)")
        print("🔐 Expires: \(otp.expiresAt.formatted())")
        print("🔐 ========================================")
        print("")
        
        // Send to phone if available
        if let phoneNumber = otp.phoneNumber {
            print("📱 SMS OTP sent to \(phoneNumber): \(otp.otpCode)")
            await sendSMSOTP(phoneNumber: phoneNumber, otpCode: otp.otpCode)
        }
        
        // Send to email if available
        if let email = otp.email {
            print("📧 Email OTP sent to \(email): \(otp.otpCode)")
            await sendEmailOTP(email: email, otpCode: otp.otpCode)
        }
        
        // Show OTP in UI for development/testing
        showDevelopmentOTP = true
        
        // Simulate network delay
        try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
    }
    
    private func sendEmailOTP(email: String, otpCode: String) async {
        // For now, we'll use a simple email service
        // In production, integrate with SendGrid, Mailgun, or Firebase Functions
        
        let emailContent = """
        <html>
        <body>
            <h2>Gift Wave - OTP Verification</h2>
            <p>Your OTP code is: <strong>\(otpCode)</strong></p>
            <p>This code will expire in 10 minutes.</p>
            <p>If you didn't request this code, please ignore this email.</p>
        </body>
        </html>
        """
        
        // For development, we'll just print the email content
        print("📧 EMAIL CONTENT:")
        print("To: \(email)")
        print("Subject: Gift Wave - OTP Verification")
        print("Body: \(emailContent)")
        
        // TODO: Integrate with real email service
        // Example with SendGrid:
        // let sendGrid = SendGrid(apiKey: "YOUR_API_KEY")
        // try await sendGrid.send(email: email, subject: "Gift Wave OTP", html: emailContent)
        
        // For now, show success message
        print("✅ Email OTP would be sent to: \(email)")
        print("🔑 OTP Code: \(otpCode)")
    }
    
    private func sendSMSOTP(phoneNumber: String, otpCode: String) async {
        // For now, we'll simulate SMS sending
        // In production, integrate with Twilio, Firebase Phone Auth, or other SMS service
        
        let smsContent = "Gift Wave OTP: \(otpCode). Valid for 10 minutes. Don't share this code."
        
        // For development, we'll just print the SMS content
        print("📱 SMS CONTENT:")
        print("To: \(phoneNumber)")
        print("Message: \(smsContent)")
        
        // TODO: Integrate with real SMS service
        // Example with Twilio:
        // let twilio = Twilio(accountSid: "YOUR_ACCOUNT_SID", authToken: "YOUR_AUTH_TOKEN")
        // try await twilio.sendSMS(to: phoneNumber, message: smsContent)
        
        // For now, show success message
        print("✅ SMS OTP would be sent to: \(phoneNumber)")
        print("🔑 OTP Code: \(otpCode)")
    }
    
    private func updateOTPStatus(status: OTPStatus) async {
        guard let otpId = currentOTP?.id else { return }
        
        do {
            var updateData: [String: Any] = ["status": status.rawValue]
            
            if status == .verified {
                updateData["verifiedAt"] = Date()
            }
            
            try await db.collection("otp_verifications").document(otpId).updateData(updateData)
            
            // Update local OTP
            if var updatedOTP = currentOTP {
                updatedOTP.status = status
                if status == .verified {
                    updatedOTP.verifiedAt = Date()
                }
                currentOTP = updatedOTP
            }
        } catch {
            print("Failed to update OTP status: \(error)")
        }
    }
    
    private func incrementOTPAttempts() async {
        guard let otpId = currentOTP?.id else { return }
        
        do {
            let newAttempts = (currentOTP?.attempts ?? 0) + 1
            try await db.collection("otp_verifications").document(otpId).updateData([
                "attempts": newAttempts
            ])
            
            // Update local OTP
            if var updatedOTP = currentOTP {
                updatedOTP.attempts = newAttempts
                currentOTP = updatedOTP
            }
        } catch {
            print("Failed to increment OTP attempts: \(error)")
        }
    }
    
    // MARK: - Validation Methods
    
    func validateCNICWithOTP(_ cnic: String) async -> Bool {
        // This method is deprecated - CNIC cannot receive OTP
        // Use validatePhoneWithOTP instead to verify phone number
        errorMessage = "CNIC verification should be done through phone verification"
        return false
    }
    
    func validatePhoneWithOTP(_ phone: String) async -> Bool {
        // First validate phone format
        let validation = DataValidator.validatePhoneNumber(phone)
        guard validation.isValid else {
            errorMessage = validation.message
            return false
        }
        
        // Generate OTP for phone verification
        await generateOTP(phoneNumber: phone, cnicNumber: nil, email: nil, type: .phone)
        return true
    }
    
    func validateEmailWithOTP(_ email: String) async -> Bool {
        // First validate email format
        let validation = DataValidator.validateEmail(email)
        guard validation.isValid else {
            errorMessage = validation.message
            return false
        }
        
        // Generate OTP for email verification
        await generateOTP(phoneNumber: nil, cnicNumber: nil, email: email, type: .email)
        return true
    }
    
    func validatePhoneAndEmailWithOTP(phone: String, email: String) async -> Bool {
        print("🔍 Starting phone and email validation...")
        print("📱 Phone: \(phone)")
        print("📧 Email: \(email)")
        
        // Validate both phone and email formats
        let phoneValidation = DataValidator.validatePhoneNumber(phone)
        let emailValidation = DataValidator.validateEmail(email)
        
        print("📱 Phone validation: \(phoneValidation.isValid) - \(phoneValidation.message)")
        print("📧 Email validation: \(emailValidation.isValid) - \(emailValidation.message)")
        
        guard phoneValidation.isValid else {
            errorMessage = phoneValidation.message
            print("❌ Phone validation failed: \(phoneValidation.message)")
            return false
        }
        
        guard emailValidation.isValid else {
            errorMessage = emailValidation.message
            print("❌ Email validation failed: \(emailValidation.message)")
            return false
        }
        
        print("✅ Both validations passed, generating OTP...")
        
        // Generate OTP and send to both phone and email
        await generateOTP(phoneNumber: phone, cnicNumber: nil, email: email, type: .phone)
        return true
    }
} 
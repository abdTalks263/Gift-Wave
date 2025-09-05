//
//  OTPVerification.swift
//  Gift Wave
//
//  Created by Abdullah Latif on 04/08/2025.
//

import Foundation
import FirebaseFirestore

enum OTPType: String, Codable {
    case phone = "phone"
    case cnic = "cnic"
    case email = "email"
}

enum OTPStatus: String, Codable {
    case pending = "pending"
    case verified = "verified"
    case expired = "expired"
    case failed = "failed"
}

struct OTPVerification: Identifiable, Codable {
    @DocumentID var id: String?
    let userId: String?
    let phoneNumber: String?
    let cnicNumber: String?
    let email: String?
    let otpType: OTPType
    let otpCode: String
    var status: OTPStatus
    var attempts: Int
    let maxAttempts: Int
    let expiresAt: Date
    let createdAt: Date
    var verifiedAt: Date?
    
    init(userId: String? = nil, phoneNumber: String? = nil, cnicNumber: String? = nil, email: String? = nil, otpType: OTPType) {
        self.userId = userId
        self.phoneNumber = phoneNumber
        self.cnicNumber = cnicNumber
        self.email = email
        self.otpType = otpType
        self.otpCode = String(format: "%06d", Int.random(in: 100000...999999))
        self.status = .pending
        self.attempts = 0
        self.maxAttempts = 3
        self.expiresAt = Date().addingTimeInterval(5 * 60) // 5 minutes
        self.createdAt = Date()
        self.verifiedAt = nil
    }
}

struct ValidationResult {
    let isValid: Bool
    let message: String
} 
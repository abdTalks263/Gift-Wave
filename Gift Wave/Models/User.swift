//
//  User.swift
//  Gift Wave
//
//  Created by Abdullah Latif on 04/08/2025.
//

import Foundation
import FirebaseFirestore

enum UserType: String, Codable, CaseIterable {
    case sender = "sender"
    case rider = "rider"
}

enum RiderStatus: String, Codable, CaseIterable {
    case pending = "pending"
    case approved = "approved"
    case rejected = "rejected"
    case banned = "banned"
}

struct User: Identifiable, Codable {
    @DocumentID var id: String?
    let email: String
    let phoneNumber: String
    let fullName: String
    let userType: UserType
    
    // Rider specific fields
    let cnic: String?
    let city: String?
    let riderStatus: RiderStatus?
    let statusReason: String? // Reason for rejection/ban
    let profileImageURL: String?
    let averageRating: Double?
    let totalDeliveries: Int?
    
    // Security fields
    let isEmailVerified: Bool
    let isPhoneVerified: Bool
    let twoFactorEnabled: Bool
    let lastLoginAt: Date?
    let loginAttempts: Int
    let isBlocked: Bool
    let blockedReason: String?
    let createdAt: Date
    let updatedAt: Date
    
    // Custom coding keys to handle Firestore properly
    enum CodingKeys: String, CodingKey {
        case id
        case email
        case phoneNumber
        case fullName
        case userType
        case cnic
        case city
        case riderStatus
        case statusReason
        case profileImageURL
        case averageRating
        case totalDeliveries
        case isEmailVerified
        case isPhoneVerified
        case twoFactorEnabled
        case lastLoginAt
        case loginAttempts
        case isBlocked
        case blockedReason
        case createdAt
        case updatedAt
    }
    
    // Computed properties
    var isRider: Bool {
        return userType == .rider
    }
    
    var isApprovedRider: Bool {
        return isRider && riderStatus == .approved
    }
    
    init(email: String, phoneNumber: String, fullName: String, userType: UserType) {
        self.email = email
        self.phoneNumber = phoneNumber
        self.fullName = fullName
        self.userType = userType
        self.cnic = nil
        self.city = nil
        self.riderStatus = nil
        self.statusReason = nil
        self.profileImageURL = nil
        self.averageRating = nil
        self.totalDeliveries = nil
        self.isEmailVerified = false
        self.isPhoneVerified = false
        self.twoFactorEnabled = false
        self.lastLoginAt = nil
        self.loginAttempts = 0
        self.isBlocked = false
        self.blockedReason = nil
        self.createdAt = Date()
        self.updatedAt = Date()
    }
    
    init(rider: RiderRegistration, profileImageURL: String? = nil) {
        self.email = rider.email
        self.phoneNumber = rider.phoneNumber
        self.fullName = rider.fullName
        self.userType = .rider
        self.cnic = rider.cnic
        self.city = rider.city
        self.riderStatus = .pending
        self.statusReason = nil
        self.profileImageURL = profileImageURL
        self.averageRating = 0.0
        self.totalDeliveries = 0
        self.isEmailVerified = false
        self.isPhoneVerified = false
        self.twoFactorEnabled = false
        self.lastLoginAt = nil
        self.loginAttempts = 0
        self.isBlocked = false
        self.blockedReason = nil
        self.createdAt = Date()
        self.updatedAt = Date()
    }
} 
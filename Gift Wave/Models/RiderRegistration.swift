//
//  RiderRegistration.swift
//  Gift Wave
//
//  Created by Abdullah Latif on 04/08/2025.
//

import Foundation

struct RiderRegistration: Codable {
    let email: String
    let phoneNumber: String
    let fullName: String
    let cnic: String
    let city: String
    let profileImageData: Data?
    
    init(email: String, phoneNumber: String, fullName: String, cnic: String, city: String, profileImageData: Data? = nil) {
        self.email = email
        self.phoneNumber = phoneNumber
        self.fullName = fullName
        self.cnic = cnic
        self.city = city
        self.profileImageData = profileImageData
    }
} 
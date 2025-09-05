//
//  DataValidator.swift
//  Gift Wave
//
//  Created by Abdullah Latif on 04/08/2025.
//

import Foundation

struct DataValidator {
    
    // MARK: - CNIC Validation
    
    static func validateCNIC(_ cnic: String) -> ValidationResult {
        // Remove any spaces, dashes, or underscores
        let cleanCNIC = cnic.replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "-", with: "")
            .replacingOccurrences(of: "_", with: "")
        
        // Check length (13 digits)
        guard cleanCNIC.count == 13 else {
            return ValidationResult(isValid: false, message: "CNIC must be exactly 13 digits")
        }
        
        // Check if all characters are digits
        guard cleanCNIC.allSatisfy({ $0.isNumber }) else {
            return ValidationResult(isValid: false, message: "CNIC must contain only numbers")
        }
        
        // Validate province code (first 2 digits)
        let provinceCode = Int(String(cleanCNIC.prefix(2))) ?? 0
        if !isValidProvinceCode(provinceCode) {
            return ValidationResult(isValid: false, message: "Invalid province code (\(provinceCode)) in CNIC")
        }
        
        // Validate check digit (last digit)
        if !isValidCheckDigit(cleanCNIC) {
            let checkDigit = String(cleanCNIC.suffix(1))
            return ValidationResult(isValid: false, message: "Invalid check digit (\(checkDigit)) in CNIC")
        }
        
        return ValidationResult(isValid: true, message: "CNIC is valid")
    }
    
    // Debug function to test CNIC validation
    static func debugCNICValidation(_ cnic: String) -> String {
        let cleanCNIC = cnic.replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "-", with: "")
            .replacingOccurrences(of: "_", with: "")
        
        var debug = "CNIC: \(cleanCNIC)\n"
        debug += "Length: \(cleanCNIC.count) (should be 13)\n"
        debug += "All digits: \(cleanCNIC.allSatisfy({ $0.isNumber }))\n"
        
        if cleanCNIC.count >= 2 {
            let provinceCode = Int(String(cleanCNIC.prefix(2))) ?? 0
            debug += "Province code: \(provinceCode) (valid: \(isValidProvinceCode(provinceCode)))\n"
        }
        
        if cleanCNIC.count >= 13 {
            let checkDigit = String(cleanCNIC.suffix(1))
            debug += "Check digit: \(checkDigit) (valid: \(isValidCheckDigit(cleanCNIC)))\n"
        }
        
        return debug
    }
    
    // Format CNIC with dashes (XXXXX-XXXXXXX-X)
    static func formatCNIC(_ cnic: String) -> String {
        // Remove any existing formatting
        let cleanCNIC = cnic.replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "-", with: "")
            .replacingOccurrences(of: "_", with: "")
        
        // Only allow digits
        let digitsOnly = cleanCNIC.filter { $0.isNumber }
        
        // Don't format if not enough digits
        guard digitsOnly.count > 0 else {
            return ""
        }
        
        // Limit to 13 digits
        let limitedDigits = String(digitsOnly.prefix(13))
        
        // Format based on length
        switch limitedDigits.count {
        case 0...5:
            return limitedDigits
        case 6...12:
            let firstFive = String(limitedDigits.prefix(5))
            let remaining = String(limitedDigits.dropFirst(5))
            return "\(firstFive)-\(remaining)"
        case 13:
            let firstFive = String(limitedDigits.prefix(5))
            let middleSeven = String(limitedDigits.dropFirst(5).prefix(7))
            let lastOne = String(limitedDigits.suffix(1))
            return "\(firstFive)-\(middleSeven)-\(lastOne)"
        default:
            return limitedDigits
        }
    }
    
    private static func isValidProvinceCode(_ code: Int) -> Bool {
        // Valid province codes for Pakistani CNIC
        // Common province codes: 1-99 are generally valid
        // For now, accept any reasonable 2-digit code
        return code >= 1 && code <= 99
    }
    
    private static func isValidCheckDigit(_ cnic: String) -> Bool {
        // For now, use a simpler validation approach
        // The check digit should be a single digit (0-9)
        let checkDigit = Int(String(cnic.suffix(1))) ?? -1
        
        // Basic validation: check digit should be between 0-9
        guard checkDigit >= 0 && checkDigit <= 9 else {
            return false
        }
        
        // For production, implement the proper Pakistani CNIC algorithm
        // For now, accept any valid single digit as check digit
        return true
    }
    
    // MARK: - Phone Number Validation
    
    static func validatePhoneNumber(_ phone: String) -> ValidationResult {
        // Remove any spaces, dashes, or plus signs
        let cleanPhone = phone.replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "-", with: "")
            .replacingOccurrences(of: "+", with: "")
        
        // Check if it starts with Pakistan country code
        if cleanPhone.hasPrefix("92") {
            let withoutCountryCode = String(cleanPhone.dropFirst(2))
            return validateLocalPhoneNumber(withoutCountryCode)
        }
        
        // Check if it's a local number (starts with 0)
        if cleanPhone.hasPrefix("0") {
            let withoutZero = String(cleanPhone.dropFirst())
            return validateLocalPhoneNumber(withoutZero)
        }
        
        // Check if it's already a local number
        return validateLocalPhoneNumber(cleanPhone)
    }
    
    private static func validateLocalPhoneNumber(_ phone: String) -> ValidationResult {
        // Check length (10 digits for local number)
        guard phone.count == 10 else {
            return ValidationResult(isValid: false, message: "Phone number must be 10 digits (excluding country code)")
        }
        
        // Check if all characters are digits
        guard phone.allSatisfy({ $0.isNumber }) else {
            return ValidationResult(isValid: false, message: "Phone number must contain only numbers")
        }
        
        // Check if it starts with valid mobile prefixes
        let validPrefixes = ["3", "4", "5", "6", "7", "8", "9"]
        let firstDigit = String(phone.prefix(1))
        
        guard validPrefixes.contains(firstDigit) else {
            return ValidationResult(isValid: false, message: "Invalid mobile number prefix")
        }
        
        return ValidationResult(isValid: true, message: "Phone number is valid")
    }
    
    // MARK: - Email Validation
    
    static func validateEmail(_ email: String) -> ValidationResult {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        
        if emailPredicate.evaluate(with: email) {
            return ValidationResult(isValid: true, message: "Email is valid")
        } else {
            return ValidationResult(isValid: false, message: "Please enter a valid email address")
        }
    }
    
    // MARK: - Name Validation
    
    static func validateName(_ name: String) -> ValidationResult {
        // Remove extra spaces
        let cleanName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Check minimum length
        guard cleanName.count >= 2 else {
            return ValidationResult(isValid: false, message: "Name must be at least 2 characters long")
        }
        
        // Check maximum length
        guard cleanName.count <= 50 else {
            return ValidationResult(isValid: false, message: "Name must be less than 50 characters")
        }
        
        // Check if contains only letters, spaces, and common name characters
        let nameRegex = "^[a-zA-Z\\s\\-']+$"
        let namePredicate = NSPredicate(format: "SELF MATCHES %@", nameRegex)
        
        if namePredicate.evaluate(with: cleanName) {
            return ValidationResult(isValid: true, message: "Name is valid")
        } else {
            return ValidationResult(isValid: false, message: "Name can only contain letters, spaces, hyphens, and apostrophes")
        }
    }
    
    // MARK: - Address Validation
    
    static func validateAddress(_ address: String) -> ValidationResult {
        let cleanAddress = address.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Check minimum length
        guard cleanAddress.count >= 10 else {
            return ValidationResult(isValid: false, message: "Address must be at least 10 characters long")
        }
        
        // Check maximum length
        guard cleanAddress.count <= 200 else {
            return ValidationResult(isValid: false, message: "Address must be less than 200 characters")
        }
        
        return ValidationResult(isValid: true, message: "Address is valid")
    }
    
    // MARK: - Gift Name Validation
    
    static func validateGiftName(_ giftName: String) -> ValidationResult {
        let cleanGiftName = giftName.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Check minimum length
        guard cleanGiftName.count >= 3 else {
            return ValidationResult(isValid: false, message: "Gift name must be at least 3 characters long")
        }
        
        // Check maximum length
        guard cleanGiftName.count <= 100 else {
            return ValidationResult(isValid: false, message: "Gift name must be less than 100 characters")
        }
        
        return ValidationResult(isValid: true, message: "Gift name is valid")
    }
    
    // MARK: - URL Validation
    
    static func validateURL(_ url: String) -> ValidationResult {
        if url.isEmpty {
            return ValidationResult(isValid: true, message: "URL is optional")
        }
        
        guard let url = URL(string: url) else {
            return ValidationResult(isValid: false, message: "Please enter a valid URL")
        }
        
        // Check if it's a valid HTTP/HTTPS URL
        if url.scheme == "http" || url.scheme == "https" {
            return ValidationResult(isValid: true, message: "URL is valid")
        } else {
            return ValidationResult(isValid: false, message: "URL must start with http:// or https://")
        }
    }
} 
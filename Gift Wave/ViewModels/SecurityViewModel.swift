//
//  SecurityViewModel.swift
//  Gift Wave
//
//  Created by Abdullah Latif on 04/08/2025.
//

import Foundation
import FirebaseFirestore
import CoreLocation

@MainActor
class SecurityViewModel: ObservableObject {
    @Published var reports: [Report] = []
    @Published var safetyAlerts: [SafetyAlert] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let db = Firestore.firestore()
    
    // MARK: - Report Methods
    
    func submitReport(reporterId: String, reporterName: String, reportedUserId: String, reportedUserName: String, reportType: ReportType, description: String, orderId: String? = nil, evidence: [String]? = nil) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let report = Report(
                reporterId: reporterId,
                reporterName: reporterName,
                reportedUserId: reportedUserId,
                reportedUserName: reportedUserName,
                reportType: reportType,
                description: description,
                orderId: orderId,
                evidence: evidence,
                status: .pending,
                createdAt: Date(),
                updatedAt: Date(),
                adminNotes: nil
            )
            
            try await db.collection("reports").addDocument(from: report)
            
            // Log security event
            await logSecurityEvent(
                userId: reporterId,
                action: "report_submitted",
                details: "Report submitted against \(reportedUserName) for \(reportType.rawValue)",
                severity: "medium"
            )
            
        } catch {
            errorMessage = "Failed to submit report: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func fetchUserReports(userId: String) async {
        isLoading = true
        
        do {
            let snapshot = try await db.collection("reports")
                .whereField("reporterId", isEqualTo: userId)
                .order(by: "createdAt", descending: true)
                .getDocuments()
            
            reports = try snapshot.documents.compactMap { document in
                try document.data(as: Report.self)
            }
        } catch {
            errorMessage = "Failed to fetch reports: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    // MARK: - Safety Alert Methods
    
    func createSafetyAlert(userId: String, userName: String, alertType: SafetyAlertType, orderId: String? = nil, location: CLLocationCoordinate2D? = nil, description: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let geoPoint = location != nil ? GeoPoint(latitude: location!.latitude, longitude: location!.longitude) : nil
            
            let alert = SafetyAlert(
                userId: userId,
                userName: userName,
                alertType: alertType,
                orderId: orderId,
                location: geoPoint,
                description: description,
                isResolved: false,
                createdAt: Date(),
                resolvedAt: nil,
                adminResponse: nil
            )
            
            try await db.collection("safety_alerts").addDocument(from: alert)
            
            // Log critical security event
            await logSecurityEvent(
                userId: userId,
                action: "safety_alert_created",
                details: "Safety alert created: \(alertType.rawValue) - \(description)",
                severity: "critical"
            )
            
        } catch {
            errorMessage = "Failed to create safety alert: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func fetchUserSafetyAlerts(userId: String) async {
        isLoading = true
        
        do {
            let snapshot = try await db.collection("safety_alerts")
                .whereField("userId", isEqualTo: userId)
                .order(by: "createdAt", descending: true)
                .getDocuments()
            
            safetyAlerts = try snapshot.documents.compactMap { document in
                try document.data(as: SafetyAlert.self)
            }
        } catch {
            errorMessage = "Failed to fetch safety alerts: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    // MARK: - Security Logging
    
    func logSecurityEvent(userId: String?, action: String, details: String, severity: String, ipAddress: String? = nil, userAgent: String? = nil) async {
        do {
            let log = SecurityLog(
                userId: userId,
                action: action,
                details: details,
                ipAddress: ipAddress,
                userAgent: userAgent,
                timestamp: Date(),
                severity: severity
            )
            
            try await db.collection("security_logs").addDocument(from: log)
        } catch {
            print("Failed to log security event: \(error)")
        }
    }
    
    // MARK: - Block User
    
    func blockUser(userId: String, reason: String) async {
        do {
            try await db.collection("users").document(userId).updateData([
                "isBlocked": true,
                "blockedReason": reason,
                "updatedAt": Date()
            ])
            
            await logSecurityEvent(
                userId: userId,
                action: "user_blocked",
                details: "User blocked: \(reason)",
                severity: "high"
            )
        } catch {
            errorMessage = "Failed to block user: \(error.localizedDescription)"
        }
    }
    
    func unblockUser(userId: String) async {
        do {
            try await db.collection("users").document(userId).updateData([
                "isBlocked": false,
                "blockedReason": nil,
                "updatedAt": Date()
            ])
            
            await logSecurityEvent(
                userId: userId,
                action: "user_unblocked",
                details: "User unblocked",
                severity: "medium"
            )
        } catch {
            errorMessage = "Failed to unblock user: \(error.localizedDescription)"
        }
    }
} 
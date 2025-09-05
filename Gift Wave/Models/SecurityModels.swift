//
//  SecurityModels.swift
//  Gift Wave
//
//  Created by Abdullah Latif on 04/08/2025.
//

import Foundation
import FirebaseFirestore

enum ReportType: String, Codable, CaseIterable {
    case misconduct = "misconduct"
    case safety = "safety"
    case fraud = "fraud"
    case harassment = "harassment"
    case other = "other"
}

enum ReportStatus: String, Codable, CaseIterable {
    case pending = "pending"
    case underReview = "underReview"
    case resolved = "resolved"
    case dismissed = "dismissed"
}

struct Report: Identifiable, Codable {
    @DocumentID var id: String?
    let reporterId: String
    let reporterName: String
    let reportedUserId: String
    let reportedUserName: String
    let reportType: ReportType
    let description: String
    let orderId: String?
    let evidence: [String]? // URLs to evidence files
    let status: ReportStatus
    let createdAt: Date
    let updatedAt: Date
    let adminNotes: String?
}

enum SafetyAlertType: String, Codable, CaseIterable {
    case panic = "panic"
    case suspicious = "suspicious"
    case delay = "delay"
    case dispute = "dispute"
}

struct SafetyAlert: Identifiable, Codable {
    @DocumentID var id: String?
    let userId: String
    let userName: String
    let alertType: SafetyAlertType
    let orderId: String?
    let location: GeoPoint?
    let description: String
    let isResolved: Bool
    let createdAt: Date
    let resolvedAt: Date?
    let adminResponse: String?
}

struct SecurityLog: Identifiable, Codable {
    @DocumentID var id: String?
    let userId: String?
    let action: String
    let details: String
    let ipAddress: String?
    let userAgent: String?
    let timestamp: Date
    let severity: String // "low", "medium", "high", "critical"
} 
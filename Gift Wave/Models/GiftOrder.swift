//
//  GiftOrder.swift
//  Gift Wave
//
//  Created by Abdullah Latif on 04/08/2025.
//

import Foundation
import FirebaseFirestore
import CoreLocation

enum OrderStatus: String, Codable, CaseIterable {
    case pending = "pending"
    case accepted = "accepted"
    case purchased = "purchased"
    case inTransit = "inTransit"
    case delivered = "delivered"
    case cancelled = "cancelled"
}

enum PaymentStatus: String, Codable, CaseIterable {
    case pending = "pending"
    case confirmed = "confirmed"
    case disputed = "disputed"
    case refunded = "refunded"
}

struct GiftOrder: Identifiable, Codable {
    @DocumentID var id: String?
    let senderId: String
    let senderName: String
    let senderPhone: String
    
    // Gift details
    let giftName: String
    let productLink: String?
    let requestVideo: Bool
    let personalMessage: String? // New field for personal notes
    
    // Receiver details
    let receiverName: String
    let receiverAddress: String
    let receiverCity: String
    let receiverPhone: String
    
    // Delivery details
    let deliveryFee: Double
    let tip: Double?
    
    // Pricing fields
    var estimatedProductPrice: Double?
    var actualProductPrice: Double?
    var totalAmount: Double
    
    // Payment tracking
    var paymentStatus: PaymentStatus
    var paymentMethod: String?
    var paymentProofURL: String?
    
    // Rider details (set when accepted)
    var riderId: String?
    var riderName: String?
    var riderPhone: String?
    
    // Order status and tracking
    var status: OrderStatus
    let createdAt: Date
    var acceptedAt: Date?
    var deliveredAt: Date?
    
    // Media URLs
    var giftImageURL: String?
    var receiptImageURL: String?
    var reactionVideoURL: String?
    
    // Location data
    var pickupLocation: GeoPoint?
    var deliveryLocation: GeoPoint?
    
    // Rating
    var rating: Int?
    var review: String?
    
    init(senderId: String, senderName: String, senderPhone: String, giftName: String, productLink: String?, requestVideo: Bool, personalMessage: String?, receiverName: String, receiverAddress: String, receiverCity: String, receiverPhone: String, deliveryFee: Double, estimatedProductPrice: Double? = nil, tip: Double? = nil) {
        self.senderId = senderId
        self.senderName = senderName
        self.senderPhone = senderPhone
        self.giftName = giftName
        self.productLink = productLink
        self.requestVideo = requestVideo
        self.personalMessage = personalMessage
        self.receiverName = receiverName
        self.receiverAddress = receiverAddress
        self.receiverCity = receiverCity
        self.receiverPhone = receiverPhone
        self.deliveryFee = deliveryFee
        self.tip = tip
        self.estimatedProductPrice = estimatedProductPrice
        self.actualProductPrice = nil
        self.totalAmount = deliveryFee + (tip ?? 0) + (estimatedProductPrice ?? 0)
        self.paymentStatus = .pending
        self.paymentMethod = nil
        self.paymentProofURL = nil
        self.riderId = nil
        self.riderName = nil
        self.riderPhone = nil
        self.status = .pending
        self.createdAt = Date()
        self.acceptedAt = nil
        self.deliveredAt = nil
        self.giftImageURL = nil
        self.receiptImageURL = nil
        self.reactionVideoURL = nil
        self.pickupLocation = nil
        self.deliveryLocation = nil
        self.rating = nil
        self.review = nil
    }
    
    // Custom initializer for testing/preview purposes
    init(senderId: String, senderName: String, senderPhone: String, giftName: String, productLink: String?, requestVideo: Bool, personalMessage: String?, receiverName: String, receiverAddress: String, receiverCity: String, receiverPhone: String, deliveryFee: Double, estimatedProductPrice: Double?, actualProductPrice: Double?, tip: Double?, totalAmount: Double, paymentStatus: PaymentStatus, paymentMethod: String?, paymentProofURL: String?, riderId: String?, riderName: String?, riderPhone: String?, status: OrderStatus, createdAt: Date, acceptedAt: Date?, deliveredAt: Date?, giftImageURL: String?, receiptImageURL: String?, reactionVideoURL: String?, pickupLocation: GeoPoint?, deliveryLocation: GeoPoint?, rating: Int?, review: String?) {
        self.senderId = senderId
        self.senderName = senderName
        self.senderPhone = senderPhone
        self.giftName = giftName
        self.productLink = productLink
        self.requestVideo = requestVideo
        self.personalMessage = personalMessage
        self.receiverName = receiverName
        self.receiverAddress = receiverAddress
        self.receiverCity = receiverCity
        self.receiverPhone = receiverPhone
        self.deliveryFee = deliveryFee
        self.tip = tip
        self.estimatedProductPrice = estimatedProductPrice
        self.actualProductPrice = actualProductPrice
        self.totalAmount = totalAmount
        self.paymentStatus = paymentStatus
        self.paymentMethod = paymentMethod
        self.paymentProofURL = paymentProofURL
        self.riderId = riderId
        self.riderName = riderName
        self.riderPhone = riderPhone
        self.status = status
        self.createdAt = createdAt
        self.acceptedAt = acceptedAt
        self.deliveredAt = deliveredAt
        self.giftImageURL = giftImageURL
        self.receiptImageURL = receiptImageURL
        self.reactionVideoURL = reactionVideoURL
        self.pickupLocation = pickupLocation
        self.deliveryLocation = deliveryLocation
        self.rating = rating
        self.review = review
    }
} 
//
//  OrderViewModel.swift
//  Gift Wave
//
//  Created by Abdullah Latif on 04/08/2025.
//

import Foundation
import FirebaseFirestore
import FirebaseStorage
import CoreLocation

@MainActor
class OrderViewModel: ObservableObject {
    @Published var orders: [GiftOrder] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let db = Firestore.firestore()
    private let storage = Storage.storage()
    
    // MARK: - Dummy Data for Testing
    
    func createDummyData() {
        // Only create dummy data if no orders exist
        if orders.isEmpty {
            let dummyOrders = [
                createDummyOrder(
                    giftName: "Birthday Cake",
                    receiverName: "Sarah Johnson",
                    receiverCity: "Karachi",
                    status: .pending,
                    requestVideo: true,
                    personalMessage: "Happy Birthday Sarah! Hope you have an amazing day! 🎂"
                ),
                createDummyOrder(
                    giftName: "Flowers Bouquet",
                    receiverName: "Ahmed Ali",
                    receiverCity: "Lahore",
                    status: .accepted,
                    requestVideo: false,
                    personalMessage: "Get well soon! Sending you lots of love and prayers."
                ),
                createDummyOrder(
                    giftName: "Chocolate Box",
                    receiverName: "Fatima Khan",
                    receiverCity: "Islamabad",
                    status: .delivered,
                    requestVideo: true,
                    personalMessage: "Congratulations on your graduation! You did it! 🎓"
                ),
                createDummyOrder(
                    giftName: "Book Collection",
                    receiverName: "Omar Hassan",
                    receiverCity: "Karachi",
                    status: .inTransit,
                    requestVideo: false,
                    personalMessage: "Hope you enjoy these books! Perfect for your reading list."
                )
            ]
            
            orders = dummyOrders
        }
    }
    
    private func createDummyOrder(giftName: String, receiverName: String, receiverCity: String, status: OrderStatus, requestVideo: Bool, personalMessage: String) -> GiftOrder {
        let estimatedPrice = Double.random(in: 1000...5000)
        let actualPrice = estimatedPrice + Double.random(in: -500...500)
        let deliveryFee = Double.random(in: 300...800)
        let tip = Double.random(in: 100...500)
        let totalAmount = actualPrice + deliveryFee + tip
        
        let order = GiftOrder(
            senderId: "dummy_sender",
            senderName: "Test User",
            senderPhone: "+92 300 1234567",
            giftName: giftName,
            productLink: "https://example.com/product",
            requestVideo: requestVideo,
            personalMessage: personalMessage,
            receiverName: receiverName,
            receiverAddress: "123 Main Street, \(receiverCity)",
            receiverCity: receiverCity,
            receiverPhone: "+92 300 7654321",
            deliveryFee: deliveryFee,
            estimatedProductPrice: estimatedPrice,
            tip: tip
        )
        
        // Update order with additional properties for dummy data
        var updatedOrder = order
        updatedOrder.actualProductPrice = actualPrice
        updatedOrder.totalAmount = totalAmount
        updatedOrder.paymentStatus = PaymentStatus.confirmed
        updatedOrder.paymentMethod = "JazzCash"
        updatedOrder.paymentProofURL = "https://example.com/payment.jpg"
        
        // Add rider info for accepted/delivered orders
        if status != .pending {
            updatedOrder.riderId = "dummy_rider"
            updatedOrder.riderName = "Ali Rider"
            updatedOrder.riderPhone = "+92 300 9999999"
            updatedOrder.status = status
            updatedOrder.acceptedAt = status == .pending ? nil : Date().addingTimeInterval(-3600)
            updatedOrder.deliveredAt = status == .delivered ? Date() : nil
            updatedOrder.giftImageURL = status == .delivered ? "https://example.com/gift.jpg" : nil
            updatedOrder.receiptImageURL = status == .delivered ? "https://example.com/receipt.jpg" : nil
            updatedOrder.reactionVideoURL = status == .delivered && requestVideo ? "https://example.com/video.mp4" : nil
            updatedOrder.rating = status == .delivered ? Int.random(in: 4...5) : nil
            updatedOrder.review = status == .delivered ? "Great service! Very professional and on time." : nil
        }
        
        return updatedOrder
    }
    
    // MARK: - Sender Methods
    
    func createOrder(order: GiftOrder) async -> GiftOrder? {
        isLoading = true
        errorMessage = nil
        
        do {
            let documentRef = try await db.collection("orders").addDocument(from: order)
            
            // Update the order with the document ID
            var createdOrder = order
            createdOrder.id = documentRef.documentID
            
            // Add to local orders array
            orders.insert(createdOrder, at: 0)
            
            // Fetch updated orders
            await fetchUserOrders(userId: order.senderId)
            
            isLoading = false
            return createdOrder
        } catch {
            errorMessage = "Failed to create order: \(error.localizedDescription)"
            isLoading = false
            return nil
        }
    }
    
    func fetchUserOrders(userId: String) async {
        isLoading = true
        
        do {
            let snapshot = try await db.collection("orders")
                .whereField("senderId", isEqualTo: userId)
                .order(by: "createdAt", descending: true)
                .getDocuments()
            
            orders = try snapshot.documents.compactMap { document in
                try document.data(as: GiftOrder.self)
            }
        } catch {
            errorMessage = "Failed to fetch orders: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func rateOrder(orderId: String, rating: Int, review: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await db.collection("orders").document(orderId).updateData([
                "rating": rating,
                "review": review
            ])
            
            // Update rider's average rating
            if let order = orders.first(where: { $0.id == orderId }),
               let riderId = order.riderId {
                await updateRiderRating(riderId: riderId)
            }
            
            await fetchUserOrders(userId: orders.first?.senderId ?? "")
        } catch {
            errorMessage = "Failed to submit rating: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    // MARK: - Rider Methods
    
    func fetchAvailableOrders(city: String) async {
        isLoading = true
        
        do {
            let snapshot = try await db.collection("orders")
                .whereField("receiverCity", isEqualTo: city)
                .whereField("status", isEqualTo: OrderStatus.pending.rawValue)
                .order(by: "createdAt", descending: true)
                .getDocuments()
            
            orders = try snapshot.documents.compactMap { document in
                try document.data(as: GiftOrder.self)
            }
        } catch {
            errorMessage = "Failed to fetch available orders: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func fetchRiderOrders(riderId: String) async {
        isLoading = true
        
        do {
            let snapshot = try await db.collection("orders")
                .whereField("riderId", isEqualTo: riderId)
                .order(by: "createdAt", descending: true)
                .getDocuments()
            
            orders = try snapshot.documents.compactMap { document in
                try document.data(as: GiftOrder.self)
            }
        } catch {
            errorMessage = "Failed to fetch rider orders: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func acceptOrder(orderId: String, riderId: String, riderName: String, riderPhone: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await db.collection("orders").document(orderId).updateData([
                "riderId": riderId,
                "riderName": riderName,
                "riderPhone": riderPhone,
                "status": OrderStatus.accepted.rawValue,
                "acceptedAt": Date()
            ])
            
            await fetchAvailableOrders(city: orders.first?.receiverCity ?? "")
        } catch {
            errorMessage = "Failed to accept order: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func updateOrderStatus(orderId: String, status: OrderStatus) async {
        isLoading = true
        errorMessage = nil
        
        do {
            var updateData: [String: Any] = ["status": status.rawValue]
            
            if status == .delivered {
                updateData["deliveredAt"] = Date()
            }
            
            try await db.collection("orders").document(orderId).updateData(updateData)
            
            // Refresh orders based on current context
            if let order = orders.first(where: { $0.id == orderId }) {
                if order.riderId != nil {
                    await fetchRiderOrders(riderId: order.riderId!)
                } else {
                    await fetchUserOrders(userId: order.senderId)
                }
            }
        } catch {
            errorMessage = "Failed to update order status: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func uploadGiftImage(orderId: String, imageData: Data) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let imageURL = try await uploadImage(imageData: imageData, path: "gift_images/\(orderId).jpg")
            try await db.collection("orders").document(orderId).updateData([
                "giftImageURL": imageURL
            ])
        } catch {
            errorMessage = "Failed to upload gift image: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func uploadReceiptImage(orderId: String, imageData: Data) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let imageURL = try await uploadImage(imageData: imageData, path: "receipt_images/\(orderId).jpg")
            try await db.collection("orders").document(orderId).updateData([
                "receiptImageURL": imageURL
            ])
        } catch {
            errorMessage = "Failed to upload receipt image: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func uploadReceiptImage(_ imageData: Data, for orderId: String) async throws -> String {
        return try await uploadImage(imageData: imageData, path: "receipt_images/\(orderId).jpg")
    }
    
    func uploadPaymentProof(_ imageData: Data, for orderId: String) async throws -> String {
        return try await uploadImage(imageData: imageData, path: "payment_proofs/\(orderId).jpg")
    }
    
    func updateOrderPrice(orderId: String, actualPrice: Double, receiptURL: String?) async {
        isLoading = true
        errorMessage = nil
        
        do {
            var updateData: [String: Any] = [
                "actualProductPrice": actualPrice,
                "status": OrderStatus.purchased.rawValue,
                "paymentStatus": PaymentStatus.pending.rawValue,
                "updatedAt": Date()
            ]
            
            if let receiptURL = receiptURL {
                updateData["receiptImageURL"] = receiptURL
            }
            
            // Calculate new total amount
            if let order = orders.first(where: { $0.id == orderId }) {
                let newTotal = actualPrice + order.deliveryFee + (order.tip ?? 0)
                updateData["totalAmount"] = newTotal
            }
            
            try await db.collection("orders").document(orderId).updateData(updateData)
            
            // Update local order
            if let index = orders.firstIndex(where: { $0.id == orderId }) {
                orders[index].actualProductPrice = actualPrice
                orders[index].status = .purchased
                orders[index].paymentStatus = .pending
                if let receiptURL = receiptURL {
                    orders[index].receiptImageURL = receiptURL
                }
                
                // Update total amount
                let newTotal = actualPrice + orders[index].deliveryFee + (orders[index].tip ?? 0)
                orders[index].totalAmount = newTotal
            }
        } catch {
            errorMessage = "Failed to update order price: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func confirmPayment(orderId: String, paymentMethod: String, paymentProofURL: String?) async {
        isLoading = true
        errorMessage = nil
        
        do {
            var updateData: [String: Any] = [
                "paymentStatus": PaymentStatus.confirmed.rawValue,
                "paymentMethod": paymentMethod,
                "status": OrderStatus.inTransit.rawValue,
                "updatedAt": Date()
            ]
            
            if let paymentProofURL = paymentProofURL {
                updateData["paymentProofURL"] = paymentProofURL
            }
            
            try await db.collection("orders").document(orderId).updateData(updateData)
            
            // Update local order
            if let index = orders.firstIndex(where: { $0.id == orderId }) {
                orders[index].paymentStatus = .confirmed
                orders[index].paymentMethod = paymentMethod
                orders[index].status = .inTransit
                if let paymentProofURL = paymentProofURL {
                    orders[index].paymentProofURL = paymentProofURL
                }
            }
        } catch {
            errorMessage = "Failed to confirm payment: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func uploadReactionVideo(orderId: String, videoData: Data) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let videoURL = try await uploadVideo(videoData: videoData, path: "reaction_videos/\(orderId).mp4")
            try await db.collection("orders").document(orderId).updateData([
                "reactionVideoURL": videoURL
            ])
        } catch {
            errorMessage = "Failed to upload reaction video: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    // MARK: - Helper Methods
    
    private func uploadImage(imageData: Data, path: String) async throws -> String {
        let storageRef = storage.reference()
        let imageRef = storageRef.child(path)
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        _ = try await imageRef.putDataAsync(imageData, metadata: metadata)
        let downloadURL = try await imageRef.downloadURL()
        return downloadURL.absoluteString
    }
    
    private func uploadVideo(videoData: Data, path: String) async throws -> String {
        let storageRef = storage.reference()
        let videoRef = storageRef.child(path)
        
        let metadata = StorageMetadata()
        metadata.contentType = "video/mp4"
        
        _ = try await videoRef.putDataAsync(videoData, metadata: metadata)
        let downloadURL = try await videoRef.downloadURL()
        return downloadURL.absoluteString
    }
    
    private func updateRiderRating(riderId: String) async {
        do {
            let snapshot = try await db.collection("orders")
                .whereField("riderId", isEqualTo: riderId)
                .whereField("rating", isGreaterThan: 0)
                .getDocuments()
            
            let ratings = snapshot.documents.compactMap { document -> Int? in
                try? document.data(as: GiftOrder.self).rating
            }
            
            if !ratings.isEmpty {
                let averageRating = Double(ratings.reduce(0, +)) / Double(ratings.count)
                try await db.collection("users").document(riderId).updateData([
                    "averageRating": averageRating,
                    "totalDeliveries": ratings.count
                ])
            }
        } catch {
            print("Failed to update rider rating: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Delivery Fee Calculation
    
    func calculateDeliveryFee(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) -> Double {
        let fromLocation = CLLocation(latitude: from.latitude, longitude: from.longitude)
        let toLocation = CLLocation(latitude: to.latitude, longitude: to.longitude)
        
        let distanceInMeters = fromLocation.distance(from: toLocation)
        let distanceInKm = distanceInMeters / 1000
        
        // Base fee: $5 for first 5km, then $1 per additional km
        let baseFee = 5.0
        let additionalKm = max(0, distanceInKm - 5)
        let additionalFee = additionalKm * 1.0
        
        return baseFee + additionalFee
    }
} 
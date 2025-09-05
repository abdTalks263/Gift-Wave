//
//  OrderDetailsView.swift
//  Gift Wave
//
//  Created by Abdullah Latif on 04/08/2025.
//

import SwiftUI

struct OrderDetailsView: View {
    let order: GiftOrder
    @EnvironmentObject var orderViewModel: OrderViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var rating: Int = 5
    @State private var review: String = ""
    @State private var showRatingSheet = false
    @State private var isSubmitting = false
    @State private var showingPaymentConfirmation = false
    @State private var showingOrderTracking = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Order Info
                    VStack(alignment: .leading, spacing: 8) {
                        Text(order.giftName)
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        if let orderId = order.id {
                            Text("Order #\(orderId.prefix(8))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        if let productLink = order.productLink {
                            Link(productLink, destination: URL(string: productLink)!)
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                        
                        OrderStatusBadge(status: order.status)
                    }
                    .padding(.bottom, 8)
                    
                    // Receiver Info
                    VStack(alignment: .leading, spacing: 4) {
                        Text("To: \(order.receiverName)")
                        Text(order.receiverAddress)
                        Text(order.receiverCity)
                        Text(order.receiverPhone)
                    }
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    
                    // Personal Message
                    if let personalMessage = order.personalMessage, !personalMessage.isEmpty {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Personal Message:")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            Text(personalMessage)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .padding()
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(8)
                        }
                    }
                    
                    // Rider Info
                    if let riderName = order.riderName {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Rider: \(riderName)")
                            if let riderPhone = order.riderPhone {
                                Text("Phone: \(riderPhone)")
                            }
                        }
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    }
                    
                    // Media
                    if let giftImageURL = order.giftImageURL {
                        AsyncImage(url: URL(string: giftImageURL)) { image in
                            image.resizable().aspectRatio(contentMode: .fit)
                        } placeholder: {
                            ProgressView()
                        }
                        .frame(maxWidth: .infinity, maxHeight: 200)
                        .cornerRadius(12)
                    }
                    if let reactionVideoURL = order.reactionVideoURL {
                        Link("View Reaction Video", destination: URL(string: reactionVideoURL)!)
                            .font(.headline)
                            .foregroundColor(.blue)
                    }
                    
                    // Cost Breakdown
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Cost Breakdown")
                            .font(.headline)
                            .fontWeight(.bold)
                        
                        VStack(spacing: 4) {
                            if let estimatedPrice = order.estimatedProductPrice {
                                Text("Estimated Product Price: \(PakistanData.currencySymbol)\(String(format: "%.0f", estimatedPrice))")
                                    .foregroundColor(.secondary)
                            }
                            if let actualPrice = order.actualProductPrice {
                                Text("Actual Product Price: \(PakistanData.currencySymbol)\(String(format: "%.0f", actualPrice))")
                                    .fontWeight(.semibold)
                            }
                            Text("Delivery Fee: \(PakistanData.currencySymbol)\(String(format: "%.0f", order.deliveryFee))")
                            if let tip = order.tip, tip > 0 {
                                Text("Tip: \(PakistanData.currencySymbol)\(String(format: "%.0f", tip))")
                            }
                            Divider()
                            Text("Total: \(PakistanData.currencySymbol)\(String(format: "%.0f", order.totalAmount))")
                                .fontWeight(.bold)
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                    
                    // Payment Status
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Payment Status")
                            .font(.headline)
                            .fontWeight(.bold)
                        
                        PaymentStatusBadge(status: order.paymentStatus)
                        
                        if order.paymentStatus == .pending && order.actualProductPrice != nil {
                            Text("Please confirm payment to proceed with delivery")
                                .font(.caption)
                                .foregroundColor(.orange)
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                    .font(.subheadline)
                    
                    // Action Buttons
                    VStack(spacing: 12) {
                        // Track Order Button
                        Button("Track Order") {
                            showingOrderTracking = true
                        }
                        .buttonStyle(.bordered)
                        .frame(maxWidth: .infinity)
                        
                        // Payment Confirmation Button
                        if order.paymentStatus == .pending && order.actualProductPrice != nil {
                            Button("Confirm Payment") {
                                showingPaymentConfirmation = true
                            }
                            .buttonStyle(.borderedProminent)
                            .frame(maxWidth: .infinity)
                        }
                        
                        // Rating Button
                        if order.status == .delivered && order.rating == nil {
                            Button("Rate Rider") {
                                showRatingSheet = true
                            }
                            .buttonStyle(.borderedProminent)
                            .frame(maxWidth: .infinity)
                        } else if let rating = order.rating {
                            HStack(spacing: 4) {
                                ForEach(0..<rating, id: \.self) { _ in
                                    Image(systemName: "star.fill").foregroundColor(.yellow)
                                }
                                Text(order.review ?? "")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding(.top, 12)
                }
                .padding(20)
            }
            .navigationTitle("Order Details")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") { dismiss() }
                }
            }
            .sheet(isPresented: $showRatingSheet) {
                NavigationView {
                    VStack(spacing: 24) {
                        Text("Rate Your Rider")
                            .font(.title2)
                            .fontWeight(.bold)
                        HStack {
                            ForEach(1...5, id: \.self) { star in
                                Image(systemName: star <= rating ? "star.fill" : "star")
                                    .resizable()
                                    .frame(width: 32, height: 32)
                                    .foregroundColor(.yellow)
                                    .onTapGesture { rating = star }
                            }
                        }
                        TextField("Write a review (optional)", text: $review)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        Button("Submit") {
                            isSubmitting = true
                            Task {
                                await orderViewModel.rateOrder(orderId: order.id ?? "", rating: rating, review: review)
                                isSubmitting = false
                                showRatingSheet = false
                                dismiss()
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(isSubmitting)
                    }
                    .padding(32)
                    .navigationTitle("Rate Rider")
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button("Cancel") { showRatingSheet = false }
                        }
                    }
                }
            }
            .sheet(isPresented: $showingPaymentConfirmation) {
                PaymentConfirmationView(order: order)
                    .environmentObject(orderViewModel)
            }
            .sheet(isPresented: $showingOrderTracking) {
                OrderTrackingView(order: order)
            }
        }
    }
}



#Preview {
    OrderDetailsView(order: GiftOrder(
        senderId: "1", 
        senderName: "Alice", 
        senderPhone: "123", 
        giftName: "Cake", 
        productLink: nil, 
        requestVideo: false, 
        personalMessage: "Happy Birthday! Hope you love it!", 
        receiverName: "Bob", 
        receiverAddress: "123 St", 
        receiverCity: "City", 
        receiverPhone: "456", 
        deliveryFee: 500, 
        estimatedProductPrice: 2000,
        actualProductPrice: 2250,
        tip: 200,
        totalAmount: 2950,
        paymentStatus: .pending,
        paymentMethod: nil,
        paymentProofURL: nil,
        riderId: "rider123",
        riderName: "Ahmed Khan",
        riderPhone: "03001111111",
        status: .purchased,
        createdAt: Date(),
        acceptedAt: Date(),
        deliveredAt: nil,
        giftImageURL: nil,
        receiptImageURL: "https://example.com/receipt.jpg",
        reactionVideoURL: nil,
        pickupLocation: nil,
        deliveryLocation: nil,
        rating: nil,
        review: nil
    ))
    .environmentObject(OrderViewModel())
} 
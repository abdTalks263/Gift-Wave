import SwiftUI

struct OrderTrackingView: View {
    let order: GiftOrder
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Order Status Timeline
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Order Status")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        VStack(spacing: 16) {
                            TrackingStep(
                                title: "Order Placed",
                                description: "Your order has been created and is waiting for a rider",
                                isCompleted: true,
                                isActive: order.status == .pending,
                                icon: "checkmark.circle.fill"
                            )
                            
                            TrackingStep(
                                title: "Rider Assigned",
                                description: "A rider has been assigned to your order",
                                isCompleted: order.status != .pending,
                                isActive: order.status == .accepted,
                                icon: "person.badge.plus"
                            )
                            
                            TrackingStep(
                                title: "Price Confirmed",
                                description: "Rider has confirmed the actual product price",
                                isCompleted: order.status == .purchased || order.status == .inTransit || order.status == .delivered,
                                isActive: order.status == .purchased,
                                icon: "checkmark.circle"
                            )
                            
                            TrackingStep(
                                title: "Payment Confirmed",
                                description: "Payment has been confirmed and order is in transit",
                                isCompleted: order.status == .inTransit || order.status == .delivered,
                                isActive: order.status == .inTransit,
                                icon: "creditcard"
                            )
                            
                            TrackingStep(
                                title: "Delivered",
                                description: "Your gift has been delivered successfully",
                                isCompleted: order.status == .delivered,
                                isActive: order.status == .delivered,
                                icon: "shippingbox"
                            )
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(16)
                    
                    // Current Status Card
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Current Status")
                            .font(.headline)
                            .fontWeight(.bold)
                        
                        HStack {
                            OrderStatusBadge(status: order.status)
                            Spacer()
                            Text(getStatusDescription())
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        if let riderName = order.riderName {
                            HStack {
                                Image(systemName: "person.fill")
                                    .foregroundColor(.blue)
                                Text("Rider: \(riderName)")
                                    .font(.subheadline)
                                Spacer()
                            }
                        }
                        
                        if let actualPrice = order.actualProductPrice {
                            HStack {
                                Image(systemName: "tag.fill")
                                    .foregroundColor(.green)
                                Text("Actual Price: \(PakistanData.currencySymbol)\(String(format: "%.0f", actualPrice))")
                                    .font(.subheadline)
                                Spacer()
                            }
                        }
                    }
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(16)
                    
                    // Action Buttons
                    VStack(spacing: 12) {
                        Button("View Full Details") {
                            // This will be handled by the parent view
                        }
                        .buttonStyle(.borderedProminent)
                        .frame(maxWidth: .infinity)
                        
                        Button("Close") {
                            dismiss()
                        }
                        .buttonStyle(.bordered)
                        .frame(maxWidth: .infinity)
                    }
                }
                .padding(20)
            }
            .navigationTitle("Order Tracking")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func getStatusDescription() -> String {
        switch order.status {
        case .pending:
            return "Waiting for rider assignment"
        case .accepted:
            return "Rider assigned, checking product"
        case .purchased:
            return "Price confirmed, waiting for payment"
        case .inTransit:
            return "In transit to receiver"
        case .delivered:
            return "Successfully delivered"
        case .cancelled:
            return "Order cancelled"
        }
    }
}

struct TrackingStep: View {
    let title: String
    let description: String
    let isCompleted: Bool
    let isActive: Bool
    let icon: String
    
    var body: some View {
        HStack(spacing: 16) {
            // Step Icon
            ZStack {
                Circle()
                    .fill(backgroundColor)
                    .frame(width: 40, height: 40)
                
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(iconColor)
            }
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(textColor)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            Spacer()
        }
        .opacity(isCompleted ? 1.0 : 0.6)
    }
    
    private var backgroundColor: Color {
        if isActive {
            return .blue
        } else if isCompleted {
            return .green
        } else {
            return .gray.opacity(0.3)
        }
    }
    
    private var iconColor: Color {
        if isActive || isCompleted {
            return .white
        } else {
            return .gray
        }
    }
    
    private var textColor: Color {
        if isActive || isCompleted {
            return .primary
        } else {
            return .secondary
        }
    }
}

#Preview {
    OrderTrackingView(order: GiftOrder(
        senderId: "sender123",
        senderName: "John Doe",
        senderPhone: "03001234567",
        giftName: "Birthday Cake",
        productLink: "https://example.com/cake",
        requestVideo: true,
        personalMessage: "Happy Birthday!",
        receiverName: "Jane Smith",
        receiverAddress: "123 Main St",
        receiverCity: "Lahore",
        receiverPhone: "03009876543",
        deliveryFee: 500,
        estimatedProductPrice: 2000,
        tip: 200
    ))
} 
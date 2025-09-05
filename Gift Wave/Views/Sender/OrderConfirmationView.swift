import SwiftUI

struct OrderConfirmationView: View {
    let order: GiftOrder
    @Environment(\.dismiss) private var dismiss
    @State private var showingOrderDetails = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 30) {
                    // Success Icon and Title
                    VStack(spacing: 16) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.green)
                        
                        Text("Order Placed Successfully!")
                            .font(.title)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                        
                        Text("Your gift order has been processed and is waiting for a rider to pick it up.")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                    }
                    
                    // Order Summary Card
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Order Summary")
                            .font(.headline)
                            .fontWeight(.bold)
                        
                        VStack(spacing: 12) {
                            OrderSummaryRow(title: "Order ID", value: order.id ?? "Generating...")
                            OrderSummaryRow(title: "Gift", value: order.giftName)
                            OrderSummaryRow(title: "Receiver", value: order.receiverName)
                            OrderSummaryRow(title: "Address", value: order.receiverAddress)
                            OrderSummaryRow(title: "City", value: order.receiverCity)
                            
                            if let estimatedPrice = order.estimatedProductPrice {
                                OrderSummaryRow(title: "Estimated Price", value: "\(PakistanData.currencySymbol)\(String(format: "%.0f", estimatedPrice))")
                            }
                            
                            OrderSummaryRow(title: "Delivery Fee", value: "\(PakistanData.currencySymbol)\(String(format: "%.0f", order.deliveryFee))")
                            
                            if let tip = order.tip, tip > 0 {
                                OrderSummaryRow(title: "Tip", value: "\(PakistanData.currencySymbol)\(String(format: "%.0f", tip))")
                            }
                            
                            Divider()
                            
                            let totalAmount = (order.estimatedProductPrice ?? 0) + order.deliveryFee + (order.tip ?? 0)
                            OrderSummaryRow(
                                title: "Total Estimated Cost",
                                value: "\(PakistanData.currencySymbol)\(String(format: "%.0f", totalAmount))",
                                isTotal: true
                            )
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(16)
                    
                    // Next Steps
                    VStack(alignment: .leading, spacing: 16) {
                        Text("What Happens Next?")
                            .font(.headline)
                            .fontWeight(.bold)
                        
                        VStack(spacing: 12) {
                            NextStepRow(
                                number: "1",
                                title: "Rider Assignment",
                                description: "A rider in your area will be assigned to your order",
                                icon: "person.badge.plus"
                            )
                            
                            NextStepRow(
                                number: "2",
                                title: "Price Confirmation",
                                description: "Rider will check the actual product price and confirm",
                                icon: "checkmark.circle"
                            )
                            
                            NextStepRow(
                                number: "3",
                                title: "Payment",
                                description: "You'll confirm the final price and make payment",
                                icon: "creditcard"
                            )
                            
                            NextStepRow(
                                number: "4",
                                title: "Delivery",
                                description: "Rider will purchase and deliver your gift",
                                icon: "shippingbox"
                            )
                        }
                    }
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(16)
                    
                    // Action Buttons
                    VStack(spacing: 12) {
                        Button("View Order Details") {
                            showingOrderDetails = true
                        }
                        .buttonStyle(.borderedProminent)
                        .frame(maxWidth: .infinity)
                        
                        Button("Back to Home") {
                            dismiss()
                        }
                        .buttonStyle(.bordered)
                        .frame(maxWidth: .infinity)
                    }
                }
                .padding(20)
            }
            .navigationTitle("Order Confirmed")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .sheet(isPresented: $showingOrderDetails) {
                OrderDetailsView(order: order)
            }
        }
    }
}

struct OrderSummaryRow: View {
    let title: String
    let value: String
    var isTotal: Bool = false
    
    var body: some View {
        HStack {
            Text(title)
                .font(isTotal ? .headline : .body)
                .foregroundColor(.primary)
            
            Spacer()
            
            Text(value)
                .font(isTotal ? .headline : .body)
                .fontWeight(isTotal ? .bold : .regular)
                .foregroundColor(.primary)
                .multilineTextAlignment(.trailing)
        }
    }
}

struct NextStepRow: View {
    let number: String
    let title: String
    let description: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 12) {
            // Step Number
            ZStack {
                Circle()
                    .fill(Color.blue)
                    .frame(width: 32, height: 32)
                
                Text(number)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            
            // Icon
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 24)
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            Spacer()
        }
    }
}

#Preview {
    OrderConfirmationView(order: GiftOrder(
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
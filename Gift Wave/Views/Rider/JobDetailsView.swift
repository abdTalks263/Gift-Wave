//
//  JobDetailsView.swift
//  Gift Wave
//
//  Created by Abdullah Latif on 04/08/2025.
//

import SwiftUI

struct JobDetailsView: View {
    let order: GiftOrder
    @EnvironmentObject var orderViewModel: OrderViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var isAccepting = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Gift Info
                    VStack(alignment: .leading, spacing: 8) {
                        Text(order.giftName)
                            .font(.title2)
                            .fontWeight(.bold)
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
                    
                    // Cost
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Delivery Fee: $\(String(format: "%.2f", order.deliveryFee))")
                        if let tip = order.tip, tip > 0 {
                            Text("Tip: $\(String(format: "%.2f", tip))")
                        }
                        Text("Total: $\(String(format: "%.2f", order.totalAmount))")
                            .fontWeight(.bold)
                    }
                    .font(.subheadline)
                }
                .padding(20)
                
                // Accept Button
                if order.status == .pending {
                    Button(action: acceptJob) {
                        HStack {
                            if isAccepting {
                                ProgressView()
                            } else {
                                Image(systemName: "checkmark.circle.fill")
                                Text("Accept Job")
                                    .fontWeight(.semibold)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                    .disabled(isAccepting)
                }
            }
            .navigationTitle("Job Details")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }
    
    private func acceptJob() {
        guard let user = authViewModel.currentUser else { return }
        isAccepting = true
        Task {
            await orderViewModel.acceptOrder(orderId: order.id ?? "", riderId: user.id ?? "", riderName: user.fullName, riderPhone: user.phoneNumber)
            isAccepting = false
            dismiss()
        }
    }
}

#Preview {
    JobDetailsView(order: GiftOrder(
        senderId: "1", 
        senderName: "Alice", 
        senderPhone: "123", 
        giftName: "Cake", 
        productLink: nil, 
        requestVideo: false, 
        personalMessage: "Happy Birthday!", 
        receiverName: "Bob", 
        receiverAddress: "123 St", 
        receiverCity: "City", 
        receiverPhone: "456", 
        deliveryFee: 5, 
        tip: 2
    ))
    .environmentObject(OrderViewModel())
    .environmentObject(AuthViewModel())
} 
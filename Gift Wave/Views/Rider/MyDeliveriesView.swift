//
//  MyDeliveriesView.swift
//  Gift Wave
//
//  Created by Abdullah Latif on 04/08/2025.
//

import SwiftUI

struct MyDeliveriesView: View {
    @EnvironmentObject var orderViewModel: OrderViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var selectedFilter: OrderStatus? = nil
    
    private var filteredOrders: [GiftOrder] {
        if let filter = selectedFilter {
            return orderViewModel.orders.filter { $0.status == filter }
        }
        return orderViewModel.orders
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Filter Buttons
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    FilterButton(title: "All", isSelected: selectedFilter == nil) {
                        selectedFilter = nil
                    }
                    
                    ForEach([OrderStatus.accepted, .purchased, .inTransit, .delivered], id: \.self) { status in
                        FilterButton(title: status.rawValue.capitalized, isSelected: selectedFilter == status) {
                            selectedFilter = status
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
            .padding(.vertical, 10)
            
            // Deliveries List
            if orderViewModel.isLoading {
                Spacer()
                ProgressView("Loading deliveries...")
                Spacer()
            } else if filteredOrders.isEmpty {
                Spacer()
                VStack(spacing: 16) {
                    Image(systemName: "bicycle")
                        .font(.system(size: 60))
                        .foregroundColor(.gray)
                    
                    Text(selectedFilter == nil ? "No Deliveries Yet" : "No \(selectedFilter?.rawValue.capitalized ?? "") Deliveries")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Text("Your accepted deliveries will appear here.")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                Spacer()
            } else {
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(filteredOrders) { order in
                            DeliveryCard(order: order)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
            }
        }
        .refreshable {
            if let userId = authViewModel.currentUser?.id {
                await orderViewModel.fetchRiderOrders(riderId: userId)
            }
        }
        .onAppear {
            if let userId = authViewModel.currentUser?.id {
                Task {
                    await orderViewModel.fetchRiderOrders(riderId: userId)
                }
            }
        }
    }
}

struct DeliveryCard: View {
    let order: GiftOrder
    @State private var showingDeliveryDetails = false
    
    var body: some View {
        Button(action: {
            showingDeliveryDetails = true
        }) {
            VStack(alignment: .leading, spacing: 16) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(order.giftName)
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Text("Order #\(order.id?.prefix(8) ?? "N/A")")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                                            OrderStatusBadge(status: order.status)
                }
                
                // Delivery Details
                VStack(spacing: 8) {
                    DeliveryDetailRow(icon: "person.fill", text: "To: \(order.receiverName)")
                    DeliveryDetailRow(icon: "location.fill", text: order.receiverAddress)
                    DeliveryDetailRow(icon: "phone.fill", text: order.receiverPhone)
                    
                    if order.requestVideo {
                        DeliveryDetailRow(icon: "video.fill", text: "Reaction video requested", color: .orange)
                    }
                }
                
                // Earnings and Actions
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Earnings")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("\(PakistanData.currencySymbol)\(String(format: "%.0f", order.totalAmount))")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.green)
                    }
                    
                    Spacer()
                    
                    // Action buttons based on status
                    switch order.status {
                    case .accepted:
                        Button("Start Delivery") {
                            // Handle start delivery
                        }
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        
                    case .purchased:
                        Button("In Transit") {
                            // Handle in transit
                        }
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        
                    case .inTransit:
                        Button("Delivered") {
                            // Handle delivered
                        }
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        
                    case .delivered:
                        Text("Completed")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.gray.opacity(0.2))
                            .foregroundColor(.secondary)
                            .cornerRadius(8)
                        
                    default:
                        EmptyView()
                    }
                }
            }
            .padding(20)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(16)
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: $showingDeliveryDetails) {
            DeliveryDetailsView(order: order)
        }
    }
}

struct DeliveryDetailRow: View {
    let icon: String
    let text: String
    var color: Color = .secondary
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(color)
                .frame(width: 16)
            
            Text(text)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(1)
            
            Spacer()
        }
    }
}

#Preview {
    MyDeliveriesView()
        .environmentObject(OrderViewModel())
        .environmentObject(AuthViewModel())
} 
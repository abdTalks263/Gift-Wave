//
//  OrdersListView.swift
//  Gift Wave
//
//  Created by Abdullah Latif on 04/08/2025.
//

import SwiftUI

struct OrdersListView: View {
    @EnvironmentObject var orderViewModel: OrderViewModel
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
                    
                    ForEach(OrderStatus.allCases, id: \.self) { status in
                        FilterButton(title: status.rawValue.capitalized, isSelected: selectedFilter == status) {
                            selectedFilter = status
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
            .padding(.vertical, 10)
            
            // Orders List
            if orderViewModel.isLoading {
                Spacer()
                ProgressView("Loading orders...")
                Spacer()
            } else if filteredOrders.isEmpty {
                Spacer()
                VStack(spacing: 16) {
                    Image(systemName: "list.bullet")
                        .font(.system(size: 60))
                        .foregroundColor(.gray)
                    
                    Text(selectedFilter == nil ? "No Orders Yet" : "No \(selectedFilter?.rawValue.capitalized ?? "") Orders")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Text("Your orders will appear here once you place them.")
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
                            OrderDetailCard(order: order)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
            }
        }
        .refreshable {
            // Refresh orders - this will be handled by the parent view
        }
    }
}

struct FilterButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.blue : Color.gray.opacity(0.2))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(20)
        }
    }
}

struct OrderDetailCard: View {
    let order: GiftOrder
    @State private var showingOrderDetails = false
    
    var body: some View {
        Button(action: {
            showingOrderDetails = true
        }) {
            VStack(alignment: .leading, spacing: 16) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(order.giftName)
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        if let orderId = order.id {
                            Text("Order #\(orderId.prefix(8))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        } else {
                            Text("Order #Generating...")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    VStack(spacing: 4) {
                        OrderStatusBadge(status: order.status)
                        PaymentStatusBadge(status: order.paymentStatus)
                    }
                }
                
                // Order Details
                VStack(spacing: 8) {
                    OrderDetailRow(icon: "person.fill", text: "To: \(order.receiverName)")
                    OrderDetailRow(icon: "location.fill", text: order.receiverAddress)
                    OrderDetailRow(icon: "calendar", text: order.createdAt.formatted(date: .abbreviated, time: .omitted))
                    
                    if let riderName = order.riderName {
                        OrderDetailRow(icon: "bicycle", text: "Rider: \(riderName)")
                    }
                }
                
                // Cost and Actions
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Total Amount")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("\(PakistanData.currencySymbol)\(String(format: "%.0f", order.totalAmount))")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                    }
                    
                    Spacer()
                    
                    if order.status == .delivered && order.rating == nil {
                        Button("Rate") {
                            // Handle rating
                        }
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                }
            }
            .padding(20)
            .background(Color(.systemGray6))
            .cornerRadius(16)
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: $showingOrderDetails) {
            OrderDetailsView(order: order)
        }
    }
}

struct OrderDetailRow: View {
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
    OrdersListView()
        .environmentObject(OrderViewModel())
} 
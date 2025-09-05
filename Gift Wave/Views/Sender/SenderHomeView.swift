//
//  SenderHomeView.swift
//  Gift Wave
//
//  Created by Abdullah Latif on 04/08/2025.
//

import SwiftUI

struct SenderHomeView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var orderViewModel = OrderViewModel()
    @StateObject private var securityViewModel = SecurityViewModel()
    @State private var showingNewOrder = false
    @State private var selectedTab = 0
    @State private var showingSafetyAlert = false
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Home Tab
            NavigationView {
                ScrollView {
                    VStack(spacing: 25) {
                        // Welcome Header
                        VStack(spacing: 16) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Welcome back,")
                                        .font(.title2)
                                        .foregroundColor(.secondary)
                                    
                                    Text(authViewModel.currentUser?.fullName ?? "User")
                                        .font(.title)
                                        .fontWeight(.bold)
                                }
                                
                                Spacer()
                                
                                HStack(spacing: 16) {
                                    Button(action: {
                                        showingSafetyAlert = true
                                    }) {
                                        Image(systemName: "exclamationmark.triangle.fill")
                                            .font(.title2)
                                            .foregroundColor(.red)
                                    }
                                    
                                    Button(action: {
                                        authViewModel.signOut()
                                    }) {
                                        Image(systemName: "rectangle.portrait.and.arrow.right")
                                            .font(.title2)
                                            .foregroundColor(.blue)
                                    }
                                }
                            }
                            
                            // Quick Stats
                            HStack(spacing: 20) {
                                StatCard(
                                    title: "Orders Sent",
                                    value: "\(orderViewModel.orders.count)",
                                    icon: "gift.fill",
                                    color: .blue
                                )
                                
                                StatCard(
                                    title: "Delivered",
                                    value: "\(orderViewModel.orders.filter { $0.status == .delivered }.count)",
                                    icon: "checkmark.circle.fill",
                                    color: .green
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // Quick Actions
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Quick Actions")
                                .font(.title2)
                                .fontWeight(.bold)
                                .padding(.horizontal, 20)
                            
                            VStack(spacing: 12) {
                                QuickActionButton(
                                    title: "Send a Gift",
                                    subtitle: "Create a new gift order",
                                    icon: "gift.fill",
                                    color: .blue
                                ) {
                                    showingNewOrder = true
                                }
                                
                                QuickActionButton(
                                    title: "Track Orders",
                                    subtitle: "View your active orders",
                                    icon: "location.fill",
                                    color: .orange
                                ) {
                                    selectedTab = 1
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                        
                        // Recent Orders
                        if !orderViewModel.orders.isEmpty {
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Recent Orders")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .padding(.horizontal, 20)
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 16) {
                                        ForEach(orderViewModel.orders.prefix(5)) { order in
                                            OrderCard(order: order)
                                        }
                                    }
                                    .padding(.horizontal, 20)
                                }
                            }
                        }
                        
                        Spacer(minLength: 100)
                    }
                    .padding(.top, 20)
                }
                .navigationBarHidden(true)
                .refreshable {
                    if let userId = authViewModel.currentUser?.id {
                        await orderViewModel.fetchUserOrders(userId: userId)
                    }
                }
            }
            .tabItem {
                Image(systemName: "house.fill")
                Text("Home")
            }
            .tag(0)
            
            // Orders Tab
            NavigationView {
                OrdersListView()
                    .environmentObject(orderViewModel)
                    .navigationTitle("My Orders")
            }
            .tabItem {
                Image(systemName: "list.bullet")
                Text("Orders")
            }
            .tag(1)
            
            // Profile Tab
            NavigationView {
                ProfileView()
                    .environmentObject(authViewModel)
                    .navigationTitle("Profile")
            }
            .tabItem {
                Image(systemName: "person.fill")
                Text("Profile")
            }
            .tag(2)
        }
        .sheet(isPresented: $showingNewOrder) {
            NewOrderView()
                .environmentObject(orderViewModel)
        }
        .sheet(isPresented: $showingSafetyAlert) {
            SafetyAlertView(order: nil)
                .environmentObject(securityViewModel)
        }
        .onAppear {
            if let userId = authViewModel.currentUser?.id {
                Task {
                    await orderViewModel.fetchUserOrders(userId: userId)
                }
            }
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

struct QuickActionButton: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                    .frame(width: 40)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
        }
    }
}

struct OrderCard: View {
    let order: GiftOrder
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(order.giftName)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(order.receiverName)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                OrderStatusBadge(status: order.status)
            }
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Delivery Fee")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("\(PakistanData.currencySymbol)\(String(format: "%.0f", order.deliveryFee))")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                Text(order.createdAt, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(16)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
        .frame(width: 280)
    }
}



#Preview {
    SenderHomeView()
        .environmentObject(AuthViewModel())
} 
//
//  RiderHomeView.swift
//  Gift Wave
//
//  Created by Abdullah Latif on 04/08/2025.
//

import SwiftUI

struct RiderHomeView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var orderViewModel = OrderViewModel()
    @StateObject private var locationManager = LocationManager()
    @State private var selectedTab = 0
    @State private var showingJobDetails = false
    @State private var selectedOrder: GiftOrder?
    @State private var maxDistanceKm: Double = 10.0
    @State private var showingDistanceFilter = false
    @State private var useLocationFilter = false
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Available Jobs Tab
            NavigationView {
                VStack(spacing: 0) {
                    if let user = authViewModel.currentUser, user.isApprovedRider {
                        if orderViewModel.isLoading {
                            Spacer()
                            ProgressView("Loading available jobs...")
                            Spacer()
                        } else if orderViewModel.orders.isEmpty {
                            Spacer()
                            VStack(spacing: 16) {
                                Image(systemName: "bicycle")
                                    .font(.system(size: 60))
                                    .foregroundColor(.gray)
                                
                                Text("No Available Jobs")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primary)
                                
                                Text("Check back later for new delivery opportunities in your city.")
                                    .font(.body)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 40)
                            }
                            Spacer()
                        } else {
                            ScrollView {
                                LazyVStack(spacing: 16) {
                                    ForEach(orderViewModel.orders) { order in
                                        AvailableJobCard(order: order) {
                                            selectedOrder = order
                                            showingJobDetails = true
                                        }
                                    }
                                }
                                .padding(.horizontal, 20)
                                .padding(.top, 20)
                            }
                        }
                    } else {
                        // Not approved rider
                        Spacer()
                        VStack(spacing: 20) {
                            Image(systemName: "clock.badge.questionmark")
                                .font(.system(size: 60))
                                .foregroundColor(.orange)
                            
                            Text("Verification Pending")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                            
                            Text("Your rider application is under review. You'll be notified once approved.")
                                .font(.body)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)
                            
                            if let user = authViewModel.currentUser {
                                VStack(spacing: 8) {
                                    Text("Status: \(user.riderStatus?.rawValue.capitalized ?? "Unknown")")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    
                                    if user.riderStatus == .rejected {
                                        Text("Your application was not approved. Please contact support.")
                                            .font(.caption)
                                            .foregroundColor(.red)
                                            .multilineTextAlignment(.center)
                                    }
                                }
                            }
                        }
                        Spacer()
                    }
                }
                .navigationTitle("Available Jobs")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            showingDistanceFilter = true
                        }) {
                            Image(systemName: "location.circle")
                                .foregroundColor(useLocationFilter ? .blue : .gray)
                        }
                    }
                }
                .refreshable {
                    if let user = authViewModel.currentUser, user.isApprovedRider {
                        if useLocationFilter, let location = locationManager.currentLocation {
                            let nearbyOrders = await locationManager.getNearbyOrders(
                                riderLocation: location,
                                maxDistanceKm: maxDistanceKm
                            )
                            orderViewModel.orders = nearbyOrders
                        } else {
                            await orderViewModel.fetchAvailableOrders(city: user.city ?? "")
                        }
                    }
                }
            }
            .tabItem {
                Image(systemName: "briefcase.fill")
                Text("Jobs")
            }
            .tag(0)
            
            // My Deliveries Tab
            NavigationView {
                MyDeliveriesView()
                    .environmentObject(orderViewModel)
                    .navigationTitle("My Deliveries")
            }
            .tabItem {
                Image(systemName: "bicycle")
                Text("Deliveries")
            }
            .tag(1)
            
            // Profile Tab
            NavigationView {
                RiderProfileView()
                    .environmentObject(authViewModel)
                    .navigationTitle("Profile")
            }
            .tabItem {
                Image(systemName: "person.fill")
                Text("Profile")
            }
            .tag(2)
        }
        .sheet(isPresented: $showingJobDetails) {
            if let order = selectedOrder {
                JobDetailsView(order: order)
                    .environmentObject(orderViewModel)
            }
        }
        .sheet(isPresented: $showingDistanceFilter) {
            DistanceFilterView(
                useLocationFilter: $useLocationFilter,
                maxDistanceKm: $maxDistanceKm,
                locationManager: locationManager
            )
        }
        .onAppear {
            if let user = authViewModel.currentUser, user.isApprovedRider {
                locationManager.requestLocationPermission()
            }
        }
        .onAppear {
            if let user = authViewModel.currentUser, user.isApprovedRider {
                Task {
                    await orderViewModel.fetchAvailableOrders(city: user.city ?? "")
                }
            }
        }
    }
}

struct AvailableJobCard: View {
    let order: GiftOrder
    let onTap: () -> Void
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 16) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(order.giftName)
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Text("To: \(order.receiverName)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("\(PakistanData.currencySymbol)\(String(format: "%.0f", order.totalAmount))")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                        
                        Text("Total Earnings")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        if let user = authViewModel.currentUser,
                           let userCity = user.city,
                           let userCoordinates = LocationUtils.getCoordinates(for: userCity),
                           let orderCoordinates = LocationUtils.getCoordinates(for: order.receiverCity) {
                            let distance = LocationUtils.calculateDistance(from: userCoordinates, to: orderCoordinates)
                            Text(LocationUtils.formatDistance(distance))
                                .font(.caption)
                                .foregroundColor(.orange)
                        }
                    }
                }
                
                // Details
                VStack(spacing: 8) {
                    JobDetailRow(icon: "location.fill", text: order.receiverAddress)
                    JobDetailRow(icon: "phone.fill", text: order.receiverPhone)
                    
                    if order.requestVideo {
                        JobDetailRow(icon: "video.fill", text: "Reaction video requested", color: .orange)
                    }
                }
                
                // Action Button
                HStack {
                    Spacer()
                    
                    Text("View Details")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                    
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            }
            .padding(20)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(16)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct JobDetailRow: View {
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
    RiderHomeView()
        .environmentObject(AuthViewModel())
} 
//
//  RiderProfileView.swift
//  Gift Wave
//
//  Created by Abdullah Latif on 04/08/2025.
//

import SwiftUI

struct RiderProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showEditProfile = false
    @State private var showEarningsHistory = false
    @State private var showSettings = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 25) {
                // Profile Header
                VStack(spacing: 16) {
                    if let user = authViewModel.currentUser {
                        // Profile Image
                        if let profileImageURL = user.profileImageURL {
                            AsyncImage(url: URL(string: profileImageURL)) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            } placeholder: {
                                Circle()
                                    .fill(Color.gray.opacity(0.2))
                                    .overlay(
                                        Image(systemName: "bicycle")
                                            .font(.system(size: 40))
                                            .foregroundColor(.gray)
                                    )
                            }
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                        } else {
                            Circle()
                                .fill(Color.gray.opacity(0.2))
                                .frame(width: 100, height: 100)
                                .overlay(
                                    Image(systemName: "bicycle")
                                        .font(.system(size: 40))
                                        .foregroundColor(.gray)
                                )
                        }
                        
                        // User Info
                        VStack(spacing: 8) {
                            Text(user.fullName)
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                            
                            Text(user.email)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Text("Rider")
                                .font(.caption)
                                .fontWeight(.medium)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 4)
                                .background(Color.green.opacity(0.2))
                                .foregroundColor(.green)
                                .cornerRadius(12)
                        }
                        
                        // Rider Status
                        if let status = user.riderStatus {
                            HStack(spacing: 8) {
                                Image(systemName: statusIcon(for: status))
                                    .foregroundColor(statusColor(for: status))
                                
                                Text("Status: \(status.rawValue.capitalized)")
                                    .font(.subheadline)
                                    .foregroundColor(statusColor(for: status))
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(statusColor(for: status).opacity(0.1))
                            .cornerRadius(12)
                        }
                    }
                }
                .padding(.top, 20)
                
                // Rider Stats
                if let user = authViewModel.currentUser {
                    VStack(spacing: 16) {
                        Text("Performance Stats")
                            .font(.title2)
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        HStack(spacing: 16) {
                            StatCard(
                                title: "Rating",
                                value: String(format: "%.1f", user.averageRating ?? 0.0),
                                icon: "star.fill",
                                color: .yellow
                            )
                            
                            StatCard(
                                title: "Deliveries",
                                value: "\(user.totalDeliveries ?? 0)",
                                icon: "checkmark.circle.fill",
                                color: .green
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                }
                
                // Profile Details
                VStack(spacing: 16) {
                    if let user = authViewModel.currentUser {
                        ProfileSection(title: "Personal Information") {
                            ProfileRow(title: "Full Name", value: user.fullName)
                            ProfileRow(title: "Email", value: user.email)
                            ProfileRow(title: "Phone", value: user.phoneNumber)
                            ProfileRow(title: "Member Since", value: user.createdAt.formatted(date: .abbreviated, time: .omitted))
                        }
                        
                        ProfileSection(title: "Rider Information") {
                            if let cnic = user.cnic {
                                ProfileRow(title: "CNIC", value: cnic)
                            }
                            if let city = user.city {
                                ProfileRow(title: "City", value: city)
                            }
                            if let averageRating = user.averageRating {
                                ProfileRow(title: "Average Rating", value: String(format: "%.1f", averageRating))
                            }
                            if let totalDeliveries = user.totalDeliveries {
                                ProfileRow(title: "Total Deliveries", value: "\(totalDeliveries)")
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                
                // Actions
                VStack(spacing: 12) {
                    Button(action: {
                        showEditProfile = true
                    }) {
                        HStack {
                            Image(systemName: "pencil")
                                .font(.system(size: 16))
                            
                            Text("Edit Profile")
                                .fontWeight(.medium)
                            
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
                    .foregroundColor(.primary)
                    
                    Button(action: {
                        showEarningsHistory = true
                    }) {
                        HStack {
                            Image(systemName: "dollarsign.circle")
                                .font(.system(size: 16))
                            
                            Text("Earnings History")
                                .fontWeight(.medium)
                            
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
                    .foregroundColor(.primary)
                    
                    Button(action: {
                        showSettings = true
                    }) {
                        HStack {
                            Image(systemName: "gearshape")
                                .font(.system(size: 16))
                            
                            Text("Settings")
                                .fontWeight(.medium)
                            
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
                    .foregroundColor(.primary)
                    
                    Button(action: {
                        authViewModel.signOut()
                    }) {
                        HStack {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                                .font(.system(size: 16))
                            
                            Text("Sign Out")
                                .fontWeight(.medium)
                            
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(12)
                    }
                    .foregroundColor(.red)
                }
                .padding(.horizontal, 20)
                
                Spacer(minLength: 50)
            }
        }
        .navigationTitle("Rider Profile")
        .sheet(isPresented: $showEditProfile) {
            NavigationView {
                EditProfileView()
            }
        }
        .sheet(isPresented: $showEarningsHistory) {
            NavigationView {
                EarningsHistoryView()
            }
        }
        .sheet(isPresented: $showSettings) {
            NavigationView {
                SettingsView()
            }
        }
    }
    
    private func statusIcon(for status: RiderStatus) -> String {
        switch status {
        case .pending:
            return "clock"
        case .approved:
            return "checkmark.circle"
        case .rejected:
            return "xmark.circle"
        case .banned:
            return "exclamationmark.triangle"
        }
    }
    
    private func statusColor(for status: RiderStatus) -> Color {
        switch status {
        case .pending:
            return .orange
        case .approved:
            return .green
        case .rejected:
            return .red
        case .banned:
            return .red
        }
    }
}

#Preview {
    NavigationView {
        RiderProfileView()
            .environmentObject(AuthViewModel())
    }
} 
//
//  ProfileView.swift
//  Gift Wave
//
//  Created by Abdullah Latif on 04/08/2025.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
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
                                        Image(systemName: "person.fill")
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
                                    Image(systemName: "person.fill")
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
                            
                            Text(user.userType.rawValue.capitalized)
                                .font(.caption)
                                .fontWeight(.medium)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 4)
                                .background(user.userType == .sender ? Color.blue.opacity(0.2) : Color.green.opacity(0.2))
                                .foregroundColor(user.userType == .sender ? .blue : .green)
                                .cornerRadius(12)
                        }
                        
                        // Rider Status (if applicable)
                        if user.isRider, let status = user.riderStatus {
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
                
                // Profile Details
                VStack(spacing: 16) {
                    if let user = authViewModel.currentUser {
                        ProfileSection(title: "Personal Information") {
                            ProfileRow(title: "Full Name", value: user.fullName)
                            ProfileRow(title: "Email", value: user.email)
                            ProfileRow(title: "Phone", value: user.phoneNumber)
                            ProfileRow(title: "Member Since", value: user.createdAt.formatted(date: .abbreviated, time: .omitted))
                        }
                        
                        if user.isRider {
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
                }
                .padding(.horizontal, 20)
                
                // Actions
                VStack(spacing: 12) {
                    Button(action: {
                        // Handle edit profile
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
                        // Handle settings
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
        .navigationTitle("Profile")
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

struct ProfileSection<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)
            
            VStack(spacing: 0) {
                content
            }
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
        }
    }
}

struct ProfileRow: View {
    let title: String
    let value: String
    
    init(title: String, value: String) {
        self.title = title
        self.value = value
    }
    
    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .foregroundColor(.primary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

#Preview {
    NavigationView {
        ProfileView()
            .environmentObject(AuthViewModel())
    }
} 
import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var notificationsEnabled = true
    @State private var darkModeEnabled = false
    @State private var showLocationSettings = false
    @State private var showNotificationSettings = false
    @State private var showPrivacySettings = false
    @State private var showSecuritySettings = false
    
    var body: some View {
        List {
            Section(header: Text("Account")) {
                NavigationLink(destination: Text("Account Settings")) {
                    SettingRow(icon: "person.fill", title: "Account Details", color: .blue)
                }
                
                NavigationLink(destination: Text("Security Settings"), isActive: $showSecuritySettings) {
                    SettingRow(icon: "lock.fill", title: "Security", color: .green)
                }
                
                NavigationLink(destination: Text("Privacy Settings"), isActive: $showPrivacySettings) {
                    SettingRow(icon: "hand.raised.fill", title: "Privacy", color: .purple)
                }
            }
            
            Section(header: Text("Preferences")) {
                NavigationLink(destination: Text("Notification Settings"), isActive: $showNotificationSettings) {
                    SettingRow(icon: "bell.fill", title: "Notifications", color: .red)
                }
                
                NavigationLink(destination: Text("Location Settings"), isActive: $showLocationSettings) {
                    SettingRow(icon: "location.fill", title: "Location Services", color: .orange)
                }
                
                Toggle(isOn: $darkModeEnabled) {
                    SettingRow(icon: "moon.fill", title: "Dark Mode", color: .gray)
                }
            }
            
            Section(header: Text("App")) {
                Button(action: {
                    // Handle contact support
                }) {
                    SettingRow(icon: "questionmark.circle.fill", title: "Help & Support", color: .blue)
                }
                
                Button(action: {
                    // Handle about
                }) {
                    SettingRow(icon: "info.circle.fill", title: "About", color: .gray)
                }
                
                Button(action: {
                    // Handle terms
                }) {
                    SettingRow(icon: "doc.text.fill", title: "Terms & Conditions", color: .gray)
                }
            }
            
            Section {
                Button(action: {
                    authViewModel.signOut()
                    dismiss()
                }) {
                    HStack {
                        Image(systemName: "arrow.right.circle.fill")
                            .foregroundColor(.red)
                        Text("Sign Out")
                            .foregroundColor(.red)
                    }
                }
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Done") {
                    dismiss()
                }
            }
        }
    }
}

struct SettingRow: View {
    let icon: String
    let title: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 24)
            Text(title)
        }
    }
}

#Preview {
    NavigationView {
        SettingsView()
            .environmentObject(AuthViewModel())
    }
}

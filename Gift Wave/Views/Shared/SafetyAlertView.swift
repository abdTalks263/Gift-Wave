//
//  SafetyAlertView.swift
//  Gift Wave
//
//  Created by Abdullah Latif on 04/08/2025.
//

import SwiftUI
import CoreLocation

struct SafetyAlertView: View {
    @EnvironmentObject var securityViewModel: SecurityViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    
    let order: GiftOrder?
    @State private var selectedAlertType: SafetyAlertType = .suspicious
    @State private var description = ""
    @State private var showingConfirmation = false
    @State private var isSubmitting = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Emergency Header
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.red)
                    
                    Text("Safety Alert")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.red)
                    
                    Text("Report any safety concerns or suspicious activity")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 20)
                
                // Alert Type Selection
                VStack(alignment: .leading, spacing: 12) {
                    Text("Alert Type")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Picker("Alert Type", selection: $selectedAlertType) {
                        ForEach(SafetyAlertType.allCases, id: \.self) { type in
                            Text(type.rawValue.capitalized).tag(type)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                .padding(.horizontal, 20)
                
                // Description
                VStack(alignment: .leading, spacing: 8) {
                    Text("Description")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    TextField("Describe what happened...", text: $description, axis: .vertical)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .lineLimit(4...8)
                }
                .padding(.horizontal, 20)
                
                // Emergency Actions
                VStack(spacing: 12) {
                    Button(action: {
                        showingConfirmation = true
                    }) {
                        HStack {
                            if isSubmitting {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                            } else {
                                Image(systemName: "exclamationmark.triangle.fill")
                                Text("Submit Safety Alert")
                                    .fontWeight(.semibold)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .disabled(isSubmitting || description.isEmpty)
                    
                    Button(action: {
                        callEmergencyServices()
                    }) {
                        HStack {
                            Image(systemName: "phone.fill")
                            Text("Call Emergency Services")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                }
                .padding(.horizontal, 20)
                
                Spacer()
            }
            .navigationTitle("Safety Alert")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .alert("Submit Safety Alert?", isPresented: $showingConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Submit") {
                    submitSafetyAlert()
                }
            } message: {
                Text("This will immediately notify our security team and may result in account review.")
            }
        }
    }
    
    private func submitSafetyAlert() {
        guard let user = authViewModel.currentUser else { return }
        
        isSubmitting = true
        
        Task {
            await securityViewModel.createSafetyAlert(
                userId: user.id ?? "",
                userName: user.fullName,
                alertType: selectedAlertType,
                orderId: order?.id,
                location: nil, // In real app, get current location
                description: description
            )
            
            isSubmitting = false
            dismiss()
        }
    }
    
    private func callEmergencyServices() {
        // Pakistan emergency numbers
        let emergencyNumbers = [
            "Police": "15",
            "Ambulance": "1122", 
            "Fire Brigade": "16",
            "Rescue 1122": "1122"
        ]
        
        // Show emergency numbers alert
        let alert = UIAlertController(title: "Emergency Services", message: "Choose emergency service:", preferredStyle: .actionSheet)
        
        for (service, number) in emergencyNumbers {
            alert.addAction(UIAlertAction(title: "\(service) (\(number))", style: .default) { _ in
                if let url = URL(string: "tel://\(number)") {
                    UIApplication.shared.open(url)
                }
            })
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        // Present alert
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController?.present(alert, animated: true)
        }
    }
}

#Preview {
    SafetyAlertView(order: nil)
        .environmentObject(SecurityViewModel())
        .environmentObject(AuthViewModel())
} 
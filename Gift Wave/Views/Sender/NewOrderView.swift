//
//  NewOrderView.swift
//  Gift Wave
//
//  Created by Abdullah Latif on 04/08/2025.
//

import SwiftUI
import CoreLocation

struct NewOrderView: View {
    @EnvironmentObject var orderViewModel: OrderViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var giftName = ""
    @State private var productLink = ""
    @State private var requestVideo = false
    @State private var personalMessage = ""
    @State private var estimatedProductPrice = ""
    @State private var receiverName = ""
    @State private var receiverAddress = ""
    @State private var selectedProvince = ""
    @State private var receiverCity = ""
    @State private var receiverPhone = ""
    @State private var tip = ""
    @State private var deliveryFee: Double = 0.0
    @State private var validationErrors: [String: String] = [:]
    @State private var showingConfirmation = false
    @State private var createdOrder: GiftOrder?
    @State private var currentStep = 0
    
    private let steps = ["Gift Details", "Receiver Info", "Review & Pay"]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Progress Bar
                HStack(spacing: 0) {
                    ForEach(0..<steps.count, id: \.self) { index in
                        Rectangle()
                            .fill(index <= currentStep ? Color.blue : Color.gray.opacity(0.3))
                            .frame(height: 4)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                
                // Step Indicator
                HStack {
                    ForEach(0..<steps.count, id: \.self) { index in
                        Text(steps[index])
                            .font(.caption)
                            .foregroundColor(index <= currentStep ? .blue : .secondary)
                        
                        if index < steps.count - 1 {
                            Spacer()
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                
                // Content
                ScrollView {
                    VStack(spacing: 25) {
                        switch currentStep {
                        case 0:
                            giftDetailsStep
                        case 1:
                            receiverInfoStep
                        case 2:
                            reviewStep
                        default:
                            EmptyView()
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 30)
                }
                
                // Navigation Buttons
                HStack(spacing: 16) {
                    if currentStep > 0 {
                        Button("Back") {
                            withAnimation {
                                currentStep -= 1
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.gray.opacity(0.2))
                        .foregroundColor(.primary)
                        .cornerRadius(12)
                    }
                    
                    Button(currentStep == steps.count - 1 ? "Place Order" : "Next") {
                        if currentStep == steps.count - 1 {
                            placeOrder()
                        } else {
                            withAnimation {
                                currentStep += 1
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(isNextButtonEnabled ? Color.blue : Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .disabled(!isNextButtonEnabled || orderViewModel.isLoading)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            .navigationTitle("New Gift Order")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .sheet(isPresented: $showingConfirmation) {
            if let order = createdOrder {
                OrderConfirmationView(order: order)
            }
        }
    }
    
    private var giftDetailsStep: some View {
        VStack(spacing: 20) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Gift Name")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                TextField("e.g., Birthday Cake, Flowers, Book", text: $giftName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .onChange(of: giftName) { _ in
                        validateGiftName()
                    }
                
                if let error = validationErrors["giftName"] {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Product Link (Optional)")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                TextField("https://example.com/product", text: $productLink)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.URL)
                    .autocapitalization(.none)
                    .onChange(of: productLink) { _ in
                        validateProductLink()
                    }
                
                if let error = validationErrors["productLink"] {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Estimated Product Price (PKR)")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                HStack {
                    Text("₨")
                        .foregroundColor(.secondary)
                        .font(.title2)
                    
                    TextField("0", text: $estimatedProductPrice)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.numberPad)
                        .onChange(of: estimatedProductPrice) { _ in
                            validateProductPrice()
                        }
                }
                
                Text("Leave empty if unsure. Rider will confirm actual price.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if let error = validationErrors["estimatedProductPrice"] {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }
            
            Toggle(isOn: $requestVideo) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Request Reaction Video")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text("Get a video of the receiver's reaction")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .toggleStyle(SwitchToggleStyle(tint: .blue))
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Personal Message (Optional)")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                TextField("Add a personal note to your gift", text: $personalMessage, axis: .vertical)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .lineLimit(3...6)
            }
        }
    }
    
    private var receiverInfoStep: some View {
        VStack(spacing: 20) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Receiver Name")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                TextField("Enter receiver's full name", text: $receiverName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .onChange(of: receiverName) { _ in
                        validateReceiverName()
                    }
                
                if let error = validationErrors["receiverName"] {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Phone Number")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                TextField("Enter receiver's phone number", text: $receiverPhone)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.phonePad)
                    .onChange(of: receiverPhone) { _ in
                        validateReceiverPhone()
                    }
                
                if let error = validationErrors["receiverPhone"] {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Province")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Picker("Province", selection: $selectedProvince) {
                    Text("Select Province").tag("")
                    ForEach(PakistanData.provinces, id: \.self) { province in
                        Text(province).tag(province)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("City")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Picker("City", selection: $receiverCity) {
                    Text("Select City").tag("")
                    ForEach(availableCities, id: \.self) { city in
                        Text(city).tag(city)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
                .disabled(selectedProvince.isEmpty)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Address")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                TextField("Enter complete delivery address", text: $receiverAddress)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .onChange(of: receiverAddress) { _ in
                        validateReceiverAddress()
                    }
                
                if let error = validationErrors["receiverAddress"] {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Tip (Optional)")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                TextField("Enter tip amount", text: $tip)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.decimalPad)
            }
        }
        .onChange(of: selectedProvince) { _ in
            receiverCity = ""
            calculateDeliveryFee()
        }
        .onChange(of: receiverCity) { _ in
            calculateDeliveryFee()
        }
    }
    
    private var reviewStep: some View {
        VStack(spacing: 20) {
            // Order Summary
            VStack(alignment: .leading, spacing: 16) {
                Text("Order Summary")
                    .font(.title2)
                    .fontWeight(.bold)
                
                VStack(spacing: 12) {
                    SummaryRow(title: "Gift", value: giftName)
                    if !productLink.isEmpty {
                        SummaryRow(title: "Product Link", value: productLink)
                    }
                    SummaryRow(title: "Reaction Video", value: requestVideo ? "Yes" : "No")
                    if !personalMessage.isEmpty {
                        SummaryRow(title: "Personal Message", value: personalMessage)
                    }
                    SummaryRow(title: "Receiver", value: receiverName)
                    SummaryRow(title: "City", value: receiverCity)
                    SummaryRow(title: "Address", value: receiverAddress)
                    SummaryRow(title: "Phone", value: receiverPhone)
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
            
            // Cost Breakdown
            VStack(alignment: .leading, spacing: 16) {
                Text("Cost Breakdown")
                    .font(.title2)
                    .fontWeight(.bold)
                
                VStack(spacing: 12) {
                    if let estimatedPrice = Double(estimatedProductPrice), estimatedPrice > 0 {
                        SummaryRow(title: "Estimated Product Price", value: "\(PakistanData.currencySymbol)\(String(format: "%.0f", estimatedPrice))")
                    }
                    SummaryRow(title: "Delivery Fee", value: "\(PakistanData.currencySymbol)\(String(format: "%.0f", deliveryFee))")
                    if let tipAmount = Double(tip), tipAmount > 0 {
                        SummaryRow(title: "Tip", value: "\(PakistanData.currencySymbol)\(String(format: "%.0f", tipAmount))")
                    }
                    
                    Divider()
                    
                    let totalAmount = (Double(estimatedProductPrice) ?? 0) + deliveryFee + (Double(tip) ?? 0)
                    SummaryRow(
                        title: "Total Estimated Cost",
                        value: "\(PakistanData.currencySymbol)\(String(format: "%.0f", totalAmount))",
                        isTotal: true
                    )
                    
                    Text("Note: Actual product price may vary. Rider will confirm final price.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.top, 8)
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
        }
    }
    
    private var isNextButtonEnabled: Bool {
        switch currentStep {
        case 0:
            return !giftName.isEmpty && validationErrors["giftName"] == nil
        case 1:
            return !receiverName.isEmpty && !receiverPhone.isEmpty && !receiverCity.isEmpty && !receiverAddress.isEmpty && 
                validationErrors["receiverName"] == nil && validationErrors["receiverAddress"] == nil && validationErrors["receiverPhone"] == nil
        case 2:
            return true
        default:
            return false
        }
    }
    
    private var availableCities: [String] {
        if selectedProvince.isEmpty {
            return []
        }
        return PakistanData.getCities(for: selectedProvince)
    }
    
    private func calculateDeliveryFee() {
        guard !selectedProvince.isEmpty && !receiverCity.isEmpty else {
            deliveryFee = 0.0
            return
        }
        
        // Calculate based on province and city
        let baseFee: Double
        let userProvince = authViewModel.currentUser?.city.flatMap { city in
            PakistanData.getProvince(for: city)
        }
        
        if userProvince == selectedProvince {
            // Same province
            baseFee = Double.random(in: 300...800)
        } else {
            // Different province
            baseFee = Double.random(in: 800...2000)
        }
        
        // Add city-specific adjustments
        let cityAdjustment: Double
        switch receiverCity.lowercased() {
        case let city where city.contains("lahore") || city.contains("karachi"):
            cityAdjustment = 1.2 // Major cities
        case let city where city.contains("islamabad") || city.contains("rawalpindi"):
            cityAdjustment = 1.1
        default:
            cityAdjustment = 1.0
        }
        
        deliveryFee = baseFee * cityAdjustment
    }
    
    // MARK: - Validation Methods
    
    private func validateGiftName() {
        let validation = DataValidator.validateGiftName(giftName)
        if validation.isValid {
            validationErrors.removeValue(forKey: "giftName")
        } else {
            validationErrors["giftName"] = validation.message
        }
    }
    
    private func validateProductLink() {
        let validation = DataValidator.validateURL(productLink)
        if validation.isValid {
            validationErrors.removeValue(forKey: "productLink")
        } else {
            validationErrors["productLink"] = validation.message
        }
    }
    
    private func validateReceiverName() {
        let validation = DataValidator.validateName(receiverName)
        if validation.isValid {
            validationErrors.removeValue(forKey: "receiverName")
        } else {
            validationErrors["receiverName"] = validation.message
        }
    }
    
    private func validateReceiverPhone() {
        let validation = DataValidator.validatePhoneNumber(receiverPhone)
        if validation.isValid {
            validationErrors.removeValue(forKey: "receiverPhone")
        } else {
            validationErrors["receiverPhone"] = validation.message
        }
    }
    
    private func validateReceiverAddress() {
        let validation = DataValidator.validateAddress(receiverAddress)
        if validation.isValid {
            validationErrors.removeValue(forKey: "receiverAddress")
        } else {
            validationErrors["receiverAddress"] = validation.message
        }
    }
    
    private func validateProductPrice() {
        if estimatedProductPrice.isEmpty {
            validationErrors.removeValue(forKey: "estimatedProductPrice")
            return
        }
        
        guard let price = Double(estimatedProductPrice) else {
            validationErrors["estimatedProductPrice"] = "Please enter a valid price"
            return
        }
        
        if price < 0 {
            validationErrors["estimatedProductPrice"] = "Price cannot be negative"
        } else if price > 100000 {
            validationErrors["estimatedProductPrice"] = "Price seems too high. Please verify."
        } else {
            validationErrors.removeValue(forKey: "estimatedProductPrice")
        }
    }
    
    private func placeOrder() {
        guard let userId = authViewModel.currentUser?.id,
              let userName = authViewModel.currentUser?.fullName,
              let userPhone = authViewModel.currentUser?.phoneNumber else {
            return
        }
        
        let estimatedPrice = Double(estimatedProductPrice) ?? 0.0
        
        let order = GiftOrder(
            senderId: userId,
            senderName: userName,
            senderPhone: userPhone,
            giftName: giftName,
            productLink: productLink.isEmpty ? nil : productLink,
            requestVideo: requestVideo,
            personalMessage: personalMessage.isEmpty ? nil : personalMessage,
            receiverName: receiverName,
            receiverAddress: receiverAddress,
            receiverCity: receiverCity,
            receiverPhone: receiverPhone,
            deliveryFee: deliveryFee,
            estimatedProductPrice: estimatedPrice > 0 ? estimatedPrice : nil,
            tip: Double(tip)
        )
        
        Task {
            let createdOrderWithId = await orderViewModel.createOrder(order: order)
            if let createdOrderWithId = createdOrderWithId {
                self.createdOrder = createdOrderWithId
                showingConfirmation = true
            }
        }
    }
}

struct SummaryRow: View {
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
        }
    }
}

#Preview {
    NewOrderView()
        .environmentObject(OrderViewModel())
        .environmentObject(AuthViewModel())
} 
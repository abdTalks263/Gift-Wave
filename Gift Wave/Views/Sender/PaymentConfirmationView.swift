import SwiftUI
import PhotosUI

struct PaymentConfirmationView: View {
    @EnvironmentObject var orderViewModel: OrderViewModel
    @Environment(\.dismiss) private var dismiss
    
    let order: GiftOrder
    @State private var selectedPaymentMethod = "JazzCash"
    @State private var selectedPaymentProof: PhotosPickerItem?
    @State private var paymentProofData: Data?
    @State private var isLoading = false
    @State private var errorMessage = ""
    @State private var showingPaymentMethods = false
    
    private let paymentMethods = [
        "JazzCash",
        "Easypaisa", 
        "Bank Transfer",
        "Cash on Delivery"
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Order Summary
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Order Summary")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        VStack(spacing: 12) {
                            DetailRow(title: "Gift", value: order.giftName)
                            DetailRow(title: "Receiver", value: order.receiverName)
                            DetailRow(title: "Address", value: order.receiverAddress)
                            if let actualPrice = order.actualProductPrice {
                                DetailRow(title: "Actual Product Price", value: "\(PakistanData.currencySymbol)\(String(format: "%.0f", actualPrice))")
                            }
                            DetailRow(title: "Delivery Fee", value: "\(PakistanData.currencySymbol)\(String(format: "%.0f", order.deliveryFee))")
                            if let tip = order.tip, tip > 0 {
                                DetailRow(title: "Tip", value: "\(PakistanData.currencySymbol)\(String(format: "%.0f", tip))")
                            }
                            
                            Divider()
                            
                            DetailRow(
                                title: "Total Amount",
                                value: "\(PakistanData.currencySymbol)\(String(format: "%.0f", order.totalAmount))",
                                isTotal: true
                            )
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                    
                    // Payment Method Selection
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Payment Method")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Select Payment Method")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            Button(action: {
                                showingPaymentMethods = true
                            }) {
                                HStack {
                                    Text(selectedPaymentMethod)
                                        .foregroundColor(.primary)
                                    Spacer()
                                    Image(systemName: "chevron.down")
                                        .foregroundColor(.secondary)
                                }
                                .padding()
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(8)
                            }
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                    
                    // Payment Instructions
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Payment Instructions")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("1. Send \(PakistanData.currencySymbol)\(String(format: "%.0f", order.totalAmount)) to the rider")
                                .font(.body)
                            
                            Text("2. Use the selected payment method: \(selectedPaymentMethod)")
                                .font(.body)
                            
                            Text("3. Upload payment proof (screenshot/photo)")
                                .font(.body)
                            
                            Text("4. Click 'Confirm Payment' to proceed")
                                .font(.body)
                        }
                        .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(12)
                    
                    // Payment Proof Upload
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Payment Proof")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Upload Payment Screenshot")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            if let paymentProofData = paymentProofData,
                               let uiImage = UIImage(data: paymentProofData) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxHeight: 200)
                                    .cornerRadius(8)
                            }
                            
                            PhotosPicker(selection: $selectedPaymentProof, matching: .images) {
                                HStack {
                                    Image(systemName: "camera")
                                    Text("Select Payment Screenshot")
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 44)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                            }
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                    
                    if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                    
                    // Confirm Payment Button
                    Button(action: confirmPayment) {
                        HStack {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                            }
                            Text("Confirm Payment")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .disabled(isLoading || paymentProofData == nil)
                }
                .padding()
            }
            .navigationTitle("Payment Confirmation")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .actionSheet(isPresented: $showingPaymentMethods) {
                ActionSheet(
                    title: Text("Select Payment Method"),
                    buttons: paymentMethods.map { method in
                        .default(Text(method)) {
                            selectedPaymentMethod = method
                        }
                    } + [.cancel()]
                )
            }
        }
        .onChange(of: selectedPaymentProof) { newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self) {
                    paymentProofData = data
                }
            }
        }
    }
    
    private func confirmPayment() {
        guard let paymentProofData = paymentProofData else {
            errorMessage = "Please upload payment proof"
            return
        }
        
        isLoading = true
        errorMessage = ""
        
        Task {
            do {
                // Upload payment proof
                let paymentProofURL = try await orderViewModel.uploadPaymentProof(paymentProofData, for: order.id ?? "")
                
                // Confirm payment
                await orderViewModel.confirmPayment(
                    orderId: order.id ?? "",
                    paymentMethod: selectedPaymentMethod,
                    paymentProofURL: paymentProofURL
                )
                
                await MainActor.run {
                    isLoading = false
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = "Failed to confirm payment: \(error.localizedDescription)"
                }
            }
        }
    }
}

struct DetailRow: View {
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
                .multilineTextAlignment(.trailing)
        }
    }
}

#Preview {
    PaymentConfirmationView(order: GiftOrder(
        senderId: "sender123",
        senderName: "John Doe",
        senderPhone: "03001234567",
        giftName: "Birthday Cake",
        productLink: "https://example.com/cake",
        requestVideo: true,
        personalMessage: "Happy Birthday!",
        receiverName: "Jane Smith",
        receiverAddress: "123 Main St",
        receiverCity: "Lahore",
        receiverPhone: "03009876543",
        deliveryFee: 500,
        estimatedProductPrice: 2000,
        actualProductPrice: 2250,
        tip: 200,
        totalAmount: 2950,
        paymentStatus: .pending,
        paymentMethod: nil,
        paymentProofURL: nil,
        riderId: "rider123",
        riderName: "Ahmed Khan",
        riderPhone: "03001111111",
        status: .purchased,
        createdAt: Date(),
        acceptedAt: Date(),
        deliveredAt: nil,
        giftImageURL: nil,
        receiptImageURL: "https://example.com/receipt.jpg",
        reactionVideoURL: nil,
        pickupLocation: nil,
        deliveryLocation: nil,
        rating: nil,
        review: nil
    ))
    .environmentObject(OrderViewModel())
} 
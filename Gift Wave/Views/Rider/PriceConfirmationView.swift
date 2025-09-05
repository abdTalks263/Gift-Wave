import SwiftUI
import PhotosUI

struct PriceConfirmationView: View {
    @EnvironmentObject var orderViewModel: OrderViewModel
    @Environment(\.dismiss) private var dismiss
    
    let order: GiftOrder
    @State private var actualProductPrice = ""
    @State private var selectedReceiptImage: PhotosPickerItem?
    @State private var receiptImageData: Data?
    @State private var showingImagePicker = false
    @State private var isLoading = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Order Details
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Order Details")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        VStack(spacing: 12) {
                            DetailRow(title: "Gift", value: order.giftName)
                            if let productLink = order.productLink {
                                DetailRow(title: "Product Link", value: productLink)
                            }
                            if let estimatedPrice = order.estimatedProductPrice {
                                DetailRow(title: "Estimated Price", value: "\(PakistanData.currencySymbol)\(String(format: "%.0f", estimatedPrice))")
                            }
                            DetailRow(title: "Receiver", value: order.receiverName)
                            DetailRow(title: "Address", value: order.receiverAddress)
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                    
                    // Price Confirmation
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Confirm Actual Price")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Actual Product Price (PKR)")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            HStack {
                                Text("₨")
                                    .foregroundColor(.secondary)
                                    .font(.title2)
                                
                                TextField("Enter actual price", text: $actualProductPrice)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .keyboardType(.numberPad)
                            }
                            
                            if let estimatedPrice = order.estimatedProductPrice {
                                let difference = (Double(actualProductPrice) ?? 0) - estimatedPrice
                                if difference != 0 {
                                    Text("Price difference: \(PakistanData.currencySymbol)\(String(format: "%.0f", difference))")
                                        .font(.caption)
                                        .foregroundColor(difference > 0 ? .red : .green)
                                }
                            }
                        }
                        
                        // Receipt Upload
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Upload Receipt (Optional)")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            if let receiptImageData = receiptImageData,
                               let uiImage = UIImage(data: receiptImageData) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxHeight: 200)
                                    .cornerRadius(8)
                            }
                            
                            PhotosPicker(selection: $selectedReceiptImage, matching: .images) {
                                HStack {
                                    Image(systemName: "camera")
                                    Text("Select Receipt Photo")
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
                    
                    // Cost Breakdown
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Updated Cost Breakdown")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        VStack(spacing: 12) {
                            if let actualPrice = Double(actualProductPrice), actualPrice > 0 {
                                SummaryRow(title: "Actual Product Price", value: "\(PakistanData.currencySymbol)\(String(format: "%.0f", actualPrice))")
                            }
                            SummaryRow(title: "Delivery Fee", value: "\(PakistanData.currencySymbol)\(String(format: "%.0f", order.deliveryFee))")
                            if let tip = order.tip, tip > 0 {
                                SummaryRow(title: "Tip", value: "\(PakistanData.currencySymbol)\(String(format: "%.0f", tip))")
                            }
                            
                            Divider()
                            
                            let totalAmount = (Double(actualProductPrice) ?? 0) + order.deliveryFee + (order.tip ?? 0)
                            SummaryRow(
                                title: "Total Amount",
                                value: "\(PakistanData.currencySymbol)\(String(format: "%.0f", totalAmount))",
                                isTotal: true
                            )
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
                }
                .padding()
            }
            .navigationTitle("Price Confirmation")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Confirm Price") {
                        confirmPrice()
                    }
                    .disabled(actualProductPrice.isEmpty || isLoading)
                }
            }
        }
        .onChange(of: selectedReceiptImage) { newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self) {
                    receiptImageData = data
                }
            }
        }
    }
    
    private func confirmPrice() {
        guard let actualPrice = Double(actualProductPrice), actualPrice > 0 else {
            errorMessage = "Please enter a valid price"
            return
        }
        
        isLoading = true
        errorMessage = ""
        
        Task {
            do {
                // Upload receipt image if available
                var receiptURL: String?
                if let receiptImageData = receiptImageData {
                    receiptURL = try await orderViewModel.uploadReceiptImage(receiptImageData, for: order.id ?? "")
                }
                
                // Update order with actual price and receipt
                await orderViewModel.updateOrderPrice(
                    orderId: order.id ?? "",
                    actualPrice: actualPrice,
                    receiptURL: receiptURL
                )
                
                await MainActor.run {
                    isLoading = false
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = "Failed to confirm price: \(error.localizedDescription)"
                }
            }
        }
    }
}



#Preview {
    PriceConfirmationView(order: GiftOrder(
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
        actualProductPrice: nil,
        tip: 200,
        totalAmount: 2700,
        paymentStatus: .pending,
        paymentMethod: nil,
        paymentProofURL: nil,
        riderId: nil,
        riderName: nil,
        riderPhone: nil,
        status: .accepted,
        createdAt: Date(),
        acceptedAt: Date(),
        deliveredAt: nil,
        giftImageURL: nil,
        receiptImageURL: nil,
        reactionVideoURL: nil,
        pickupLocation: nil,
        deliveryLocation: nil,
        rating: nil,
        review: nil
    ))
    .environmentObject(OrderViewModel())
} 
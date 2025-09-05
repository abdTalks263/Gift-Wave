//
//  DeliveryDetailsView.swift
//  Gift Wave
//
//  Created by Abdullah Latif on 04/08/2025.
//

import SwiftUI
import PhotosUI

struct DeliveryDetailsView: View {
    let order: GiftOrder
    @EnvironmentObject var orderViewModel: OrderViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var selectedGiftPhoto: PhotosPickerItem?
    @State private var giftImageData: Data?
    @State private var selectedReceiptPhoto: PhotosPickerItem?
    @State private var receiptImageData: Data?
    @State private var selectedVideo: PhotosPickerItem?
    @State private var videoData: Data?
    @State private var isUploading = false
    @State private var showingMap = false
    @State private var showingPriceConfirmation = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Order Info
                    VStack(alignment: .leading, spacing: 8) {
                        Text(order.giftName)
                            .font(.title2)
                            .fontWeight(.bold)
                        OrderStatusBadge(status: order.status)
                    }
                    .padding(.bottom, 8)
                    
                    // Receiver Info
                    VStack(alignment: .leading, spacing: 4) {
                        Text("To: \(order.receiverName)")
                        Text(order.receiverAddress)
                        Text(order.receiverCity)
                        Text(order.receiverPhone)
                    }
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    
                    // Upload Gift Image
                    if order.giftImageURL == nil {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Upload Gift Photo")
                                .font(.headline)
                            PhotosPicker(selection: $selectedGiftPhoto, matching: .images) {
                                HStack {
                                    Image(systemName: "photo")
                                    Text(giftImageData == nil ? "Select Photo" : "Photo Selected")
                                }
                                .padding()
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(8)
                            }
                            .onChange(of: selectedGiftPhoto) { newItem in
                                Task {
                                    if let data = try? await newItem?.loadTransferable(type: Data.self) {
                                        giftImageData = data
                                    }
                                }
                            }
                            if let data = giftImageData {
                                Button("Upload Gift Photo") {
                                    uploadGiftImage(data: data)
                                }
                                .disabled(isUploading)
                            }
                        }
                    }
                    
                    // Upload Receipt
                    if order.receiptImageURL == nil {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Upload Receipt")
                                .font(.headline)
                            PhotosPicker(selection: $selectedReceiptPhoto, matching: .images) {
                                HStack {
                                    Image(systemName: "photo")
                                    Text(receiptImageData == nil ? "Select Receipt" : "Receipt Selected")
                                }
                                .padding()
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(8)
                            }
                            .onChange(of: selectedReceiptPhoto) { newItem in
                                Task {
                                    if let data = try? await newItem?.loadTransferable(type: Data.self) {
                                        receiptImageData = data
                                    }
                                }
                            }
                            if let data = receiptImageData {
                                Button("Upload Receipt") {
                                    uploadReceiptImage(data: data)
                                }
                                .disabled(isUploading)
                            }
                        }
                    }
                    
                    // Upload Reaction Video
                    if order.requestVideo && order.reactionVideoURL == nil {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Upload Reaction Video")
                                .font(.headline)
                            PhotosPicker(selection: $selectedVideo, matching: .videos) {
                                HStack {
                                    Image(systemName: "video")
                                    Text(videoData == nil ? "Select Video" : "Video Selected")
                                }
                                .padding()
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(8)
                            }
                            .onChange(of: selectedVideo) { newItem in
                                Task {
                                    if let data = try? await newItem?.loadTransferable(type: Data.self) {
                                        videoData = data
                                    }
                                }
                            }
                            if let data = videoData {
                                Button("Upload Video") {
                                    uploadReactionVideo(data: data)
                                }
                                .disabled(isUploading)
                            }
                        }
                    }
                    
                    // Navigation and Delivery Actions
                    VStack(spacing: 12) {
                        Button("Open Map & Directions") {
                            showingMap = true
                        }
                        .buttonStyle(.bordered)
                        .disabled(isUploading)
                        
                        // Price Confirmation Button (only show if order is accepted and no actual price set)
                        if order.status == .accepted && order.actualProductPrice == nil {
                            Button("Confirm Product Price") {
                                showingPriceConfirmation = true
                            }
                            .buttonStyle(.borderedProminent)
                            .disabled(isUploading)
                        }
                        
                        if order.status == .inTransit {
                            Button("Mark as Delivered") {
                                markAsDelivered()
                            }
                            .buttonStyle(.borderedProminent)
                            .disabled(isUploading)
                        }
                    }
                    .padding(.top, 12)
                }
                .padding(20)
            }
            .navigationTitle("Delivery Details")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") { dismiss() }
                }
            }
            .sheet(isPresented: $showingMap) {
                DeliveryMapView(order: order)
            }
            .sheet(isPresented: $showingPriceConfirmation) {
                PriceConfirmationView(order: order)
                    .environmentObject(orderViewModel)
            }
        }
    }
    
    private func uploadGiftImage(data: Data) {
        isUploading = true
        Task {
            await orderViewModel.uploadGiftImage(orderId: order.id ?? "", imageData: data)
            isUploading = false
        }
    }
    private func uploadReceiptImage(data: Data) {
        isUploading = true
        Task {
            await orderViewModel.uploadReceiptImage(orderId: order.id ?? "", imageData: data)
            isUploading = false
        }
    }
    private func uploadReactionVideo(data: Data) {
        isUploading = true
        Task {
            await orderViewModel.uploadReactionVideo(orderId: order.id ?? "", videoData: data)
            isUploading = false
        }
    }
    private func markAsDelivered() {
        isUploading = true
        Task {
            await orderViewModel.updateOrderStatus(orderId: order.id ?? "", status: .delivered)
            isUploading = false
            dismiss()
        }
    }
}

#Preview {
    DeliveryDetailsView(order: GiftOrder(
        senderId: "1", 
        senderName: "Alice", 
        senderPhone: "123", 
        giftName: "Cake", 
        productLink: nil, 
        requestVideo: true, 
        personalMessage: "Happy Birthday!", 
        receiverName: "Bob", 
        receiverAddress: "123 St", 
        receiverCity: "City", 
        receiverPhone: "456", 
        deliveryFee: 5, 
        tip: 2
    ))
    .environmentObject(OrderViewModel())
} 
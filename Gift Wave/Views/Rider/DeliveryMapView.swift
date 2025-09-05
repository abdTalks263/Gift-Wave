//
//  DeliveryMapView.swift
//  Gift Wave
//
//  Created by Abdullah Latif on 04/08/2025.
//

import SwiftUI
import MapKit

struct DeliveryMapView: View {
    let order: GiftOrder
    @Environment(\.dismiss) private var dismiss
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    @State private var selectedLocation: DeliveryLocation = .pickup
    @State private var showingDirections = false
    
    enum DeliveryLocation: String, CaseIterable {
        case pickup = "Pickup Location"
        case delivery = "Delivery Location"
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Location Selector
                Picker("Location", selection: $selectedLocation) {
                    ForEach(DeliveryLocation.allCases, id: \.self) { location in
                        Text(location.rawValue).tag(location)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                // Map
                Map(coordinateRegion: $region, annotationItems: [order]) { order in
                    MapAnnotation(coordinate: getCoordinate(for: selectedLocation)) {
                        VStack {
                            Image(systemName: selectedLocation == .pickup ? "mappin.circle.fill" : "house.circle.fill")
                                .font(.title)
                                .foregroundColor(selectedLocation == .pickup ? .blue : .green)
                            
                            Text(selectedLocation == .pickup ? "Shop" : "Delivery")
                                .font(.caption)
                                .background(Color.white.opacity(0.8))
                                .cornerRadius(4)
                        }
                    }
                }
                
                // Action Buttons
                VStack(spacing: 16) {
                    Button(action: {
                        showingDirections = true
                    }) {
                        HStack {
                            Image(systemName: "location.fill")
                            Text("Get Directions")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    
                    Button(action: {
                        openInMaps()
                    }) {
                        HStack {
                            Image(systemName: "arrow.up.right.square")
                            Text("Open in Maps")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                }
                .padding()
            }
            .navigationTitle("Delivery Map")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingDirections) {
                DirectionsView(order: order, location: selectedLocation)
            }
        }
    }
    
    private func getCoordinate(for location: DeliveryLocation) -> CLLocationCoordinate2D {
        // In a real app, you'd get actual coordinates from the order
        // For now, using sample coordinates
        switch location {
        case .pickup:
            return CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
        case .delivery:
            return CLLocationCoordinate2D(latitude: 37.7849, longitude: -122.4094)
        }
    }
    
    private func openInMaps() {
        let coordinate = getCoordinate(for: selectedLocation)
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate))
        mapItem.name = selectedLocation == .pickup ? "Gift Shop" : "Delivery Address"
        mapItem.openInMaps(launchOptions: nil)
    }
}

struct DirectionsView: View {
    let order: GiftOrder
    let location: DeliveryMapView.DeliveryLocation
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Directions to \(location.rawValue)")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(location == .pickup ? "Navigate to the shop to purchase the gift" : "Navigate to deliver the gift")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding()
                
                // Sample directions - in real app, you'd integrate with MapKit directions
                VStack(alignment: .leading, spacing: 8) {
                    DirectionStep(step: "1", instruction: "Head north on Main Street", distance: "0.2 km")
                    DirectionStep(step: "2", instruction: "Turn right onto Oak Avenue", distance: "0.5 km")
                    DirectionStep(step: "3", instruction: "Destination will be on your left", distance: "0.1 km")
                }
                .padding()
                
                Spacer()
                
                Button("Start Navigation") {
                    // In real app, start turn-by-turn navigation
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .padding()
            }
            .navigationTitle("Directions")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct DirectionStep: View {
    let step: String
    let instruction: String
    let distance: String
    
    var body: some View {
        HStack(spacing: 12) {
            Text(step)
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(width: 24, height: 24)
                .background(Color.blue)
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 2) {
                Text(instruction)
                    .font(.subheadline)
                
                Text(distance)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
}

#Preview {
    DeliveryMapView(order: GiftOrder(
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
} 
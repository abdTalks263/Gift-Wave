import SwiftUI

struct DistanceFilterView: View {
    @Binding var useLocationFilter: Bool
    @Binding var maxDistanceKm: Double
    @ObservedObject var locationManager: LocationManager
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Location Permission Status
                VStack(spacing: 16) {
                    Image(systemName: locationManager.isLocationEnabled ? "location.fill" : "location.slash")
                        .font(.system(size: 50))
                        .foregroundColor(locationManager.isLocationEnabled ? .green : .red)
                    
                    Text(locationManager.isLocationEnabled ? "Location Enabled" : "Location Disabled")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(locationManager.isLocationEnabled ? 
                         "You can filter jobs by distance from your current location" :
                         "Enable location access to filter jobs by distance")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }
                
                // Distance Filter Toggle
                VStack(alignment: .leading, spacing: 16) {
                    Text("Distance-Based Filtering")
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    Toggle("Show jobs within distance", isOn: $useLocationFilter)
                        .disabled(!locationManager.isLocationEnabled)
                    
                    if useLocationFilter && locationManager.isLocationEnabled {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Maximum Distance: \(String(format: "%.1f", maxDistanceKm)) km")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            
                            Slider(value: $maxDistanceKm, in: 1...20, step: 0.5)
                                .accentColor(.blue)
                            
                            HStack {
                                Text("1 km")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                Spacer()
                                
                                Text("20 km")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(12)
                    }
                }
                
                // Current Location Info
                if let location = locationManager.currentLocation {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Current Location")
                            .font(.headline)
                            .fontWeight(.bold)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Latitude: \(String(format: "%.4f", location.latitude))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Text("Longitude: \(String(format: "%.4f", location.longitude))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(12)
                    }
                }
                
                // Action Buttons
                VStack(spacing: 12) {
                    if !locationManager.isLocationEnabled {
                        Button("Enable Location Access") {
                            locationManager.requestLocationPermission()
                        }
                        .buttonStyle(.borderedProminent)
                        .frame(maxWidth: .infinity)
                    }
                    
                    Button("Apply Filter") {
                        dismiss()
                    }
                    .buttonStyle(.borderedProminent)
                    .frame(maxWidth: .infinity)
                    .disabled(useLocationFilter && !locationManager.isLocationEnabled)
                }
                
                Spacer()
            }
            .padding(20)
            .navigationTitle("Distance Filter")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    DistanceFilterView(
        useLocationFilter: .constant(true),
        maxDistanceKm: .constant(10.0),
        locationManager: LocationManager()
    )
} 
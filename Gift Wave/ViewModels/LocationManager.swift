import Foundation
import CoreLocation
import FirebaseFirestore

@MainActor
class LocationManager: NSObject, ObservableObject {
    @Published var currentLocation: CLLocationCoordinate2D?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var isLocationEnabled = false
    @Published var errorMessage: String?
    
    private let locationManager = CLLocationManager()
    private let db = Firestore.firestore()
    
    override init() {
        super.init()
        setupLocationManager()
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 100 // Update every 100 meters
    }
    
    func requestLocationPermission() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func startLocationUpdates() {
        guard CLLocationManager.locationServicesEnabled() else {
            errorMessage = "Location services are disabled"
            return
        }
        
        switch authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
            isLocationEnabled = true
        case .denied, .restricted:
            errorMessage = "Location access denied. Please enable in Settings."
        case .notDetermined:
            requestLocationPermission()
        @unknown default:
            errorMessage = "Unknown location authorization status"
        }
    }
    
    func stopLocationUpdates() {
        locationManager.stopUpdatingLocation()
        isLocationEnabled = false
    }
    
    func updateRiderLocation(userId: String) {
        guard let location = currentLocation else { return }
        
        Task {
            do {
                let geoPoint = LocationUtils.createGeoPoint(from: location)
                try await db.collection("users").document(userId).updateData([
                    "currentLocation": geoPoint,
                    "lastLocationUpdate": Date()
                ])
            } catch {
                print("Failed to update rider location: \(error)")
            }
        }
    }
    
    func getNearbyOrders(
        riderLocation: CLLocationCoordinate2D,
        maxDistanceKm: Double = 10.0
    ) async -> [GiftOrder] {
        do {
            let snapshot = try await db.collection("orders")
                .whereField("status", isEqualTo: OrderStatus.pending.rawValue)
                .getDocuments()
            
            let allOrders = try snapshot.documents.compactMap { document in
                try document.data(as: GiftOrder.self)
            }
            
            // Filter orders by distance
            return LocationUtils.filterOrdersByDistance(
                orders: allOrders,
                riderLocation: riderLocation,
                maxDistanceKm: maxDistanceKm
            )
        } catch {
            print("Failed to fetch nearby orders: \(error)")
            return []
        }
    }
}

// MARK: - CLLocationManagerDelegate

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        currentLocation = location.coordinate
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        errorMessage = "Location update failed: \(error.localizedDescription)"
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        authorizationStatus = status
        
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            isLocationEnabled = true
            startLocationUpdates()
        case .denied, .restricted:
            isLocationEnabled = false
            errorMessage = "Location access denied"
        case .notDetermined:
            isLocationEnabled = false
        @unknown default:
            isLocationEnabled = false
        }
    }
} 
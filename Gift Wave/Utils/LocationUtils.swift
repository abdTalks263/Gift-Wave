import Foundation
import CoreLocation
import FirebaseFirestore

struct LocationUtils {
    
    // MARK: - Haversine Formula for Distance Calculation
    
    /// Calculate distance between two coordinates using Haversine formula
    /// Returns distance in kilometers
    static func calculateDistance(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) -> Double {
        let fromLocation = CLLocation(latitude: from.latitude, longitude: from.longitude)
        let toLocation = CLLocation(latitude: to.latitude, longitude: to.longitude)
        
        let distanceInMeters = fromLocation.distance(from: toLocation)
        return distanceInMeters / 1000 // Convert to kilometers
    }
    
    /// Check if a location is within specified radius (in km)
    static func isWithinRadius(
        userLocation: CLLocationCoordinate2D,
        targetLocation: CLLocationCoordinate2D,
        radiusKm: Double
    ) -> Bool {
        let distance = calculateDistance(from: userLocation, to: targetLocation)
        return distance <= radiusKm
    }
    
    // MARK: - Firebase Geo Queries
    
    /// Create a GeoPoint from CLLocationCoordinate2D
    static func createGeoPoint(from coordinate: CLLocationCoordinate2D) -> GeoPoint {
        return GeoPoint(latitude: coordinate.latitude, longitude: coordinate.longitude)
    }
    
    /// Convert GeoPoint to CLLocationCoordinate2D
    static func createCoordinate(from geoPoint: GeoPoint) -> CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: geoPoint.latitude, longitude: geoPoint.longitude)
    }
    
    // MARK: - City Coordinates (Pakistan)
    
    static let pakistanCities: [String: CLLocationCoordinate2D] = [
        "Lahore": CLLocationCoordinate2D(latitude: 31.5204, longitude: 74.3587),
        "Karachi": CLLocationCoordinate2D(latitude: 24.8607, longitude: 67.0011),
        "Islamabad": CLLocationCoordinate2D(latitude: 33.6844, longitude: 73.0479),
        "Rawalpindi": CLLocationCoordinate2D(latitude: 33.5651, longitude: 73.0169),
        "Faisalabad": CLLocationCoordinate2D(latitude: 31.4167, longitude: 73.0833),
        "Multan": CLLocationCoordinate2D(latitude: 30.1575, longitude: 71.5249),
        "Peshawar": CLLocationCoordinate2D(latitude: 34.0150, longitude: 71.5805),
        "Quetta": CLLocationCoordinate2D(latitude: 30.1798, longitude: 66.9750),
        "Sialkot": CLLocationCoordinate2D(latitude: 32.4927, longitude: 74.5313),
        "Gujranwala": CLLocationCoordinate2D(latitude: 32.1617, longitude: 74.1883),
        "Sargodha": CLLocationCoordinate2D(latitude: 32.0836, longitude: 72.6711),
        "Bahawalpur": CLLocationCoordinate2D(latitude: 29.3956, longitude: 71.6722),
        "Sukkur": CLLocationCoordinate2D(latitude: 27.7032, longitude: 68.8589),
        "Jhang": CLLocationCoordinate2D(latitude: 31.2682, longitude: 72.3181),
        "Sheikhupura": CLLocationCoordinate2D(latitude: 31.7131, longitude: 73.9783),
        "Mardan": CLLocationCoordinate2D(latitude: 34.1983, longitude: 72.0458),
        "Gujrat": CLLocationCoordinate2D(latitude: 32.5742, longitude: 74.0754),
        "Kasur": CLLocationCoordinate2D(latitude: 31.1156, longitude: 74.4467),
        "Dera Ghazi Khan": CLLocationCoordinate2D(latitude: 30.0561, longitude: 70.6344),
        "Sahiwal": CLLocationCoordinate2D(latitude: 30.6641, longitude: 73.1016)
    ]
    
    /// Get coordinates for a city
    static func getCoordinates(for city: String) -> CLLocationCoordinate2D? {
        return pakistanCities[city]
    }
    
    // MARK: - Distance-Based Job Filtering
    
    /// Filter orders by distance from rider's location
    static func filterOrdersByDistance(
        orders: [GiftOrder],
        riderLocation: CLLocationCoordinate2D,
        maxDistanceKm: Double = 10.0
    ) -> [GiftOrder] {
        return orders.filter { order in
            guard let cityCoordinates = getCoordinates(for: order.receiverCity) else {
                return false
            }
            
            let distance = calculateDistance(from: riderLocation, to: cityCoordinates)
            return distance <= maxDistanceKm
        }
    }
    
    // MARK: - Format Distance for Display
    
    static func formatDistance(_ distanceKm: Double) -> String {
        if distanceKm < 1 {
            let meters = distanceKm * 1000
            return "\(Int(meters))m"
        } else if distanceKm < 10 {
            return String(format: "%.1fkm", distanceKm)
        } else {
            return String(format: "%.0fkm", distanceKm)
        }
    }
    
    // MARK: - Delivery Fee Calculation Based on Distance
    
    static func calculateDeliveryFee(
        from: CLLocationCoordinate2D,
        to: CLLocationCoordinate2D,
        baseFee: Double = 300.0
    ) -> Double {
        let distance = calculateDistance(from: from, to: to)
        
        // Base fee for first 5km, then additional fee per km
        if distance <= 5 {
            return baseFee
        } else {
            let additionalKm = distance - 5
            let additionalFee = additionalKm * 50 // Rs. 50 per additional km
            return baseFee + additionalFee
        }
    }
} 
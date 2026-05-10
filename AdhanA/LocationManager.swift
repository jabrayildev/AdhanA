import Foundation
import CoreLocation
import Combine

final class LocationManager: NSObject, ObservableObject {
    
    private let manager = CLLocationManager()
    private let geocoder = CLGeocoder()
    
    @Published var city: String = "Loading..."
    @Published var latitude: Double?
    @Published var longitude: Double?
    
    @Published var isLoading: Bool = false
    @Published var permissionDenied: Bool = false
    
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }
    
    func requestLocation() {
        let status = manager.authorizationStatus
        
        switch status {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
            
        case .authorizedWhenInUse, .authorizedAlways:
            isLoading = true
            manager.requestLocation() // 👈 не постоянный GPS
            
        case .denied, .restricted:
            permissionDenied = true
            city = "Location Disabled"
            
        @unknown default:
            break
        }
    }
}

extension LocationManager: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let location = locations.last else { return }
        
        latitude = location.coordinate.latitude
        longitude = location.coordinate.longitude
        
        resolveCity(from: location)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        city = "Location Error"
        isLoading = false
    }
}

private extension LocationManager {
    
    func resolveCity(from location: CLLocation) {
        
        geocoder.reverseGeocodeLocation(location, preferredLocale: Locale(identifier: "az_AZ")) { [weak self] places, error in
            
            guard let self else { return }
            
            self.isLoading = false
            
            guard let place = places?.first, error == nil else {
                self.city = "Current Location"
                return
            }
            
            self.city =
                place.locality ??
                place.subAdministrativeArea ??
                place.administrativeArea ??
                place.country ??
                "Current Location"
        }
    }
}

//
//  LocationHelper.swift
//  SomeApp
//
//  Created by Perry Shalom on 13/05/2019.
//  Copyright © 2019 PerrchicK. All rights reserved.
//

import Foundation
import CoreLocation

func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
    return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
}

typealias RawJsonFormat = [String: Any]

extension CLLocationCoordinate2D {
    init?(json: RawJsonFormat) {
        guard
            let latitude = json["latitude"] as? Double,
            let longitude = json["longitude"] as? Double
            else { return nil }
        
        self.init(latitude: latitude, longitude: longitude)
    }
    
    func toDictionary() -> [String:Double] {
        return ["latitude": latitude, "longitude": longitude]
    }
    
    func toString() -> String {
        return "latitude: \(latitude), longitude: \(longitude)"
    }
}

protocol LocationHelperDelegate: class {
    func onLocationUpdated(updatedLocation: CLLocation?)
}

class LocationHelper: NSObject, CLLocationManagerDelegate {
    static let shared: LocationHelper = LocationHelper()
    
    private var callbacks: [CallbackClosure<CLLocation?>]
    var lastKnownLocation: CLLocation? {
        return locationManager.location
    }
    
    weak var delegate: LocationHelperDelegate?
    private(set) var currentLocation: CLLocation?
    private lazy var locationManager: CLLocationManager = {
        let locationManager: CLLocationManager = CLLocationManager();
        locationManager.delegate = self
        
        PerrFuncs.runOnBackground(afterDelay: 1, block: {
            self.startMonitoring()
        })
        
        return locationManager
    }()
    
    override init() {
        callbacks = []
        
        super.init()
        
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidEnterBackground), name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationWillEnterForeground), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
        
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }
    
    func requestLocation(callback: @escaping CallbackClosure<CLLocation?>) {
        callbacks.append(callback)
        locationManager.requestLocation()
    }
    
    var distanceFilter: CLLocationDistance {
        get {
            return locationManager.distanceFilter
        }
        set {
            locationManager.distanceFilter = newValue
        }
    }
    
    func startUpdate() {
        guard isForegroundPermissionGranted else { return }

        locationManager.startUpdatingLocation()
        locationManager.allowsBackgroundLocationUpdates = true
    }
    
    func stopUpdate() {
        locationManager.stopUpdatingLocation()
        //locationManager.allowsBackgroundLocationUpdates = false
    }
    
    var isBackgroundPermissionGranted: Bool {
        return CLLocationManager.authorizationStatus() == .authorizedAlways
    }
    
    var isForegroundPermissionGranted: Bool {
        return CLLocationManager.authorizationStatus() == .authorizedWhenInUse || isBackgroundPermissionGranted
    }
    
    @objc func applicationWillEnterForeground(notification: Notification) {
        startUpdate()
    }
    
    @objc func applicationDidEnterBackground(notification: Notification) {
        stopUpdate()
    }

    var isCarSpeed: Bool {
        return (currentLocation?.speed).or(0) > 5
    }
    
    var isAlmostIdle: Bool {
        return (currentLocation?.speed).or(0) < 1
    }

    func requestPermissionsIfNeeded(type: CLAuthorizationStatus) {
        let counterKey: String = "\(type.rawValue)"
        let permissionRequestCounter: Int = UserDefaults.load(key: counterKey, defaultValue: 0)
        if permissionRequestCounter > 0 {
            if let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) {
                if UIApplication.shared.canOpenURL(settingsUrl) {
                    if #available(iOS 10.0, *) {
                        UIApplication.shared.open(settingsUrl, completionHandler: nil)
                    } else {
                        // Fallback on earlier versions
                        UIApplication.shared.openURL(settingsUrl)
                    }
                }
            }
        } else {
            // First time for this life time
            if type == .authorizedAlways {
                locationManager.requestAlwaysAuthorization()
            } else {
                locationManager.requestWhenInUseAuthorization()
            }
        }
        
        UserDefaults.save(value: permissionRequestCounter + 1, forKey: counterKey).synchronize()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        startMonitoring()
    }
    
    // https://developer.apple.com/documentation/corelocation/monitoring_the_user_s_proximity_to_geographic_regions
    // https://developer.apple.com/library/archive/documentation/iPhone/Conceptual/iPhoneOSProgrammingGuide/BackgroundExecution/BackgroundExecution.html#//apple_ref/doc/uid/TP40007072-CH4-SW7
    func startMonitoring() {
        guard isBackgroundPermissionGranted, let lastKnownLocation = lastKnownLocation else { return }
        
        locationManager.startMonitoring(for: CLCircularRegion(center: lastKnownLocation.coordinate, radius: CLLocationDistance(500), identifier: "Your current location"))
    }
    
    // MARK: - CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        📘(error)
        callbacks.forEach( { $0(nil) } )
        callbacks.removeAll()
        delegate?.onLocationUpdated(updatedLocation: nil)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            currentLocation = location
            callbacks.forEach( { $0(location) } )
            callbacks.removeAll()
            delegate?.onLocationUpdated(updatedLocation: location)
            
            startMonitoring()
        }
    }
}

//
//  CommunicationMapLocationViewController.swift
//  SomeApp
//
//  Created by Perry on 3/23/16.
//  Copyright © 2016 PerrchicK. All rights reserved.
//

import Foundation
import MapKit
import Alamofire

class CommunicationMapLocationViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    let GoogleMapsUrlApiKey = "AIzaSyBprjBz5erFJ6Ai9OnEmZdY3uYIoWNtGGI"
    let afkeaLatitude: Double = 32.115216
    let afkeaLongitude: Double = 34.8174598
    let MyAnnotationViewIdentifier: String = "MyAnnotationViewIdentifier"

    @IBOutlet weak var tappedCoordinateButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var followCurrentLocationSwitch: UISwitch!

    lazy var locationManager = CLLocationManager()
    var tappedCoordinate: CLLocationCoordinate2D?
    let regionRadius: CLLocationDistance = 100

    var shouldMapFollowCurrentLocation: Bool {
        return followCurrentLocationSwitch.isOn
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        CLGeocoder().geocodeAddressString("Bnei Efraim, Tel Aviv") { (placemarks, error) in
            if let placemarks = placemarks {
                📘(placemarks)
            }
        }

        // A workaround to get a custom user interaction on the map
        mapView.onLongPress({ [weak self] (longPressGestureRecognizer) in
            guard longPressGestureRecognizer.state == .began, let mapView = self?.mapView else { return }

            let longPressedLocationCoordinate = mapView.convert(longPressGestureRecognizer.location(in: mapView), toCoordinateFrom: mapView)
            📘("tapped on location's coordinate:\n\(longPressedLocationCoordinate)")
            self?.mapView(mapView, didFeelLongPressOnCoordinate: longPressedLocationCoordinate)
        })
        
        tappedCoordinateButton.onClick { [weak self] (tapGestureRecognizer) in
            if let coordinatesString = self?.tappedCoordinateButton.titleLabel?.text {
                UIPasteboard.general.string = NSString(string: coordinatesString) as String
                ToastMessage.show(messageText: "copied to clipbaord")
            }
        }
        
        view.onSwipe(direction: .right) { [weak self] (swipeGestureRecognizer) in
            self?.navigationController?.popViewController(animated: true)
        }

        view.onSwipe(direction: .down) { [weak self] (swipeGestureRecognizer) in
            self?.dismiss(animated: true, completion: { 
                ToastMessage.show(messageText: "game dismissed")
            })
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        takeMapToLocation(CLLocation(latitude: afkeaLatitude, longitude: afkeaLongitude))

        locationManager.requestWhenInUseAuthorization()

        locationManager.startUpdatingLocation()
        locationManager.delegate = self
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        locationManager.delegate = nil
    }

    @IBAction func nativeRequestButtonPressed(_ sender: UIButton) {
        requestAddressWithNSURLSession(latitude: tappedCoordinate?.latitude ?? afkeaLatitude, longitude: tappedCoordinate?.longitude ?? afkeaLongitude)
    }

    @IBAction func afnetworkingRequestButtonPressed(_ sender: UIButton) {
        requestAddressWithAlamofire(latitude: tappedCoordinate?.latitude ?? afkeaLatitude, longitude: tappedCoordinate?.longitude ?? afkeaLongitude)
    }
    
    /**
     Makes a request for Reverse Geocoding:
     https://developers.google.com/maps/documentation/geocoding/start#reverse
     
     ... And prints the result out to a toast message.
     
     - parameter latitude: Double for latitude value
     - parameter longitude: Double for longitude value
     */
    func requestAddressWithNSURLSession(latitude lat: Double, longitude lng: Double) {
        let urlString = String(format: "https://maps.googleapis.com/maps/api/geocode/json?latlng=%f,%f&key=%@", lat, lng ,GoogleMapsUrlApiKey)
        guard let url = URL(string: urlString) else { return }
        let request = URLRequest(url: url)

        let dataTask = URLSession.shared.dataTask(with: request, completionHandler: { [weak self] (data, response, connectionError) -> Void in
            guard let data = data else { return }
            if connectionError == nil {
                do {
                    let innerJson = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers)
                    let toastText = self?.parseResponse(innerJson) ?? "Parsing failed"
                    runOnUiThread(block: { () -> Void in
                        
                        ToastMessage.show(messageText: toastText)
                    })
                } catch {
                    📘("Error: (\(error))")
                }
            }
        })

        // Go fetch...
        dataTask.resume()
    }
    
    func requestAddressWithAlamofire(latitude lat: Double, longitude lng: Double) {
        // Make request
        let urlString = String(format: "https://maps.googleapis.com/maps/api/geocode/json?latlng=%f,%f&key=%@", lat, lng ,GoogleMapsUrlApiKey)
        
        // Make HTTP request and fetch...
        📘("Calling: \(urlString)")
        Alamofire.request(urlString).responseJSON { [weak self] (response) in
            if let JSON = response.result.value, response.result.error == nil {
                // Request succeeded! ... parse response
                ToastMessage.show(messageText: self?.parseResponse(JSON) ?? "Parsing failed")
            } else {
                // Request failed! ... handle failure
                ToastMessage.show(messageText: "Error retrieving address")
            }
        }
    }
    
    func takeMapToLocation(_ location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    func parseResponse(_ responseObject: Any) -> String? {
        var result: String?

        guard let responseDictionary = responseObject as? [AnyHashable:Any],
            let status = responseDictionary["status"] as? String, status == "OK" else { return result }

        📘("Parsing JSON dictionary:\n\(responseDictionary)")
        if let results = responseDictionary["results"] as? [AnyObject],
            let firstPlace = results[0] as? [String:AnyObject],
            let firstPlaceName = firstPlace["formatted_address"] as? String {
            result = "Found address: \(firstPlaceName)"
        }

        return result
    }
    
    //MARK: - CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            manager.startUpdatingLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard shouldMapFollowCurrentLocation, locationManager == manager, let location = locations.first else { return }

        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    // MARK: - MKMapViewDelegate
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        var annotationView: MKAnnotationView!

        if let dequeuedAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: MyAnnotationViewIdentifier) {
            dequeuedAnnotationView.annotation = annotation
            annotationView = dequeuedAnnotationView
        } else {
            // Dequeued failed -> instantiate
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: MyAnnotationViewIdentifier)
            annotationView.addSubview(SomeAnnotationView())
        }

        annotationView.canShowCallout = true

        return annotationView
    }

    func mapView(_ mapView: MKMapView, didFeelLongPressOnCoordinate coordinate: CLLocationCoordinate2D) {
        let annotation = MKPointAnnotation()
        self.tappedCoordinate = coordinate
        tappedCoordinateButton.setTitle("\(coordinate.latitude),\(coordinate.longitude)", for: .normal)
        
        annotation.title = "@: \(annotation.pointerAddress)"
        annotation.subtitle = "b-date: \(Date.init().timeIntervalSince1970)"
        annotation.coordinate = coordinate
        
        mapView.addAnnotation(annotation)
    }
}

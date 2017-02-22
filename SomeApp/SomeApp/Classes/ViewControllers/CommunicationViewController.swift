//
//  CommunicationViewController.swift
//  SomeApp
//
//  Created by Perry on 3/23/16.
//  Copyright © 2016 PerrchicK. All rights reserved.
//

import Foundation
import MapKit

class CommunicationViewController: UIViewController, MKMapViewDelegate {
    let GoogleMapsUrlApiKey = "AIzaSyBprjBz5erFJ6Ai9OnEmZdY3uYIoWNtGGI"
    let afkeaLatitude: Double = 32.115216
    let afkeaLongitude: Double = 34.8174598

    @IBOutlet weak var tappedCoordinateLabel: UILabel!
    var tappedCoordinate: CLLocationCoordinate2D?
    let MyAnnotationViewIdentifier = "MyAnnotationViewIdentifier"

    @IBOutlet weak var mapView: MKMapView!
    let regionRadius: CLLocationDistance = 100

    func takeMapToLocation(_ location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // A workaround to get taps on map
        mapView.onClick { [weak self] (tapGestureRecognizer) in
            guard let mapView = self?.mapView else { return }

            let tappedLocationCoordinate = mapView.convert(tapGestureRecognizer.location(in: mapView), toCoordinateFrom: mapView)
            📘("tapped on location's coordinate:\n\(tappedLocationCoordinate)")
            self?.mapView(mapView, didFeelTapOnCoordinate: tappedLocationCoordinate)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        takeMapToLocation(CLLocation(latitude: afkeaLatitude, longitude: afkeaLongitude))
    }

    @IBAction func nativeRequestButtonPressed(_ sender: UIButton) {
        requestAddressWithNSURLSession(latitude: tappedCoordinate?.latitude ?? afkeaLatitude, longitude: tappedCoordinate?.longitude ?? afkeaLongitude)
    }

    @IBAction func afnetworkingRequestButtonPressed(_ sender: UIButton) {
//        requestAddressWithAlamofire(latitude: tappedCoordinate?.latitude ?? afkeaLatitude, longitude: tappedCoordinate?.longitude ?? afkeaLongitude)
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
        let url = URL(string: urlString)
        let request = URLRequest(url: url!)

        let task = URLSession.shared.dataTask(with: request, completionHandler: { [weak self] (data, response, connectionError) -> Void in
            guard let data = data else { return }
            if connectionError == nil {
                do {
                    let innerJson = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers)

                    runOnUiThread(block: { () -> Void in
                        ToastMessage.show(messageText: self?.parseResponse(innerJson as AnyObject) ?? "Parsing failed")
                    })
                } catch {
                    📘("Error: (\(error))")
                }
            }
        })

        // Go fetch...
        task.resume()
    }
    
    func requestAddressWithAlamofire(latitude lat: Double, longitude lng: Double) {
        // Make request
        let urlString = String(format: "https://maps.googleapis.com/maps/api/geocode/json?latlng=%f,%f&key=%@", lat, lng ,GoogleMapsUrlApiKey)
        
        // Make HTTP request and fetch...
        📘("Calling: \(urlString)")
//        Alamofire.request(.GET, urlString).responseJSON { [weak self] (response) in
//            if let JSON = response.result.value, response.result.error == nil {
//                // Request succeeded! ... parse response
//                ToastMessage.show(messageText: self?.parseResponse(JSON) ?? "Parsing failed")
//            } else {
//                // Request failed! ... handle failure
//                ToastMessage.show(messageText: "Error retrieving address")
//            }
//        }
    }
    
    func parseResponse(_ responseObject: AnyObject) -> String? {
        var result :String?

        guard let responseDictionary = responseObject as? [String:AnyObject],
            let status = responseDictionary["status"] as? String, status == "OK" else { return result }

        📘("Parsing JSON dictionary:\n\(responseDictionary)")
        if let results = responseDictionary["results"] as? [AnyObject],
            let firstPlace = results[0] as? [String:AnyObject],
            let firstPlaceName = firstPlace["formatted_address"] as? String {
            result = "Found address: \(firstPlaceName)"
        }

        return result
    }
    
    // MARK: - MKMapViewDelegate
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        var annotationView: MKAnnotationView!

        if let dequeuedAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: MyAnnotationViewIdentifier) {
            dequeuedAnnotationView.annotation = annotation
            annotationView = dequeuedAnnotationView
        } else {
            // Dequeued failed
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: MyAnnotationViewIdentifier)
            annotationView.addSubview(SomeAnnotationView())
        }

        annotationView.canShowCallout = false
        return annotationView
    }

    func mapView(_ mapView: MKMapView, didFeelTapOnCoordinate tappedCoordinate: CLLocationCoordinate2D) {
        let annotation = MKPointAnnotation()
        self.tappedCoordinate = tappedCoordinate
        self.tappedCoordinateLabel.text = "\((self.tappedCoordinate?.latitude)!),\((self.tappedCoordinate?.longitude)!)"
        annotation.title = "annotation's callout title"
        annotation.coordinate = tappedCoordinate
        
        mapView.addAnnotation(annotation)
    }
}

//
//  CommunicationViewController.swift
//  SomeApp
//
//  Created by Perry on 3/23/16.
//  Copyright © 2016 PerrchicK. All rights reserved.
//

import Foundation

class CommunicationViewController: UIViewController {
    let GoogleMapsUrlApiKey = "AIzaSyBprjBz5erFJ6Ai9OnEmZdY3uYIoWNtGGI"

    @IBAction func nativeRequestButtonPressed(sender: UIButton) {
        requestAddressWithNSURLSession(latitude: 32.115216, longitude: 34.8174598)
    }

    @IBAction func afnetworkingRequestButtonPressed(sender: UIButton) {
        requestAddressWithAFNetworking(latitude: 32.115216, longitude: 34.8174598)
    }
    
    func requestAddressWithNSURLSession(latitude lat: Double, longitude lng: Double) {
        // Make request
        let urlString = String(format: "https://maps.googleapis.com/maps/api/geocode/json?latlng=%f,%f&key=%@", lat, lng ,GoogleMapsUrlApiKey)
        let url = NSURL(string: urlString)
        let request = NSURLRequest(URL: url!)

        let task = NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: { [weak self] (data, response, connectionError) -> Void in
            guard let data = data else { return }
            if connectionError == nil {
                do {
                    let innerJson = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers)

                    runOnUiThread(block: { () -> Void in
                        ToastMessage.show(messageText: self?.parseResponse(innerJson) ?? "Parsing failed")
                    })
                } catch {
                    📘("Error: (\(error))")
                }
            }
        })

        // Go fetch...
        task.resume()
    }
    
    func requestAddressWithAFNetworking(latitude lat: Double, longitude lng: Double) {
        // Make request
        let urlString = String(format: "https://maps.googleapis.com/maps/api/geocode/json?latlng=%f,%f&key=%@", lat, lng ,GoogleMapsUrlApiKey)
        let url = NSURL(string: urlString)
        let request = NSURLRequest(URL: url!)
        
        // Make operation of HTTP request
        let operation = AFHTTPRequestOperation(request: request)
        operation.responseSerializer = AFJSONResponseSerializer()
        📘("Calling: \(urlString)")
        operation.setCompletionBlockWithSuccess({ [weak self] (operation, responseObject) -> Void in
            // Request succeeded! ... parse response
            ToastMessage.show(messageText: self?.parseResponse(responseObject) ?? "Parsing failed")
        }, failure: { (operation, error) -> Void in
            // Request failed! ... handle failure
            ToastMessage.show(messageText: "Error retrieving address")
        })
        
        // Go fetch...
        operation.start()
    }
    
    func parseResponse(responseObject: AnyObject) -> String? {
        var result :String?

        guard let responseDictionary = responseObject as? [String:AnyObject],
            status = responseDictionary["status"] as? String
            where status == "OK" else { return result }

        📘("Parsing JSON dictionary:\n\(responseDictionary)")
        if let results = responseDictionary["results"] as? [AnyObject],
            let firstPlace = results[0] as? [String:AnyObject],
            let firstPlaceName = firstPlace["formatted_address"] as? String {
            result = "Found address: \(firstPlaceName)"
        }

        return result
    }
}
//
//  SettingsViewController.swift
//  wheresMyUmbrella
//
//  Created by Guilherme Sakae on 2015-03-20.
//  Copyright (c) 2015 Guilherme Sakae. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController, GMSMapViewDelegate {
    var returnLocationToParent: ((location: CLLocation) -> ())?
    
    @IBOutlet weak var wheatherLocationLabel: UILabel!
    @IBOutlet weak var mapView: GMSMapView!
    
    var currentLocation = CLLocation()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        mapView.myLocationEnabled = true
        mapView.settings.myLocationButton = true
        mapView.camera = GMSCameraPosition(target: currentLocation.coordinate, zoom: 14, bearing: 0, viewingAngle: 0)
        setCityNameAndMarker(currentLocation.coordinate)
    }
    
    func setCityNameAndMarker(location: CLLocationCoordinate2D) {
        self.currentLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
        self.returnLocationToParent?(location: self.currentLocation)
        
        let geocoder = GMSGeocoder()
        geocoder.reverseGeocodeCoordinate(location, completionHandler: { (response, error) -> Void in
            if let address = response?.firstResult() {
                var marker = GMSMarker(position: location)
                marker.map = self.mapView!
                
                self.wheatherLocationLabel.text = address.lines[0] as! NSString as String
                
                UIView.animateWithDuration(0.25, animations: { () -> Void in
                    self.view.layoutIfNeeded()
                })
            }
        })
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
    }

    @IBAction func dissmissMe(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - Delegates
    
    //Maps delegate
    func mapView(mapView: GMSMapView!, idleAtCameraPosition position: GMSCameraPosition!) {
        
    }
    
    func mapView(mapView: GMSMapView!, didTapAtCoordinate coordinate: CLLocationCoordinate2D) {
        mapView.clear()
        setCityNameAndMarker(coordinate)
    }
    
    func mapView(mapView: GMSMapView!, willMove gesture: Bool) {
        mapView.clear()
    }
}

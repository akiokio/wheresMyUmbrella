//
//  SettingsViewController.swift
//  wheresMyUmbrella
//
//  Created by Guilherme Sakae on 2015-03-20.
//  Copyright (c) 2015 Guilherme Sakae. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {
    var returnLocationToParent: ((location: CLLocation) -> ())?
    
    @IBOutlet weak var wheatherLocationLabel: UILabel!
    @IBOutlet weak var mapView: UIView!
    
    var currentLocation = CLLocation()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setCityNameAndMarker(currentLocation.coordinate)
    }
    
    func setCityNameAndMarker(location: CLLocationCoordinate2D) {
        self.currentLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
        self.returnLocationToParent?(location: self.currentLocation)
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
    }

    @IBAction func dissmissMe(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - Delegates
    
}

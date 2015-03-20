//
//  DashboardViewController.swift
//  wheresMyUmbrella
//
//  Created by Guilherme Sakae on 2015-03-16.
//  Copyright (c) 2015 Guilherme Sakae. All rights reserved.
//

import UIKit
import CoreLocation

class DashboardViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var guessLabel: UILabel!
    @IBOutlet weak var todayBigIcoImageView: UIImageView!
    @IBOutlet weak var todayPrecipChangeLabel: UILabel!
    
    @IBOutlet weak var dayPlusOneLabel: UILabel!
    @IBOutlet weak var dayPlusOnePrecipChanceLabel: UILabel!
    @IBOutlet weak var dayPlusTwoLabel: UILabel!
    @IBOutlet weak var dayPlusTwoPrecipChanceLabel: UILabel!
    @IBOutlet weak var dayPlusThreeLabel: UILabel!
    @IBOutlet weak var dayPlusThreePrecipChanceLabel: UILabel!
    @IBOutlet weak var dayPlusFourLabel: UILabel!
    @IBOutlet weak var dayPlusFourPrecipChanceLabel: UILabel!
    @IBOutlet weak var dayPlusFiveLabel: UILabel!
    @IBOutlet weak var dayPlusFivePrecipChanceLabel: UILabel!
    
    @IBOutlet weak var dayPlusOneIcon: UIImageView!
    @IBOutlet weak var dayPlusTwoIcon: UIImageView!
    @IBOutlet weak var dayPlusThreeIcon: UIImageView!
    @IBOutlet weak var dayPlusFourIcon: UIImageView!
    @IBOutlet weak var dayPlusFiveIcon: UIImageView!
    
    @IBOutlet weak var wheatherLocationLabel: UILabel!
    @IBOutlet weak var reminderTimeLabel: UILabel!

    @IBOutlet weak var settingsButton: UIButton!

    var locationManager: CLLocationManager!
    var currentLocation = CLLocation()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        
        checkForPrivacyAuthorization(locationManager)
        
        getWeatherData(self.currentLocation.coordinate)
    }
    
    func getWeatherData(coordinates: CLLocationCoordinate2D){
        WeatherData.getWeatherDataForLocation("\(coordinates.latitude)",
            longitude: "\(coordinates.longitude)", completionBlock: {(forecast) in
                
                var currentForecast = forecast["currently"] as NSDictionary
                var todayPrecip : Double = currentForecast["precipProbability"] as Double * 100
                var recomendation : String = "Not sure yet :/"
                
                if(todayPrecip <= 25){
                    recomendation = "The chances are low, don't take the umbrella and enjoy the day"
                } else if (todayPrecip > 25 && todayPrecip <= 50){
                    recomendation = "You can risk not take you umbrella, chances are lower than 50%"
                } else if (todayPrecip > 50 && todayPrecip <= 75){
                    recomendation = "Wow take a loot at the skies, maybe it's gonna rain"
                } else if (todayPrecip > 75 && todayPrecip <= 100){
                    recomendation = "Yes you should get your umbrella and good luck :)"
                }
                
                let iconName = currentForecast["icon"] as String
                let nextWeekForecast = forecast["daily"] as NSDictionary
                let nextWeekForecastData = nextWeekForecast["data"] as NSArray
                var nextWeekArray : [NSDictionary] = []
                
                // Need to start at 1 because the first occurence in the data array is today
                for index in 1...5{
                    var dayForecast : NSDictionary = nextWeekForecastData[index] as NSDictionary
                    let date = NSDate(timeIntervalSince1970: dayForecast["time"] as Double)
                    
                    let dayDict = [  "date": self.dateStringFromUnixTime(dayForecast["time"] as Int),
                        "precipPercent": String(format: "%.0f%%", (dayForecast["precipProbability"] as Double * 100)),
                        "icon": dayForecast["icon"] as String]
                    nextWeekArray.append(dayDict)
                    
                }
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.guessLabel.text = recomendation
                    self.todayPrecipChangeLabel.text = NSString(format: "%.0f%%", todayPrecip)
                    self.todayBigIcoImageView.image = self.wheatherIcoFromString(iconName)
                    
                    self.dayPlusOneLabel.text = nextWeekArray[0]["date"] as? String
                    self.dayPlusOnePrecipChanceLabel.text = nextWeekArray[0]["precipPercent"] as? String
                    self.dayPlusTwoLabel.text = nextWeekArray[1]["date"] as? String
                    self.dayPlusTwoPrecipChanceLabel.text = nextWeekArray[1]["precipPercent"] as? String
                    self.dayPlusThreeLabel.text = nextWeekArray[2]["date"] as? String
                    self.dayPlusThreePrecipChanceLabel.text = nextWeekArray[2]["precipPercent"] as? String
                    self.dayPlusFourLabel.text = nextWeekArray[3]["date"] as? String
                    self.dayPlusFourPrecipChanceLabel.text = nextWeekArray[3]["precipPercent"] as? String
                    self.dayPlusFiveLabel.text = nextWeekArray[4]["date"] as? String
                    self.dayPlusFivePrecipChanceLabel.text = nextWeekArray[4]["precipPercent"] as? String
                    
                    self.dayPlusOneIcon.image = self.wheatherIcoFromString(nextWeekArray[0]["icon"] as String)
                    self.dayPlusTwoIcon.image = self.wheatherIcoFromString(nextWeekArray[1]["icon"] as String)
                    self.dayPlusThreeIcon.image = self.wheatherIcoFromString(nextWeekArray[2]["icon"] as String)
                    self.dayPlusFourIcon.image = self.wheatherIcoFromString(nextWeekArray[3]["icon"] as String)
                    self.dayPlusFiveIcon.image = self.wheatherIcoFromString(nextWeekArray[4]["icon"] as String)
                })
        })
    }
    
    func setCityName(location: CLLocation) {
        let geocoder = GMSGeocoder()
        geocoder.reverseGeocodeCoordinate(currentLocation.coordinate, completionHandler: { (response, error) -> Void in
            if let address = response?.firstResult(){
                let lines = address.lines as [String]
                self.wheatherLocationLabel.text = join("\n", lines)
                UIView.animateWithDuration(0.25, animations: { () -> Void in
                    self.view.layoutIfNeeded()
                })
            }
        })
    }
    
    func checkForPrivacyAuthorization(manager: CLLocationManager!){
        //Now in iOS8 sometimes the location is disabled in privacy settings so whe use this snippet to warn the user
        switch CLLocationManager.authorizationStatus() {
            case .AuthorizedAlways:
                println("Already authorized")
            case .NotDetermined:
                manager.requestAlwaysAuthorization()
            case .AuthorizedWhenInUse, .Restricted, .Denied:
                let alertController = UIAlertController(
                    title: "Background Location Access Disabled",
                    message: "In order to be notified about adorable kittens near you, please open this app's settings and set location access to 'Always'.",
                    preferredStyle: .Alert)
                
                let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
                alertController.addAction(cancelAction)
                
                let openAction = UIAlertAction(title: "Open Settings", style: .Default) { (action) in
                    if let url = NSURL(string:UIApplicationOpenSettingsURLString) {
                        UIApplication.sharedApplication().openURL(url)
                    }
                }
                alertController.addAction(openAction)
                
                self.presentViewController(alertController, animated: true, completion: nil)
            }
    }
    
    // MARK: - Navigation Methods
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier ==  "showSettings" {
            let destinationViewController = segue.destinationViewController as SettingsViewController
            destinationViewController.currentLocation = self.currentLocation
            
            destinationViewController.returnLocationToParent = {[weak self] (location) in
                if let weekSelf = self {
                    weekSelf.returnLocationToParent(location)
                }
            }
        }
    }
    
    func returnLocationToParent(location: CLLocation) {
        self.currentLocation = location
        getWeatherData(self.currentLocation.coordinate)
        setCityName(self.currentLocation)
    }
    
    // Not used for now
    // MARK: - Delegate Methods
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        self.currentLocation = locationManager.location
        setCityName(locations.last as CLLocation)
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        println("Error while updating location " + error.localizedDescription)

    }
    
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .AuthorizedAlways || status == .AuthorizedWhenInUse {
            manager.startUpdatingLocation()
        }
    }
    
    
    // MARK: - Shake gestures
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    override func motionEnded(motion: UIEventSubtype, withEvent event: UIEvent) {
        if event.subtype == .MotionShake {
            getWeatherData(self.currentLocation.coordinate)
            setCityName(self.currentLocation)
        }
    }

    // MARK: - Navigation Style
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    // MARK: - Refactor this
    func wheatherIcoFromString(stringIcon : String) -> UIImage {
        var imageName : String
        switch stringIcon {
        case "clear-day":
            imageName = "clear-day"
        case "clear-night":
            imageName = "clear-night"
        case "rain":
            imageName = "rain"
        case "snow":
            imageName = "snow"
        case "sleet":
            imageName = "sleet"
        case "wind":
            imageName = "wind"
        case "fog":
            imageName = "fog"
        case "cloudy":
            imageName = "cloudy"
        case "partly-cloudy-day":
            imageName = "partly-cloudy"
        case "partly-cloudy-night":
            imageName = "cloudy-night"
        default:
            imageName = "default"
        }
        
        return UIImage(named: imageName)!
    }
    
    func dateStringFromUnixTime(unixTime: Int) -> String {
        let timeInSeconds = NSTimeInterval(unixTime)
        let wheaterDate = NSDate(timeIntervalSince1970: timeInSeconds)
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
        return dateFormatter.stringFromDate(wheaterDate)
    }
    
}


//
//  WheatherData.swift
//  wheresMyUmbrella
//
//  Created by Guilherme Sakae on 2015-03-16.
//  Copyright (c) 2015 Guilherme Sakae. All rights reserved.
//

import Foundation
import UIKit

struct WeatherData {
    static let apiKey: String = "eb491ec2587b823374feac4baa1936a6"
    
    static func getWeatherDataForLocation(latitude: String, longitude: String, completionBlock: (forecastData: NSDictionary)->()) {
        let baseURL = NSURL(string: "https://api.forecast.io/forecast/\(apiKey)/")
        let forecastURL = NSURL(string: "\(latitude),\(longitude)", relativeToURL: baseURL)
        
        let sharedSession = NSURLSession.sharedSession()
        
        let downloadTask : NSURLSessionDownloadTask = sharedSession.downloadTaskWithURL(forecastURL!, completionHandler: { (location: NSURL!, response: NSURLResponse!, error: NSError!) -> Void in
            if error == nil {
                let dataObject  = NSData(contentsOfURL: location)
                let weatherData: NSDictionary = NSJSONSerialization.JSONObjectWithData(dataObject!, options: nil, error: nil) as NSDictionary
//                println(weatherData)
                
//                var currentWheather = Current(weatherDictionary: weatherData)
                completionBlock(forecastData: weatherData)
            } else {
                println(error)
            }
        })
        
        downloadTask.resume()
        
    }
}

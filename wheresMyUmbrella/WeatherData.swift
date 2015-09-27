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
        
        let downloadTask : NSURLSessionDownloadTask = sharedSession.downloadTaskWithURL(forecastURL!, completionHandler: { (location: NSURL?, response: NSURLResponse?, error: NSError?) -> Void in
            if error == nil {
                let dataObject  = NSData(contentsOfURL: location!)
                do {
                    let weatherData = try NSJSONSerialization.JSONObjectWithData(dataObject!, options: NSJSONReadingOptions.AllowFragments)
                    
                    //                println(weatherData)
                    
                    //                var currentWheather = Current(weatherDictionary: weatherData)
                    completionBlock(forecastData: weatherData as! NSDictionary)
                } catch let error as NSError {
                    print("A JSON parsing error occurred, here are the details:\n \(error)")
                }
            } else {
                print(error)
            }
        })
        
        downloadTask.resume()
        
    }
}

//
//  WeatherStats.swift
//  Weather
//
//  Created by Mark Gumbs on 25/06/2016.
//  Copyright © 2016 britishairways. All rights reserved.
//

import UIKit

class WeatherStats: NSObject {
    
    // NOTE:  Ties are in Unix timestamps (e.g. 1467154800 = 06/28/2016 @ 11:00pm (UTC) )
    var dateAndTime : Double? // NOTE:  We may need bigger than an Int for future robustness
    var dateAndTimeStamp : NSDate?
//    var dayOrNight : String?
    var summary : String?
    var icon : String?
    var sunriseTime : Double?
    var sunriseTimeStamp : NSDate?
    var sunsetTime : Double?
    var sunsetTimeStamp : NSDate?
    var moonPhase : Float?
    var nearestStormDistance : Int?
    var nearestStormBearing : Int?
    var precipIntensity : Float?
    var precipIntensityMax : Float?
    var precipIntensityMaxTime : String?
    var precipProbability : Float?
    var precipType  : String?
    var temperature : Float?
    var temperatureMin : Float?
    var temperatureMinTime : String?
    var temperatureMax : Float?
    var temperatureMaxTime : String?
    var apparentTemperature : Float?
    var apparentTemperatureMin : Float?
    var apparentTemperatureMinTime : String?
    var apparentTemperatureMax : Float?
    var apparentTemperatureMaxTime : String?
    var humidity : Float?
    var windSpeed : Float?
    var windBearing : Float?
    var visibility : Float?
    var cloudCover : Float?
    
    // var date = NSDate(timeIntervalSince1970: timeInterval)
    
    override init(){
        
    }
    
    init(fromDictionary weatherDict: NSDictionary){
        
        if let lDateAndTime  = weatherDict["time"] as? Double {
            dateAndTime = lDateAndTime
            dateAndTimeStamp = NSDate(timeIntervalSince1970: dateAndTime!)  // NOTE:  Remember to add offset etc
            
            let formatter = DateFormatter()
            //formatter.dateFormat = "h:mm a"
            formatter.timeZone = NSTimeZone(forSecondsFromGMT: 7 * 3600) as TimeZone!  // original string in GMT
        }

        if let lSummary  = weatherDict["summary"] as? String {
            summary = lSummary
        }
  
        if let lIcon  = weatherDict["icon"] as? String {
            icon = lIcon
            
//            if lIcon.contains("night") {
//                dayOrNight = "NIGHT"
//            }
//            else {
//                dayOrNight = "DAY"
//            }
        }
        
        if let lSunriseTime  = weatherDict["sunriseTime"] as? Double {
            sunriseTime = lSunriseTime
            sunriseTimeStamp = NSDate(timeIntervalSince1970: sunriseTime!)  // NOTE:  Remember to add offset etc
        }
        
        if let lSunsetTime = weatherDict["sunsetTime"] as? Double {
            sunsetTime = lSunsetTime
            sunsetTimeStamp = NSDate(timeIntervalSince1970: sunsetTime!)  // NOTE:  Remember to add offset etc
            
        }
        
        if let lMoonPhase  = weatherDict["moonPhase"] as? Float {
            moonPhase = lMoonPhase
        }
        
        if let lNearestStormDistance  = weatherDict["nearestStormDistance"] as? Int {
            nearestStormDistance = lNearestStormDistance
        }
        
        if let lNearestStormBearing  = weatherDict["nearestStormBearing"] as? Int {
            nearestStormBearing = lNearestStormBearing
        }
        
        if let lPrecipIntensity  = weatherDict["precipIntensity"] as? Float {
            precipIntensity = lPrecipIntensity
        }
        
        if let lPrecipIntensityMax  = weatherDict["precipIntensityMax"] as? Float {
            precipIntensityMax = lPrecipIntensityMax
        }
        
        if let lPrecipIntensityMaxTime  = weatherDict["precipIntensityMaxTime"] as? String {
            precipIntensityMaxTime = lPrecipIntensityMaxTime
        }
        
        if let lPrecipProbability  = weatherDict["precipProbability"] as? Float {
            precipProbability = lPrecipProbability
        }
        
        if let lPrecipType  = weatherDict["precipType"] as? String {
            precipType = lPrecipType
        }
        
        if let lTemperature  = weatherDict["temperature"] as? Float {
            temperature = lTemperature
        }
        
        if let lTemperatureMin  = weatherDict["temperatureMin"] as? Float {
            temperatureMin = lTemperatureMin
        }
        
        if let lTemperatureMinTime  = weatherDict["temperatureMinTime"] as? String {
            temperatureMinTime = lTemperatureMinTime
        }
        
        if let lTemperatureMax  = weatherDict["temperatureMax"] as? Float {
            temperatureMax = lTemperatureMax
        }
        
        if let lTemperatureMaxTime  = weatherDict["temperatureMaxTime"] as? String {
            temperatureMaxTime = lTemperatureMaxTime
        }
        
        if let lApparentTemperature  = weatherDict["apparentTemperature"] as? Float {
            apparentTemperature = lApparentTemperature
        }
        
        if let lApparentTemperatureMin  = weatherDict["apparentTemperatureMin"] as? Float {
            apparentTemperatureMin = lApparentTemperatureMin
        }
        
        if let lApparentTemperatureMinTime  = weatherDict["apparentTemperatureMinTime"] as? String {
            apparentTemperatureMinTime = lApparentTemperatureMinTime
        }
        
        if let lApparentTemperatureMax  = weatherDict["apparentTemperatureMax"] as? Float {
            apparentTemperatureMax = lApparentTemperatureMax
        }
        
        if let lApparentTemperatureMaxTime  = weatherDict["apparentTemperatureMaxTime"] as? String {
            apparentTemperatureMaxTime = lApparentTemperatureMaxTime
        }

        if let lHumidity  = weatherDict["humidity"] as? Float {
            humidity = lHumidity
        }
        
        if let lWindSpeed  = weatherDict["windSpeed"] as? Float {
            windSpeed = lWindSpeed
        }
        
        if let lWindBearing  = weatherDict["windBearing"] as? Float {
            windBearing = lWindBearing
        }
        
        if let lVisibility   = weatherDict["visibility"] as? Float {
            visibility = lVisibility
        }
        
        if let lCloudCover    = weatherDict["cloudCover"] as? Float {
            cloudCover = lCloudCover
        }
        

    }
}

extension NSDate {
    func isBetweeen(date date1: NSDate, andDate date2: NSDate) -> Bool {
        return date1.compare(self as Date) == self.compare(date2 as Date)
    }
}

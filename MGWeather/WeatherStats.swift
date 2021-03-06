//
//  WeatherStats.swift
//  Weather
//
//  Created by Mark Gumbs on 25/06/2016.
//

import UIKit

class WeatherStats: NSObject {
    
    // NOTE:  Times are in Unix timestamps (e.g. 1467154800 = 06/28/2016 @ 11:00pm (UTC) )
    var dateAndTime : Double?
    var dateAndTimeStamp : NSDate?
    var summary : String?
    var icon : String?
    var sunriseTime : Double?
    var sunriseTimeStamp : NSDate?
    var sunsetTime : Double?
    var sunsetTimeStamp : NSDate?
    var moonPhase : Float?
    var nearestStormDistance : Int?
    var nearestStormDistanceUnits : String?
    var nearestStormBearing : Int?
    var precipIntensity : Float?
    var percipDecodedIntensity : String?
    var precipIntensityMax : Float?
    var precipIntensityMaxTime : String?
    var precipProbability : Float?
    var precipType  : String?
    var temperature : Float?
    var temperatureUnits : String?
    
    var temperatureMin : Float?
    var temperatureMinTime : Double?
    var temperatureMinTimeStamp : NSDate?
    var temperatureMax : Float?
    var temperatureMaxTime : Double?
    var temperatureMaxTimeStamp : NSDate?
    
    var apparentTemperature : Float?
    var apparentTemperatureMin : Float?
    var apparentTemperatureMinTime : String?
    var apparentTemperatureMax : Float?
    var apparentTemperatureMaxTime : String?
    var humidity : Float?
    var windSpeed : Float?
    var windSpeedUnits : String?
    var windBearing : Float?
    var visibility : Float?
    var cloudCover : Float?
    
    // var date = NSDate(timeIntervalSince1970: timeInterval)
    
    override init(){

    }
    
    init(fromDictionary weatherDict: NSDictionary){
        
        let urlUnits = GlobalConstants.urlUnitsChosen
        
        if let lDateAndTime  = weatherDict["time"] as? Double {
            
            dateAndTime = lDateAndTime
            dateAndTimeStamp = NSDate(timeIntervalSince1970: dateAndTime!)  // GMT
            dateAndTimeStamp = Utility.getTimeInWeatherTimezone(dateAndTime: dateAndTimeStamp!)
            
        }

        if let lSummary  = weatherDict["summary"] as? String {
            summary = lSummary
            // Attempt to find out how heavy the perciptation is
            
            if lSummary.lowercased().range(of: "drizzle") != nil {
                percipDecodedIntensity = GlobalConstants.PrecipitationIntensity.Light
            }

            else if lSummary.lowercased().range(of: "light rain") != nil {
                percipDecodedIntensity = GlobalConstants.PrecipitationIntensity.Medium
            }

            else if lSummary.lowercased().range(of: "rain") != nil {
                percipDecodedIntensity = GlobalConstants.PrecipitationIntensity.Heavy
            }

            else {
                percipDecodedIntensity = GlobalConstants.PrecipitationIntensity.Medium
            }
            
        }
  
        if let lIcon  = weatherDict["icon"] as? String {
            icon = lIcon
        }
        
        if let lSunriseTime  = weatherDict["sunriseTime"] as? Double {
            sunriseTime = lSunriseTime
            sunriseTimeStamp = NSDate(timeIntervalSince1970: sunriseTime!)
            sunriseTimeStamp = Utility.getTimeInWeatherTimezone(dateAndTime: sunriseTimeStamp!)
        }
        
        if let lSunsetTime = weatherDict["sunsetTime"] as? Double {
            sunsetTime = lSunsetTime
            sunsetTimeStamp = NSDate(timeIntervalSince1970: sunsetTime!)
            sunsetTimeStamp = Utility.getTimeInWeatherTimezone(dateAndTime: sunsetTimeStamp!)
            
        }
        
        if let lMoonPhase  = weatherDict["moonPhase"] as? Float {
            moonPhase = lMoonPhase
        }
        
        if let lNearestStormDistance  = weatherDict["nearestStormDistance"] as? Int {
            nearestStormDistance = lNearestStormDistance
            
            // NOTE:  Cant call method in an init so have to do the calculation of units here
            
            var returnUnits = ""
            switch (urlUnits) {
            case "us", "uk2":
                returnUnits = "mi"
            case "si", "ca":
                returnUnits = "km"
            default:
                returnUnits = "mi"
            }
            
            nearestStormDistanceUnits = returnUnits
        }
        
        // NOTE:  nearestStormBearing may not be returned if not necessary
        if let lNearestStormBearing  = weatherDict["nearestStormBearing"] as? Int {
            nearestStormBearing = lNearestStormBearing
        }
        
        if let lPrecipIntensity  = weatherDict["precipIntensity"] as? Float {
            precipIntensity = lPrecipIntensity
            
            // Attempt to find out how heavy the perciptation is
            
//            if (lPrecipIntensity > 0.00 && lPrecipIntensity <= 0.26) {
//                percipDecodedIntensity = GlobalConstants.PrecipitationIntensity.Light
//            }
//            else if (lPrecipIntensity > 0.27 && lPrecipIntensity < 0.70) {
//                percipDecodedIntensity = GlobalConstants.PrecipitationIntensity.Medium
//            }
//            else {
//                percipDecodedIntensity = GlobalConstants.PrecipitationIntensity.Heavy
//            }
//            
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
            
            // Rain, Sleet or Snow
            precipType = lPrecipType
        }
        
        if let lTemperature  = weatherDict["temperature"] as? Float {
            temperature = lTemperature
            
            // NOTE:  Cant call method in an init so have to do the calculation of units here
            
            var returnUnits = ""
            
            switch (urlUnits) {
            case "us":
                returnUnits = "F"
            case "si", "uk2", "ca":
                returnUnits = "C"
            default:
                returnUnits = "C"
            }
            
            temperatureUnits = returnUnits
        }
        
        if let lTemperatureMin  = weatherDict["temperatureMin"] as? Float {
            temperatureMin = lTemperatureMin
            
            if (temperatureUnits == nil) {
                
                // For DailySummary, the temperature is nil, therefore the units is not set there.
                // Double check here and set if not present.
                
                // NOTE:  Cant call method in an init so have to do the calculation of units here
                
                var returnUnits = ""
                
                switch (urlUnits) {
                case "us":
                    returnUnits = "F"
                case "si", "uk2", "ca":
                    returnUnits = "C"
                default:
                    returnUnits = "C"
                }
                
                temperatureUnits = returnUnits
            }
        }
        
        if let lTemperatureMinTime  = weatherDict["temperatureMinTime"] as? Double {
            temperatureMinTime = lTemperatureMinTime
            temperatureMinTimeStamp = NSDate(timeIntervalSince1970: lTemperatureMinTime)
            temperatureMinTimeStamp = Utility.getTimeInWeatherTimezone(dateAndTime: temperatureMinTimeStamp!)
        }
        
        if let lTemperatureMax  = weatherDict["temperatureMax"] as? Float {
            temperatureMax = lTemperatureMax
        }
        
        if let lTemperatureMaxTime  = weatherDict["temperatureMaxTime"] as? Double {
            
            temperatureMaxTime = lTemperatureMaxTime
            temperatureMaxTimeStamp = NSDate(timeIntervalSince1970: lTemperatureMaxTime)
            temperatureMaxTimeStamp = Utility.getTimeInWeatherTimezone(dateAndTime: temperatureMaxTimeStamp!)
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

            // NOTE:  Cant call method in an init sohave to do the calculation of units here
            
            var returnUnits = ""
            
            switch (urlUnits) {
            case "us", "uk2":
                returnUnits = "mph"
            case "si":
                returnUnits = "ms"
            case "ca":
                returnUnits = "kph"
            default:
                returnUnits = "mph"
            }
            
            windSpeedUnits = returnUnits

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


//
//  Utility.swift
//  MGWeather
//
//  Created by Mark Gumbs on 02/09/2016.
//  Copyright © 2016 britishairways. All rights reserved.
//

import UIKit

class Utility: NSObject {

    class func getBuildVersion() -> String {
        
      return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        
    }
    
    class func getWeatherIcon(serviceIcon : String) -> String {
        
        var iconName : String!
        
        // TODO:  If its a 'special' day (Halloween, Bonfire Night) etc, and we are in the
        // UK or US where they celebrate it, we can show a themed background
        
        switch serviceIcon {
        case "clear-day":
            iconName = GlobalConstants.WeatherIcon.clearDay
        case "clear-night" :
            iconName = GlobalConstants.WeatherIcon.clearNight
        case "rain" :
            iconName = GlobalConstants.WeatherIcon.rain
        case "snow":
            iconName = GlobalConstants.WeatherIcon.snow
        case "sleet":
            iconName = GlobalConstants.WeatherIcon.sleet
        case "wind":
            iconName = GlobalConstants.WeatherIcon.wind
        case "fog":
            iconName = GlobalConstants.WeatherIcon.fog
        case "cloudy":
            iconName = GlobalConstants.WeatherIcon.cloudy
        case "partly-cloudy-day":
            iconName = GlobalConstants.WeatherIcon.partlyCloudyDay
        case "partly-cloudy-night":
            iconName = GlobalConstants.WeatherIcon.partlyCloudyNight
        default:
            iconName = ""
        }
        
        return iconName
    }
    
    class func getWeatherImage(serviceIcon : String, dayOrNight : String) -> String {
        
        var imageName : String!
        
        switch serviceIcon {
        case "clear-day":
            imageName  = GlobalConstants.ImageFile.FileName.clearDay.rawValue
        case "clear-night" :
            imageName  = GlobalConstants.ImageFile.FileName.clearNight.rawValue
        case "rain" :
            if dayOrNight == "DAY" {
                imageName  = GlobalConstants.ImageFile.FileName.rain.rawValue
            }
            else {
                imageName  = GlobalConstants.ImageFile.FileName.rainNight.rawValue
            }
        case "snow":
            imageName  = GlobalConstants.ImageFile.FileName.snow.rawValue
        case "sleet":
            imageName  = GlobalConstants.ImageFile.FileName.sleet.rawValue
        case "wind":
            imageName  = GlobalConstants.ImageFile.FileName.wind.rawValue
        case "fog":
            imageName  = GlobalConstants.ImageFile.FileName.fog.rawValue
        case "cloudy":
            imageName  = GlobalConstants.ImageFile.FileName.cloudy.rawValue
        case "partly-cloudy-day":
            imageName  = GlobalConstants.ImageFile.FileName.partlyCloudyDay.rawValue
        case "partly-cloudy-night":
            imageName = GlobalConstants.ImageFile.FileName.partlyCloudyNight.rawValue
        default:
            imageName  = ""
        }
        
        return imageName
    }
    
    class func getSpecialDayWeatherImage(dayOrNight : String) -> String {
        
        // Based on the day, return a special background image regardless of the weather conditions
        // 
        // Will only focus on Halloween, Bonfire night, Christmas Day and New Years eve for now
        
        var imageName : String!
        
        let today = Date()
        let df = DateFormatter()
        df.dateFormat = "MM-dd"  // Remove timestamp for comparison
        
        let dateString = df.string(from: today as Date)
        
        imageName  = ""
        switch dateString {
        case "10-31":
            if dayOrNight == "NIGHT" {
                imageName  = GlobalConstants.ImageFile.FileName.halloween.rawValue
            }
        case "11-05":
            if dayOrNight == "NIGHT" {
                imageName  = GlobalConstants.ImageFile.FileName.bonfireNight.rawValue
            }
        case "12-25":
            if dayOrNight == "DAY" {
                imageName  = GlobalConstants.ImageFile.FileName.xmasDay.rawValue
            }
            else {
                imageName  = GlobalConstants.ImageFile.FileName.xmasNight.rawValue
            }
        case "12-31":
            if dayOrNight == "NIGHT" {
                imageName  = GlobalConstants.ImageFile.FileName.newYearsEve.rawValue
            }
        default:
            imageName  = ""
        }
        
        return imageName

    }
    
    class func showMessage(titleString : String, messageString : String)
    {
        let alertView = UIAlertView(title: titleString, message: messageString, delegate: nil, cancelButtonTitle: "OK")
        alertView.show()
    }
    
    // Methods to obtain ast loaded background image
    
    class func getLastLoadedBackground () -> String {
        
        let userDefaults = UserDefaults.standard
        var lastBackground = userDefaults.string(forKey: GlobalConstants.Defaults.LastLoadedBackground)
        
        if lastBackground == nil {
            lastBackground = GlobalConstants.DefaultBackgroundImage
        }
        return lastBackground!
    }
    
    class func setLastLoadedBackground (backgroundName: String) {
        
        let userDefaults = UserDefaults.standard
        userDefaults.set(backgroundName, forKey: GlobalConstants.Defaults.LastLoadedBackground)
        
    }
    
    
    class func areDatesSameDay (date1: NSDate, date2: NSDate) -> Bool {
        
        var retVal = false
        
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"  // Remove timestamp for comparison
        
        let compareDateString1 = df.string(from: date1 as Date)
        let compareDateString2 = df.string(from: date2 as Date)
        
        if compareDateString1 == compareDateString2 {
            retVal = true
        }
        
        return retVal
    }
    
    class func isTomorrow (date1: NSDate) -> Bool {
        
        var retVal = false
        
        let today = Date()
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)
        
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"  // Remove timestamp for comparison
        
        let compareDateString1 = df.string(from: date1 as Date)
        let compareDateString2 = df.string(from: tomorrow!)
        
        if compareDateString1 == compareDateString2 {
            retVal = true
        }
        
        return retVal
    }
    

    class func compassDirectionFromDegrees (degrees : Float) -> String {
        
        // Reference:  
        // http://climate.umn.edu/snow_fence/components/winddirectionanddegreeswithouttable3.htm
        
        var retVal = ""
        let directions = ["N", "NNE", "NE", "ENE", "E", "ESE", "SE", "SSE",
                          "S", "SSW", "SW", "WSW", "W", "WNW", "NW", "NNW"]
        
        let compassSegments = Float(360 / directions.count)  // Will be 22.5
        
        let i = (degrees + 11.25) / compassSegments
        
        let x = i.truncatingRemainder(dividingBy: 16)
        let directionsMod = Int(floor(x))
        
        // We want to TRUNC the mod so that we get the correct direction range from the array
        retVal = directions[directionsMod]
        
        return retVal
    }
}

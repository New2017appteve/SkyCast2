//
//  Utility.swift
//  MGWeather
//
//  Created by Mark Gumbs on 02/09/2016.
//

import UIKit

class Utility: NSObject {

    class func getBuildVersion() -> String {
        
      return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        
    }
    
    class func getWeatherIcon(serviceIcon : String, scheme : String, dayOrNight : String) -> String {

        var iconName : String!
        var lDayOrNight : String!
        
        // If no parameter for DayOrNight, assume Day
        
        if (dayOrNight == "") {
            lDayOrNight = "DAY"
        }
        else {
            lDayOrNight = dayOrNight
        }
        
        if (scheme == GlobalConstants.ColourScheme.Light) {
            
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
                if lDayOrNight == "DAY" {
                    iconName = GlobalConstants.WeatherIcon.fog
                }
                else {
                    iconName = GlobalConstants.WeatherIcon.fogNight
                }
            case "cloudy":
                iconName = GlobalConstants.WeatherIcon.cloudy
            case "partly-cloudy-day":
                iconName = GlobalConstants.WeatherIcon.partlyCloudyDay
            case "partly-cloudy-night":
                iconName = GlobalConstants.WeatherIcon.partlyCloudyNight
            // Custom
            case "UMBRELLA":
                iconName = GlobalConstants.WeatherIcon.umbrella
            case "SUNRISE":
                iconName = GlobalConstants.WeatherIcon.sunrise
            case "SUNSET":
                iconName = GlobalConstants.WeatherIcon.sunset
            default:
                iconName = ""
            }
            
        }
        else {
            switch serviceIcon {
            case "clear-day":
                iconName = GlobalConstants.WeatherIcon.clearDay_White
            case "clear-night" :
                iconName = GlobalConstants.WeatherIcon.clearNight_White
            case "rain" :
                iconName = GlobalConstants.WeatherIcon.rain_White
            case "snow":
                iconName = GlobalConstants.WeatherIcon.snow_White
            case "sleet":
                iconName = GlobalConstants.WeatherIcon.sleet_White
            case "wind":
                iconName = GlobalConstants.WeatherIcon.wind_White
            case "fog":
                if lDayOrNight == "DAY" {
                    iconName = GlobalConstants.WeatherIcon.fog_White
                }
                else {
                    iconName = GlobalConstants.WeatherIcon.fogNight_White
                }
            case "cloudy":
                iconName = GlobalConstants.WeatherIcon.cloudy_White
            case "partly-cloudy-day":
                iconName = GlobalConstants.WeatherIcon.partlyCloudyDay_White
            case "partly-cloudy-night":
                iconName = GlobalConstants.WeatherIcon.partlyCloudyNight_White
            // Custom
            case "UMBRELLA":
                iconName = GlobalConstants.WeatherIcon.umbrella_White
            case "SUNRISE":
                iconName = GlobalConstants.WeatherIcon.sunrise_White
            case "SUNSET":
                iconName = GlobalConstants.WeatherIcon.sunset_White
                
            default:
                iconName = ""
            }
            
        }

        return iconName
    }
    
    class func getWeatherIcon(serviceIcon : String) -> String {
        
        var iconName : String!
        
        // Load the saved colour scheme that user selected.  If not set, use default
        let userDefaults = UserDefaults.standard
        var scheme = userDefaults.string(forKey: GlobalConstants.Defaults.SavedColourScheme)
        
        if (scheme == nil) {
            scheme = GlobalConstants.DefaultColourScheme  // Dark
        }
        
        iconName = getWeatherIcon(serviceIcon: serviceIcon, scheme: scheme!, dayOrNight: "" )
        
        return iconName
    }
    
    // Overloaded function, pass in if time is Day or Night so we can get correct icons
    // where necessary.
    class func getWeatherIcon(serviceIcon : String, dayOrNight : String) -> String {
        
        var iconName : String!
        
        // Load the saved colour scheme that user selected.  If not set, use default
        let userDefaults = UserDefaults.standard
        var scheme = userDefaults.string(forKey: GlobalConstants.Defaults.SavedColourScheme)
        
        if (scheme == nil) {
            scheme = GlobalConstants.DefaultColourScheme  // Dark
        }
        
        iconName = getWeatherIcon(serviceIcon: serviceIcon, scheme: scheme!, dayOrNight: dayOrNight )
        
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
            if dayOrNight == "DAY" {
                imageName  = GlobalConstants.ImageFile.FileName.fog.rawValue
            }
            else {
                imageName  = GlobalConstants.ImageFile.FileName.fogNight.rawValue
            }
        case "cloudy":
            imageName  = GlobalConstants.ImageFile.FileName.cloudy.rawValue
        case "partly-cloudy-day":
            // TODO:  Random choosing of some alternate pcs
            imageName  = GlobalConstants.ImageFile.FileName.partlyCloudyDay.rawValue
        case "partly-cloudy-night":
            imageName = GlobalConstants.ImageFile.FileName.partlyCloudyNight.rawValue
        default:
            imageName  = ""
        }
        
        return imageName
    }
    
//    class func getSpecialRainIcon (precipitation : Float) {
//        
//        var rainType = ""
//        
//        if (precipitation > 0 && precipitation < 0.098) {
//            rainType = "LIGHT"
//        }
//        else if (precipitation >= 0.098 && precipitation < 0.39) {
//            rainType = "MODERATE"
//        }
//        else if (precipitation >= 0.39 ) {
//            rainType = "HEAVY"
//        }
//        
//    }
    /*
    Light rain — when the precipitation rate is < 2.5 mm (0.098 in) per hour
    Moderate rain — when the precipitation rate is between 2.5 mm (0.098 in) - 7.6 mm (0.30 in) or 10 mm (0.39 in) per hour[105][106]
    Heavy rain — when the precipitation rate is > 7.6 mm (0.30 in) per hour,[105] or between 10 mm (0.39 in) and 50 mm (2.0 in) per hour[106]
    Violent rain — when the precipitation rate is > 50 mm (2.0 in) per hour[106]
    
    */
    class func getSpecialDayWeatherImage(dayOrNight : String) -> String {
        
        // Based on the day, return a special background image regardless of the weather conditions
        // 
        // Will only focus on Halloween, Bonfire night, Christmas Day and New Years eve for now
        
        var imageName : String!
        
        var today = Date()
        today = Utility.getTimeInWeatherTimezone(dateAndTime: today as NSDate) as Date

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
        
        var today = Date()
        today = Utility.getTimeInWeatherTimezone(dateAndTime: today as NSDate) as Date
        
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
    
    class func getTimeInWeatherTimezone(dateAndTime: NSDate) -> NSDate {
        
        let timezoneOffsetMinutes = GlobalConstants.timezoneOffset * 60
        let localDateTimeStamp = dateAndTime.add(minutes: timezoneOffsetMinutes)
        
        return localDateTimeStamp as NSDate
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
    
    class func setupColourScheme() -> ColourScheme {
        
        // Load the saved colour scheme that user selected.  If not set, use default
        let userDefaults = UserDefaults.standard
        var scheme = userDefaults.string(forKey: GlobalConstants.Defaults.SavedColourScheme)
        
        if (scheme == nil) {
            scheme = GlobalConstants.DefaultColourScheme  // Dark
        }

        var textColourScheme : UIColor!
        var podColourScheme : UIColor!
        var titleViewColourScheme : UIColor!
        
        if (scheme == GlobalConstants.ColourScheme.Dark) {
            podColourScheme = GlobalConstants.podDark
            textColourScheme = GlobalConstants.writingLight
            titleViewColourScheme = UIColor.black
        }
        else {
            podColourScheme = UIColor.white //GlobalConstants.podLight
            textColourScheme = UIColor.black //GlobalConstants.writingDark
            titleViewColourScheme = GlobalConstants.DarkestGray
        }
        
        let returnColourScheme = ColourScheme()
        
        returnColourScheme.type = scheme
        returnColourScheme.podColourScheme = podColourScheme
        returnColourScheme.textColourScheme = textColourScheme
        returnColourScheme.titleViewColourScheme = titleViewColourScheme
        
        return returnColourScheme
    }
}

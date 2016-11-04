//
//  GlobalConstants.swift
//  Weather
//
//  Created by Mark Gumbs on 26/06/2016.
//  Copyright © 2016 britishairways. All rights reserved.
//

import UIKit

class GlobalConstants: NSObject {

    static let DemoMode = false

    static let AppName = "SkyCast"
    
   // http://www.developerdave.co.uk/2015/09/better-completion-handlers-in-swift/
    typealias CompletionHandlerType = (CompletionResult) -> Void
    
    enum CompletionResult {
        case Success(AnyObject?)
        case Failure(Error)
    }
    
    enum CompletionError: Error {
        case AuthenticationFailure
    }

    // Colour Shades
    static var DarkestGray = UIColor(red: 203/255, green: 210/255, blue: 214/255, alpha: 0.95)
    static var DarkerGray = UIColor(red: 225/255, green: 228/255, blue: 230/255, alpha: 0.95)
    static var LighterGray = UIColor(red: 242/255, green: 242/255, blue: 242/255, alpha: 0.95)
    static var LightestGray = UIColor(red: 250/255, green: 245/255, blue: 245/255, alpha: 1)
    
    static var DarkerYellow = UIColor(red: 250/255, green: 239/255, blue: 117/255, alpha: 0.95)
    static var LighterYellow = UIColor(red: 252/255, green: 218/255, blue: 116/255, alpha: 0.95)
 
    static var DarkerBlue = UIColor(red: 154/255, green: 181/255, blue: 224/255, alpha: 0.95)
    static var LighterBlue = UIColor(red: 179/255, green: 202/255, blue: 239/255, alpha: 0.95)

    
    // Tableview shading
    struct TableViewAlternateShading {
        static var Darkest = DarkestGray
        static var Darker = DarkerGray
        static var Lighter = LighterGray
        static var Lightest = LightestGray
    }
    struct TableViewAlternateShadingDay {
        static var Darker = DarkerYellow
        static var Lighter = LighterYellow
    }
    struct TableViewAlternateShadingNight {
        static var Darker = DarkerBlue
        static var Lighter = LighterBlue
    }
    
    static let DisplayViewAlpha = 0.85
    
    // Tableview 
    static let NumberOfHoursToShowFromNow = 12
    
    // Weather Screen View Shaiding
    struct ViewShading {
        static var Darker = UIColor(red: 227/255, green: 230/255, blue: 232/255, alpha: 0.95) // Darker Shade
        static var Lighter = UIColor(red: 245/255, green: 247/255, blue: 245/255, alpha: 0.95) // Lighter Shade
    }
    
    
    // Create a singleton so that the variables can be called outside of the class
    static let sharedInstance = GlobalConstants()
    
    // Ensure no spaces in URL
    
    static let SupportEmailAddress = "mgdeveloper7@gmail.com"
    static let DarkSkyURL = "https://darksky.net/poweredby/"
    static let WeatherIconURL = "https://icons8.com"
    static let WeatherPhotosURL = "http://www.freedigitalphotos.net"
    
    static let WeatherURL = "https://api.darksky.net/forecast/2dd6883f4f06cd2acdd6b3b0771a9b7c/51.508146,-0.624004"
    static let BaseWeatherURL = "https://api.darksky.net/forecast/2dd6883f4f06cd2acdd6b3b0771a9b7c/"

    static let celsiusURLParameter = "?units=si"
    
    static let DemoWeatherFile = "sample_data_cippenham2"
    
    static let degreesSymbol = "\u{00B0}C"  // TODO:  Look at celsuis and farenheight
    
    static let MetersPerSecondToMph = Float(2.23694)
    
    // Keys to read from NSUserDefaults
    struct Defaults {
        static let SavedTemperatureUnits = "savedTemperatureUnits"
        static let SavedDayOrNightColourSetting = "savedDayOrNightColourSetting"
        static let LastLoadedBackground = "lastLoadedBackground"
    }
    
    // Temperature Units
    struct TemperatureUnits {
        static let Celsuis = "celsuis"
        static let Fahrenheit = "fahrenheit"
    }
    
    static let DefaultTemperatureUnit = "celsuis"
    static let DefaultDayOrNightSwitch = "ON"
    static let DefaultBackgroundImage = "sky_background_PEXELS"
    
    // Icon Constants  (Icons from https://icons8.com/web-app/category/Weather) //TODO:  Include Credits for each icon
    // https://makeappicon.com/
    
    struct Images {
        enum ServiceIcon : String {
            
            // These names are returned from the Dark Sky API
            case clearDay = "clear-day"
            case clearNight = "clear-night"
            case rain = "rain"
            case snow = "snow"
            case sleet = "sleet"
            case wind = "wind"
            case fog = "fog"
            case cloudy = "cloudy"
            case partlyCloudyDay = "partly-cloudy-day"
            case partlyCloudyNight = "partly-cloudy-night"
            
            // Future
            case hail = "hail"
            case thunderstorm = "thunderstorm"
            case tornado = "tornado"
        }
    }
    
    // http://www.freedigitalphotos.net/  (photos with ID-100....)
    // https://www.pexels.com/
    
    struct ImageFile {
        enum FileName : String {
            
            case clearDay = "clear_day_sunshine-186980-pexels.jpeg" //"ID-100206388_Sun Sky Blue_samarttiw.jpg"
            case clearNight = "clear_night_moon-photo-70182-pexels.jpeg" //""ID-10028938_Starry Nignt Dark Blue_nuttakit.jpg"
            case rain = "rain_day-125510-pexels.jpeg" //"ID-100292943_Close Up Texture Of Water Drop_khunaspix.jpg"
            case snow = "snow_day-forest-trees_pexels.jpeg" //"ID-100197671_Winter Landscape_Vichaya Kiatying-Angsulee.jpg"
            case sleet = "sleet_pexels-12875.jpeg" //"sleet"
            case wind = "wind_person-woman-girl-blonde-pexels.jpg" //"windy.jpg"
            case fog = "fog_day_road_foggy-mist-pexels.jpg" //"ID-10010583_Atmosphere Of Haze_dan.jpg"
            case fogNight = "fog_night_foggy-mist-forest-trees-42263-pexels"
            case cloudy = "cloud_overcast-27194-pexels.jpg" //"ID-100202953_White And Gray Clouds_Stoonn.jpg"
            case partlyCloudyDay = "partial_cloud_day-28501-pexels.jpg" //"partial_clouds_day-53594_PEXELS.jpeg"
            case partlyCloudyNight = "partial_cloudy_night-98855-pexels.jpeg" //"night-clouds-trees_PEXELS.jpg"
            
            // Future
            case hail = "hail"
            case thunderstorm = "lightning-day-sky-53459-pexels.jpeg" //"ID-100105405_Night Lightning_antpkr.jpg"
            case tornado = "tornado"
        }
    }
    
    struct WeatherIcon {
        
        static var clearDay = "Sun-50"
        static var clearNight = "Bright Moon-50"
        static var rain = "Rain-50"
        static var snow = "Snow-50"
        static var sleet = "Sleet-50"
        static var wind = "Cloud-50"  // TODO:  Find icon
        static var fog = "Fog Day-50"  // TODO:  Do Fog Day/Night
        static var cloudy = "Cloud-50"
        static var partlyCloudyDay = "Partly Cloudy Day-50"
        static var partlyCloudyNight = "Partly Cloudy Night-50"
        
        // Future
        static var hail = "Hail-50"
        static var thunderstorm = "Storm-50"
        static var tornado = "tornado"


    }
    
    enum DistanceUnits: String {
        case Meters = "meters"
        case Miles = "miles"
        case Kilometers = "kilometers"
    }
    
    // TODO:  Convert wind direction
    // http://climate.umn.edu/snow_fence/components/winddirectionanddegreeswithouttable3.htm
}

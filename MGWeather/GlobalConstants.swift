//
//  GlobalConstants.swift
//  Weather
//
//  Created by Mark Gumbs on 26/06/2016.
//

import UIKit
import GoogleMobileAds

class GlobalConstants: NSObject {

    // Create a singleton so that the variables can be called outside of the class
    static let sharedInstance = GlobalConstants()
    
    //
    // Variables written to at some point in the code (only done for performance issues, for example,
    // to avoid reading from NSUserDefaults mutiple times)
    //
    
    static var timezoneOffset = 0
    static var urlUnitsChosen = ""
    
    //
    //
    // The remainder will be read-only
    //
    
    static let AppName = "SkyCast"

    // Completion Handler code (NOT CURRENTLY USED)
   // http://www.developerdave.co.uk/2015/09/better-completion-handlers-in-swift/
    typealias CompletionHandlerType = (CompletionResult) -> Void
    
    enum CompletionResult {
        case Success(AnyObject?)
        case Failure(Error)
    }
    
    enum CompletionError: Error {
        case AuthenticationFailure
    }

    // Colour Scheme
    
    struct ColourScheme {
        static var Dark = "Dark"
        static var Light = "Light"
    }
    
    static var podDark = UIColor(red: 24/255, green: 25/255, blue: 26/255, alpha: 0.85)
    static var podLight = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.85)

    static var writingDark = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 1)
    static var writingLight = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)

    // Colour Shades
    static var DarkestGray = UIColor(red: 203/255, green: 210/255, blue: 214/255, alpha: 0.95)
    static var DarkerGray = UIColor(red: 225/255, green: 228/255, blue: 230/255, alpha: 0.95)
    static var LighterGray = UIColor(red: 242/255, green: 242/255, blue: 242/255, alpha: 0.95)
    static var LightestGray = UIColor(red: 250/255, green: 245/255, blue: 245/255, alpha: 1)
    
    // Day/Night colours for lighter theme
    static var DarkerYellow = UIColor(red: 250/255, green: 239/255, blue: 117/255, alpha: 0.95)
    static var LighterYellow = UIColor(red: 252/255, green: 218/255, blue: 116/255, alpha: 0.95)
    static var DarkerBlue = UIColor(red: 154/255, green: 181/255, blue: 224/255, alpha: 0.95)
    static var LighterBlue = UIColor(red: 179/255, green: 202/255, blue: 239/255, alpha: 0.95)

        // Day/Night colours for darker theme
    static var DarkerBlack = UIColor(red: 30/255, green: 30/255, blue: 30/255, alpha: 0.85)
    static var LighterBlack = UIColor(red: 70/255, green: 70/255, blue: 65/255, alpha: 0.85)

    static var TwighlightShading = UIColor(red: 193/255, green: 217/255, blue: 206/255, alpha: 0.85)
    //static var TwighlightShading = UIColor(red: 199/255, green: 160/255, blue: 54/255, alpha: 0.80)
    
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

    // Dark Theme
    struct TableViewAlternateShadingDayDarkTheme {
        static var Darker = DarkerBlack
        static var Lighter = LighterBlack
    }
    struct TableViewAlternateShadingNightDarkTheme {
        static var Darker = DarkerBlack
        static var Lighter = LighterBlack
    }
    
    struct WeatherWarning {
        static var Advisory = UIColor(red: 252/255, green: 248/255, blue: 5/255, alpha: 1.0)
        static var Watch = UIColor(red: 252/255, green: 186/255, blue: 206/255, alpha: 1.0)
        static var Warning = UIColor(red: 252/255, green: 63/255, blue: 206/255, alpha: 1.0)
    }

    // Selected hour
    static var TableViewSelectedHourShading = UIColor(red: 18/255, green: 64/255, blue: 201/255, alpha: 0.85)

    static let DisplayViewAlpha = 0.85
    
    // Tableview 
    static let NumberOfHoursToShowFromNow = 14  // Max 48
    
    // Weather Screen View Shading
    struct ViewShading {
        static var Darker = UIColor(red: 227/255, green: 230/255, blue: 232/255, alpha: 1) // Darker Shade
        static var Lighter = UIColor(red: 245/255, green: 247/255, blue: 245/255, alpha: 1) // Lighter Shade
    }
    
    // Segmented Control Colours
    struct SegmentedControlTheme {
        struct Dark {
            static var Buttons = UIColor.white
            static var Text = UIColor.black
        }
        struct Light {
            static var Buttons = UIColor(red: 49/255, green: 121/255, blue: 214/255, alpha: 1)
            static var Text = UIColor.white
        }
    }

    
    // Ensure no spaces in URL
    
    static let SupportEmailAddress = "mgdeveloper7@gmail.com"
    static let DarkSkyURL = "https://darksky.net/poweredby/"
    static let WeatherIconURL = "https://icons8.com"
    static let WeatherPhotosURL = "https://www.pexels.com"
    
    static let WeatherURL = "https://api.darksky.net/forecast/2dd6883f4f06cd2acdd6b3b0771a9b7c/51.508146,-0.624004"
    static let BaseWeatherURL = "https://api.darksky.net/forecast/2dd6883f4f06cd2acdd6b3b0771a9b7c/"

//    static let celsiusURLParameter = "?units=si"
//    static let siUnitURLParameter = "?units=uk2"
//    static let imperialUnitURLParameter = "?units=us"
    
    static let DemoWeatherFile = "sample_data_cippenham2"
    
    static let degreesSymbol = "\u{00B0}"
    
    static let MetersPerSecondToMph = Float(2.23694)
    
    // Rain related
    
    static let RainIconReportThresholdPercent = 4
    static let RainDistanceReportThreshold = 1

/*
    // http://www.leancrew.com/all-this/2012/10/matplotlib-and-the-dark-sky-api/
     Numerical	Descriptive
     < 15	sporadic
     15-30	light
     30-45	moderate
     > 45	heavy

*/
    // Wind related
    static let WindStrengthThreshold = 9  // KPH or MPH

    // Keys to read from NSUserDefaults
    struct Defaults {
        static let URLDefaultUnits = "urlDefaultUnits"
        static let SavedTemperatureUnits = "savedTemperatureUnits"
        static let SavedDayOrNightColourSetting = "savedDayOrNightColourSetting"
        static let SavedColourScheme = "savedColourScheme"
        static let LastLoadedBackground = "lastLoadedBackground"
    }
    
    // NSNotification Keys
    
    static let weatherRefreshFinishedKey = Notification.Name("WeatherRefreshedFinished")
    static let locationRefreshFinishedKey = Notification.Name("LocationRefreshedFinished")
    
    // Temperature Units
    struct TemperatureUnits {
        static let Celsuis = "celsuis"
        static let Fahrenheit = "fahrenheit"
    }
    
    // Percipitation Types
    
    struct PrecipitationType {
        static let Rain = "rain"
        static let Sleet = "sleet"
        static let Snow = "snow"
    }

    struct PrecipitationIntensity {
        static let Light = "LIGHT"
        static let Medium = "MEDIUM"
        static let Heavy = "HEAVY"
    }
    
    // Defaults
    
    static let DefaultURLUnit = "uk2"
    static let DefaultTemperatureUnit = TemperatureUnits.Celsuis
    static let DefaultDayOrNightSwitch = "ON"
    static let DefaultColourScheme = GlobalConstants.ColourScheme.Dark
    static let DefaultBackgroundImage = "sky_background_PEXELS"
    
    //
    // WEATHER BACKGROUNDS
    //
    
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
            
            // Relates to standard from Dark Sky API
            case clearDay = "clear_day_sunshine-186980-pexels.jpeg"
            case clearNight = "clear-night-city-pexels-294560.jpeg" //"clear_night_moon-pexels-26341.jpg"
            case rain = "rain_day-125510-pexels.jpeg"
            case snow = "snow_day-forest-trees_pexels.jpeg"
            case sleet = "sleet_pexels-12875.jpeg"
            case wind = "wind_person-woman-girl-blonde-pexels.jpg"
            case fog = "fog_day_road_foggy-mist-pexels.jpg"
            case cloudy = "cloud_overcast-27194-pexels.jpg"
            case partlyCloudyDay = "partial_cloud_day-28501-pexels.jpg"
            case partlyCloudyNight = "partial-cloud-night-30376-pexels"
            
            // Future
            case hail = "hail-pexels-photo"
            case thunderstorm = "lightning-day-sky-53459-pexels.jpeg"
            case tornado = "tornado-pexels-26517"
            
            // Custom (variations on the standard)
            case rainNight = "rain_night-pexels"
            case sleetNight = "sleet-night-pexels-29756.jpg"
            case snowNight = "snow-night-pexels-23976.jpg"
            case fogNight = "fog_night_foggy-mist-forest-trees-42263-pexels"
            case cloudyNight = "overcast-night-pexels-111263.jpeg"
            case partlyCloudyDayAlternate = "partial_cloud_day_water-163900-pexels"
            case partlyCloudyNightAlternate = "partial_cloudy_night-70439-pexels.jpeg"
            
            // Themed Occasions
            case halloween = "halloween-pumpkin-carving-face"
            case bonfireNight = "fireworks-rocket-night-sky-46159"
            case xmasDay = "santa-claus-christmas-41963-pexels"
            case xmasNight = "christmas-candles-54512-pexels"
            case newYearsEve = "new-year-night-38196-pexels"
            
            // Misc (used in Settings and About screens)
            case miscSunsetPoppy = "sunset-field-poppy-pexels"
            case miscMountainFlowers = "mountain-flowers-pexels"
            case miscSunsetTwighlight = "sky_background_PEXELS"
            
        }
    }
    
    // The following define 3 backgrounds we can use in the settings and about screen
    
    struct SettingsScreenBackground {
        static var One = ImageFile.FileName.thunderstorm
        static var Two = ImageFile.FileName.bonfireNight
        static var Three = ImageFile.FileName.wind
    }
    
    struct AboutScreenBackground {
        static var One = ImageFile.FileName.miscSunsetPoppy
        static var Two = ImageFile.FileName.miscMountainFlowers
        static var Three = ImageFile.FileName.miscSunsetTwighlight
    }
    
    //
    // WEATHER ICONS
    //
    
    // Check country may icons https://thenounproject.com/tomwalshdesign/collection/maps-of-the-world-europe/?oq=uk&cidx=2&i=675308
    
    // Cloud App Icon by http://www.flaticon.com/free-icon/clouds_136722
    
    struct WeatherIcon {
        
        static var clearDay = "Sun-50"
        static var clearNight = "Bright Moon-50"
        static var rain = "Rain-50"
        static var snow = "Snow-50"
        static var sleet = "Sleet-50"
        static var wind = "Windy"
        static var fog = "Fog Day-50"  // NOTE: Day and Night def for fog is not from API
        static var fogNight = "Fog Night-50" // NOTE: Day and Night def for fog is not from API
        static var cloudy = "Cloud-50"
        static var partlyCloudyDay = "Partly Cloudy Day-50"
        static var partlyCloudyNight = "Partly Cloudy Night-50"
        
        // Future
        static var hail = "Hail-50"
        static var thunderstorm = "Thunderstorm"
        static var tornado = "Tornado"
        
        // Custom
        static var umbrella = "Umbrella"
        static var sunrise = "Sunrise-50"
        static var sunset = "Sunset-50"
        static var windy = "Windsock"
        static var snowflake = "Snowflake"
        
        static var lightRain = "Light Rain-50"
        static var heavyRain = "Heavy Rain-50"

        //
        // WHITE
        //
        
        static var clearDay_White = "Sun-White"
        static var clearNight_White = "Bright-Moon-White"
        static var rain_White = "Rain-White"
        static var snow_White = "Snow-White"
        static var sleet_White = "Sleet-White"
        static var wind_White = "Windy-White"
        static var fog_White = "Fog-Day-White"
        static var fogNight_White = "Fog-Night-White"
        static var cloudy_White = "Cloud-White"
        static var partlyCloudyDay_White = "Partly-Cloudy-Day-White"
        static var partlyCloudyNight_White = "Partly-Cloudy-Night-White"
        
        // Future
        static var hail_White = "Hail-White"
        static var thunderstorm_White = "Thunderstorm-White"
        static var tornado_White = "Tornado-White"
        
        // Custom
        static var umbrella_White = "Umbrella-White"
        static var sunrise_White = "Sunrise-White"
        static var sunset_White = "Sunset-White"
        static var windy_White = "Windsock-White"
        static var snowflake_White = "Snowflake-White"

        static var lightRain_White = "Light-Rain-White"
        static var heavyRain_White = "Heavy-Rain-White"

    }
    
    // Distance and unit related
    
    
    enum DistanceUnits: String {
        case Meters = "meters"
        case Miles = "miles"
        case Kilometers = "kilometers"
    }
    
    struct urlUnit {
        static let ca = "ca"
        static let uk = "uk2"
        static let us = "us"
        static let si = "si"
    }
    
    // TODO:  Convert wind direction
    // http://climate.umn.edu/snow_fence/components/winddirectionanddegreeswithouttable3.htm
    
    // MARK:  Banner Ad related
    
    // Get Started:  https://firebase.google.com/docs/admob/ios/quick-start
    
    struct BannerAdTestIDs {
        // List of devices used whilst testing, in order to see test banner ads
        static let IPhone6 = "d908ab2aa2246c48dd031abe26ac03f5"
        static let Simulator = kGADSimulatorID
    }
    
    static let AdMobAppID = "ca-app-pub-7564315004238579~8353051847"
    static let AdMobBannerID = "ca-app-pub-7564315004238579/6736717849"
    
    static let TestAdMobAppID = "ca-app-pub-3940256099942544~1458002511"
    static let TestAdMobBannerID = "ca-app-pub-3940256099942544/2934735716"
    
    //  How often banner ads are shown on some screens (e.g 3 means display ads once every 3 times)
    static let BannerAdDisplayFrequency = 3
    
    // Test Latitude and Longitude
    // Baird Close - latitude = 51.5082001314047 longitude = -0.62429395504354

    // TODO:
    // Use http://burningsoul.cloud/apis/moon for moon info
    //
    // This Time Last Year
    //  NSDate().timeIntervalSince1970
 
    // Google Maps API
    
    static let GoogleMapAPIKey = "AIzaSyA3YCR-a3OTW--dEVFKBkxbT_Kwn2EYkIQ"
    static var GoogleMapAPIBrowserKey = "AIzaSyCUezEihEvHKOdKfS2vyTaQHlKZ26gNETQ"
    static let GoogleMapOAuth2ClietID = "941132294503-93iclt25guqovnc4ejipnbmedusimkud.apps.googleusercontent.com"
}

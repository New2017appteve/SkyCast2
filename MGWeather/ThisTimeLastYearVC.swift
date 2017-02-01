//
//  ThisTimeLastYearVC.swift
//  SkyCast
//
//  Created by Mark Gumbs on 20/12/2016.
//  Copyright © 2016 MGSoft. All rights reserved.
//

import UIKit
import GoogleMobileAds

protocol ThisTimeLastYearVCDelegate {

}
class ThisTimeLastYearVC: UIViewController, GADBannerViewDelegate {

    var weather: Weather?
    var tmpWeather : Weather?
    var url : String?
    var inDayOrNight : String?  // Change Name?
    
    var dailyWeather : Weather!  // This is passed in from ParentWeatherVC
    var delegate:ThisTimeLastYearVCDelegate?
    
    var dayOrNightColourSetting: String?
    var infoLabelTimerCount = 0
    var weatherDetailsTimerCount = 0
    
    var sunriseTimeStamp: NSDate?
    var sunsetTimeStamp: NSDate?
    var tomorrowSunriseTimeStamp: NSDate?
    var tomorrowSunsetTimeStamp: NSDate?
    
    var podColourScheme: UIColor?
    var writingColourScheme: UIColor?

    
    // MARK: Outlets
    
    @IBOutlet weak var outerScreenView : UIView!
    @IBOutlet weak var weatherImageOuterView : UIView!
    @IBOutlet weak var weatherImage : UIImageView!
    
    @IBOutlet weak var infoView : UIView!
    @IBOutlet weak var infoLabel : UILabel!
    
    @IBOutlet weak var nowLabel : UILabel!
    @IBOutlet weak var currentTempView : UIView!
    @IBOutlet weak var currentTempDetailView : UIView!
    @IBOutlet weak var currentTemp : UILabel!
    @IBOutlet weak var windspeed : UILabel!
    
    @IBOutlet weak var nowDetailOneView : UIView!
    @IBOutlet weak var feelsLikeTemp : UILabel!
    @IBOutlet weak var currentWeatherIcon : UIImageView!
    
    @IBOutlet weak var currentSummary : UILabel!
    
    @IBOutlet weak var weatherDetailOuterView : UIView!
    @IBOutlet weak var weatherDetailView : UIView!
    @IBOutlet weak var weatherDetailStackView : UIStackView!
    
    @IBOutlet weak var todayLabel : UILabel!
    @IBOutlet weak var todaySummary : UILabel!
    @IBOutlet weak var todayHighLowTemp : UILabel!
    @IBOutlet weak var currentWindspeed : UILabel!
    @IBOutlet weak var cloudCover : UILabel!
    
    @IBOutlet weak var todayHighLowTempTitle : UILabel!
    @IBOutlet weak var windspeedTitle : UILabel!
    @IBOutlet weak var cloudCoverTitle : UILabel!
    @IBOutlet weak var humidityTitle : UILabel!
    
    @IBOutlet weak var sunriseStackView : UIStackView!
    @IBOutlet weak var sunriseIcon : UIImageView!
    @IBOutlet weak var sunrise : UILabel!
    @IBOutlet weak var sunsetStackView : UIStackView!
    @IBOutlet weak var sunsetIcon : UIImageView!
    @IBOutlet weak var sunset : UILabel!
    @IBOutlet weak var humidity : UILabel!

    @IBOutlet weak var poweredByDarkSkyButton : UIButton!
    
    // The banner views.
    @IBOutlet weak var bannerOuterView: UIView!
    @IBOutlet weak var closeBannerButton : UIButton!
    @IBOutlet weak var bannerView: GADBannerView!

    override func viewDidLoad() {
        super.viewDidLoad()

        inDayOrNight = "DAY"
        currentTempView.alpha = 0
        weatherDetailOuterView.alpha = 0
        
        setupScreenBeforeDataLoad()
        getWeatherDataFromService()
        
        // Do any additional setup after loading the view.
//        setupDisplayTimer()
//        setupScreen()
//        setupColourScheme()
//        populateTodayWeatherDetails()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if AppSettings.ShowBannerAds {
            loadBannerAd()
            bannerOuterView.isHidden = false
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func setupScreenBeforeDataLoad() {
    
        let lastLoadedBackground = Utility.getLastLoadedBackground()
        
        // Ease in the image view
        self.weatherImage.alpha = 0.2
        weatherImage.image = UIImage(named: lastLoadedBackground)!
        
        UIView.animate(withDuration: 0.6, delay: 0.0, options: UIViewAnimationOptions.curveEaseIn, animations: {
            self.weatherImage.alpha = 1
        }, completion: nil)
        
    }
    
    func setupScreenAfterDataLoad() {
        
        // NOTE:  This will be called from a background thread
        
        setupDisplayTimer()
        setupScreen()
        setupColourScheme()
        populateTodayWeatherDetails()
    }
    
    func setupScreen () {
        
       // bannerOuterView.isHidden = true
        closeBannerButton.isHidden = true  // Will only show once banner ad loaded
        
        let userDefaults = UserDefaults.standard
        dayOrNightColourSetting = userDefaults.string(forKey: GlobalConstants.Defaults.SavedDayOrNightColourSetting)
        
        if (dayOrNightColourSetting == nil) {
            
            // Set default and save it
            dayOrNightColourSetting = GlobalConstants.DefaultColourScheme  // Dark
            userDefaults.set(dayOrNightColourSetting, forKey: GlobalConstants.Defaults.SavedColourScheme)
        }
        
        // Make round corners for the outerviews
        currentTempDetailView.layer.cornerRadius = 10.0
        currentTempDetailView.clipsToBounds = true
        
        infoView.layer.cornerRadius = 5.0
        infoView.clipsToBounds = true
        
        weatherDetailOuterView.layer.cornerRadius = 10.0
        weatherDetailOuterView.clipsToBounds = true
        
        poweredByDarkSkyButton.titleEdgeInsets.right = 10 // Add right padding of text
        
        nowDetailOneView.backgroundColor = UIColor.clear
        nowDetailOneView.alpha = 1
        
        // Hide weather details initially until timer starts
        self.weatherDetailStackView.alpha = 0
        
    }
    
    func setupColourScheme() {
        
        // Setup pods and text colour accordingly
        
        let colourScheme = Utility.setupColourScheme()
        
        let textColourScheme = colourScheme.textColourScheme
        let podColourScheme = colourScheme.podColourScheme
        let titleViewColourScheme = colourScheme.titleViewColourScheme
        
        // Labels
        
        infoLabel.textColor = textColourScheme
        nowLabel.textColor = textColourScheme
        currentTemp.textColor = textColourScheme
        windspeed.textColor = textColourScheme
        feelsLikeTemp.textColor = textColourScheme
        currentWindspeed.textColor = textColourScheme
        currentSummary.textColor = textColourScheme
        todayLabel.textColor = textColourScheme
        todaySummary.textColor = textColourScheme
        todayHighLowTemp.textColor = textColourScheme
        cloudCover.textColor = textColourScheme
        sunrise.textColor = textColourScheme
        sunset.textColor = textColourScheme
        humidity.textColor = textColourScheme
        
        todayHighLowTempTitle.textColor = textColourScheme
        windspeedTitle.textColor = textColourScheme
        cloudCoverTitle.textColor = textColourScheme
        humidityTitle.textColor = textColourScheme
        
        // Pods
        
        infoView.backgroundColor = podColourScheme
        currentTempDetailView.backgroundColor = podColourScheme
        
        infoView.alpha = CGFloat(GlobalConstants.DisplayViewAlpha)
        currentTempDetailView.alpha = CGFloat(GlobalConstants.DisplayViewAlpha)
        weatherDetailOuterView.alpha = 1.0 //CGFloat(GlobalConstants.DisplayViewAlpha)
        
        weatherDetailOuterView.backgroundColor = UIColor.clear //podColourScheme
        weatherDetailView.backgroundColor = podColourScheme
        
        // Buttons and Title Labels
        nowLabel.backgroundColor = titleViewColourScheme
        todayLabel.backgroundColor = titleViewColourScheme
        poweredByDarkSkyButton.backgroundColor = titleViewColourScheme
        
        // Ease in the two pods
        self.currentTempView.alpha = 0.0
        UIView.animate(withDuration: 1.2, delay: 0.5, options: UIViewAnimationOptions.curveEaseIn, animations: {
            self.currentTempView.alpha = 1
        }, completion: nil)
        
        self.weatherDetailOuterView.alpha = 0.0
        UIView.animate(withDuration: 1.2, delay: 0.5, options: UIViewAnimationOptions.curveEaseIn, animations: {
            self.weatherDetailOuterView.alpha = 1
        }, completion: nil)
        
    }
    
    func loadBannerAd() {
        
        bannerView.delegate = self
        
        print("Google Mobile Ads SDK version: \(GADRequest.sdkVersion())")
        bannerView.adUnitID = AppSettings.AdMobBannerID
        bannerView.rootViewController = self
        
        let request = GADRequest()
        if AppSettings.BannerAdsTestMode {
            // Display test banner ads in the simulator
            //  request.testDevices = [AppSettings.AdTestDeviceID]
            request.testDevices = [GlobalConstants.BannerAdTestIDs.Simulator,
                                   GlobalConstants.BannerAdTestIDs.IPhone6]
        }
        
//        // Make ads more location specific
//        if let currentLocation = weatherLocation.currentLocation {
//            request.setLocationWithLatitude(CGFloat(currentLocation.coordinate.latitude),
//                                            longitude: CGFloat(currentLocation.coordinate.longitude),
//                                            accuracy: CGFloat(currentLocation.horizontalAccuracy))
//        }
        bannerView.load(request)
    }

    
    func populateTodayWeatherDetails() {

        if let todayArray = dailyWeather?.currentBreakdown {
            
            //
            // Now Pod
            //
            
            currentSummary.text = todayArray.summary
            
            let thisTimeLastYearTime = todayArray.dateAndTimeStamp
            nowLabel.text = "  " + getTimeLastYear(lastYearDate: thisTimeLastYearTime!)
            
            let degreesSymbol = GlobalConstants.degreesSymbol + todayArray.temperatureUnits!
            currentTemp.text = String(Int(round(todayArray.temperature! as Float))) + degreesSymbol
            
            // Inner Pod 1
            feelsLikeTemp.text = "Feels Like: " + String(Int(round(todayArray.apparentTemperature! as Float))) + degreesSymbol
            
//            // Inner Pod 2

            
            var windDirection = ""
            if (todayArray.windBearing != nil) {
                windDirection = Utility.compassDirectionFromDegrees(degrees: todayArray.windBearing!)
            }
            
            var rainDirection = ""
            if (todayArray.nearestStormBearing != nil) {
                rainDirection = Utility.compassDirectionFromDegrees(degrees: Float(todayArray.nearestStormBearing!))
            }
            
            // TODO:  Report KM or MI accordingly.  Create utility to see if units in MPH/KPH from service
            
            let windSpeedUnits = todayArray.windSpeedUnits!
            
            // TODO: Tidy up string concat
            
            //if (windDirection != nil || windDirection != "") {
            if ( !(windDirection.isEmpty) || windDirection != "") {
                currentWindspeed.text = "Wind: " + String(Int(todayArray.windSpeed!))
                currentWindspeed.text = currentWindspeed.text! + " " + windSpeedUnits + " " + windDirection
            }
            
// NOT NEEDED            let nearestRain = todayArray.nearestStormDistance!
            
//            if (nearestRain == 0) {
//                nearestRainDistance.text = "Rain nearby" //"Raining"
//            }
//            else if (nearestRain > 0 && nearestRain <= GlobalConstants.RainDistanceReportThreshold) {
//                nearestRainDistance.text = "Rain nearby"
//            }
//            else if (nearestRain > GlobalConstants.RainDistanceReportThreshold) {
//                let rainUnits = todayArray.nearestStormDistanceUnits
//                
//                // TODO: Tidy up string concat
//                
//                if ( !(rainDirection.isEmpty) || rainDirection != "") {
//                    nearestRainDistance.text = "Rain " + String(todayArray.nearestStormDistance!) + " "
//                    nearestRainDistance.text = nearestRainDistance.text! + rainUnits! + " " + rainDirection
//                }
//            }
            
            
            // Min Temp, Max Temp, Sunrise and Sunset we can get from the 'daily' figures
            
            let dayArray = dailyWeather?.dailyBreakdown.dailyStats
            
            for days in dayArray! {
                
                // If today, populate the relevant fields
                let sameDay = Utility.areDatesSameDay(date1: todayArray.dateAndTimeStamp!, date2: days.dateAndTimeStamp!)
                
                if sameDay {
                    
                    //
                    // Today Summary Pod
                    //
                    
                    let minTempString = String(Int(round(days.temperatureMin!))) + degreesSymbol
                    let maxTempString = String(Int(round(days.temperatureMax!))) + degreesSymbol
                    todayHighLowTemp.text = maxTempString + " / " + minTempString
                    
                    let windspeedUnits = days.windSpeedUnits
                    windspeed.text = String(Int(days.windSpeed!)) + " " + windspeedUnits!
                    
                    cloudCover.text = String(Int(round(days.cloudCover!*100))) + "%"
                    humidity.text = String(Int(round(days.humidity!*100))) + "%"
                    
                    sunrise.text = String(days.sunriseTimeStamp!.shortTimeString())
                    sunset.text = String(days.sunsetTimeStamp!.shortTimeString())
                    sunriseTimeStamp = days.sunriseTimeStamp as NSDate?
                    sunsetTimeStamp = days.sunsetTimeStamp as NSDate?
                    
                    // Populate with the correct sunrise/sunset icon scheme
                    let sunriseIconImage = Utility.getWeatherIcon(serviceIcon: "SUNRISE", dayOrNight: "", weatherStats: days)
                    sunriseIcon.image = UIImage(named: sunriseIconImage)!
                    
                    let sunsetIconImage = Utility.getWeatherIcon(serviceIcon: "SUNSET", dayOrNight: "", weatherStats: days)
                    sunsetIcon.image = UIImage(named: sunsetIconImage)!
                    
                }
                
                // We want tomorrows sunrise and sunset times as well for use in calculations later
                
                let tomorrow = Utility.isTomorrow(date1: days.dateAndTimeStamp!)
                
                if tomorrow {
                    tomorrowSunriseTimeStamp = days.sunriseTimeStamp as NSDate?
                    tomorrowSunsetTimeStamp = days.sunsetTimeStamp as NSDate?
                }
            }  // days
            
            // Get the summary from the Hourly sumary
            let hourlyBreakdown = dailyWeather?.hourBreakdown
            todaySummary.text = hourlyBreakdown?.summary
            
            // Populate the weather image
            let icon = todayArray.icon
            let enumVal = GlobalConstants.Images.ServiceIcon(rawValue: icon!)
            
            var backgroundImageName = ""
            if AppSettings.SpecialThemedBackgroundsForEvents {
                // Get a special background if its a 'themed day (e.g Chrisrmas etc)
                backgroundImageName = Utility.getSpecialDayWeatherImage(dayOrNight: inDayOrNight!)
            }
            
            if backgroundImageName == "" {
                backgroundImageName = Utility.getWeatherImage(serviceIcon: (enumVal?.rawValue)!, dayOrNight: inDayOrNight!)
            }
            
            if !(String(backgroundImageName).isEmpty) {
                weatherImage.image = UIImage(named: backgroundImageName)!
                Utility.setLastLoadedBackground(backgroundName: backgroundImageName)
            }
            
            // Populate the weather icons
            
            let weatherIconEnumVal = GlobalConstants.Images.ServiceIcon(rawValue: icon!)
            let weatherIconName = Utility.getWeatherIcon(serviceIcon: (weatherIconEnumVal?.rawValue)!, dayOrNight: inDayOrNight!, weatherStats: todayArray)
            
            if !(String(weatherIconName).isEmpty) {
                currentWeatherIcon.image = UIImage(named: weatherIconName)!
            }
            
        }  // todayArray
        
    }

    // Display Screen Functions
    
    func setupDisplayTimer() {
        
        infoLabelTimerCount = 0
        weatherDetailsTimerCount = 0
        
        _ = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(updateWeatherDetailsOnScreen), userInfo: nil, repeats: true)
        
    }
    
    func updateWeatherDetailsOnScreen() {
        
        infoLabelTimerCount += 1
        weatherDetailsTimerCount += 1
        
        infoLabel.text = "Weather Last Year"
        
        let detailsMod = infoLabelTimerCount % 3
        switch (detailsMod) {
        case 0:
            hideWeatherDetailsView()
        case 1:
            showWeatherDetailsView()
        case 2:
        return // Do nothing, this wlll have the effect of showing the weather details longer
        default:
            infoLabel.text = ""
        }
        
    }
    
    func hideWeatherDetailsView () {
        
        // Hide the weather details view whilst showing the today summary text
        self.todaySummary.alpha = 0
        UIView.animate(withDuration: 0.6, delay: 0.0, options: UIViewAnimationOptions.curveEaseIn, animations: {
            self.todaySummary.alpha = 1
        }, completion: nil)
        
        self.weatherDetailStackView.alpha = 1
        UIView.animate(withDuration: 0.6, delay: 0.0, options: UIViewAnimationOptions.curveEaseIn, animations: {
            self.weatherDetailStackView.alpha = 0
        }, completion: nil)
    }
    
    func showWeatherDetailsView () {
        
        // Hide the weather details view whilst showing the today summary text
        self.todayLabel.text = "  Day Summary"
        self.todaySummary.alpha = 1
        UIView.animate(withDuration: 0.6, delay: 0.0, options: UIViewAnimationOptions.curveEaseIn, animations: {
            self.todaySummary.alpha = 0
        }, completion: nil)
        
        self.weatherDetailStackView.alpha = 0
        UIView.animate(withDuration: 0.6, delay: 0.0, options: UIViewAnimationOptions.curveEaseIn, animations: {
            self.weatherDetailStackView.alpha = 1
        }, completion: nil)
    }
    
//    func hideNowDetailsOneView () {
//        
//        self.todayLabel.text = "  Day Summary"
//        
//        self.nowDetailOneView.alpha = CGFloat(GlobalConstants.DisplayViewAlpha)
//        UIView.animate(withDuration: 0.6, delay: 0.0, options: UIViewAnimationOptions.curveEaseIn, animations: {
//            self.nowDetailOneView.alpha = 0
//        }, completion: nil)
//    }

    
    
    func isDayTime (dateTime : NSDate) -> Bool {
        
        var retVal : Bool!
        
        // Calculate whether current time is in the day or the night
        // Look at tomorrows sunrise and sunset times too incase the results span days
        
        if (dateTime.isBetweeen(date: sunsetTimeStamp!, andDate: sunriseTimeStamp!) ||
            dateTime.isBetweeen(date: tomorrowSunsetTimeStamp!, andDate: tomorrowSunriseTimeStamp!) ) {
            retVal = true
        }
        else {
            retVal = false
        }
        
        return retVal
    }

    func getTimeLastYear(lastYearDate: NSDate) -> String {
        
        var today = NSDate()
        today = Utility.getTimeInWeatherTimezone(dateAndTime: today)
        
     //   var returnTime = lastYearDate.shortTimeString()
        var returnTime = lastYearDate.longDateString()
        
        if !Utility.areDatesSameDay(date1: today, date2: lastYearDate) {
//            returnTime = (lastYearDate.shortDayMonthYear())! + " @ " + (lastYearDate.shortTimeString())
            returnTime = (lastYearDate.longDateString()) + "  @ " + (lastYearDate.shortTimeString())
        }
        
        return returnTime
        
    }

    // MARK:  Button Methods
    @IBAction func backButtonPressed(_ sender: AnyObject) {
        // Dismiss view
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func closeBannerAdButtonPressed(_ sender: AnyObject) {
        
        // Dismiss banner ad view
        bannerOuterView.isHidden = true
    }
    
    @IBAction func poweredByDarkSkyButtonPressed(_ sender: AnyObject) {
        
        // Display the Dark Sky webpage
        UIApplication.shared.openURL(URL(string: GlobalConstants.DarkSkyURL)!)
    }

    
    // MARK:  GADBannerViewDelegate methods
    
    // Tells the delegate an ad request loaded an ad.
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        print("Ad has been received")
        
        // show the delete ad button
        closeBannerButton.isHidden = false
    }
    
    // MARK:  Service Call methods
    
    func getWeatherDataFromService(){
        
        // NOTE:  This function is called from a background thread
        
        print("URL= " + url!)
        
        let scdService = GetWeatherData()
        
        if (scdService == nil) {
            let message = "Weather details cannot be retrieved at this time.  Please try again"
            Utility.showMessage(titleString: "Error", messageString: message )
            self.view.hideToastActivity()
        }
        else {
            scdService.getData(urlAndParameters: url! as String) {
                [unowned self] (response, error, headers, statusCode) -> Void in
                
                if statusCode >= 200 && statusCode < 300 {
                    
                    let data = response?.data(using: String.Encoding.utf8)
                    
                    do {
                        let getResponse = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! NSDictionary
                        
                        print("Weather search complete")
                        
                        self.tmpWeather = Weather(fromDictionary: getResponse )
                        //self.weather = self.tmpWeather
                        self.dailyWeather = self.tmpWeather
                        DispatchQueue.main.async {
                    
                            // Hide animation on the main thread, once finished background task
                            self.view.hideToastActivity()
                            self.setupScreenAfterDataLoad()
                        }
                        
                    } catch let error as NSError {
                        print("json error: \(error.localizedDescription)")
                        
                        DispatchQueue.main.async {
                            let message = "Weather details cannot be retrieved at this time.  Please try again"
                            Utility.showMessage(titleString: "Error", messageString: message )
                            self.view.hideToastActivity()

                        }
                    }
                    
                } else if statusCode == 404 {
                    // Create default message, may be overridden later if we have found something in response
                    let message = "Weather details cannot be retrieved at this time.  Please try again"
                    
                    DispatchQueue.main.async {
                        Utility.showMessage(titleString: "Error", messageString: message )
                        self.view.hideToastActivity()

                    }
                    
                } else if statusCode == 2000 {
                    // Custom code for a timeout
                    let message = "Weather details cannot be retrieved at this time from Dark Sky.  Please try again"
                    
                    DispatchQueue.main.async {
                        Utility.showMessage(titleString: "Error", messageString: message )
                        self.view.hideToastActivity()

                    }
                    
                } else {
                    DispatchQueue.main.async {
                        let message = "Weather details cannot be retrieved at this time.  Please try again"
                        Utility.showMessage(titleString: "Error", messageString: message )

                    }
                }
            }
        }  // End IF
    }

}

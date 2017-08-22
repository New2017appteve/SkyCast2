 //
//  DailyTabVC.swift
//  Weather
//
//  Created by Mark Gumbs on 29/06/2016.
//

import UIKit
import GoogleMobileAds

protocol DailyTabVCDelegate
{
    func switchViewControllers()
    func returnRefreshedLocationDetails() -> Location
    func returnRefreshedWeatherDetails() -> Weather
    func setupDayOrNightIndicator(dayOrNight : String)
}

class DailyTabVC: UIViewController, GADBannerViewDelegate  {

    var dailyWeather : Weather!  // This is passed in from ParentWeatherVC
    var weatherLocation : Location!  // This is passed in from ParentWeatherVC
    
    var delegate:DailyTabVCDelegate?
    var sunriseTimeStamp: NSDate?
    var sunsetTimeStamp: NSDate?
    var tomorrowSunriseTimeStamp: NSDate?
    var tomorrowSunsetTimeStamp: NSDate?
    var weatherAlertStartTime: NSDate?
    var weatherAlertEndTime: NSDate?
    
    var infoLabelTimerCount = 0
    var lastUpdatedTime: String?  // TODO:  Later
    
    // Outlets
    @IBOutlet weak var weatherSummaryView : UIView!
    @IBOutlet weak var infoLabel : UILabel!
    @IBOutlet weak var locationLabel : UILabel!
    @IBOutlet weak var dailyWeatherTableView : UITableView!
    @IBOutlet weak var outerScreenView : UIView!
    @IBOutlet weak var weatherImage : UIImageView!
    @IBOutlet weak var nextDaysSummary : UITextView!
    
    // The banner views.
    @IBOutlet weak var bannerOuterView: UIView!
    @IBOutlet weak var closeBannerButton : UIButton!
    @IBOutlet weak var bannerView: GADBannerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupScreen()
        setupDisplayTimer()
        setupSwipeGestures()

        bannerOuterView.isHidden = true
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Register to receive notifications
        NotificationCenter.default.addObserver(self, selector: #selector(DailyTabVC.locationDataRefreshed), name: GlobalConstants.locationRefreshFinishedKey, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(DailyTabVC.weatherDataRefreshed), name: GlobalConstants.weatherRefreshFinishedKey, object: nil)

        // Ease in the weather image view for effect
        self.weatherImage.alpha = 0.2
        UIView.animate(withDuration: 0.6, delay: 0.0, options: UIViewAnimationOptions.curveEaseIn, animations: {
            self.weatherImage.alpha = 1
            }, completion: nil)

        // Ease in the two pods
        self.weatherSummaryView.alpha = 0.0
        UIView.animate(withDuration: 1.2, delay: 0.5, options: UIViewAnimationOptions.curveEaseIn, animations: {
            self.weatherSummaryView.alpha = CGFloat(GlobalConstants.DisplayViewAlpha)
        }, completion: nil)
        
        self.dailyWeatherTableView.alpha = 0.0
        UIView.animate(withDuration: 1.2, delay: 0.5, options: UIViewAnimationOptions.curveEaseIn, animations: {
            self.dailyWeatherTableView.alpha = CGFloat(GlobalConstants.DisplayViewAlpha)
        }, completion: nil)

        setupColourScheme()
        populateDailyWeatherDetails()
        
        if AppSettings.ShowBannerAds {
            // For this screen we only want to randomly show the banner ad, so thats its an
            // occasional annoyance
            
            bannerOuterView.isHidden = true
            let rand = Int(arc4random_uniform(4))
            if (rand % GlobalConstants.BannerAdDisplayFrequency == 0) {
                loadBannerAd()
                bannerOuterView.isHidden = false
            }
        }

    }

    override func viewDidDisappear(_ animated: Bool) {

    }

    
    func setupScreen () {
        
        closeBannerButton.isHidden = true  // Will only show once banner ad loaded
        
        weatherSummaryView.layer.cornerRadius = 10.0
        weatherSummaryView.clipsToBounds = true

        dailyWeatherTableView.alpha = CGFloat(GlobalConstants.DisplayViewAlpha)
        dailyWeatherTableView.layer.cornerRadius = 10.0
        dailyWeatherTableView.clipsToBounds = true
        
        updateLocationDetailsOnScreen()

    }

    // Display screen functions
    func setupDisplayTimer() {
        
        infoLabelTimerCount = 0
        
        _ = Timer.scheduledTimer(timeInterval: 4.0, target: self, selector: #selector(updateWeatherDetailsOnScreen), userInfo: nil, repeats: true)
        
    }
    
    func setupColourScheme() {

        // Setup pods and text colour accordingly
        
        let colourScheme = Utility.setupColourScheme()
        
        let textColourScheme = colourScheme.textColourScheme
        let podColourScheme = colourScheme.podColourScheme

        weatherSummaryView.backgroundColor = podColourScheme
        dailyWeatherTableView.backgroundColor = podColourScheme

        
        // Labels
        nextDaysSummary.textColor = textColourScheme
        locationLabel.textColor = textColourScheme
        infoLabel.textColor = textColourScheme
        
        weatherSummaryView.alpha = CGFloat(GlobalConstants.DisplayViewAlpha)

    }
    
    func loadBannerAd() {
    
        bannerView.delegate = self
        
        print("Google Mobile Ads SDK version: \(GADRequest.sdkVersion())")
        bannerView.adUnitID = AppSettings.AdMobBannerID
        bannerView.rootViewController = self
        
        let request = GADRequest()
        if AppSettings.BannerAdsTestMode {
            // Display test banner ads in the simulator
           // request.testDevices = [AppSettings.AdTestDeviceID]
            request.testDevices = [GlobalConstants.BannerAdTestIDs.Simulator,
                                   GlobalConstants.BannerAdTestIDs.IPhone6]

        }

        // Make ads more location specific
        if let currentLocation = weatherLocation.currentLocation {
            request.setLocationWithLatitude(CGFloat(currentLocation.coordinate.latitude),
                                            longitude: CGFloat(currentLocation.coordinate.longitude),
                                            accuracy: CGFloat(currentLocation.horizontalAccuracy))
        }
        bannerView.load(request)

    }
    
    
    func populateDailyWeatherDetails() {
        
        if let tmpDailyWeather = dailyWeather {
            
            // Min Temp, Max Temp, Sunrise and Sunset we can get from the 'daily' figures
            let todayArray = dailyWeather?.currentBreakdown
            let dayArray = dailyWeather?.dailyBreakdown.dailyStats
            
            for days in dayArray! {
                
                // If today, populate the relevant fields
                let sameDay = Utility.areDatesSameDay(date1: (todayArray?.dateAndTimeStamp!)!, date2: days.dateAndTimeStamp!)
                
                if sameDay {
                    // TODO:  Handle if sunrise and sunset timestamps are nil (polar regions)
                    sunriseTimeStamp = days.sunriseTimeStamp as NSDate?
                    sunsetTimeStamp = days.sunsetTimeStamp as NSDate?                    
                }
                
                // We want tomorrows sunrise and sunset times as well
                
                let tomorrow = Utility.isTomorrow(date1: days.dateAndTimeStamp!)
                
                if tomorrow {
                    tomorrowSunriseTimeStamp = days.sunriseTimeStamp as NSDate?
                    tomorrowSunsetTimeStamp = days.sunsetTimeStamp as NSDate?
                }
            }
            
            // If weather alert, get the alert start and end times
            if (dailyWeather?.weatherAlert == true) {

                getWeatherAlertStartAndEndTimes()
            }

            var isItDayOrNight = "NIGHT"
            var timeNow = NSDate()
            timeNow = Utility.getTimeInWeatherTimezone(dateAndTime: timeNow)

            if isDayTime(dateTime: timeNow) {
                isItDayOrNight = "DAY"
            }

            // Set the variable at the parent view controller level
            delegate?.setupDayOrNightIndicator(dayOrNight: isItDayOrNight)
            
            // Populate the weather image
            let icon = tmpDailyWeather.currentBreakdown.icon
            let enumVal = GlobalConstants.Images.ServiceIcon(rawValue: icon!)
            let nextDaysSummaryString = tmpDailyWeather.dailyBreakdown.summary
            
            var backgroundImageName = ""
            
            if AppSettings.SpecialThemedBackgroundsForEvents {
                // Get a special background if its a 'themed day (e.g Chrisrmas etc)
                backgroundImageName = Utility.getSpecialDayWeatherImage(dayOrNight: isItDayOrNight)
            }
            
            if backgroundImageName == "" {
                backgroundImageName = Utility.getWeatherImage(serviceIcon: (enumVal?.rawValue)!, dayOrNight: isItDayOrNight)
            }
            
            if !(String(backgroundImageName).isEmpty) {
                weatherImage.image = UIImage(named: backgroundImageName)!
            }
            
            if nextDaysSummaryString?.isEmpty != nil {
                nextDaysSummary.text = nextDaysSummaryString
            }
            
            dailyWeatherTableView.reloadData()
        }
    }
    
    func updateWeatherDetailsOnScreen() {
        
        infoLabelTimerCount += 1
        
//        lastUpdatedTime = reformatLastUpdatedTimeIfNeeded(lastUpdatedDate: lastUpdatedTimeStamp!)
        
        // Do a mod of 4, so that we can display the 'Last Updated' time slightly longer than
        let mod = infoLabelTimerCount % 2
        switch (mod) {
        case 0:
             updateMinorLocationDetailsOnScreen()
        case 1:
            updateAltitudeDetailsOnScreen()
        default:
            infoLabel.text = ""
        }
        
    }
    
    func isDayTime (dateTime : NSDate) -> Bool {
        
        var retVal : Bool!
        
        // Return if no timestaps (if near polar regions)
        if (sunriseTimeStamp == nil || sunsetTimeStamp == nil) {
            return true
        }

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

    func getWeatherAlertStartAndEndTimes() {
        
        // Cater for more than 1 alert description
        
        let alertCount = dailyWeather.weatherAlerts.count
        
        if alertCount > 0 {
            for i in 0...alertCount - 1 {
                
                weatherAlertStartTime = dailyWeather.weatherAlerts[i].alertDateAndTimeStamp
                weatherAlertEndTime = dailyWeather.weatherAlerts[i].alertExpiryDateAndTimeStamp
                
            }
        }
    }
    
    /// Force the text in a UITextView to always center itself.
    func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutableRawPointer) {
        let textView = object as! UITextView
        var topCorrect = (textView.bounds.size.height - textView.contentSize.height * textView.zoomScale) / 2
        topCorrect = topCorrect < 0.0 ? 0.0 : topCorrect;
        textView.contentInset.top = topCorrect
    }
    
    // MARK:  Swipe Gesture functions
    
    func setupSwipeGestures () {
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(DailyTabVC.swiped(gesture:)))
        swipeDown.direction = .down
        self.view.addGestureRecognizer(swipeDown)
        
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(DailyTabVC.swiped(gesture:)))
        swipeUp.direction = .up
        self.view.addGestureRecognizer(swipeUp)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(DailyTabVC.swiped(gesture:)))
        swipeRight.direction = .right
        self.view.addGestureRecognizer(swipeRight)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(DailyTabVC.swiped(gesture:)))
        swipeLeft.direction = .left
        self.view.addGestureRecognizer(swipeLeft)
    }
    
    func swiped(gesture: UIGestureRecognizer)
    {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer
        {
            switch swipeGesture.direction
            {
                
            case UISwipeGestureRecognizerDirection.right:
                print("Swiped Right")
                
            case UISwipeGestureRecognizerDirection.left:
                print("Swiped Left")
                delegate?.switchViewControllers()
                
            case UISwipeGestureRecognizerDirection.up:
                print("Swiped Up")
                
            case UISwipeGestureRecognizerDirection.down:
                print("Swiped Down")
                
            default:
                break
            }
        }
    }
    
    // MARK:  Button methods
    @IBAction func closeBannerAdButtonPressed(_ sender: AnyObject) {
        
        // Dismiss banner ad view
        bannerOuterView.isHidden = true
    }

    // MARK: Location methods (TODO:  this is identical to TodayTab)
    
    func updateLocationDetailsOnScreen() {
        
        // Ensure that weatherLocation has a value before setting
        guard let loc = weatherLocation else {
            locationLabel.text = GlobalConstants.LocationNotFoundString
            print("Location name not found")
            //
            return
        }
        locationLabel.text = getFormattedLocation(locationObj: loc)
        infoLabel.text = getFormattedMinorLocation(locationObj: loc)

    }

    func updateMinorLocationDetailsOnScreen() {
        
        // Ensure that weatherLocation has a value before setting
        guard let loc = weatherLocation else {
            locationLabel.text = GlobalConstants.LocationNotFoundString
            print("Location name not found")
            //
            return
        }
        infoLabel.text = getFormattedMinorLocation(locationObj: loc)
        
    }
    
    func updateAltitudeDetailsOnScreen() {
        
        // Ensure that weatherLocation has a value before setting
        guard let altitude = weatherLocation.currentAltitude else {
            infoLabel.text = ""
            return
        }
        
        // Altitude will be in meteres
        let units = " meters"
        infoLabel.text = String(Int(altitude)) + units + " above sea level"
        
    }
    
    func getFormattedLocation(locationObj: Location) -> String {
        
        var returnString = ""
        
        if locationObj.currentCity != nil && locationObj.currentCountry != nil {
            returnString = locationObj.currentCity! + ", " + locationObj.currentCountry!
        }
        else if locationObj.currentCity != nil && locationObj.currentCountryCode != nil {
            returnString = locationObj.currentCity! + ", " + locationObj.currentCountryCode!
        }
        else if locationObj.currentCity != nil {
            returnString = locationObj.currentCity!
        }
        else if locationObj.currentStreet != nil && locationObj.currentCountry != nil {
            returnString = locationObj.currentStreet! + ", " + locationObj.currentCountry!
        }
            // Check if location has a name before giving up
        else if locationObj.name != nil {
            returnString = locationObj.name!
        }
        else {
            returnString = GlobalConstants.LocationNotFoundString
        }
        
        return returnString
    }

    func getFormattedMinorLocation(locationObj: Location) -> String {
        
        var returnString = ""
        
        if locationObj.currentStreet != nil {
            returnString = locationObj.currentStreet!
        }
        else if locationObj.currentPostcode != nil {
            returnString = locationObj.currentPostcode!
        }
        else {
            returnString = GlobalConstants.LocationNotFoundString
        }
        
        return returnString
    }
    
    // MARK:  Notification complete methods
    
    func locationDataRefreshed() {
        print("Location Data Refreshed - DailyTab")
        
        // NOTE:  This will be called on a background thread
        
        // The phone could have moved location since the last refresh.
        // Get the updated location details after it has been refreshed.
        
        DispatchQueue.main.async {
            self.weatherLocation = nil
            self.weatherLocation = self.delegate?.returnRefreshedLocationDetails()
            self.updateLocationDetailsOnScreen()
        }
        
        // NOTE:  We want to keep listening for notifications incase a change is made in
        // the Settings screen so they have not been removed
        
    }

    func weatherDataRefreshed() {
        print("Weather Data Refreshed - DailyTab")

        dailyWeather = delegate?.returnRefreshedWeatherDetails()

        NotificationCenter.default.removeObserver(self, name: GlobalConstants.weatherRefreshFinishedKey, object: nil);

        // NOTE:  This will be run on a background thread
        DispatchQueue.main.async {
            
            self.setupColourScheme()
            self.populateDailyWeatherDetails()
            
            // Scroll to the top of the table view
            self.dailyWeatherTableView.contentOffset = CGPoint(x: 0, y: 0 - self.dailyWeatherTableView.contentInset.top)

        }
    }
    
    // MARK:  GADBannerViewDelegate methods
    
    // Tells the delegate an ad request loaded an ad.
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        print("Ad has been received")
        
        // show the delete ad button
        closeBannerButton.isHidden = false
    }
}

// MARK: UITableViewDataSource

extension DailyTabVC : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        // We dont want 'today' in this list so -1
        return dailyWeather.dailyBreakdown.dailyStats.count - 1
    }
  
    private func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return tableView.rowHeight-2
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // We dont want 'today' in this list so +1
        let dayWeather = dailyWeather.dailyBreakdown.dailyStats[indexPath.row + 1]
        let degreesSymbol = GlobalConstants.degreesSymbol + dayWeather.temperatureUnits!
        
        let cell:DailyWeatherCell = self.dailyWeatherTableView.dequeueReusableCell(withIdentifier: "DailyWeatherCellID") as! DailyWeatherCell
        
        cell.weatherAlertIcon.isHidden = true
        cell.windyLabel.isHidden = true
        cell.windyIcon.isHidden = true
        
        cell.dateLabel.text = (dayWeather.dateAndTimeStamp?.shortDayOfTheWeek())! + " " + (dayWeather.dateAndTimeStamp?.getDateSuffix())!

        cell.sunriseLabel.text = dayWeather.sunriseTimeStamp?.shortTimeString()
        cell.sunsetLabel.text = dayWeather.sunsetTimeStamp?.shortTimeString()
        cell.summaryLabel.text = dayWeather.summary
        cell.minTempLabel.text = String(Int(round(dayWeather.temperatureMin!))) + degreesSymbol
        cell.maxTempLabel.text = String(Int(round(dayWeather.temperatureMax!))) + degreesSymbol
        
        // Weather alert icon.
        // Only show if in alert time range
        
        if (dailyWeather?.weatherAlert == true) {
        
            let tomorrow = dayWeather.dateAndTimeStamp?.add(minutes: 720)
            let today = dayWeather.dateAndTimeStamp
            
            // Check to see if the alert start of end time is in day dange also
            if (dayWeather.dateAndTimeStamp?.isBetweeen(date: weatherAlertEndTime!,
                                                        andDate: weatherAlertStartTime!))!
                ||
                (weatherAlertStartTime?.isBetweeen(date: tomorrow! as NSDate, andDate: today!))!
                ||
                (weatherAlertEndTime?.isBetweeen(date: tomorrow! as NSDate, andDate: today!))!
            {
                cell.weatherAlertIcon.isHidden = false
            }
            else {
                cell.weatherAlertIcon.isHidden = true
            }
        }
        else {
            cell.weatherAlertIcon.isHidden = true
        }
        
        // Windy icon
        if (Int(dayWeather.windSpeed!) > GlobalConstants.WindStrengthThreshold) {
            let windSpeedUnits = dayWeather.windSpeedUnits!
            var currentWindspeed = ""

            currentWindspeed = String(Int(dayWeather.windSpeed!)) + " " + windSpeedUnits
            
            // TODO: Show and remove icon instead of hiding (to preserve spacing)
            cell.windyLabel.isHidden = false
            cell.windyIcon.isHidden = false
            
            cell.windyLabel.text = currentWindspeed
        }
        else {
            cell.windyLabel.isHidden = true
            cell.windyIcon.isHidden = true
        }

        let rainProbabilityForDay = Int(round(dayWeather.precipProbability!*100))
        
        if (rainProbabilityForDay > GlobalConstants.RainIconReportThresholdPercent) {
            cell.rainIcon.isHidden = false
            cell.rainProbabilityLabel.text = String(rainProbabilityForDay) + "%"
        }
        else {
            cell.rainIcon.isHidden = true
            cell.rainProbabilityLabel.text = ""
        }
        
        let icon = dayWeather.icon
        let iconName = Utility.getWeatherIcon(serviceIcon: icon!, dayOrNight: "", weatherStats: dayWeather)

        if iconName != "" {
            cell.dailyWeatherIcon.image = UIImage(named: iconName)!
        }
        
        // Get the length of sunlight in the day
        if (dayWeather.sunriseTimeStamp != nil && dayWeather.sunsetTimeStamp != nil) {
            let dayDurationSeconds = Int(Utility.secondsBetween(date1: dayWeather.sunsetTimeStamp!, date2: dayWeather.sunriseTimeStamp!))
            let (h,m,_) = Utility.secondsToHoursMinutesSeconds(seconds: dayDurationSeconds)
            let hoursAndMinutes = String(h) + "h " + String(m) + "m"
            
            cell.sunriseIcon.isHidden = false
            cell.sunsetIcon.isHidden = false
            cell.dayDurationLabel.text = hoursAndMinutes
        }
        else {
            
            // Sometimes we get no sunrise or sunset data (north and south pole places)
            // Hide icons if so
            
            cell.sunriseIcon.isHidden = true
            cell.sunsetIcon.isHidden = true
            cell.dayDurationLabel.text = ""
        }
        
        // Setup text colour according to colour scheme
        
        let colourScheme = Utility.setupColourScheme()
        let textColourScheme = colourScheme.textColourScheme
        
        cell.dateLabel.textColor = textColourScheme
        cell.sunriseLabel.textColor = textColourScheme
        cell.sunsetLabel.textColor = textColourScheme
        cell.dayDurationLabel.textColor = textColourScheme
        cell.summaryLabel.textColor = textColourScheme
        cell.minTempTitle.textColor = textColourScheme
        cell.maxTempTitle.textColor = textColourScheme
        cell.windyLabel.textColor = textColourScheme
        cell.rainProbabilityLabel.textColor = textColourScheme
        
        // Populate with the correct rain icon scheme
        
        if (dayWeather.precipType == GlobalConstants.PrecipitationType.Rain) {
            let rainIconImage = Utility.getWeatherIcon(serviceIcon: "UMBRELLA", dayOrNight: "", weatherStats: dayWeather)
            cell.rainIcon.image = UIImage(named: rainIconImage)!
        }
        else if (dayWeather.precipType == GlobalConstants.PrecipitationType.Sleet) {
            let rainIconImage = Utility.getWeatherIcon(serviceIcon: "SNOWFLAKE", dayOrNight: "", weatherStats: dayWeather)
            cell.rainIcon.image = UIImage(named: rainIconImage)!
        }
        else if (dayWeather.precipType == GlobalConstants.PrecipitationType.Snow) {
            let rainIconImage = Utility.getWeatherIcon(serviceIcon: "SNOWFLAKE", dayOrNight: "", weatherStats: dayWeather)
            cell.rainIcon.image = UIImage(named: rainIconImage)!
        }
        else {
            // Default
            let rainIconImage = Utility.getWeatherIcon(serviceIcon: "UMBRELLA", dayOrNight: "", weatherStats: dayWeather)
            cell.rainIcon.image = UIImage(named: rainIconImage)!
        }

        // Populate with the correct windy icon scheme
        let windyIconImage = Utility.getWeatherIcon(serviceIcon: "WINDY", dayOrNight: "", weatherStats: dayWeather)
        cell.windyIcon.image = UIImage(named: windyIconImage)!

        // Populate with the correct sunrise/sunset icon scheme
        let sunriseIconImage = Utility.getWeatherIcon(serviceIcon: "SUNRISE", dayOrNight: "", weatherStats: dayWeather)
        cell.sunriseIcon.image = UIImage(named: sunriseIconImage)!

        let sunsetIconImage = Utility.getWeatherIcon(serviceIcon: "SUNSET", dayOrNight: "", weatherStats: dayWeather)
        cell.sunsetIcon.image = UIImage(named: sunsetIconImage)!
        
        
        // Alternate the shading of each table view cell
        if (colourScheme.type == GlobalConstants.ColourScheme.Dark) {
            if (indexPath.row % 2 == 0) {
                cell.backgroundColor = GlobalConstants.TableViewAlternateShadingDayDarkTheme.Darker
            }
            else {
                cell.backgroundColor = GlobalConstants.TableViewAlternateShadingDayDarkTheme.Lighter
            }
        }
        else {
            if (indexPath.row % 2 == 0) {
                cell.backgroundColor = GlobalConstants.TableViewAlternateShading.Darker
            }
            else {
                cell.backgroundColor = UIColor.white // GlobalConstants.TableViewAlternateShading.Lightest
            }
        }
  
        return cell
    }

}


// MARK: UITableViewDelegate
extension DailyTabVC : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

//        var dailyWeather = super.weather?.dailyBreakdown.dailyStats[indexPath.row]
//        print (super.weather)
    }

    private func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: IndexPath) -> Bool {
        return true
    }
    
    private func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {

    }
}


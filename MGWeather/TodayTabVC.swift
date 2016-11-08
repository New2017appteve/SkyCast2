//
//  TodayTabVC.swift
//  Weather
//
//  Created by Mark Gumbs on 28/06/2016.
//  Copyright © 2016 britishairways. All rights reserved.
//

import UIKit

protocol TodayTabVCDelegate
{
    // Following methods are part of ParentWeatherVC
    
    func refreshWeatherDataFromService()
    func refreshWeatherDataFromService2(completionHandler: @escaping GlobalConstants.CompletionHandlerType)
    func getAndSetLocation()
    func switchViewControllers()
    func returnRefreshedLocationDetails() -> Location
    func returnRefreshedWeatherDetails() -> Weather
}

class TodayTabVC: UIViewController, UITextViewDelegate {
    
    var delegate:TodayTabVCDelegate?
    var dayOrNightColourSetting: String?
    
    var sunriseTimeStamp: NSDate?
    var sunsetTimeStamp: NSDate?
    var tomorrowSunriseTimeStamp: NSDate?
    var tomorrowSunsetTimeStamp: NSDate?
    var lastUpdatedTime = ""
    
    var infoLabelTimerCount = 0
    
    // MARK: Outlets
    
    @IBOutlet weak var outerScreenView : UIView!
    @IBOutlet weak var weatherImageOuterView : UIView!
    
    @IBOutlet weak var weatherLabel : UILabel!
    @IBOutlet weak var weatherImage : UIImageView!
    @IBOutlet weak var lastUpdatedLabel : UILabel!

    @IBOutlet weak var infoView : UIView!
    @IBOutlet weak var infoLabel : UILabel!
    
    @IBOutlet weak var currentTempView : UIView!
    @IBOutlet weak var currentTempDetailView : UIView!
    @IBOutlet weak var currentTemp : UILabel!
    @IBOutlet weak var windspeed : UILabel!
    @IBOutlet weak var feelsLikeTemp : UILabel!
    @IBOutlet weak var currentWeatherIcon : UIImageView!

    @IBOutlet weak var currentSummary : UILabel!

    @IBOutlet weak var weatherDetailOuterView : UIView!
    @IBOutlet weak var weatherDetailView : UIView!
    @IBOutlet weak var todaySummary : UILabel!
    @IBOutlet weak var todayHighLowTemp : UILabel!
    @IBOutlet weak var cloudCover : UILabel!
    @IBOutlet weak var rainProbability : UILabel!
    
    @IBOutlet weak var sunriseStackView : UIStackView!
    @IBOutlet weak var sunriseIcon : UIImageView!
    @IBOutlet weak var sunrise : UILabel!
    @IBOutlet weak var sunsetStackView : UIStackView!
    @IBOutlet weak var sunsetIcon : UIImageView!
    @IBOutlet weak var sunset : UILabel!
    @IBOutlet weak var humidity : UILabel!
    @IBOutlet weak var weatherAlertTitle : UILabel!
    @IBOutlet weak var weatherAlertButton : UIButton!
    @IBOutlet weak var poweredByDarkSkyText : UITextView!
    
    private let cellId = "cellId"
    
    @IBOutlet weak var hourlyWeatherTableView : UITableView!
    @IBOutlet weak var hourlyWeatherTableViewHeight : NSLayoutConstraint!
    
    @IBOutlet weak var dailyWeather : Weather!
    @IBOutlet weak var weatherLocation : Location!
    
    enum Menu: String {
        case ShowSettings = "App Settings"
        case ShowAbout = "About"
    }
    
    var tableView : UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        NotificationCenter.default.addObserver(self, selector: #selector(TodayTabVC.networkStatusChanged(_:)), name: NSNotification.Name(rawValue: ReachabilityStatusChangedNotification), object: nil)

        setupDisplayTimer()
        setupSwipeGestures()
        setupScreen ()
        populateTodayWeatherDetails()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Register to receive notifications
        NotificationCenter.default.addObserver(self, selector: #selector(TodayTabVC.weatherDataRefreshed), name: GlobalConstants.weatherRefreshFinishedKey, object: nil)
        
        // Register to receive notification
        NotificationCenter.default.addObserver(self, selector: #selector(TodayTabVC.locationDataRefreshed), name: GlobalConstants.locationRefreshFinishedKey, object: nil)
        
        
        // Ease in the weather background for effect
        self.weatherImage.alpha = 0.2
        UIView.animate(withDuration: 0.6, delay: 0.0, options: UIViewAnimationOptions.curveEaseIn, animations: {
            self.weatherImage.alpha = 1
        }, completion: nil)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: GlobalConstants.weatherRefreshFinishedKey, object: nil);
        NotificationCenter.default.removeObserver(self, name: GlobalConstants.locationRefreshFinishedKey, object: nil);
    }

    
    func createHorizontalTableView() {
        
        let frame = CGRect(x: 0, y: view.bounds.height/8, width: view.bounds.width/6, height: view.bounds.height/8)
        
        tableView = UITableView(frame: frame)
        tableView.delegate = self
        tableView.dataSource = self
        
        if tableView.responds(to: (#selector(getter: UITableViewCell.separatorInset))) {
            tableView.separatorInset = UIEdgeInsets.zero;
        }
        
        if tableView.responds(to:(#selector(getter: UIView.layoutMargins))) {
            tableView.layoutMargins = UIEdgeInsets.zero;
        }
        
        tableView.transform = CGAffineTransform(rotationAngle: -CGFloat(M_PI_2))

        view.addSubview(tableView)
}
    
    
    func setupScreen () {
                      
        // Make the credit label clickable
        let urlString = "Powered By Dark Sky API"
        let attributedString = NSMutableAttributedString(string: urlString)
        attributedString.addAttribute(NSLinkAttributeName, value: GlobalConstants.DarkSkyURL, range: NSRange(location: 0, length: 23))
        
//        attributedString.addAttribute(NSFontAttributeName,
//                                     value: UIFont(
//                                        name: "HelveticaNeue-UltraLight",
//                                        size: 10.0),
//                                     range: NSRange(
//                                        location: 0,
//                                        length:23))
        
        poweredByDarkSkyText.attributedText = attributedString
    
        let userDefaults = UserDefaults.standard
        dayOrNightColourSetting = userDefaults.string(forKey: GlobalConstants.Defaults.SavedDayOrNightColourSetting)
        
        currentTempDetailView.alpha = CGFloat(GlobalConstants.DisplayViewAlpha)
        weatherDetailOuterView.alpha = CGFloat(GlobalConstants.DisplayViewAlpha)
        infoView.alpha = CGFloat(GlobalConstants.DisplayViewAlpha)
        
        // Make round corners for the outerviews
        currentTempDetailView.layer.cornerRadius = 10.0
        currentTempDetailView.clipsToBounds = true
        
        infoView.layer.cornerRadius = 5.0
        infoView.clipsToBounds = true
        
        weatherDetailOuterView.layer.cornerRadius = 10.0
        weatherDetailOuterView.clipsToBounds = true
        
        sunriseIcon.layer.cornerRadius = 2.0
        sunriseIcon.clipsToBounds = true
        sunsetIcon.layer.cornerRadius = 2.0
        sunsetIcon.clipsToBounds = true
        
        if dayOrNightColourSetting == "ON" {
            sunriseIcon.backgroundColor = GlobalConstants.TableViewAlternateShadingDay.Lighter
            sunsetIcon.backgroundColor = GlobalConstants.TableViewAlternateShadingNight.Lighter
        }
        else {
            sunriseIcon.backgroundColor = UIColor.clear
            sunsetIcon.backgroundColor = UIColor.clear
        }
        
 //       updateLocationDetailsOnScreen()
    }
    
    func updateLocationDetailsOnScreen() {
        
        // Ensure that weatherLocation has a value before setting
        guard let loc = weatherLocation else {
            infoLabel.text = "Location name not found"
            print("Location name not found")
            //
            return
        }
        infoLabel.text = getFormattedLocation(locationObj: loc)

    }
    
    
    func getFormattedLocation(locationObj: Location) -> String {
        
        var returnString = ""
        
        if locationObj.currentStreet != nil && locationObj.currentPostcode != nil {
            returnString = locationObj.currentStreet! + ", " + locationObj.currentPostcode!
        }
        else if locationObj.currentCity != nil && locationObj.currentPostcode != nil {
            returnString = locationObj.currentCity! + ", " + locationObj.currentPostcode!
        }
        else if locationObj.currentCity != nil && locationObj.currentStreet != nil {
            returnString = locationObj.currentStreet! + ", " + locationObj.currentCity!
        }
        else if locationObj.currentCity != nil {
            returnString = locationObj.currentCity!
        }
        else if locationObj.currentStreet != nil {
            returnString = locationObj.currentStreet!
        }
        else if locationObj.currentPostcode != nil {
            returnString = locationObj.currentPostcode!
        }
        else {
            returnString = "Location name not found"
        }

        return returnString
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)

        if (segue.identifier == "infoScreenSegue") {
            
            var weatherAlertDescription = ""
            
            // If weather alert, enable the button so user can bring up alert text view
            
            //weatherAlertDescription = "A storm is approaching the south west of the country.  Amber alert has been raised"
            
            // Cater for more than 1 alert description
            
            let alertCount = dailyWeather.weatherAlerts.count
            
            for i in 0...alertCount - 1 {
                
                let alertTime = dailyWeather.weatherAlerts[i].alertDateAndTimeStamp
                let alertExpiry = dailyWeather.weatherAlerts[i].alertExpiryDateAndTimeStamp
                
                let alertTimeDescription = (alertTime?.dayOfTheWeek())! + " " + (alertTime?.getDateSuffix())! + " to " + (alertExpiry?.dayOfTheWeek())! + " " + (alertExpiry?.getDateSuffix())!
                
                weatherAlertDescription = alertTimeDescription + "\r\n\n" + dailyWeather.weatherAlerts[i].alertDescription! + "\r\n\n"
            }
            
            let vc:InfoPopupViewController = segue.destination as! InfoPopupViewController
            vc.informationString = weatherAlertDescription
            
        }
        
    }

    func setupDisplayTimer() {
    
        infoLabelTimerCount = 0
        
        _ = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(updateInfoLabel), userInfo: nil, repeats: true)

    }
    
    func updateInfoLabel() {
        
        infoLabelTimerCount += 1
        
        // Do a mod of 4, so that we can display the 'Last Updated' time slightly longer than
        let mod = infoLabelTimerCount % 4
        switch (mod) {
        case 0:
            infoLabel.text = "Pull to refresh"
        case 1:
            infoLabel.text = "Last Updated: " + lastUpdatedTime
        case 2:
            infoLabel.text = "Last Updated: " + lastUpdatedTime
        case 3:
            
            updateLocationDetailsOnScreen()
//            guard let loc = weatherLocation else {
//                infoLabel.text = "Location name not found"
//                print("Location name not found")
//                //
//                return
//            }
//
//            infoLabel.text = getFormattedLocation(locationObj: loc)
        default:
            infoLabel.text = ""
        }
        
    }
    
    // MARK:  Swipe Gesture functions
    
    func setupSwipeGestures () {
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(TodayTabVC.swiped(gesture:)))
        swipeDown.direction = .down
        self.view.addGestureRecognizer(swipeDown)
        
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(TodayTabVC.swiped(gesture:)))
        swipeUp.direction = .up
        self.view.addGestureRecognizer(swipeUp)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(TodayTabVC.swiped(gesture:)))
        swipeRight.direction = .right
        self.view.addGestureRecognizer(swipeRight)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(TodayTabVC.swiped(gesture:)))
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
                delegate?.switchViewControllers()
                
            case UISwipeGestureRecognizerDirection.left:
                print("Swiped Left")
                
            case UISwipeGestureRecognizerDirection.up:
                print("Swiped Up")
                
            case UISwipeGestureRecognizerDirection.down:
                print("Swiped Down")
                
                Reach().monitorReachabilityChanges()
                
                var connected = false
                let status = Reach().connectionStatus()
                switch status {
                case .unknown, .offline:
                    print("Not connected")
                case .online(.wwan):
                    print("Connected via WWAN")
                    connected = true
                case .online(.wiFi):
                    print("Connected via WiFi")
                    connected = true
                }

                if connected
                {
                    refreshDataAfterPullToRefresh()
                    // TODO:  May want to retrieve location data incase user has moved
                }
                else
                {
                    // Internet Connection not Available!
                    Utility.showMessage(titleString: "Error", messageString: "You are not connected to the internet.  Please check your cellular or wi-fi settings" )
                }

            default:
                break
            }
        }
    }
    
 
    func removeSwipeGestures() {
        
        if self.view.gestureRecognizers != nil {
            for gesture in view.gestureRecognizers! {
                if let recognizer = gesture as? UISwipeGestureRecognizer {
                    view.removeGestureRecognizer(recognizer)
                }
            }
        }
    }
   
    
    func disableScreen() {
        self.outerScreenView.isUserInteractionEnabled = false
        removeSwipeGestures()
    }
    
    func enableScreen() {
        self.outerScreenView.isUserInteractionEnabled = true
        setupSwipeGestures ()
    }
    
    
    func refreshDataAfterSettingChange() {
        
        refreshDataAfterPullToRefresh()
    }
    
    func refreshDataAfterPullToRefresh() {

        disableScreen()
        
        // Make a toast to say data is refreshing
        self.view.makeToast("Refreshing weather data", duration: 1.0, position: .bottom)
        self.view.makeToastActivity(.center)
        
        let userDefaults = UserDefaults.standard
        dayOrNightColourSetting = userDefaults.string(forKey: GlobalConstants.Defaults.SavedDayOrNightColourSetting)
        
        self.delegate?.getAndSetLocation()
        self.delegate?.refreshWeatherDataFromService2
            { (result) -> Void in
                switch (result) {
                    
                // A refreshed weather object is returned, pass this back into dailyWeather
                case .Success(let refreshedWeatherData):
                    
                    self.dailyWeather = refreshedWeatherData as! Weather
                    
                    // Refresh the screen and table view
                    DispatchQueue.main.async {

                        self.populateTodayWeatherDetails()
                        self.hourlyWeatherTableView.reloadData()
                        self.enableScreen()
                        
                        self.view.hideToastActivity()
                        
                        // Scroll to the top of the table view
                        self.hourlyWeatherTableView.contentOffset = CGPoint(x: 0, y: 0 - self.hourlyWeatherTableView.contentInset.top)
                    }
                    
                    break;
                case .Failure(let error):
                    let messageText = "Weather data cannot be retrieved at this moment.  Please try again later"
                    Utility.showMessage(titleString: "Error", messageString: messageText )

                    self.enableScreen()
                    break;
                }
        }

    }
    
    func textView(textView: UITextView, shouldInteractWithURL URL: NSURL, inRange characterRange: NSRange) -> Bool {
        UIApplication.shared.openURL(URL as URL)
        return false
    }
    
    func getLastUpdatedTime() -> String {
        
        let today = NSDate()
        let timeNow = today.shortTimeString()
        
        return timeNow

    }
    
    func populateTodayWeatherDetails() {

        // Rather than force unwrapping, use conditional let
        if let todayArray = dailyWeather?.currentBreakdown {
            
            lastUpdatedTime  = getLastUpdatedTime()

            // NOTE:  Better to use the Minute summary at this level

            currentTemp.text = String(Int(round(todayArray.temperature! as Float))) + GlobalConstants.degreesSymbol
            feelsLikeTemp.text = "Feels Like: " + String(Int(round(todayArray.apparentTemperature! as Float))) + GlobalConstants.degreesSymbol
            windspeed.text = String(Int(round(todayArray.windSpeed! * GlobalConstants.MetersPerSecondToMph))) + " mph"
            rainProbability.text = String(Int(round(todayArray.precipProbability!*100))) + "%"
            cloudCover.text = String(Int(round(todayArray.cloudCover!*100))) + "%"
            humidity.text = String(Int(round(todayArray.humidity!*100))) + "%"
            
            // Min Temp, Max Temp, Sunrise and Sunset we can get from the 'daily' figures
            
            let dayArray = dailyWeather?.dailyBreakdown.dailyStats
            
            for days in dayArray! {
                
                // If today, populate the relevant fields
                let sameDay = areDatesSameDay(date1: todayArray.dateAndTimeStamp!, date2: days.dateAndTimeStamp!)
                
                if sameDay {
                    let minTempString = String(Int(round(days.temperatureMin!))) + GlobalConstants.degreesSymbol
                    let maxTempString = String(Int(round(days.temperatureMax!))) + GlobalConstants.degreesSymbol
                    
                    sunrise.text = String(days.sunriseTimeStamp!.shortTimeString())
                    sunset.text = String(days.sunsetTimeStamp!.shortTimeString())
                    
                    sunriseTimeStamp = days.sunriseTimeStamp as NSDate?
                    sunsetTimeStamp = days.sunsetTimeStamp as NSDate?
                    
                    todayHighLowTemp.text = maxTempString + " / " + minTempString
                }
                
                // We want tomorrows sunrise and sunset times as well
                
                let tomorrow = isTomorrow(date1: days.dateAndTimeStamp!)
                
                if tomorrow {
                    tomorrowSunriseTimeStamp = days.sunriseTimeStamp as NSDate?
                    tomorrowSunsetTimeStamp = days.sunsetTimeStamp as NSDate?
                }
            }
            
            let hourlyBreakdown = dailyWeather?.hourBreakdown
            todaySummary.text = hourlyBreakdown?.summary
            
            let minuteBreakdown = dailyWeather?.minuteBreakdown
            currentSummary.text = minuteBreakdown?.summary
            
            // Populate the weather image
            
            let icon = todayArray.icon
            let enumVal = GlobalConstants.Images.ServiceIcon(rawValue: icon!)
            let backgroundImageName = Utility.getWeatherImage(serviceIcon: (enumVal?.rawValue)!)
            
            if String(backgroundImageName).isEmpty != nil {
                weatherImage.image = UIImage(named: backgroundImageName)!
                Utility.setLastLoadedBackground(backgroundName: backgroundImageName)
            }

            // Populate the weather icon
            
            let weatherIconEnumVal = GlobalConstants.Images.ServiceIcon(rawValue: icon!)
            let weatherIconName = Utility.getWeatherIcon(serviceIcon: (weatherIconEnumVal?.rawValue)!)
            if String(weatherIconName).isEmpty != nil {
                currentWeatherIcon.image = UIImage(named: weatherIconName)!
            }

            // If weather alert, enable the button so user can bring up alert text view
            if (dailyWeather?.weatherAlert == true) {
                
                weatherAlertButton.isHidden = false
                weatherAlertTitle.isHidden = false
                
                weatherAlertButton.isEnabled = true
                weatherAlertButton.setTitle(nil, for: .normal)
                weatherAlertTitle.text = "Weather Alert"
                weatherAlertButton.setImage(UIImage(named: "Alert"), for: UIControlState.normal)
            }
            else {
                weatherAlertButton.isHidden = true
                weatherAlertTitle.isHidden = true
            }
        }

//        UIView.animate(withDuration: 0.7, delay: 0.7, options: UIViewAnimationOptions.curveEaseOut, animations: {
//            self.outerScreenView.alpha = 1.0
//
//            }, completion:{_ in
//                //self.refreshingTest.hidden = true
//        })
        
    }
    
    func areDatesSameDay (date1: NSDate, date2: NSDate) -> Bool {
        
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
    
    func isTomorrow (date1: NSDate) -> Bool {

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
    
    // MARK:  Button Press Methods

    @IBAction func infoButtonPressed(_ sender: AnyObject) {
        // infoScreenSegue
        
        self.performSegue(withIdentifier: "infoScreenSegue", sender: self)
    }
    
    // MARK:  Reach methods
    func networkStatusChanged(_ notification: Notification) {
        let userInfo = (notification as NSNotification).userInfo
        print("Network Status Changed")
    }
    
    
    // MARK:  Notification complete methods
    
    func weatherDataRefreshed() {
        print("Weather Data Refreshed")

        // Currently this will only be called after changing a setting on the Settings screen
        
        // NOTE:  This will be called on a background thread
        
        dailyWeather = delegate?.returnRefreshedWeatherDetails()
        DispatchQueue.main.async {
            self.populateTodayWeatherDetails()
            
            // Double check to see if the user has changed day/night setings before reloading 
            // the hour tableView.  It may have not got written to in time the first time around
            
            let userDefaults = UserDefaults.standard
            self.dayOrNightColourSetting = userDefaults.string(forKey: GlobalConstants.Defaults.SavedDayOrNightColourSetting)
            
            self.hourlyWeatherTableView.reloadData()
        
            // Scroll to the top of the table view
            self.hourlyWeatherTableView.contentOffset = CGPoint(x: 0, y: 0 - self.hourlyWeatherTableView.contentInset.top)
        }
    }
    
    func locationDataRefreshed() {
        print("Location Data Refreshed")
        
        // NOTE:  This will be called on a background thread
        
        // The phone could have moved location since the last refresh.
        // Get the updated location details after it has been refreshed.
        
        weatherLocation = nil
        weatherLocation = delegate?.returnRefreshedLocationDetails()
        DispatchQueue.main.async {
            self.updateLocationDetailsOnScreen()
        }
    }
}

// MARK:- Extension:  UIPopoverPresentationControllerDelegate methods

extension TodayTabVC : UIPopoverPresentationControllerDelegate {
    
    func popoverPresentationControllerDidDismissPopover(popoverPresentationController: UIPopoverPresentationController) {
        
    }
    
    func popoverPresentationController(popoverPresentationController: UIPopoverPresentationController, willRepositionPopoverToRect rect: UnsafeMutablePointer<CGRect>, inView view: AutoreleasingUnsafeMutablePointer<UIView?>) {
        
    }
    
    func popoverPresentationControllerShouldDismissPopover(popoverPresentationController: UIPopoverPresentationController) -> Bool {
        return true
    }
}


// MARK: UITableViewDataSource
extension TodayTabVC : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return GlobalConstants.NumberOfHoursToShowFromNow
    }
    
    func numberOfSectionsInTableView(tableView:UITableView)->Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            
            if (dayOrNightColourSetting == nil) {
                dayOrNightColourSetting = GlobalConstants.DefaultDayOrNightSwitch  // ON
            }
        }
        
        // We dont want the current hour in this list so +1
        let hourWeather = dailyWeather?.hourBreakdown.hourStats[indexPath.row + 1]
        
        let cell:HourlyWeatherCell = self.hourlyWeatherTableView.dequeueReusableCell(withIdentifier: "HourWeatherCellID") as! HourlyWeatherCell
        
        var hourTimeStamp = hourWeather?.dateAndTimeStamp
        
        cell.hourLabel.text = hourWeather?.dateAndTimeStamp!.shortHourTimeString()
        cell.temperatureLabel.text = String(Int(round(hourWeather!.temperature!))) + GlobalConstants.degreesSymbol
        
        let icon = hourWeather?.icon
        let iconName = Utility.getWeatherIcon(serviceIcon: icon!)
        
        if iconName != "" {
            cell.summaryIcon.image = UIImage(named: iconName)!
        }
        
        // Alternate the shading of each table view cell
        if dayOrNightColourSetting == "ON" {
            if (indexPath.row % 2 == 0) {
                // Lighter Shade
                
                if isDayTime(dateTime: hourTimeStamp!) { // if hourWeather?.dayOrNight == "DAY" {
                    cell.backgroundColor = GlobalConstants.TableViewAlternateShadingDay.Darker
                }
                else {
                    cell.backgroundColor = GlobalConstants.TableViewAlternateShadingNight.Darker
                }
            }
            else {
                if isDayTime(dateTime: hourTimeStamp!) { //if hourWeather?.dayOrNight == "DAY" {
                    cell.backgroundColor = GlobalConstants.TableViewAlternateShadingDay.Lighter
                }
                else {
                    cell.backgroundColor = GlobalConstants.TableViewAlternateShadingNight.Lighter
                }
            }
        }
        else {
            if (indexPath.row % 2 == 0) {
                // Lighter Shade
                cell.backgroundColor = GlobalConstants.TableViewAlternateShading.Darker
            }
            else {
                cell.backgroundColor = GlobalConstants.TableViewAlternateShading.Lighter
            }
        }

        return cell
    }
}


// MARK: UITableViewDelegate
extension TodayTabVC : UITableViewDelegate {

    private func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: IndexPath) -> Bool {
        return true
    }
    
    private func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
    }
}

// MARK:- Extension:  SettingsViewControllerDelegate

extension TodayTabVC : SettingsViewControllerDelegate {
    
    // Refresh data after pressing 'OK' in the settings screen
    func refreshData() {
        print("Refreshing data")
        
        Reach().monitorReachabilityChanges()
        
        var connected = false
        let status = Reach().connectionStatus()
        switch status {
        case .unknown, .offline:
            print("Not connected")
        case .online(.wwan):
            print("Connected via WWAN")
            connected = true
        case .online(.wiFi):
            print("Connected via WiFi")
            connected = true
        }

        if connected
        {
            self.refreshDataAfterPullToRefresh()
        }
        else
        {
            // Internet Connection not Available!
            Utility.showMessage(titleString: "Error", messageString: "You are not connected to the internet.  Please check your cellular or wi-fi settings" )
        }
    }
}


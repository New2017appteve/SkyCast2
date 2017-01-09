//
//  TodayTabVC.swift
//  Weather
//
//  Created by Mark Gumbs on 28/06/2016.
//

import UIKit
import GoogleMobileAds

protocol TodayTabVCDelegate
{
    // Following methods are part of ParentWeatherVC
    
    func switchViewControllers()
    
    func refreshLocationAndWeatherData()
    func returnRefreshedLocationDetails() -> Location
    func returnRefreshedWeatherDetails() -> Weather
}

class TodayTabVC: UIViewController, UITextViewDelegate, GADBannerViewDelegate {
    
    var dailyWeather : Weather!  // This is passed in from ParentWeatherVC
    var weatherLocation : Location!  // This is passed in from ParentWeatherVC
    
    var delegate:TodayTabVCDelegate?
    var dayOrNightColourSetting: String?
    
    var sunriseTimeStamp: NSDate?
    var sunsetTimeStamp: NSDate?
    var tomorrowSunriseTimeStamp: NSDate?
    var tomorrowSunsetTimeStamp: NSDate?
    var lastUpdatedTimeStamp: NSDate?
    var lastUpdatedTime = ""

    var infoLabelTimerCount = 0
    var weatherDetailsTimerCount = 0
    var lastSelectedHourIndexRow = -1  // Dummy value to indicate no selection
    var lastSelectedHourIndexPath: IndexPath?
    
    var podColourScheme: UIColor?
    var writingColourScheme: UIColor?
    
    var currentSelectedHourCellColour: UIColor?
    
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
    
    @IBOutlet weak var nowDetailTwoView : UIView!
    @IBOutlet weak var rainNowInfoStackView : UIStackView!
    @IBOutlet weak var rainNowIcon : UIImageView!
    @IBOutlet weak var rainNowProbability : UILabel!
    @IBOutlet weak var nearestRainDistance : UILabel!
    
    @IBOutlet weak var currentSummary : UILabel!

    @IBOutlet weak var weatherDetailOuterView : UIView!
    @IBOutlet weak var weatherDetailView : UIView!
    @IBOutlet weak var weatherDetailStackView : UIStackView!
    
    @IBOutlet weak var todayLabel : UILabel!
    @IBOutlet weak var todaySummary : UILabel!
    @IBOutlet weak var todayHighLowTemp : UILabel!
    @IBOutlet weak var currentWindspeed : UILabel!
    @IBOutlet weak var cloudCover : UILabel!
    @IBOutlet weak var rainProbability : UILabel!
    
    @IBOutlet weak var todayHighLowTempTitle : UILabel!
    @IBOutlet weak var windspeedTitle : UILabel!
    @IBOutlet weak var cloudCoverTitle : UILabel!
    @IBOutlet weak var humidityTitle : UILabel!
    @IBOutlet weak var rainProbabilityTitle : UILabel!
    @IBOutlet weak var weatherAlertTitle : UILabel!
    
    @IBOutlet weak var sunriseStackView : UIStackView!
    @IBOutlet weak var sunriseIcon : UIImageView!
    @IBOutlet weak var sunrise : UILabel!
    @IBOutlet weak var sunsetStackView : UIStackView!
    @IBOutlet weak var sunsetIcon : UIImageView!
    @IBOutlet weak var sunset : UILabel!
    @IBOutlet weak var humidity : UILabel!

    @IBOutlet weak var weatherAlertButton : UIButton!
    @IBOutlet weak var bigWeatherAlertButton : UIButton!
    @IBOutlet weak var poweredByDarkSkyButton : UIButton!

    @IBOutlet weak var hourlyDetailView : UIView!
    @IBOutlet weak var hourlyDetailCloseButton : UIButton!
    @IBOutlet weak var hourlyDetailStackView : UIStackView!
    @IBOutlet weak var hourSummaryTitle : UILabel!

    @IBOutlet weak var hourTempTitle : UILabel!
    @IBOutlet weak var hourWindspeedTitle : UILabel!
    @IBOutlet weak var hourCloudCoverTitle : UILabel!
    @IBOutlet weak var hourRainProbabilityTitle : UILabel!
    
    @IBOutlet weak var hourSummary : UILabel!
    @IBOutlet weak var hourTemp : UILabel!
    @IBOutlet weak var hourWindspeed : UILabel!
    @IBOutlet weak var hourCloudCover : UILabel!
    @IBOutlet weak var hourRainProbability : UILabel!

    private let cellId = "cellId"
    
    @IBOutlet weak var hourlyWeatherTableView : UITableView!
    
    // The banner views.
    @IBOutlet weak var bannerOuterView: UIView!
    @IBOutlet weak var closeBannerButton : UIButton!
    @IBOutlet weak var bannerView: GADBannerView!
    
    enum Menu: String {
        case ShowSettings = "App Settings"
        case ShowAbout = "About"
    }
    
    var tableView : UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        NotificationCenter.default.addObserver(self, selector: #selector(TodayTabVC.networkStatusChanged(_:)), name: NSNotification.Name(rawValue: ReachabilityStatusChangedNotification), object: nil)
        
        // NOTE:  May not need the following 2 for startup
        NotificationCenter.default.addObserver(self, selector: #selector(TodayTabVC.locationDataRefreshed), name: GlobalConstants.locationRefreshFinishedKey, object: nil)
        
        NotificationCenter.default.addObserver(self, selector:
            #selector(TodayTabVC.weatherDataRefreshed), name: GlobalConstants.weatherRefreshFinishedKey, object: nil)

        setupDisplayTimer()
        setupSwipeGestures()
        setupScreen ()
        populateTodayWeatherDetails()
        bannerOuterView.isHidden = true

        setupColourScheme()
    }
    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    
        setupColourScheme()
        
        // Ease in the weather background for effect
        self.weatherImage.alpha = 0.2
        UIView.animate(withDuration: 0.6, delay: 0.0, options: UIViewAnimationOptions.curveEaseIn, animations: {
            self.weatherImage.alpha = 1
        }, completion: nil)
        
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
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidDisappear(_ animated: Bool) {

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
        
        bannerOuterView.isHidden = true
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
        
        // Selected Hour
       // hourlyDetailView.backgroundColor = GlobalConstants.TableViewSelectedHourShading
        
        poweredByDarkSkyButton.titleEdgeInsets.right = 10 // Add right padding of text
        
        nowDetailOneView.backgroundColor = UIColor.clear
        nowDetailTwoView.backgroundColor = UIColor.clear
        nowDetailOneView.alpha = 0
        nowDetailTwoView.alpha = 1
        
        // Hide weather details initially until timer starts
        self.weatherDetailStackView.alpha = 0
        
        if AppSettings.showHourWeatherOnSelect {
            
            weatherDetailView.isHidden = false
            hourlyDetailView.isHidden = true
            
            hourlyDetailView.layer.cornerRadius = 10.0
            hourlyDetailView.clipsToBounds = true
           // hourlyDetailView.layer.borderWidth = 2
           // hourlyDetailView.layer.borderColor = UIColor.white.cgColor
            
            hourlyWeatherTableView.allowsSelection = true
        }
        else {
            hourlyDetailView.isHidden = true
            hourlyWeatherTableView.allowsSelection = false
        }
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
        rainNowProbability.textColor = textColourScheme
        nearestRainDistance.textColor = textColourScheme
        currentWindspeed.textColor = textColourScheme
        currentSummary.textColor = textColourScheme
        todayLabel.textColor = textColourScheme
        todaySummary.textColor = textColourScheme
        todayHighLowTemp.textColor = textColourScheme
        cloudCover.textColor = textColourScheme
        rainProbability.textColor = textColourScheme
        sunrise.textColor = textColourScheme
        sunset.textColor = textColourScheme
        humidity.textColor = textColourScheme
        weatherAlertTitle.textColor = textColourScheme
        
        todayHighLowTempTitle.textColor = textColourScheme
        windspeedTitle.textColor = textColourScheme
        cloudCoverTitle.textColor = textColourScheme
        humidityTitle.textColor = textColourScheme
        rainProbabilityTitle.textColor = textColourScheme
        weatherAlertTitle.textColor = textColourScheme
        
        hourSummaryTitle.textColor = textColourScheme
        hourTempTitle.textColor = textColourScheme
        hourWindspeedTitle.textColor = textColourScheme
        hourCloudCoverTitle.textColor = textColourScheme
        hourRainProbabilityTitle.textColor = textColourScheme
        
        hourTemp.textColor = textColourScheme
        hourSummary.textColor = textColourScheme
        hourWindspeed.textColor = textColourScheme
        hourCloudCover.textColor = textColourScheme
        hourRainProbability.textColor = textColourScheme
        
        // Pods
        
        infoView.backgroundColor = podColourScheme
        currentTempDetailView.backgroundColor = podColourScheme
        
        infoView.alpha = CGFloat(GlobalConstants.DisplayViewAlpha)
        currentTempDetailView.alpha = CGFloat(GlobalConstants.DisplayViewAlpha)
        weatherDetailOuterView.alpha = 1.0 //CGFloat(GlobalConstants.DisplayViewAlpha)
        
        weatherDetailOuterView.backgroundColor = UIColor.clear //podColourScheme
        weatherDetailView.backgroundColor = podColourScheme
        
        hourlyDetailView.backgroundColor = podColourScheme
        
        // Buttons and Title Labels
        nowLabel.backgroundColor = titleViewColourScheme
        todayLabel.backgroundColor = titleViewColourScheme
        poweredByDarkSkyButton.backgroundColor = titleViewColourScheme
        
        hourSummaryTitle.backgroundColor = titleViewColourScheme
        
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
        
        // Make ads more location specific
        if let currentLocation = weatherLocation.currentLocation {
            request.setLocationWithLatitude(CGFloat(currentLocation.coordinate.latitude),
                                            longitude: CGFloat(currentLocation.coordinate.longitude),
                                            accuracy: CGFloat(currentLocation.horizontalAccuracy))
        }
        bannerView.load(request)
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
            var weatherAlertURL = ""
            
            // If weather alert, enable the button so user can bring up alert text view
            
            //weatherAlertDescription = "A storm is approaching the south west of the country.  Amber alert has been raised"
            
            // Cater for more than 1 alert description
            
            let alertCount = dailyWeather.weatherAlerts.count
            
            if alertCount > 0 {
                for i in 0...alertCount - 1 {
                    
                    let alertTime = dailyWeather.weatherAlerts[i].alertDateAndTimeStamp
                    let alertExpiry = dailyWeather.weatherAlerts[i].alertExpiryDateAndTimeStamp
                    
                    let alertTimeDescription =
                        (alertTime?.shortDayOfTheWeek())! + " " +
                        (alertTime?.getDateSuffix())! + " @" +
                        (alertTime?.shortTimeString())! +
                        " to " +
                        (alertExpiry?.shortDayOfTheWeek())! + " " +
                        (alertExpiry?.getDateSuffix())! + " @" +
                        (alertExpiry?.shortTimeString())!
                    
                    weatherAlertURL = dailyWeather.weatherAlerts[i].uri!
                    weatherAlertDescription = alertTimeDescription + "\r\n\n" + dailyWeather.weatherAlerts[i].alertDescription! + "\r\n\n"
                }
            }
            else {
                
                // NOTE: This should never happen really, but here incase I'm testing 
                
                weatherAlertDescription = "TEST:  A storm is approaching the south west of the country.  Amber alert has been raised"
            }
            
            let vc:InfoPopupViewController = segue.destination as! InfoPopupViewController
            vc.informationString = weatherAlertDescription
            vc.weatherAlertSourceURL = weatherAlertURL
            
        }
        
    }

    // Display screen functions
    func setupDisplayTimer() {
    
        infoLabelTimerCount = 0
        weatherDetailsTimerCount = 0
        
        _ = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(updateWeatherDetailsOnScreen), userInfo: nil, repeats: true)

    }
    
    func updateWeatherDetailsOnScreen() {
        
        infoLabelTimerCount += 1
        weatherDetailsTimerCount += 1
        
        lastUpdatedTime = reformatLastUpdatedTimeIfNeeded(lastUpdatedDate: lastUpdatedTimeStamp!)
        
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
        default:
            infoLabel.text = ""
        }
        
        let detailsMod = infoLabelTimerCount % 3
        switch (detailsMod) {
        case 0:
            hideWeatherDetailsView()
            hideNowDetailsOneView ()
        case 1:
            showWeatherDetailsView()
            hideNowDetailsTwoView ()
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
        self.todayLabel.text = "  Today's Summary"
        self.todaySummary.alpha = 1
        UIView.animate(withDuration: 0.6, delay: 0.0, options: UIViewAnimationOptions.curveEaseIn, animations: {
            self.todaySummary.alpha = 0
        }, completion: nil)
        
        self.weatherDetailStackView.alpha = 0
        UIView.animate(withDuration: 0.6, delay: 0.0, options: UIViewAnimationOptions.curveEaseIn, animations: {
            self.weatherDetailStackView.alpha = 1
        }, completion: nil)
    }
    
    func hideNowDetailsOneView () {
        
        self.todayLabel.text = "  Next 24 Hours"
        self.nowDetailTwoView.alpha = 0
        UIView.animate(withDuration: 0.6, delay: 0.0, options: UIViewAnimationOptions.curveEaseIn, animations: {
            self.nowDetailTwoView.alpha = CGFloat(GlobalConstants.DisplayViewAlpha)
        }, completion: nil)
        
        self.nowDetailOneView.alpha = CGFloat(GlobalConstants.DisplayViewAlpha)
        UIView.animate(withDuration: 0.6, delay: 0.0, options: UIViewAnimationOptions.curveEaseIn, animations: {
            self.nowDetailOneView.alpha = 0
        }, completion: nil)
    }
    
    func hideNowDetailsTwoView () {
        
        self.nowDetailOneView.alpha = 0
        UIView.animate(withDuration: 0.6, delay: 0.0, options: UIViewAnimationOptions.curveEaseIn, animations: {
            self.nowDetailOneView.alpha = CGFloat(GlobalConstants.DisplayViewAlpha)
        }, completion: nil)
        
        self.nowDetailTwoView.alpha = CGFloat(GlobalConstants.DisplayViewAlpha)
        UIView.animate(withDuration: 0.6, delay: 0.0, options: UIViewAnimationOptions.curveEaseIn, animations: {
            self.nowDetailTwoView.alpha = 0
        }, completion: nil)
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
                
                // Shift the whole view down slightly to indicate a refresh is going on
                UIView.animate(withDuration: 0.3, delay: 0.0, options: UIViewAnimationOptions.curveEaseIn, animations: {
                    self.outerScreenView.frame = self.view.frame.offsetBy(dx: 0.0, dy: 30.0);
                    
                }, completion: nil)
            
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
//    
//    func moveViewUpAfterRefreshSwipe() {
//        
//        // Shift the whole view down slightly to indicate a refresh is going on
//        UIView.animate(withDuration: 0.3, delay: 0.0, options: UIViewAnimationOptions.curveEaseIn, animations: {
//            self.outerScreenView.frame = self.view.frame.offsetBy(dx: 0.0, dy: 30.0);
//            
//        }, completion: nil)
//
//    }
 
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

        weatherDetailView.isHidden = false
        hourlyDetailView.isHidden = true
        lastSelectedHourIndexRow = -1
        
        disableScreen()

        // NOTE: Notifications for Weather and Location should be active already
        
        let userDefaults = UserDefaults.standard
        dayOrNightColourSetting = userDefaults.string(forKey: GlobalConstants.Defaults.SavedDayOrNightColourSetting)
        
        // The toast to say data is refreshing will be done in parent
        self.delegate?.refreshLocationAndWeatherData()
        
        // Data for Location and Weather will be updated once each notification has fired
        
    }
    
    func getLastUpdatedTime() -> String {
        
        var today = NSDate()
        today = Utility.getTimeInWeatherTimezone(dateAndTime: today)

        let timeNow = today.shortTimeString()
        
        lastUpdatedTimeStamp = today
        
        return timeNow

    }

    func reformatLastUpdatedTimeIfNeeded(lastUpdatedDate: NSDate) -> String {
        
        // If the last updated time is yesterday, add on the datestamp before the timestamp
        
        var today = NSDate()
        today = Utility.getTimeInWeatherTimezone(dateAndTime: today)
        
        var returnTime = lastUpdatedDate.shortTimeString()
        
        if !Utility.areDatesSameDay(date1: today, date2: lastUpdatedDate) {
            returnTime = (lastUpdatedDate.shortDayMonthYear())! + " @ " + (lastUpdatedDate.shortTimeString())
        }
        
        return returnTime
        
    }

    func populateTodayWeatherDetails() {
//
//        var degreesSymbol = ""
//        
//        // Rather than force unwrapping, use conditional let to check weather array
//        if let lWeather = dailyWeather {
//            if lWeather.flags.units == "si" {
//                degreesSymbol = GlobalConstants.degreesSymbol + "C"
//            }
//            else {
//                degreesSymbol = GlobalConstants.degreesSymbol + "F"
//            }
//        }
//        
        if let todayArray = dailyWeather?.currentBreakdown {
            
            lastUpdatedTime  = getLastUpdatedTime()

            //
            // Now Pod
            //
            
            let degreesSymbol = GlobalConstants.degreesSymbol + todayArray.temperatureUnits!
            currentTemp.text = String(Int(round(todayArray.temperature! as Float))) + degreesSymbol
            
            // Inner Pod 1
            feelsLikeTemp.text = "Feels Like: " + String(Int(round(todayArray.apparentTemperature! as Float))) + degreesSymbol
            
            // Inner Pod 2
            let minuteBreakdown = dailyWeather?.minuteBreakdown
            currentSummary.text = minuteBreakdown?.summary

            let minuteStats = minuteBreakdown?.minuteStats
            let rainProbabilityNow = Int(round((minuteStats?[0].precipProbability!)!*100))
            
            // Populate with the correct rain icon scheme
            let rainIconImage = Utility.getWeatherIcon(serviceIcon: "UMBRELLA", dayOrNight: "")
            rainNowIcon.image = UIImage(named: rainIconImage)!

            if (rainProbabilityNow > GlobalConstants.RainIconReportThresholdPercent) {
                rainNowIcon.isHidden = false
                rainNowProbability.text = String(rainProbabilityNow) + "%"
            }
            else {
                rainNowIcon.isHidden = true
                rainNowProbability.text = ""
            }
            
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
            
            let nearestRain = todayArray.nearestStormDistance!
        
            if (nearestRain == 0) {
                nearestRainDistance.text = "Rain nearby" //"Raining"
            }
            else if (nearestRain > 0 && nearestRain <= GlobalConstants.RainDistanceReportThreshold) {
                nearestRainDistance.text = "Rain nearby"
            }
            else if (nearestRain > GlobalConstants.RainDistanceReportThreshold) {
                let rainUnits = todayArray.nearestStormDistanceUnits
                
                // TODO: Tidy up string concat
                
                if ( !(rainDirection.isEmpty) || rainDirection != "") {
                    nearestRainDistance.text = "Rain " + String(todayArray.nearestStormDistance!) + " "
                    nearestRainDistance.text = nearestRainDistance.text! + rainUnits! + " " + rainDirection
                }
            }

            
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
                    
//                    windspeed.text = String(Int(round(days.windSpeed! * GlobalConstants.MetersPerSecondToMph))) + " " + windspeedUnits!
                    windspeed.text = String(Int(days.windSpeed!)) + " " + windspeedUnits!

                    cloudCover.text = String(Int(round(days.cloudCover!*100))) + "%"
                    humidity.text = String(Int(round(days.humidity!*100))) + "%"
                    rainProbability.text = String(Int(round(days.precipProbability!*100))) + "%"
                    
                    sunrise.text = String(days.sunriseTimeStamp!.shortTimeString())
                    sunset.text = String(days.sunsetTimeStamp!.shortTimeString())
                    sunriseTimeStamp = days.sunriseTimeStamp as NSDate?
                    sunsetTimeStamp = days.sunsetTimeStamp as NSDate?
                    
                    // Populate with the correct sunrise/sunset icon scheme
                    let sunriseIconImage = Utility.getWeatherIcon(serviceIcon: "SUNRISE", dayOrNight: "")
                    sunriseIcon.image = UIImage(named: sunriseIconImage)!
                    
                    let sunsetIconImage = Utility.getWeatherIcon(serviceIcon: "SUNSET", dayOrNight: "")
                    sunsetIcon.image = UIImage(named: sunsetIconImage)!

                }
                
                // We want tomorrows sunrise and sunset times as well for use in calculations later
                
                let tomorrow = Utility.isTomorrow(date1: days.dateAndTimeStamp!)
                
                if tomorrow {
                    tomorrowSunriseTimeStamp = days.sunriseTimeStamp as NSDate?
                    tomorrowSunsetTimeStamp = days.sunsetTimeStamp as NSDate?
                }
            }
            
            let hourlyBreakdown = dailyWeather?.hourBreakdown
            todaySummary.text = hourlyBreakdown?.summary
            
            // We have the sunset and sunrise times for today and tomorrow, so work out if
            // the current time is day or night
            
            var isItDayOrNight = "NIGHT"
            
            var timeNow = NSDate()
            timeNow = Utility.getTimeInWeatherTimezone(dateAndTime: timeNow)
            
            if isDayTime(dateTime: timeNow) {
                isItDayOrNight = "DAY"
            }

            // Populate the weather image
            let icon = todayArray.icon
            let enumVal = GlobalConstants.Images.ServiceIcon(rawValue: icon!)
            
            var backgroundImageName = ""
            if AppSettings.SpecialThemedBackgroundsForEvents {
                // Get a special background if its a 'themed day (e.g Chrisrmas etc)
                backgroundImageName = Utility.getSpecialDayWeatherImage(dayOrNight: isItDayOrNight)
            }
            
            if backgroundImageName == "" {
                backgroundImageName = Utility.getWeatherImage(serviceIcon: (enumVal?.rawValue)!, dayOrNight: isItDayOrNight)
            }
            
            //if String(backgroundImageName).isEmpty != nil {
            if !(String(backgroundImageName).isEmpty) {
                weatherImage.image = UIImage(named: backgroundImageName)!
                Utility.setLastLoadedBackground(backgroundName: backgroundImageName)
            }
            
            // Populate the weather icons
            
            let weatherIconEnumVal = GlobalConstants.Images.ServiceIcon(rawValue: icon!)
            let weatherIconName = Utility.getWeatherIcon(serviceIcon: (weatherIconEnumVal?.rawValue)!, dayOrNight: isItDayOrNight)
            
            //if String(weatherIconName).isEmpty != nil {
            if !(String(weatherIconName).isEmpty) {
                currentWeatherIcon.image = UIImage(named: weatherIconName)!
            }
            
            // If weather alert, enable the button so user can bring up alert text view
            if (dailyWeather?.weatherAlert == true) {
                
                weatherAlertButton.isHidden = false
                bigWeatherAlertButton.isHidden = false
                weatherAlertTitle.isHidden = false
                
                weatherAlertButton.isEnabled = true
                bigWeatherAlertButton.isEnabled = true
                weatherAlertButton.setTitle(nil, for: .normal)
                weatherAlertTitle.text = "Weather Alert"
                weatherAlertButton.setImage(UIImage(named: "Alert"), for: UIControlState.normal)
            }
            else {
                weatherAlertButton.isHidden = true
                bigWeatherAlertButton.isHidden = true
                weatherAlertTitle.isHidden = true
            }
        }
        
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

    func isSunriseHour (dateTime : NSDate) -> Bool {
        
        var retVal : Bool!
        
        // Calculate whether the sun rises in next hour
        
        let nextHourTime = dateTime.add(minutes: 60) as NSDate
        
        if (sunriseTimeStamp!.isBetweeen(date: nextHourTime, andDate: dateTime) ||
            tomorrowSunriseTimeStamp!.isBetweeen(date: nextHourTime, andDate: dateTime) ) {
            
            retVal = true
        }
        else {
            retVal = false
        }
        
        return retVal
    }
    
    func isSunsetHour (dateTime : NSDate) -> Bool {
        
        var retVal : Bool!
        
        // Calculate whether the sun rises in next hour
        
        let nextHourTime = dateTime.add(minutes: 60) as NSDate
        
        if (sunsetTimeStamp!.isBetweeen(date: nextHourTime, andDate: dateTime) ||
            tomorrowSunriseTimeStamp!.isBetweeen(date: nextHourTime, andDate: dateTime) ) {
            
            retVal = true
        }
        else {
            retVal = false
        }
        
        return retVal
    }


    // MARK:  Button Press Methods

    @IBAction func closeBannerAdButtonPressed(_ sender: AnyObject) {

        // Dismiss banner ad view
        bannerOuterView.isHidden = true
    }

    @IBAction func infoButtonPressed(_ sender: AnyObject) {
        // infoScreenSegue
        self.performSegue(withIdentifier: "infoScreenSegue", sender: self)
    }
    
    @IBAction func poweredByDarkSkyButtonPressed(_ sender: AnyObject) {
        
        // Display the Dark Sky webpage
        UIApplication.shared.openURL(URL(string: GlobalConstants.DarkSkyURL)!)
    }
    
    @IBAction func hourDetailCloseButtonPressed(_ sender: AnyObject) {
        
        weatherDetailView.isHidden = false
        hourlyDetailView.isHidden = true
        
        lastSelectedHourIndexRow = -1
        
        if lastSelectedHourIndexPath != nil {
            hourlyWeatherTableView.deselectRow(at: lastSelectedHourIndexPath!, animated: false)
        }

    }
    
    // MARK:  Reach methods
    func networkStatusChanged(_ notification: Notification) {
        _ = (notification as NSNotification).userInfo
        print("Network Status Changed")
    }
    
    
    // MARK:  Notification complete methods
    
    func weatherDataRefreshed() {
        print("Weather Data Refreshed - TodayTab")
        
        // NOTE:  This will be called on a background thread
        
        DispatchQueue.main.async {
            self.dailyWeather = self.delegate?.returnRefreshedWeatherDetails()
            
            // Double check to see if the user has changed day/night setings before reloading 
            // the hour tableView.  It may have not got written to in time the first time around
            
            let userDefaults = UserDefaults.standard
            self.dayOrNightColourSetting = userDefaults.string(forKey: GlobalConstants.Defaults.SavedDayOrNightColourSetting)
            
            self.populateTodayWeatherDetails()
            self.hourlyWeatherTableView.reloadData()
            self.enableScreen()
            
            // Scroll to the top of the table view
            self.hourlyWeatherTableView.contentOffset = CGPoint(x: 0, y: 0 - self.hourlyWeatherTableView.contentInset.top)
            
            // NOTE:  We want to keep listening for notifications incase a change is made in
            // the Settings screen so they have not been removed

        }
    }
    
    func locationDataRefreshed() {
        print("Location Data Refreshed - TodayTab")
        
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
    
    // MARK:  GADBannerViewDelegate methods
    
    // Tells the delegate an ad request loaded an ad.
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        print("Ad has been received")
        
        // show the delete ad button
        closeBannerButton.isHidden = false
    }
}



// MARK:- Extension:  UIPopoverPresentationControllerDelegate methods

extension TodayTabVC : UIPopoverPresentationControllerDelegate {
    
    func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
        
    }
    
    func popoverPresentationController(_ popoverPresentationController: UIPopoverPresentationController, willRepositionPopoverTo rect: UnsafeMutablePointer<CGRect>, in view: AutoreleasingUnsafeMutablePointer<UIView>) {
        
    }
    
    
    func popoverPresentationControllerShouldDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) -> Bool {
        return true
    }
    
}


// MARK: UITableViewDataSource
extension TodayTabVC : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return GlobalConstants.NumberOfHoursToShowFromNow
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
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
        
        let hourTimeStamp = hourWeather?.dateAndTimeStamp
        
        let sunriseHour = isSunriseHour(dateTime: hourTimeStamp!)
        let sunSetHour = isSunsetHour(dateTime: hourTimeStamp!)
        let dayOrNight = (isDayTime(dateTime: hourTimeStamp!) ? "DAY" : "NIGHT")

        cell.hourLabel.text = hourWeather?.dateAndTimeStamp!.shortHourTimeString()
        
//        if sunriseHour {
//            cell.showSunriseSunsetDetails()
//        }

        let degreesSymbol = GlobalConstants.degreesSymbol + hourWeather!.temperatureUnits!
        cell.temperatureLabel.text = String(Int(round(hourWeather!.temperature!))) + degreesSymbol
        
        // Rain and Wind thresholds
        
        if (Int(round(hourWeather!.precipProbability!*100)) > GlobalConstants.RainIconReportThresholdPercent) {
            
            // Populate with the correct rain icon scheme
            let rainIconImage = Utility.getWeatherIcon(serviceIcon: "UMBRELLA", dayOrNight: "")
            cell.rainIcon.image = UIImage(named: rainIconImage)!

            cell.rainIcon.isHidden = false
            cell.rainProbabilityLabel.text = String(Int(round(hourWeather!.precipProbability!*100))) + "%"
        }
        else {
            cell.rainIcon.isHidden = true
            cell.rainProbabilityLabel.text = ""
        }
        
        if (Int((hourWeather?.windSpeed!)!) > GlobalConstants.WindStrengthThreshold) {
            
            // Populate with the correct wind icon scheme
            let windyIconImage = Utility.getWeatherIcon(serviceIcon: "WINDY", dayOrNight: "")
            cell.windyIcon.image = UIImage(named: windyIconImage)!
            
            cell.windyIcon.isHidden = false
        }
        else {
            cell.windyIcon.isHidden = true
        }
        
        let icon = hourWeather?.icon
        let iconName = Utility.getWeatherIcon(serviceIcon: icon!, dayOrNight: dayOrNight)
        
        if iconName != "" {
            cell.summaryIcon.image = UIImage(named: iconName)!
        }
        
        // Setup text colour according to colour scheme.  However, we want to override the
        // colouring if the scheme is Dark and Daytime colours is ON
        
        let colourScheme = Utility.setupColourScheme()
        let textColourScheme = colourScheme.textColourScheme
        
        if (dayOrNightColourSetting == "ON" && colourScheme.type == GlobalConstants.ColourScheme.Dark) {
          
            cell.hourLabel.textColor = UIColor.black
            cell.temperatureLabel.textColor = UIColor.black
            cell.rainProbabilityLabel.textColor = UIColor.black
            
            // Force rain umbrella, windy and weather icon black
            let lRainIconImage = GlobalConstants.WeatherIcon.umbrella
            cell.rainIcon.image = UIImage(named: lRainIconImage)!
            
            let lWeatherIcon = Utility.getWeatherIcon(serviceIcon: icon!, scheme: GlobalConstants.ColourScheme.Light, dayOrNight: dayOrNight)
            cell.summaryIcon.image = UIImage(named: lWeatherIcon)!
            
            // Populate with the correct wind icon scheme
            let lWindyIconImage = Utility.getWeatherIcon(serviceIcon: "WINDY", scheme: GlobalConstants.ColourScheme.Light, dayOrNight: dayOrNight)
            cell.windyIcon.image = UIImage(named: lWindyIconImage)!

        }
        else {
            cell.hourLabel.textColor = textColourScheme
            cell.temperatureLabel.textColor = textColourScheme
            cell.rainProbabilityLabel.textColor = textColourScheme
            // Umbrella and windsock already set
        }
        
        // Alternate the shading of each table view cell
        if dayOrNightColourSetting == "ON" {
            
            if (sunriseHour || sunSetHour) {
                cell.backgroundColor = GlobalConstants.TwighlightShading
            }
            else if (indexPath.row % 2 == 0) {
                // Lighter Shade
                
                if isDayTime(dateTime: hourTimeStamp!) {
                    cell.backgroundColor = GlobalConstants.TableViewAlternateShadingDay.Darker
                }
                else {
                    cell.backgroundColor = GlobalConstants.TableViewAlternateShadingNight.Darker
                }
            }
            else {
                if isDayTime(dateTime: hourTimeStamp!) {
                    cell.backgroundColor = GlobalConstants.TableViewAlternateShadingDay.Lighter
                }
                else {
                    cell.backgroundColor = GlobalConstants.TableViewAlternateShadingNight.Lighter
                }
            }
        }
        else {
            if (colourScheme.type == GlobalConstants.ColourScheme.Dark) {
                if (indexPath.row % 2 == 0) {
                    // Lighter Shade
                    cell.backgroundColor = GlobalConstants.TableViewAlternateShadingDayDarkTheme.Darker
                }
                else {
                    cell.backgroundColor = GlobalConstants.TableViewAlternateShadingDayDarkTheme.Lighter
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
        }  // dayOrNightColourSetting
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        weatherDetailView.isHidden = true
        hourlyDetailView.isHidden = false
        
        let colourScheme = Utility.setupColourScheme()
        
        if (lastSelectedHourIndexRow != indexPath.row) {
            
            // New row selected
            
            // We dont want the current hour in this list so +1
            let hourWeather = dailyWeather?.hourBreakdown.hourStats[indexPath.row + 1]
     
            let hour = hourWeather?.dateAndTimeStamp!.shortHourTimeString()
            hourSummaryTitle.text = "  Hour Summary - " + hour!
            hourSummary.text = hourWeather?.summary
            
            let degreesSymbol = GlobalConstants.degreesSymbol + hourWeather!.temperatureUnits!
            var hourTempText = String(Int(round(hourWeather!.temperature!))) + degreesSymbol
            
            if (hourWeather?.temperature != hourWeather?.apparentTemperature) {
                
                let feelsLikeTempText = String(Int(round(hourWeather!.apparentTemperature!))) + degreesSymbol
                hourTempText = hourTempText + " ( " + feelsLikeTempText + " )"
                hourTempTitle.text = "Temp / Feels Like:"
            }
            hourTemp.text = hourTempText
            
            let windspeedUnits = hourWeather?.windSpeedUnits
            hourWindspeed.text = String(Int((hourWeather?.windSpeed!)!)) + " " + windspeedUnits!
            
            hourCloudCover.text = String(Int(round((hourWeather?.cloudCover!)!*100))) + "%"
            hourRainProbability.text = String(Int(round(hourWeather!.precipProbability!*100))) + "%"
        
            hourlyDetailView.layer.borderWidth = 2
            hourlyDetailView.layer.borderColor = UIColor.white.cgColor

            if let cell = (tableView.cellForRow(at: indexPath) as? HourlyWeatherCell) {
                
                if (colourScheme.type == GlobalConstants.ColourScheme.Dark) {
                    cell.contentView.backgroundColor = UIColor.gray
                    
//                    cell.hourLabel.textColor = UIColor.white
//                    cell.temperatureLabel.textColor = UIColor.white
//                    cell.rainProbabilityLabel.textColor = UIColor.white
                }
                else {
                    cell.contentView.backgroundColor = UIColor.white
                    
//                    cell.hourLabel.textColor = UIColor.black
//                    cell.temperatureLabel.textColor = UIColor.black
//                    cell.rainProbabilityLabel.textColor = UIColor.black
                }
                
//                cell.hourLabel.textColor = textColourScheme
//                cell.temperatureLabel.textColor = textColourScheme
//                cell.rainProbabilityLabel.textColor = textColourScheme
            }
            
            lastSelectedHourIndexPath = indexPath
            lastSelectedHourIndexRow = indexPath.row
            
        }
        else {
            
            // A selected cell has been clicked on again.  So hide the detail view and show the 
            // summary view
            
            weatherDetailView.isHidden = false
            hourlyDetailView.isHidden = true
            lastSelectedHourIndexRow = -1
            
            hourlyDetailView.layer.borderWidth = 0
            hourlyDetailView.layer.borderColor = UIColor.clear.cgColor

            hourlyWeatherTableView.deselectRow(at: indexPath, animated: false)
            
            if let cell = (tableView.cellForRow(at: indexPath) as? HourlyWeatherCell) {
//                cell.hourLabel.textColor = UIColor.black
//                cell.temperatureLabel.textColor = UIColor.black
//                cell.rainProbabilityLabel.textColor = UIColor.black
            }

        }
        
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        weatherDetailView.isHidden = false
        hourlyDetailView.isHidden = true

    }
    
//    func setupHourDisplayTimer() {
//        
//        _ = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(hideHourSelection), userInfo: nil, repeats: true)
//    }
//    
//    func hideHourSelection () {
//        
//        weatherDetailView.isHidden = false
//        hourlyDetailView.isHidden = true
//    }
    
}  // Extension


//extension TodayTabVC : GADBannerViewDelegate {
//    
//    /// Tells the delegate an ad request loaded an ad.
//    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
//        print("adViewDidReceiveAd")
//    }
//}

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


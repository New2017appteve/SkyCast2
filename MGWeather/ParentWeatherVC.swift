//
//  ParentWeatherVC.swift
//  MGWeather
//
//  Created by Mark Gumbs on 30/08/2016.
//

import UIKit
import CoreLocation

class ParentWeatherVC: UIViewController, CLLocationManagerDelegate, SettingsViewControllerDelegate, SunriseSunsetViewControllerDelegate, TodayTabVCDelegate, DailyTabVCDelegate, ThisTimeLastYearVCDelegate  {

    // https://ahmedabdurrahman.com/2015/08/31/how-to-switch-view-controllers-using-segmented-control-swift/
    
    enum TabIndex : Int {
        case FirstChildTab = 0
        case SecondChildTab = 1
    }
    
    @IBOutlet weak var segmentedControl: WeatherSegmentedControl!
    @IBOutlet weak var titleBar: UINavigationBar!
    @IBOutlet weak var titleBarNavItem: UINavigationItem!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var weatherImage : UIImageView!
    @IBOutlet weak var iconRefreshButton : UIButton!

    enum Menu: String {
        case Weather = "Weather"
        case ThisTimeLastYear = "This Time Last Year"
        case SunriseSunset = "Daily Timeline"
        case ShowSettings = "App Settings"
        case ShowAbout = "About"
    }
    
    // Custom outlets
    let customBarButtonAction = UIButton(type: .custom)
    
    var locationManager = CLLocationManager() //: CLLocationManager!
    var locationFound: Bool!
    var locationName: String!
    
    var weather: Weather?
    var tmpWeather : Weather?
    var weatherLocation = Location()
    let geoCoder = CLGeocoder()
    
    var currentViewController: UIViewController?
    
    var loadingMode = ""  // Can either be 'STARTUP' or 'REFRESHING"
    var parentDayOrNight = ""  // DAY or NIGHT. Will be set from DailyTabVC and used in ThisTimeLastYear
    
    lazy var firstChildTabVC: UIViewController? = {
        let firstChildTabVC = self.storyboard?.instantiateViewController(withIdentifier: "TodayTabVC") as! TodayTabVC
        return firstChildTabVC
    }()
    lazy var secondChildTabVC : UIViewController? = {
        let secondChildTabVC = self.storyboard?.instantiateViewController(withIdentifier: "DailyTabVC") as! DailyTabVC
        return secondChildTabVC
    }()
    
    // MARK: - View Controller Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadingMode = "STARTUP"
        getURLUnits()
        setupScreen()
        segmentedControl.isEnabled = false
        // barButtonAction.isEnabled = false
        customBarButtonAction.isEnabled = false
        
        setViewControllerTitle()
        
        // Register to receive notification for location and Reachability
        NotificationCenter.default.addObserver(self, selector: #selector(ParentWeatherVC.locationDataRefreshed), name: GlobalConstants.locationRefreshFinishedKey, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(ParentWeatherVC.weatherDataRefreshed), name: GlobalConstants.weatherRefreshFinishedKey, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(ParentWeatherVC.networkStatusChanged(_:)), name: NSNotification.Name(rawValue: ReachabilityStatusChangedNotification), object: nil)
        
        Reach().monitorReachabilityChanges()
        
        var connectedToInternet = false
        let status = Reach().connectionStatus()
        switch status {
        case .unknown, .offline:
            print("Not connected")
        case .online(.wwan):
            print("Connected via WWAN")
            connectedToInternet = true
        case .online(.wiFi):
            print("Connected via WiFi")
            connectedToInternet = true
        }
        
        // Ease in the pod
        self.contentView.alpha = 0.2
        UIView.animate(withDuration: 0.8, delay: 0.1, options: UIViewAnimationOptions.curveEaseIn, animations: {
            self.contentView.alpha = 1
        }, completion: nil)
        
        // Only get weather services if user has allowed location services on device and we have
        // an internet connection of some sort
        
        if allowedToUseLocation() {
            
            if connectedToInternet
            {
                if (loadingMode == "STARTUP") {
                    // Make a toast to say data is refreshing
                    self.view.makeToast("Getting Location", duration: 2.0, position: .bottom)
                    self.view.makeToastActivity(.center)
                }
                
                iconRefreshButton.isEnabled = false
                self.getAndSetLocation()
                
                // NOTE:  Weather data will be retrieved once the Location data has loaded and notified
            }
            else
            {
                // Internet Connection not Available!
                Utility.showMessage(titleString: "Error", messageString: "You are not connected to the internet.  Please check your cellular or wi-fi settings" )
                self.view.hideToastActivity()
                iconRefreshButton.isEnabled = true
            }

        }
        
//        getLatLngForZip(zipCode: "SL19HL")
        getLatLngForZip(zipCode: "AN")
    }

    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let currentViewController = currentViewController {
            currentViewController.viewWillDisappear(animated)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if (segue.identifier == "settingsScreenSegue") {
            
            let vc:SettingsViewController = segue.destination as! SettingsViewController
            vc.delegate = self
        }
        
        if (segue.identifier == "sunriseSunsetSegue") {
            
            // Get todays sunrise and sunset data to pass to view controller
            
            var sunriseTimeStamp : NSDate!
            var sunsetTimeStamp : NSDate!
            var tempMin : Float!
            var tempMax : Float!
            var tempMinTimeStamp : NSDate!
            var tempMaxTimeStamp : NSDate!
            var degreesSymbol : String!
            var moonPhase : Float!
            var tomorrowMoonPhase: Float?
            
            let todayArray = weather?.currentBreakdown
            let dayArray = weather?.dailyBreakdown.dailyStats
            
            for days in dayArray! {
                
                let sameDay = Utility.areDatesSameDay(date1: (todayArray?.dateAndTimeStamp!)!, date2: days.dateAndTimeStamp!)
                
                let tomorrow = Utility.isTomorrow(date1: days.dateAndTimeStamp!)

                if sameDay {
                    sunriseTimeStamp = days.sunriseTimeStamp as NSDate?
                    sunsetTimeStamp = days.sunsetTimeStamp as NSDate?
                    tempMinTimeStamp = days.temperatureMinTimeStamp
                    tempMaxTimeStamp = days.temperatureMaxTimeStamp
                    tempMin = days.temperatureMin
                    tempMax = days.temperatureMax
                    degreesSymbol = GlobalConstants.degreesSymbol + (todayArray?.temperatureUnits!)!
                    moonPhase = days.moonPhase
                }
                
                if tomorrow {
                    tomorrowMoonPhase = days.moonPhase
                }

            }
    
            let vc:SunriseSunsetViewController = segue.destination as! SunriseSunsetViewController
            vc.delegate = self
            
            vc.dailyWeather = weather
            vc.sunriseDateTime = sunriseTimeStamp
            vc.sunsetDateTime = sunsetTimeStamp
            vc.tempMinDateTime = tempMinTimeStamp
            vc.tempMaxDateTime = tempMaxTimeStamp
            vc.tempMin = tempMin
            vc.tempMax = tempMax
            vc.degreesSymbol = degreesSymbol
            vc.moonPhase = moonPhase
            vc.tomorrowMoonPhase = tomorrowMoonPhase
        }
        
        if (segue.identifier == "ThisTimeLastYearSegue") {
            // Send over weather object for the moment whilst we design screen
            
            let url = getURL(period: "LAST_YEAR")
            let vc:ThisTimeLastYearVC = segue.destination as! ThisTimeLastYearVC
            vc.delegate = self
            vc.dailyWeather = weather
            vc.url = url
            vc.inDayOrNight = parentDayOrNight
        }
        
    }
    
    // MARK:  Setup Screen 
    
    func setupScreen() {
        
        let lastLoadedBackground = Utility.getLastLoadedBackground()

        // Ease in the image view
        self.weatherImage.alpha = 0.2
        weatherImage.image = UIImage(named: lastLoadedBackground)!
        
        UIView.animate(withDuration: 0.6, delay: 0.0, options: UIViewAnimationOptions.curveEaseIn, animations: {
            self.weatherImage.alpha = 1
            }, completion: nil)
        
        iconRefreshButton.layer.cornerRadius = 10.0
        iconRefreshButton.clipsToBounds = true
        iconRefreshButton.alpha = 0.85

        setRightBarButtonImage()
    }
    
    func setRightBarButtonImage () {
        
        customBarButtonAction.setImage(UIImage(named: "Menu"), for: UIControlState.normal)
        customBarButtonAction.addTarget(self, action: #selector(ParentWeatherVC.barBtnActionPressed(_:)), for: UIControlEvents.touchUpInside)
        //button.frame = CGRectMake(0, 0, 53, 31)
        customBarButtonAction.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        
        let barButton = UIBarButtonItem(customView: customBarButtonAction)
        titleBarNavItem.rightBarButtonItem = barButton
    }
    
    func setupTabs () {

        segmentedControl.initUI()
        segmentedControl.selectedSegmentIndex = TabIndex.FirstChildTab.rawValue
        displayCurrentTab(tabIndex: TabIndex.FirstChildTab.rawValue)
    }
    
   
    func setViewControllerTitle () {
        
        let titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: view.frame.size.width - 120, height: 44))
        titleLabel.backgroundColor = UIColor.clear
        titleLabel.numberOfLines = 1
        titleLabel.textAlignment = NSTextAlignment.center
        titleLabel.text = GlobalConstants.AppName
        titleBar.topItem?.titleView = titleLabel

    }
    
    func setupDayOrNightIndicator(dayOrNight : String) {
        
        // Delegate method. called form DailyTabVC
        parentDayOrNight = dayOrNight
    }
    
    // MARK: - Switching Tabs Functions
    @IBAction func switchTabs(_ sender: AnyObject) {
        
        self.switchViewControllers(sender)
    }
    
    func switchViewControllers(_ sender: AnyObject) {
        self.currentViewController!.view.removeFromSuperview()
        self.currentViewController!.removeFromParentViewController()
        
        displayCurrentTab(tabIndex: sender.selectedSegmentIndex)
    }

    func switchViewControllers() {
        
        if segmentedControl.selectedSegmentIndex == 0 {
            segmentedControl.selectedSegmentIndex = 1
        }
        else {
            segmentedControl.selectedSegmentIndex = 0
        }
        
        self.currentViewController!.view.removeFromSuperview()
        self.currentViewController!.removeFromParentViewController()
        
        displayCurrentTab(tabIndex: segmentedControl.selectedSegmentIndex)
    }

    func displayCurrentTab(tabIndex: Int){
        if let vc = viewControllerForSelectedSegmentIndex(index: tabIndex) {
            
            self.addChildViewController(vc)
            vc.didMove(toParentViewController: self)
            
            vc.view.frame = self.contentView.bounds
            self.contentView.addSubview(vc.view)
            self.currentViewController = vc
        }
    }
    
    func viewControllerForSelectedSegmentIndex(index: Int) -> UIViewController? {
        
        var vc: UIViewController?
        switch index {
        case TabIndex.FirstChildTab.rawValue :
            var vc1: TodayTabVC
            vc1 = firstChildTabVC as! TodayTabVC
            vc1.dailyWeather = weather
            vc1.weatherLocation = weatherLocation
            vc1.delegate = self
            vc = vc1
        case TabIndex.SecondChildTab.rawValue :
            var vc2: DailyTabVC
            vc2 = secondChildTabVC as! DailyTabVC
            vc2.dailyWeather = weather!
            vc2.weatherLocation = weatherLocation
            vc2.delegate = self
            vc = vc2
        default:
            return nil
        }
        
        return vc
    }    
    
    // Google Map API
    
    func getLatLngForZip(zipCode: String) {
        
// http://mhorga.org/2015/08/14/geocoding-in-ios.html
        
        // NOTE:  Google Maps Geocoding API has to be ENABLED against project in Google
        
        let baseUrl = "https://maps.googleapis.com/maps/api/geocode/json?"
        let apikey = GlobalConstants.GoogleMapAPIKey
        
        let url = NSURL(string: "\(baseUrl)address=\(zipCode)&key=\(apikey)")
        let data = NSData(contentsOf: url! as URL)
        let json = try! JSONSerialization.jsonObject(with: data! as Data, options: JSONSerialization.ReadingOptions.allowFragments) as! NSDictionary
        if let result = json["results"] as? NSArray {
            
            let x = result[0] as? NSDictionary
            
            let address = x?["formatted_address"] as? String
            if let geometry = x?["geometry"] as? NSDictionary {
                if let location = geometry["location"] as? NSDictionary {
                    let latitude = location["lat"] as! Float
                    let longitude = location["lng"] as! Float
                    print("\n\(latitude), \(longitude)" + " - " + address!)
                }
            }
        }
    }
    
    // MARK:  Weather Data Loading functions
    
    func getURLUnits() {
        
        // Populate the chosen URL units and save to constants
        
        let userDefaults = UserDefaults.standard
        var urlUnits = userDefaults.string(forKey: GlobalConstants.Defaults.URLDefaultUnits)
        
        if (urlUnits == nil) {
            urlUnits = GlobalConstants.DefaultURLUnit  // uk2
            GlobalConstants.urlUnitsChosen = GlobalConstants.DefaultURLUnit
            
            // Save this as a default
            userDefaults.set(urlUnits, forKey: GlobalConstants.Defaults.URLDefaultUnits)
            userDefaults.synchronize() //  Explicitly save the settings
        }
        else {
            GlobalConstants.urlUnitsChosen = urlUnits!
        }
        
    }
    
    func getURL(period: String) -> String {
        
        var returnURL = ""
        
        // Obtain the correct latitude and logitude.  This should be in our weatherLocation object
        
        var urlWithLocation = ""
        urlWithLocation = GlobalConstants.BaseWeatherURL + String(weatherLocation.currentLatitude!) + "," + String(weatherLocation.currentLongitude!)
        
        if (period == "LAST_YEAR") {

            // Add in the UNIX time of last year if we want to implement 'this time last year'
            // Place afer the latitude
            
            let today = Date()
            let lastYear = Calendar.current.date(byAdding: .year, value: -1, to: today)
            var thisTimeLastYear = lastYear?.timeIntervalSince1970
            
           // Note:  lround removes the .0 from the rounded Double
            urlWithLocation = urlWithLocation + "," + String(lround(Double((thisTimeLastYear!.description))!))
        }
        
        let urlUnits = GlobalConstants.urlUnitsChosen  // This should be set by now or set to default
        returnURL = urlWithLocation + "?units=" + urlUnits
        
        return returnURL
    }

    func getWeatherDataFromService(){

        // NOTE:  This function is called from a background thread
        let url = getURL(period: "NOW")
        
        print("URL= " + url)
        
        let scdService = GetWeatherData()
        
        // TODO;  If timed out, we dont seem to be getting a proper error code
        if (scdService == nil) {
            let message = "Weather details cannot be retrieved at this time.  Please try again"
            Utility.showMessage(titleString: "Error", messageString: message )
            self.view.hideToastActivity()
            iconRefreshButton.isEnabled = true
        }
        else {
            scdService.getData(urlAndParameters: url as String) {
                [unowned self] (response, error, headers, statusCode) -> Void in
                
                if statusCode >= 200 && statusCode < 300 {
                    
                    let data = response?.data(using: String.Encoding.utf8)
                    
                    do {
                        let getResponse = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! NSDictionary

                        print("Weather search complete")

                        self.tmpWeather = Weather(fromDictionary: getResponse )
                        self.weather = self.tmpWeather

                        NotificationCenter.default.post(name: GlobalConstants.weatherRefreshFinishedKey, object: nil)
                        
                        DispatchQueue.main.async {
                            
                            // Reenable controls
                            self.segmentedControl.isEnabled = true
                           // self.barButtonAction.isEnabled = true
                            self.customBarButtonAction.isEnabled = true
                            
                            if self.loadingMode == "STARTUP" {
                                self.setupTabs()
                            }
                            
                            // Hide animation on the main thread, once finished background task
                            self.view.hideToastActivity()
                            self.iconRefreshButton.isEnabled = true
                        }
                        
                    } catch let error as NSError {
                        print("json error: \(error.localizedDescription)")
                        
                        DispatchQueue.main.async {
                            let message = "Weather details cannot be retrieved at this time.  Please try again"
                            Utility.showMessage(titleString: "Error", messageString: message )
                            self.view.hideToastActivity()
                            self.iconRefreshButton.isEnabled = true
                        }
                    }
                    
                } else if statusCode == 404 {
                    // Create default message, may be overridden later if we have found something in response
                    let message = "Weather details cannot be retrieved at this time.  Please try again"
                    
                    DispatchQueue.main.async {
                        Utility.showMessage(titleString: "Error", messageString: message )
                        self.view.hideToastActivity()
                        self.iconRefreshButton.isEnabled = true
                    }
                    
                } else if statusCode == 2000 {
                    // Custom code for a timeout
                    let message = "Weather details cannot be retrieved at this time from Dark Sky.  Please try again"
                    
                    DispatchQueue.main.async {
                        Utility.showMessage(titleString: "Error", messageString: message )
                        self.view.hideToastActivity()
                        self.iconRefreshButton.isEnabled = true
                    }
                    
                } else {
                    DispatchQueue.main.async {
                        let message = "Weather details cannot be retrieved at this time.  Please try again"
                        Utility.showMessage(titleString: "Error", messageString: message )
                        self.iconRefreshButton.isEnabled = true
                    }
                }
            }
        }  // End IF
    }
    
    
    func refreshLocationAndWeatherData() {
        
        // We want to refresh the Location and Weather data and populate the objects.
        // Once done, the weatherRefreshed notification will fire and then the relevant screen
        // updates can be performed in DailyTabVC and TodayTabVC accordingly
        
        loadingMode = "REFRESHING"
        
        self.getAndSetLocation()
        // NOTE:  Weather data will be retrieved once the Location data has loaded and notified
    }
    

    func returnRefreshedWeatherDetails() -> Weather {
        
        return weather!
    }
    

    // MARK:- Location details
    
    func returnRefreshedLocationDetails() -> Location {
        
        return weatherLocation
    }


    func retrieveWeatherAndLocationData () {
        
        self.getAndSetLocation()
        
        // NOTE:  The setup of the screen in the tabs will be done after getWeatherDataFromService() has finished
    }
    
    func retrieveWeatherData () {
  
        // Make a toast to say data is refreshing
//        self.view.makeToast("Refreshing data", duration: 1.0, position: .bottom)
//        self.view.makeToastActivity(.center)
        iconRefreshButton.isEnabled = false
        
        getWeatherDataFromService()
        
        // NOTE:  The setup of the screen in the tabs will be done after getWeatherDataFromService() has finished
    }
    
    func allowedToUseLocation () -> Bool {
    
        // If user has not allowed location services, display standard Apple message to allow
        // user to turn on location services
        
        var allowed = false
        
        if (CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse ||
            CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedAlways) {
            
            allowed = true
        }
        else {

            self.locationManager.requestAlwaysAuthorization();
            allowed = false
        }

        return allowed
    }
    
    func getAndSetLocation() {
        
        // Get the current location and the weather data based on location
        
        locationFound = getLocation()
    }
    
    func getLocation() -> Bool {
        
        //locationManager = CLLocationManager()

        var lFound = false

        self.view.makeToast("Refreshing data", duration: 2.0, position: .bottom)
        self.view.makeToastActivity(.center)
        iconRefreshButton.isEnabled = false

        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        
        locationManager.startUpdatingLocation()
        locationManager.startMonitoringSignificantLocationChanges()
        
        // Check if the user allowed authorization (TODO:  authorized replaced with authorizedAlways?)
        if (CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse ||
            CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedAlways)
        {
            print(locationManager.location ?? "Location Error")
            if locationManager.location != nil {
                
                lFound = true
                locationManager.stopUpdatingLocation()
                locationManager.stopMonitoringSignificantLocationChanges()

                var currentLocation = CLLocation()
                currentLocation = locationManager.location!
                
                weatherLocation.currentLatitude = currentLocation.coordinate.latitude
                weatherLocation.currentLongitude = currentLocation.coordinate.longitude
                weatherLocation.currentLocation = currentLocation
                
                // Note:  Toast will be hidden in setLocationDetails
                setLocationDetails()

            }
            
        } else {
            
            // Location settings not enabled on the phone, prompt user t do it manually
            
            Utility.showMessage(titleString: "Error", messageString: "Cannot find your current location.  Please ensure that Skycast is allowed to access your location on this device. \n\nGo to Settings -> SkyCast and turn Location to Always" )
            
            locationManager.stopUpdatingLocation()
            locationManager.stopMonitoringSignificantLocationChanges()
            self.view.hideToastActivity()
            iconRefreshButton.isEnabled = true
            
            // NOTE:  We dont want to post a finished notification here since its likely that the
            // iPhone is asking the user to allow location to be used.  Or location service is off.
   //         NotificationCenter.default.post(name: GlobalConstants.locationRefreshFinishedKey, object: nil)

        }
        
        return lFound
    }
    
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        
//        // The following will be called when the location has been updated.
//        // The last location will be stored in the last element of the locations array
//        
//        let latestLocation = locations.last
//        weatherLocation.currentLatitude = latestLocation!.coordinate.latitude
//        weatherLocation.currentLongitude = latestLocation!.coordinate.longitude
//        weatherLocation.currentLocation = latestLocation
//        
//        setLocationDetails()
//    }
    
    func setLocationDetails()
    {

        let location = CLLocation(latitude: weatherLocation.currentLatitude!, longitude: weatherLocation.currentLongitude!)
        
        geoCoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) -> Void in
            
            if error != nil {
                
                DispatchQueue.main.async {
                    print("Reverse geocoder failed with error" + (error?.localizedDescription)!)
                    Utility.showMessage(titleString: "Error", messageString: "Cannot find your current location, please try again" )
                    self.view.hideToastActivity()
                    self.iconRefreshButton.isEnabled = true
                
                    NotificationCenter.default.post(name: GlobalConstants.locationRefreshFinishedKey, object: nil)
                }
                return
            }
            if (placemarks?.count)! > 0 {

                // We have data

                let placeArray = placemarks as [CLPlacemark]!

                // Place details
                var placeMark: CLPlacemark!
                placeMark = placeArray?[0]  // Address dictionary

                // Location name
                if let locationName = placeMark.addressDictionary?["Name"] as? NSString
                {
                    print(locationName)
                }

                // Street address
                if let street = placeMark.addressDictionary?["Thoroughfare"] as? NSString
                {
                    self.weatherLocation.currentStreet = street as String
                    print(street)
                }

                // City
                if let city = placeMark.addressDictionary?["City"] as? NSString
                {
                    self.weatherLocation.currentCity = city as String
                    print(city)
                }

                // Zip code
                if let zip = placeMark.addressDictionary?["ZIP"] as? NSString
                {
                    print(zip)
                    self.weatherLocation.currentPostcode = zip as String
                }

                // Country
                if let country = placeMark.addressDictionary?["Country"] as? NSString
                {
                    self.weatherLocation.currentCountry = country as String
                    print(country)
                    
                }
                
                if let countryCode = placeMark.addressDictionary?["CountryCode"] as? NSString
                {
                    self.weatherLocation.currentCountryCode = countryCode as String
                    print(countryCode)
                    
                }
                
                DispatchQueue.main.async {
                    
                    self.view.hideToastActivity()

                    NotificationCenter.default.post(name: GlobalConstants.locationRefreshFinishedKey, object: nil)
                }
            }
                
            else {
                print("Problem with the data received from geocoder")
                
                DispatchQueue.main.async {
                    Utility.showMessage(titleString: "Error", messageString: "Cannot find your current location, please try again" )
                    self.view.hideToastActivity()
                    self.iconRefreshButton.isEnabled = true
                    NotificationCenter.default.post(name: GlobalConstants.locationRefreshFinishedKey, object: nil)
                }
            }
        })
        
    }
    
    // MARK:- Button methods
    
    
    @IBAction func refreshButtonPressed(_ sender: AnyObject) {
        
        // If user has not allowed location services, warn them to turn it on
        // Otherwise get weather details
        
        if allowedToUseLocation() {
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
                retrieveWeatherAndLocationData()
            }
            else
            {
                // Internet Connection not Available!
                Utility.showMessage(titleString: "Error", messageString: "You are not connected to the internet.  Please check your cellular or wi-fi settings" )
            }
        }
        else {
            
            Utility.showMessage(titleString: "Error", messageString: "Cannot find your current location.  Please ensure that Skycast is allowed to access your location on this device. \n\nGo to Settings -> SkyCast and turn Location to Always" )

            iconRefreshButton.isEnabled = true

        }
    }
    
    
    @IBAction func barBtnActionPressed(_ sender: AnyObject) {
        
        let actionMenu = UIAlertController(title: "Menu", message: "", preferredStyle: UIAlertControllerStyle.actionSheet)
        
        if let popover = actionMenu.popoverPresentationController{
            
            popover.barButtonItem = sender as? UIBarButtonItem
            popover.permittedArrowDirections = UIPopoverArrowDirection.down
            popover.popoverLayoutMargins = UIEdgeInsets(top: 10, left: 4, bottom: 10, right: 4)
        }
        
        if (AppSettings.showThisTimeLastYear) {
            actionMenu.addAction(thisTimeLastYearAction)
        }

        if (AppSettings.showTimeline) {
            actionMenu.addAction(sunriseSunsetAction)
        }
        
        actionMenu.addAction(showSettingsAction)
        actionMenu.addAction(showAboutAction)
        // Adding Cancel allows user to click outside of menu to dismiss alert
        actionMenu.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        self.present(actionMenu, animated: true, completion: nil)
        
    }
    
    // MARK:- Menu action methods

    var thisTimeLastYearAction: UIAlertAction {
        return UIAlertAction(title: Menu.ThisTimeLastYear.rawValue, style: .default, handler: { (alert) -> Void in
            
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "ThisTimeLastYearSegue", sender: self)
            }
        })
    }
    
    var sunriseSunsetAction: UIAlertAction {
        return UIAlertAction(title: Menu.SunriseSunset.rawValue, style: .default, handler: { (alert) -> Void in
            
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "sunriseSunsetSegue", sender: self)
            }
        })
    }

   var showSettingsAction: UIAlertAction {
        return UIAlertAction(title: Menu.ShowSettings.rawValue, style: .default, handler: { (alert) -> Void in
            
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "settingsScreenSegue", sender: self)
            }
        })
    }
    
    var showAboutAction: UIAlertAction {
        return UIAlertAction(title: Menu.ShowAbout.rawValue, style: .default, handler: { (alert) -> Void in
            
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "aboutScreenSegue", sender: self)
            }
        })
    }
    

    func refreshData() {
        print("refreshing data")
    }
    
    // MARK:  Notification Completion methods
    func locationDataRefreshed() {
        // NOTE:  This will be called on a background thread
        
        print("Location Data Refreshed - Parent")
//        self.view.hideToastActivity()
        
        // Toast will be hidden after the data has been retrieved
        retrieveWeatherData()
        
    }
    
    func weatherDataRefreshed() {
        print("Weather Data Refreshed - Parent")
        self.view.hideToastActivity()

    }
    
    // MARK:  SettingsViewControllerDelegate delegate Methods
    func refreshDataAfterSettingChange() {

        Reach().monitorReachabilityChanges()
        
        var connectedToInternet = false
        let status = Reach().connectionStatus()
        switch status {
        case .unknown, .offline:
            print("Not connected")
        case .online(.wwan):
            print("Connected via WWAN")
            connectedToInternet = true
        case .online(.wiFi):
            print("Connected via WiFi")
            connectedToInternet = true
        }
        
        if connectedToInternet
        {
            // Force tab back to main screen (TODO:  Review)
            segmentedControl.selectedSegmentIndex = TabIndex.FirstChildTab.rawValue
            displayCurrentTab(tabIndex: TabIndex.FirstChildTab.rawValue)

            retrieveWeatherAndLocationData()
        }
        else
        {
            // Internet Connection not Available!
            Utility.showMessage(titleString: "Error", messageString: "You are not connected to the internet.  Please check your cellular or wi-fi settings" )
        }
    }
    
    // MARK:  Reach methods
    func networkStatusChanged(_ notification: Notification) {
        let userInfo = (notification as NSNotification).userInfo
        print(userInfo ?? "Network Status Changed Default Message")
    }

}


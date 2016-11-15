//
//  ParentWeatherVC.swift
//  MGWeather
//
//  Created by Mark Gumbs on 30/08/2016.
//

import UIKit
import CoreLocation

class ParentWeatherVC: UIViewController, CLLocationManagerDelegate, SettingsViewControllerDelegate, TodayTabVCDelegate, DailyTabVCDelegate  {

    // https://ahmedabdurrahman.com/2015/08/31/how-to-switch-view-controllers-using-segmented-control-swift/
    
    enum TabIndex : Int {
        case FirstChildTab = 0
        case SecondChildTab = 1
    }
    
    @IBOutlet weak var segmentedControl: WeatherSegmentedControl!
    @IBOutlet weak var titleBar: UINavigationBar!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var weatherImage : UIImageView!
    @IBOutlet weak var refreshButton : UIButton!

    enum Menu: String {
        case Weather = "Weather"
        case ShowSettings = "App Settings"
        case ShowAbout = "About"
    }
    
    var locationManager: CLLocationManager!
    //var locationManager = CLLocationManager()
    var locationFound: Bool!
    var locationName: String!
    
    var weather: Weather?
    var tmpWeather : Weather?
    var weatherLocation = Location()
    let geoCoder = CLGeocoder()
    
    var currentViewController: UIViewController?
    
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
        
        setupScreen()
        segmentedControl.isEnabled = false
        
        NotificationCenter.default.addObserver(self, selector: #selector(ParentWeatherVC.networkStatusChanged(_:)), name: NSNotification.Name(rawValue: ReachabilityStatusChangedNotification), object: nil)
        
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
            self.view.hideToastActivity()
            refreshButton.isEnabled = true
        }
        
        setViewControllerTitle()

    }
    

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let currentViewController = currentViewController {
            currentViewController.viewWillDisappear(animated)
        }
    }
    
    func setupScreen() {
        
        let lastLoadedBackground = Utility.getLastLoadedBackground()

        // Ease in the image view
        self.weatherImage.alpha = 0.2
        weatherImage.image = UIImage(named: lastLoadedBackground)!
        
        UIView.animate(withDuration: 0.6, delay: 0.0, options: UIViewAnimationOptions.curveEaseIn, animations: {
            self.weatherImage.alpha = 1
            }, completion: nil)
        
        refreshButton.layer.cornerRadius = 5.0
        refreshButton.clipsToBounds = true

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
        //titleLabel.font = UIFont(name: UIConfig.Fonts.OswaldRegular,  size: 16)
        titleLabel.textAlignment = NSTextAlignment.center
        titleLabel.text = GlobalConstants.AppName
        titleBar.topItem?.titleView = titleLabel

    }
/*
    func setLocationInTitle () {
        
        let titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: view.frame.size.width - 120, height: 44))
        titleLabel.backgroundColor = UIColor.clear
        titleLabel.numberOfLines = 1
        //titleLabel.font = UIFont(name: UIConfig.Fonts.OswaldRegular,  size: 16)
        titleLabel.textAlignment = NSTextAlignment.center
        titleLabel.text = weatherLocation.currentCity! + ", " + weatherLocation.currentCountry!
        titleBar.topItem?.titleView = titleLabel
        
    }
*/
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if (segue.identifier == "settingsScreenSegue") {
            
            let vc:SettingsViewController = segue.destination as! SettingsViewController
            vc.delegate = self
        }
        
        if (segue.identifier == "aboutScreenSegue") {
            
            
        }
        
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
    
    
    // MARK:  Weather Data Loading functions
    
    func getURL () -> String {
        
        var returnURL = ""
        
        // Obtain the correct latitude and logitude.  This should be in our weatherLocation object
//        var url = GlobalConstants.BaseWeatherURL + String(weatherLocation.currentLatitude!) + "," + String(weatherLocation.currentLongitude!)
        
        // Find out if user preference is celsuis or fahenheight.  Pass relevant parameter on url
        let userDefaults = UserDefaults.standard
        var celsuisOrFahrenheit = userDefaults.string(forKey: GlobalConstants.Defaults.SavedTemperatureUnits)
        
        if (celsuisOrFahrenheit == nil) {
            celsuisOrFahrenheit = GlobalConstants.DefaultTemperatureUnit  // Celsius
        }
        
        if celsuisOrFahrenheit == GlobalConstants.TemperatureUnits.Celsuis {
            returnURL = GlobalConstants.WeatherURL + GlobalConstants.celsiusURLParameter
        }
        else {
            returnURL = GlobalConstants.WeatherURL
        }
        
        return returnURL
    }

    func getWeatherDataFromService(){

        // NOTE:  This function is called from a background thread
        let url = getURL()
        
        print("URL= " + url)
        
        let scdService = GetWeatherData()
        
        scdService.getData(urlAndParameters: url as String) {
            [unowned self] (response, error, headers, statusCode) -> Void in
            
            if statusCode >= 200 && statusCode < 300 {
                
                let data = response?.data(using: String.Encoding.utf8)
                
                do {
                    let getResponse = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! NSDictionary

                    print("Weather search finished")

                    self.tmpWeather = Weather(fromDictionary: getResponse )
                    self.weather = self.tmpWeather
                    
                    NotificationCenter.default.post(name: GlobalConstants.weatherRefreshFinishedKey, object: nil)

                    DispatchQueue.main.async {
                        self.segmentedControl.isEnabled = true
                        self.setupTabs()
                        
                        // Hide animation on the main thread, once finished background task
                        self.view.hideToastActivity()
                        self.refreshButton.isEnabled = true
                    }
                    
                } catch let error as NSError {
                    print("json error: \(error.localizedDescription)")
                    
                    //                 self.serviceCallFailure(alertTitle: "Error", withMessage: "There was an error processing the response.  Please try again later.  If it persists, please raise a fault with ITSC")
                }
                
            } else if statusCode == 404 {
                // Create default message, may be overridden later if we have found something in response
                var message = "Weather details cannot be retrieved at this time.  Please try again"
                
                // Check to see why we got a 404.
                if let errorString = error?.localizedDescription , !errorString.isEmpty {

                    if errorString.lowercased().range(of: "custaa_cpva_9003") != nil {
                        message = "Weather details cannot be retrieved at this time.  Please try again"
                    }
                        
                }
                
                //             self.serviceCallFailure(alertTitle: "Error", withMessage: message)
            } else {
                //              self.serviceCallFailure(alertTitle: "Error", withMessage: "Customer service cannot be retrieved.  Please try again later.  If it persists, please raise a fault with ITSC")
            }
        }
    }
    
    func refreshWeatherDataFromService2(completionHandler: @escaping GlobalConstants.CompletionHandlerType) {

        // NOTE:  This function is called from a background thread
        let url = getURL()
        
        print("URL= " + url)
        
        let scdService = GetWeatherData()
        
        scdService.getData(urlAndParameters: url as String) {
            [unowned self] (response, error, headers, statusCode) -> Void in
            
            if statusCode >= 200 && statusCode < 300 {
                
                let data = response?.data(using: String.Encoding.utf8)
                
                do {
                    let getResponse = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! NSDictionary
                    
                    print("Weather search finished")
                    
                    self.tmpWeather = Weather(fromDictionary: getResponse )
                    self.weather = self.tmpWeather

                    // Return the updated Weather object of successful
                    completionHandler(GlobalConstants.CompletionResult.Success(self.tmpWeather as AnyObject?))
                    
                } catch let error as NSError {
                    print("json error: \(error.localizedDescription)")
                    completionHandler(GlobalConstants.CompletionResult.Failure(GlobalConstants.CompletionError.AuthenticationFailure))
                }
                
            } else if statusCode == 404 {
                // Create default message, may be overridden later if we have found something in response
                let message = "Weather details cannot be retrieved at this time.  Please try again"
                Utility.showMessage(titleString: "Error", messageString: message )

                // Check to see why we got a 404.
//                if let errorString = error?.localizedDescription , !errorString.isEmpty {
//                    // "No customers found for search"
//                    
//                    if errorString.lowercased().range(of: "custaa_cpva_9003") != nil {
//                        message = "Weather details cannot be retrieved at this time.  Please try again"
//                    }
//                    
//                }
                completionHandler(GlobalConstants.CompletionResult.Failure(GlobalConstants.CompletionError.AuthenticationFailure))

                //             self.serviceCallFailure(alertTitle: "Error", withMessage: message)
            } else {
                let message = "Weather details cannot be retrieved at this time.  Please try again"
                Utility.showMessage(titleString: "Error", messageString: message )
            }
        }
    }
    
    
    func refreshWeatherDataFromService() {
        
        // NOTE:  This function is called from a background thread
        let url = getURL()
        
        print("URL= " + url)
        
        let scdService = GetWeatherData()
        
        scdService.getData(urlAndParameters: url as String) {
            [unowned self] (response, error, headers, statusCode) -> Void in
            
            if statusCode >= 200 && statusCode < 300 {
                
                let data = response?.data(using: String.Encoding.utf8)
                
                do {
                    let getResponse = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! NSDictionary
                    
                    // self.customerDataDictionary = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as! NSDictionary
                    
                    // Hide animation on the main thread, once finished background task
                    //dispatch_async(dispatch_get_main_queue()) {
                    //                       self.view.hideToastActivity()
                    print("Weather search finished")
                    //}
                    
                    self.tmpWeather = Weather(fromDictionary: getResponse )
                    self.weather = self.tmpWeather
                    
                    //   DispatchQueue.main.async {
                    //       self.setupTabs()
                    //       self.setupScreen()
                    //   }
                    
                } catch let error as NSError {
                    print("json error: \(error.localizedDescription)")
                }
                
            } else if statusCode == 404 {
                // Create default message, may be overridden later if we have found something in response
                let message = "Weather details cannot be retrieved at this time.  Please try again"
                Utility.showMessage(titleString: "Error", messageString: message )
                
//                // Check to see why we got a 404.
//                if let errorString = error?.localizedDescription , !errorString.isEmpty {
//                    // "No customers found for search"
//                    
//                    if errorString.lowercased().range(of: "custaa_cpva_9003") != nil {
//                        message = "Weather details cannot be retrieved at this time.  Please try again"
//                    }
//                    
//                }
                
            } else {
                let message = "Weather details cannot be retrieved at this time.  Please try again"
                Utility.showMessage(titleString: "Error", messageString: message )
            }
        }
    }

//    func fetch(completionHandler: CompletionHandlerType) {
//        let random = Int(arc4random_uniform(7))
//        if (random > 4) {
//            completionHandler(CompletionResult.Success(1 as AnyObject?))
//        } else {
//            completionHandler(CompletionResult.Failure(CompletionError.AuthenticationFailure))
//        }
//    }

    func returnRefreshedWeatherDetails() -> Weather {
        
        return weather!
    }
    

    // MARK:- Location details
    
    func returnRefreshedLocationDetails() -> Location {
        
        return weatherLocation
    }


    func retrieveWeatherAndLocationData () {
        
        self.getAndSetLocation()
        
        // Make a toast to say data is refreshing
        self.view.makeToast("Refreshing weather data", duration: 1.0, position: .bottom)
        self.view.makeToastActivity(.center)
        refreshButton.isEnabled = false
        
        getWeatherDataFromService()
        
        // NOTE:  The setup of the screen in the tabs will be done after getWeatherDataFromService() has finished
    }
    
    func getAndSetLocation() {
        
        // Get the current location and the weather data based on location
        
        locationFound = getLocation()
        if locationFound == true {
            //  setUsersClosestCity()
        }
        
    }
    
    func getLocation() -> Bool {
        
        locationManager = CLLocationManager()

        var locationFound = false

        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.requestWhenInUseAuthorization()
        locationManager.startMonitoringSignificantLocationChanges()
        
        // Check if the user allowed authorization (TODO:  authorized replaced with authorizedAlways?)
        if (CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse ||
            CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedAlways)
        {
            print(locationManager.location ?? "Location Error")
            if locationManager.location != nil {
                
                locationFound = true
                locationManager.stopUpdatingLocation()
                locationManager.stopMonitoringSignificantLocationChanges()

                //  didUpdateLocations will populate longitude and latitude here
            }
            
        } else {
            Utility.showMessage(titleString: "Error", messageString: "Cannot find your current location, please try again" )
            locationManager.stopUpdatingLocation()
            locationManager.stopMonitoringSignificantLocationChanges()
            self.view.hideToastActivity()
            refreshButton.isEnabled = true

        }
        
        return locationFound
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        // The following will be called when the location has been updated.
        // The last location will be stored in the last element of the locations array
        
        let latestLocation = locations.last
        weatherLocation.currentLatitude = latestLocation!.coordinate.latitude
        weatherLocation.currentLongitude = latestLocation!.coordinate.longitude
        weatherLocation.currentLocation = locations.last
        
        setUsersClosestCity()
    }
    
    func setUsersClosestCity()
    {

        let location = CLLocation(latitude: weatherLocation.currentLatitude!, longitude: weatherLocation.currentLongitude!)
        
        geoCoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) -> Void in
            
            if error != nil {
                print("Reverse geocoder failed with error" + (error?.localizedDescription)!)
                Utility.showMessage(titleString: "Error", messageString: "Cannot find your current location, please try again" )
                self.view.hideToastActivity()
                self.refreshButton.isEnabled = true
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
                
                NotificationCenter.default.post(name: GlobalConstants.locationRefreshFinishedKey, object: nil)
                
            }
                
            else {
                print("Problem with the data received from geocoder")
                Utility.showMessage(titleString: "Error", messageString: "Cannot find your current location, please try again" )
                self.view.hideToastActivity()
                self.refreshButton.isEnabled = true

            }
            
        })
        
    }
    
    
    @IBAction func refreshButtonPressed(_ sender: AnyObject) {
        
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
    
    
    @IBAction func barBtnActionPressed(_ sender: AnyObject) {
        
        let actionMenu = UIAlertController(title: "Actions", message: "", preferredStyle: UIAlertControllerStyle.actionSheet)
        
        if let popover = actionMenu.popoverPresentationController{
            
            popover.barButtonItem = sender as! UIBarButtonItem
            popover.permittedArrowDirections = UIPopoverArrowDirection.down
            popover.popoverLayoutMargins = UIEdgeInsets(top: 10, left: 4, bottom: 10, right: 4)
        }
        
        actionMenu.addAction(weatherAction)
        actionMenu.addAction(showSettingsAction)
        actionMenu.addAction(showAboutAction)
        
        self.present(actionMenu, animated: true, completion: nil)
        
    }
        
    // MARK:- Menu action methods
    
    var weatherAction: UIAlertAction {
        return UIAlertAction(title: Menu.Weather.rawValue, style: .default, handler: { (alert) -> Void in

            // We just want to dismiss the popover to return to the weather view
            self.dismiss(animated: true, completion: nil)
        })
    }

   var showSettingsAction: UIAlertAction {
        return UIAlertAction(title: Menu.ShowSettings.rawValue, style: .default, handler: { (alert) -> Void in
            
        //    DispatchQueue.main.async {
                self.performSegue(withIdentifier: "settingsScreenSegue", sender: self)
        //    }
        })
    }
    
    var showAboutAction: UIAlertAction {
        return UIAlertAction(title: Menu.ShowAbout.rawValue, style: .default, handler: { (alert) -> Void in
            
          //  DispatchQueue.main.async {
                self.performSegue(withIdentifier: "aboutScreenSegue", sender: self)
          //  }
        })
    }
    

    func refreshData() {
        print("refreshing data")
    }
    
    // SettingsViewControllerDelegate delegate Methods
    func refreshDataAfterSettingChange() {

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
    
    // MARK:  Reach methods
    func networkStatusChanged(_ notification: Notification) {
        let userInfo = (notification as NSNotification).userInfo
        print(userInfo)
    }

}


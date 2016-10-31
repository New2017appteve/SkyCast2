//
//  ParentWeatherVC.swift
//  MGWeather
//
//  Created by Mark Gumbs on 30/08/2016.
//  Copyright © 2016 britishairways. All rights reserved.
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
    @IBOutlet weak var refreshButton : UIButton!

    enum Menu: String {
        case Weather = "Weather"
        case ShowSettings = "App Settings"
        case ShowAbout = "About"
    }
    
    var locationManager = CLLocationManager()
    var locationFound: Bool!
    var locationName: String!
    
    var weather: Weather?
    var tmpWeather : Weather?
    var weatherLocation = Location()
    
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
        
        segmentedControl.isEnabled = false
        
        if Reachability.isConnectedToNetwork() == true
        {
            retrieveWeatherAndLocationData()
        }
        else
        {
            // Internet Connection not Available!
            Utility.showMessage(titleString: "Error", messageString: "You are not connected to the internet.  Please check your cellular or wi-fi settings" )
        }
        
        setViewControllerTitle()

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let currentViewController = currentViewController {
            currentViewController.viewWillDisappear(animated)
        }
    }
    
    func retrieveWeatherAndLocationData () {
       
        // Get the current location and the weather data based on location
        
        locationFound = getLocation()
        if locationFound == true {
            setUsersClosestCity()
        }
        
        
        // Make a toast to say data is refreshing
        self.view.makeToast("Refreshing weather data", duration: 1.0, position: .bottom)
        self.view.makeToastActivity(.center)
        
        getWeatherDataFromService()
        
        // NOTE:  The setup of the screen in the tabs will be done after getWeatherDataFromService() has finished
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
        self.currentViewController!.view.removeFromSuperview()
        self.currentViewController!.removeFromParentViewController()
        
        displayCurrentTab(tabIndex: sender.selectedSegmentIndex)
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
            vc2.delegate = self
            vc = vc2
        default:
            return nil
        }
        
        return vc
    }    

    // MARK:  Customer Data Loading functions
    
    func getURL () -> String {
        
        var returnURL = ""
        let latitude = weatherLocation.currentLatitude
        
        // Obtain the correct latitude and logitude.  This should be in our weatherLocation object
//        var url = GlobalConstants.BaseWeatherURL + String(latitude!) + "," + String(weatherLocation.currentLongitude!)
        
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
                    
                    DispatchQueue.main.async {
                        self.segmentedControl.isEnabled = true
                        self.setupTabs()
                        
                        // Hide animation on the main thread, once finished background task
                        self.view.hideToastActivity()
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
                var message = "Weather details cannot be retrieved at this time.  Please try again"
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
                var message = "Weather details cannot be retrieved at this time.  Please try again"
                Utility.showMessage(titleString: "Error", messageString: message )
            }
        }
    }
    
    
    func refreshWeatherDataFromService() {
        
        // NOTE:  This function is called from a background thread
        //let url = GlobalConstants.WeatherURL
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
                var message = "Weather details cannot be retrieved at this time.  Please try again"
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
                var message = "Weather details cannot be retrieved at this time.  Please try again"
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

    // MARK:- Location details
    
    func getLocation() -> Bool {
        
        var locationFound = false
        
        // TODO:  Review to see if needed
        
//       // let locationManager = CLLocationManager()
//        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
//        locationManager.delegate = self;
//
//        var status = CLLocationManager.authorizationStatus()
//        if status == .NotDetermined || status == .Denied || status == .AuthorizedWhenInUse {
//            // present an alert indicating location authorization required
//            // and offer to take the user to Settings for the app via
//            // UIApplication -openUrl: and UIApplicationOpenSettingsURLString
//            locationManager.requestAlwaysAuthorization()
//            locationManager.requestWhenInUseAuthorization()
//        }
//        locationManager.startUpdatingLocation()
//        locationManager.startUpdatingHeading()
        
        
        //setLocationInTitle()

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
            print(locationManager.location)
            if locationManager.location != nil {
                
                locationFound = true
                weatherLocation.currentLatitude = locationManager.location!.coordinate.latitude
                weatherLocation.currentLongitude = locationManager.location!.coordinate.longitude
            }
            
        } else {
            Utility.showMessage(titleString: "Error", messageString: "Cannot find your current location, please try again" )
        }
        
        return locationFound
    }
    
    func setUsersClosestCity()
    {
        let geoCoder = CLGeocoder()
        let location = CLLocation(latitude: weatherLocation.currentLatitude!, longitude: weatherLocation.currentLongitude!)
        geoCoder.reverseGeocodeLocation(location)
        {
            (placemarks, error) -> Void in
            
            if error != nil {
                print("Reverse geocoder failed with error" + (error?.localizedDescription)!)
                Utility.showMessage(titleString: "Error", messageString: "Cannot find your current location, please try again" )
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
                }
                
                // Country
                if let country = placeMark.addressDictionary?["Country"] as? NSString
                {
                    self.weatherLocation.currentCountry = country as String
                    print(country)
                    
                }
                
                //self.setLocationInTitle()
                
            }
                
                
            else {
                print("Problem with the data received from geocoder")
                Utility.showMessage(titleString: "Error", messageString: "Cannot find your current location, please try again" )

            }
            
        }
    }
    
    @IBAction func refreshButtonPressed(_ sender: AnyObject) {
        
        if Reachability.isConnectedToNetwork() == true
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
        
        if Reachability.isConnectedToNetwork() == true
        {
            retrieveWeatherAndLocationData()
        }
        else
        {
            // Internet Connection not Available!
            Utility.showMessage(titleString: "Error", messageString: "You are not connected to the internet.  Please check your cellular or wi-fi settings" )
        }

    }

}


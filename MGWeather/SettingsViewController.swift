//
//  SettingsViewController.swift
//  MGWeather
//
//  Created by Mark Gumbs on 20/07/2016.
//

import UIKit
import GoogleMobileAds

protocol SettingsViewControllerDelegate
{
    func refreshData()
    func refreshDataAfterSettingChange()
}

class SettingsViewController: UIViewController {

    var delegate:SettingsViewControllerDelegate?
    
    @IBOutlet weak var weatherImage : UIImageView!
    @IBOutlet weak var settingsView: UIView!
    
    @IBOutlet weak var colourSchemeTitle : UILabel!
    @IBOutlet weak var colourSchemeControl : UISegmentedControl!
    @IBOutlet weak var tempUnitsTitle : UILabel!
    @IBOutlet weak var tempUnitsControl : UISegmentedControl!
    
    @IBOutlet weak var tempUnitsDescriptionView: UIView!
    @IBOutlet weak var usUnitLabel : UILabel!
    @IBOutlet weak var siUnitLabel : UILabel!
    @IBOutlet weak var ukUnitLabel : UILabel!
    @IBOutlet weak var caUnitLabel : UILabel!
    
    @IBOutlet weak var dayNightColourTitle : UILabel!
    @IBOutlet weak var dayNightColourControl : UISegmentedControl!
    
    /// The banner view.
    @IBOutlet weak var bannerView: GADBannerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        loadSettings()
        setupScreen()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupScreen ()
        
        // Ease in the outer screen view for effect
        self.weatherImage.alpha = 0.2
        self.settingsView.alpha = CGFloat(GlobalConstants.DisplayViewAlpha)
        UIView.animate(withDuration: 0.8, delay: 0.15, options: UIViewAnimationOptions.curveEaseIn, animations: {
                self.weatherImage.alpha = CGFloat(GlobalConstants.DisplayViewAlpha)
            }, completion: nil)
        
        // Ease in the two pods
        self.settingsView.alpha = 0.0
        UIView.animate(withDuration: 1.5, delay: 0.5, options: UIViewAnimationOptions.curveEaseIn, animations: {
            self.settingsView.alpha = CGFloat(GlobalConstants.DisplayViewAlpha)
        }, completion: nil)

    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func setupScreen () {

        // Make round corners for the outerviews
        settingsView.layer.cornerRadius = 10.0
        settingsView.clipsToBounds = true
        
        tempUnitsDescriptionView.layer.borderWidth = 1.0
        tempUnitsDescriptionView.layer.cornerRadius = 5
        tempUnitsDescriptionView.clipsToBounds = true

        changeBackground()
        setupColourScheme()
       
        if AppSettings.ShowBannerAds {
            loadBannerAd()
        }
    }
    
    func setupColourScheme() {
        
        // Setup pods and text colour accordingly
        
        let colourScheme = Utility.setupColourScheme()
        
        let textColourScheme = colourScheme.textColourScheme
        let podColourScheme = colourScheme.podColourScheme
        
        // Labels
        tempUnitsTitle.textColor = textColourScheme
        dayNightColourTitle.textColor = textColourScheme
        colourSchemeTitle.textColor = textColourScheme
        usUnitLabel.textColor = textColourScheme
        ukUnitLabel.textColor = textColourScheme
        siUnitLabel.textColor = textColourScheme
        caUnitLabel.textColor = textColourScheme
        
        // Pods
        settingsView.backgroundColor = podColourScheme
        settingsView.alpha = CGFloat(GlobalConstants.DisplayViewAlpha)
        
        // Borders
        tempUnitsDescriptionView.layer.borderColor = textColourScheme?.cgColor
        
        // Segmented Controls

        // Change default colours if dark theme
        if (colourScheme.type == GlobalConstants.ColourScheme.Dark) {
            changeSegmentedControlColours(scheme: GlobalConstants.ColourScheme.Dark)
        }
        else {
            changeSegmentedControlColours(scheme: GlobalConstants.ColourScheme.Light)
        }
        
    }

    func changeBackground () {
    
        // Change the background between three different types
        
        var backgroundImageName : String!
        
        let rand = Int(arc4random_uniform(3))
        switch (rand) {
        case 0:
            backgroundImageName = GlobalConstants.SettingsScreenBackground.One.rawValue
        case 1:
            backgroundImageName = GlobalConstants.SettingsScreenBackground.Two.rawValue
        case 2:
            backgroundImageName = GlobalConstants.SettingsScreenBackground.Three.rawValue
        default:
            backgroundImageName = GlobalConstants.SettingsScreenBackground.One.rawValue
        }

        weatherImage.image = UIImage(named: backgroundImageName)!

    }
    
    
    func changeSegmentedControlColours(scheme : String) {
        
        if (scheme == GlobalConstants.ColourScheme.Dark) {
            (dayNightColourControl.subviews[0] as UIView).tintColor = GlobalConstants.SegmentedControlTheme.Dark.Buttons
            (dayNightColourControl.subviews[1] as UIView).tintColor = GlobalConstants.SegmentedControlTheme.Dark.Buttons
            dayNightColourControl.setTitleTextAttributes([NSForegroundColorAttributeName: GlobalConstants.SegmentedControlTheme.Dark.Text], for: UIControlState.selected)
            
            (tempUnitsControl.subviews[0] as UIView).tintColor = GlobalConstants.SegmentedControlTheme.Dark.Buttons
            (tempUnitsControl.subviews[1] as UIView).tintColor = GlobalConstants.SegmentedControlTheme.Dark.Buttons
            (tempUnitsControl.subviews[2] as UIView).tintColor = GlobalConstants.SegmentedControlTheme.Dark.Buttons
            (tempUnitsControl.subviews[3] as UIView).tintColor = GlobalConstants.SegmentedControlTheme.Dark.Buttons
            
            tempUnitsControl.setTitleTextAttributes([NSForegroundColorAttributeName: GlobalConstants.SegmentedControlTheme.Dark.Text], for: UIControlState.selected)
            
            (colourSchemeControl.subviews[0] as UIView).tintColor = GlobalConstants.SegmentedControlTheme.Dark.Buttons
            (colourSchemeControl.subviews[1] as UIView).tintColor = GlobalConstants.SegmentedControlTheme.Dark.Buttons
            colourSchemeControl.setTitleTextAttributes([NSForegroundColorAttributeName: GlobalConstants.SegmentedControlTheme.Dark.Text], for: UIControlState.selected)

        }
        else {
            (dayNightColourControl.subviews[0] as UIView).tintColor = GlobalConstants.SegmentedControlTheme.Light.Buttons
            (dayNightColourControl.subviews[1] as UIView).tintColor = GlobalConstants.SegmentedControlTheme.Light.Buttons
            dayNightColourControl.setTitleTextAttributes([NSForegroundColorAttributeName: GlobalConstants.SegmentedControlTheme.Light.Text], for: UIControlState.selected)
            
            (tempUnitsControl.subviews[0] as UIView).tintColor = GlobalConstants.SegmentedControlTheme.Light.Buttons
            (tempUnitsControl.subviews[1] as UIView).tintColor = GlobalConstants.SegmentedControlTheme.Light.Buttons
            (tempUnitsControl.subviews[2] as UIView).tintColor = GlobalConstants.SegmentedControlTheme.Light.Buttons
            (tempUnitsControl.subviews[3] as UIView).tintColor = GlobalConstants.SegmentedControlTheme.Light.Buttons
            
            tempUnitsControl.setTitleTextAttributes([NSForegroundColorAttributeName: GlobalConstants.SegmentedControlTheme.Light.Text], for: UIControlState.selected)
            
            (colourSchemeControl.subviews[0] as UIView).tintColor = GlobalConstants.SegmentedControlTheme.Light.Buttons
            (colourSchemeControl.subviews[1] as UIView).tintColor = GlobalConstants.SegmentedControlTheme.Light.Buttons
            colourSchemeControl.setTitleTextAttributes([NSForegroundColorAttributeName: GlobalConstants.SegmentedControlTheme.Light.Text], for: UIControlState.selected)
        }

    }
    func switchColourSchemesInternally () {
        
        var textColourScheme : UIColor!
        var podColourScheme : UIColor!
        
        if (colourSchemeControl.selectedSegmentIndex == 0) {
            // Dark
            
            podColourScheme = GlobalConstants.podDark
            textColourScheme = GlobalConstants.writingLight
            
            // Borders
            tempUnitsDescriptionView.layer.borderColor = GlobalConstants.writingLight.cgColor

            changeSegmentedControlColours(scheme: GlobalConstants.ColourScheme.Dark)
        }
        else {
            podColourScheme = UIColor.white //GlobalConstants.podLight
            textColourScheme = UIColor.black //GlobalConstants.writingDark
            
            // Borders
            tempUnitsDescriptionView.layer.borderColor = UIColor.black.cgColor

            changeSegmentedControlColours(scheme: GlobalConstants.ColourScheme.Light)

        }
        
        // Labels
        tempUnitsTitle.textColor = textColourScheme
        dayNightColourTitle.textColor = textColourScheme
        colourSchemeTitle.textColor = textColourScheme
        usUnitLabel.textColor = textColourScheme
        ukUnitLabel.textColor = textColourScheme
        siUnitLabel.textColor = textColourScheme
        caUnitLabel.textColor = textColourScheme
        
        // Pods
        settingsView.backgroundColor = podColourScheme

    }
    
    func loadBannerAd() {
        
        print("Google Mobile Ads SDK version: \(GADRequest.sdkVersion())")
        bannerView.adUnitID = AppSettings.AdMobBannerID
        bannerView.rootViewController = self
        
        let request = GADRequest()
        if AppSettings.BannerAdsTestMode {
            // Display test banner ads in the simulator
            request.testDevices = [GlobalConstants.BannerAdTestIDs.Simulator,
                                   GlobalConstants.BannerAdTestIDs.IPhone6]
        }

        bannerView.load(request)
    }
    
    // MARK:  Load/Save details
    func loadSettings() {
        
        let userDefaults = UserDefaults.standard
        var urlUnits = userDefaults.string(forKey: GlobalConstants.Defaults.URLDefaultUnits)

 //       var celsuisOrFahrenheit = userDefaults.string(forKey: GlobalConstants.Defaults.SavedTemperatureUnits)
        var dayOrNightColours = userDefaults.string(forKey: GlobalConstants.Defaults.SavedDayOrNightColourSetting)
        var colourSchemeSet = userDefaults.string(forKey: GlobalConstants.Defaults.SavedColourScheme)
        
//        if (celsuisOrFahrenheit == nil) {
//            celsuisOrFahrenheit = GlobalConstants.DefaultTemperatureUnit  // Celsius
//            saveSettings()
//        }
//        else {
//            if celsuisOrFahrenheit == GlobalConstants.TemperatureUnits.Celsuis {
//                tempUnitsControl.selectedSegmentIndex = 0
//            }
//            else {
//                tempUnitsControl.selectedSegmentIndex = 1
//            }
//        }
        
        if (urlUnits == nil) {
            urlUnits = GlobalConstants.DefaultURLUnit  // uk2
            GlobalConstants.urlUnitsChosen = GlobalConstants.DefaultURLUnit

            saveSettings()
        }
//        else {
            if urlUnits == GlobalConstants.urlUnit.us {
                tempUnitsControl.selectedSegmentIndex = 0
            }
            else if urlUnits == GlobalConstants.urlUnit.si {
                tempUnitsControl.selectedSegmentIndex = 1
            }
            else if urlUnits == GlobalConstants.urlUnit.uk {
                tempUnitsControl.selectedSegmentIndex = 2
            }
            else if urlUnits == GlobalConstants.urlUnit.ca {
                tempUnitsControl.selectedSegmentIndex = 3
            }
            
            GlobalConstants.urlUnitsChosen = urlUnits!

//        }

        
        if (dayOrNightColours == nil) {
            dayOrNightColours = GlobalConstants.DefaultDayOrNightSwitch  // On
            saveSettings()
        }
//        else {
            if dayOrNightColours == "ON" {
                dayNightColourControl.selectedSegmentIndex = 0
            }
            else {
                dayNightColourControl.selectedSegmentIndex = 1
            }
//        }
        
        if (colourSchemeSet == nil) {
            colourSchemeSet = GlobalConstants.DefaultColourScheme  // On
            saveSettings()
        }
//        else {
            if colourSchemeSet == GlobalConstants.ColourScheme.Dark {
                colourSchemeControl.selectedSegmentIndex = 0
            }
            else {
                colourSchemeControl.selectedSegmentIndex = 1
            }
//        }
        

    }
    
    func saveSettings() {
        
        // Save any settings to NSUserDefaults
//        var celsuisOrFahrenheit : String!
        var dayOrNightColours : String!
        var colourSchemeSet : String!
        var urlUnits : String!
        
        if (tempUnitsControl.selectedSegmentIndex == 0) {
            urlUnits = GlobalConstants.urlUnit.us
        }
        else if (tempUnitsControl.selectedSegmentIndex == 1) {
            urlUnits = GlobalConstants.urlUnit.si
        }
        else if (tempUnitsControl.selectedSegmentIndex == 2) {
            urlUnits = GlobalConstants.urlUnit.uk
        }
        else if (tempUnitsControl.selectedSegmentIndex == 3) {
            urlUnits = GlobalConstants.urlUnit.ca
        }
        
        GlobalConstants.urlUnitsChosen = urlUnits!  // Important

        if (dayNightColourControl.selectedSegmentIndex == 0) {
            dayOrNightColours = "ON"
        }
        else {
            dayOrNightColours = "OFF"
        }

        if (colourSchemeControl.selectedSegmentIndex == 0) {
            colourSchemeSet = GlobalConstants.ColourScheme.Dark
        }
        else {
            colourSchemeSet = GlobalConstants.ColourScheme.Light
        }

        let userDefaults = UserDefaults.standard
        userDefaults.set(urlUnits, forKey: GlobalConstants.Defaults.URLDefaultUnits)
//        userDefaults.set(celsuisOrFahrenheit, forKey: GlobalConstants.Defaults.SavedTemperatureUnits)
        userDefaults.set(dayOrNightColours, forKey: GlobalConstants.Defaults.SavedDayOrNightColourSetting)
        userDefaults.set(colourSchemeSet, forKey: GlobalConstants.Defaults.SavedColourScheme)
        
        userDefaults.synchronize() //  Explicitly save the settings
        
       //self.delegate?.refreshData()
        self.delegate?.refreshDataAfterSettingChange()  // Call to ParentWeatherVC
    }
    
    
    // MARK:  Button Methods
    @IBAction func okButtonPressed(_ sender: AnyObject) {
        
        saveSettings()
        
        // Dismiss view
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func backButtonPressed(_ sender: AnyObject) {
        
        // Dismiss view
        self.dismiss(animated: true, completion: nil)
    }

    // MARK:  SegmentedControl actions
    
    @IBAction func olourSchemeChanged(_ sender: Any) {
        switchColourSchemesInternally()
    }

}

//
//  SettingsViewController.swift
//  MGWeather
//
//  Created by Mark Gumbs on 20/07/2016.
//  Copyright © 2016 britishairways. All rights reserved.
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
    
    @IBOutlet weak var backButton : UIButton!
    @IBOutlet weak var okButton : UIButton!
    
    @IBOutlet weak var tempUnitsControl : UISegmentedControl!
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
        
        // Ease in the outer screen view for effect
        self.weatherImage.alpha = 0.2
        self.settingsView.alpha = CGFloat(GlobalConstants.DisplayViewAlpha)
        UIView.animate(withDuration: 0.8, delay: 0.15, options: UIViewAnimationOptions.curveEaseIn, animations: {
            self.weatherImage.alpha = CGFloat(GlobalConstants.DisplayViewAlpha)
         //   self.settingsView.alpha = CGFloat(GlobalConstants.DisplayViewAlpha)
            }, completion: nil)
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func setupScreen () {
    
        settingsView.backgroundColor = GlobalConstants.ViewShading.Lighter
        
        settingsView.alpha = CGFloat(GlobalConstants.DisplayViewAlpha)

        // Make round corners for the outerviews
        settingsView.layer.cornerRadius = 10.0
        settingsView.clipsToBounds = true
        
        if AppSettings.ShowBannerAds {
            loadBannerAd()
        }
    }
    
    func loadBannerAd() {
        
        print("Google Mobile Ads SDK version: \(GADRequest.sdkVersion())")
        bannerView.adUnitID = AppSettings.AdMobBannerID
        bannerView.rootViewController = self
        
        let request = GADRequest()
        if AppSettings.BannerAdsTestMode {
            // Display test banner ads in the simulator
            request.testDevices = [kGADSimulatorID]
        }

        bannerView.load(request)
    }
    
    // MARK:  Load/Save details
    func loadSettings() {
        
        let userDefaults = UserDefaults.standard
        var celsuisOrFahrenheit = userDefaults.string(forKey: GlobalConstants.Defaults.SavedTemperatureUnits)
        var dayOrNightColours = userDefaults.string(forKey: GlobalConstants.Defaults.SavedDayOrNightColourSetting)
        
        if (celsuisOrFahrenheit == nil) {
            celsuisOrFahrenheit = GlobalConstants.DefaultTemperatureUnit  // Celsius
            saveSettings()
        }
        else {
            if celsuisOrFahrenheit == GlobalConstants.TemperatureUnits.Celsuis {
                tempUnitsControl.selectedSegmentIndex = 0
            }
            else {
                tempUnitsControl.selectedSegmentIndex = 1
            }
        }
        
        if (dayOrNightColours == nil) {
            dayOrNightColours = GlobalConstants.DefaultDayOrNightSwitch  // On
            saveSettings()
        }
        else {
            if dayOrNightColours == "ON" {
                dayNightColourControl.selectedSegmentIndex = 0
            }
            else {
                dayNightColourControl.selectedSegmentIndex = 1
            }
        }

    }
    
    func saveSettings() {
        
        // Save any settings to NSUserDefaults
        var celsuisOrFahrenheit : String!
        var dayOrNightColours : String!
        
        if (tempUnitsControl.selectedSegmentIndex == 0) {
            celsuisOrFahrenheit = GlobalConstants.TemperatureUnits.Celsuis
        }
        else {
            celsuisOrFahrenheit = GlobalConstants.TemperatureUnits.Fahrenheit
        }

        if (dayNightColourControl.selectedSegmentIndex == 0) {
            dayOrNightColours = "ON"
        }
        else {
            dayOrNightColours = "OFF"
        }

        let userDefaults = UserDefaults.standard
        userDefaults.set(celsuisOrFahrenheit, forKey: GlobalConstants.Defaults.SavedTemperatureUnits)
        userDefaults.set(dayOrNightColours, forKey: GlobalConstants.Defaults.SavedDayOrNightColourSetting)
        
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

}

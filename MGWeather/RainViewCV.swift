//
//  RainViewCV.swift
//  SkyCast
//
//  Created by Mark Gumbs on 19/04/2017.
//  Copyright © 2017 MGSoft. All rights reserved.
//

import UIKit

protocol RainViewCVDelegate
{
    func returnRefreshedWeatherDetails() -> Weather
}

class RainViewCV: UIViewController {

    var delegate:RainViewCVDelegate?
    
    @IBOutlet weak var cvBackgroundView : UIView!
    @IBOutlet weak var rainNowIcon : UIImageView!
    @IBOutlet weak var rainNowProbability : UILabel!
    @IBOutlet weak var nearestRainDistance : UILabel!

    var dailyWeather : Weather!  // This is passed in from ParentWeatherVC
    var rainNowIconString: String?
    var rainNowProbabilityPercent = 0
    var rainNowProbabilityString: String?
    var nearestRainDistanceString: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(RainViewCV.weatherDataRefreshed), name: GlobalConstants.todayScreenRefreshFinishedKey, object: nil)

        setupData()
        setupView()
        setupColourScheme()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupView () {
        
   //     cvBackgroundView.alpha = CGFloat(GlobalConstants.DisplayViewAlpha)
        cvBackgroundView.backgroundColor = UIColor.clear
        
        // Do any additional setup after loading the view.
        nearestRainDistance.text = nearestRainDistanceString
        rainNowProbability.text = rainNowProbabilityString
        if (rainNowProbabilityPercent > GlobalConstants.RainIconReportThresholdPercent) {
            rainNowIcon.isHidden = false
        }
        else {
            rainNowIcon.isHidden = true
        }

    }
    
    func setupData() {
        
        if let todayArray = dailyWeather?.currentBreakdown {
            
            var rainDirection = ""
            if (todayArray.nearestStormBearing != nil) {
                rainDirection = Utility.compassDirectionFromDegrees(degrees: Float(todayArray.nearestStormBearing!))
            }
            
            // Find out if we want to report rain, sleet or snow
            
            var displayPrecipType = "Rain"  // Default
            if (todayArray.precipType == GlobalConstants.PrecipitationType.Rain) {
                displayPrecipType = "Rain"
            }
            else if (todayArray.precipType == GlobalConstants.PrecipitationType.Sleet) {
                displayPrecipType = "Sleet"
            }
            else if (todayArray.precipType == GlobalConstants.PrecipitationType.Snow) {
                displayPrecipType = "Snow"
            }
            
            var nearestRain = 99999
            var nearestRainFound = false
            
            if (todayArray.nearestStormDistance != nil) {
                nearestRain = todayArray.nearestStormDistance!
                nearestRainFound = true
            }
            else {
                nearestRainFound = false
            }
            
            if (nearestRainFound) {
                if (nearestRain == 0) {
                    nearestRainDistanceString = displayPrecipType + " nearby" //"Raining"
                }
                else if (nearestRain > 0 && nearestRain <= GlobalConstants.RainDistanceReportThreshold) {
                    nearestRainDistanceString = displayPrecipType + " nearby"
                }
                else if (nearestRain > GlobalConstants.RainDistanceReportThreshold) {
                    let rainUnits = todayArray.nearestStormDistanceUnits
                    
                    // TODO: Tidy up string concat
                    
                    if ( !(rainDirection.isEmpty) || rainDirection != "") {
                        nearestRainDistanceString = displayPrecipType + " " + String(todayArray.nearestStormDistance!) + " "
                        nearestRainDistanceString = nearestRainDistanceString! + rainUnits! + " " + rainDirection
                    }
                }
            }
            
            rainNowProbabilityPercent = Int(round((todayArray.precipProbability!)*100))
            
            if (rainNowProbabilityPercent > GlobalConstants.RainIconReportThresholdPercent) {
                //rainNowIcon.isHidden = false
                rainNowProbabilityString = String(rainNowProbabilityPercent) + "%"
            }
            else {
                // rainNowIcon.isHidden = true
                rainNowProbabilityString = ""
            }
            
        } // TodayArray

        
        // Populate with the correct rain icon scheme
        if let todayArray = dailyWeather?.currentBreakdown {
            
            if (todayArray.precipType == GlobalConstants.PrecipitationType.Rain) {
                let rainIconImage = Utility.getWeatherIcon(serviceIcon: "UMBRELLA", dayOrNight: "", weatherStats: todayArray)
                rainNowIcon.image = UIImage(named: rainIconImage)!
            }
            else if (todayArray.precipType == GlobalConstants.PrecipitationType.Sleet) {
                let rainIconImage = Utility.getWeatherIcon(serviceIcon: "SNOWFLAKE", dayOrNight: "", weatherStats: todayArray)
                rainNowIcon.image = UIImage(named: rainIconImage)!
            }
            else if (todayArray.precipType == GlobalConstants.PrecipitationType.Snow) {
                let rainIconImage = Utility.getWeatherIcon(serviceIcon: "SNOWFLAKE", dayOrNight: "", weatherStats: todayArray)
                rainNowIcon.image = UIImage(named: rainIconImage)!
            }
            else {
                // Default
                let rainIconImage = Utility.getWeatherIcon(serviceIcon: "UMBRELLA", dayOrNight: "", weatherStats: todayArray)
                rainNowIcon.image = UIImage(named: rainIconImage)!
            }
        }
        
    }
    
    func setupColourScheme() {
        
        // Setup pods and text colour accordingly
        
        let colourScheme = Utility.setupColourScheme()
        
        let textColourScheme = colourScheme.textColourScheme
//        let podColourScheme = colourScheme.podColourScheme
        
        // Labels
        
        rainNowProbability.textColor = textColourScheme
        nearestRainDistance.textColor = textColourScheme
        
    }

    func weatherDataRefreshed() {
        print("Weather Data Refreshed - RainViewCV")
        
        dailyWeather = nil
        dailyWeather = delegate?.returnRefreshedWeatherDetails()
        
        rainNowIconString = ""
        rainNowProbabilityPercent = 0
        rainNowProbabilityString = ""
        nearestRainDistanceString = ""

        setupData()
        setupView()
    }

}

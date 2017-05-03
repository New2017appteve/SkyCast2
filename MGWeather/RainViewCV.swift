//
//  RainViewCV.swift
//  SkyCast
//
//  Created by Mark Gumbs on 19/04/2017.
//  Copyright © 2017 MGSoft. All rights reserved.
//

import UIKit

class RainViewCV: UIViewController {

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

        setupScreen()
        setupColourScheme()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupScreen () {
        
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
    
    func setupColourScheme() {
        
        // Setup pods and text colour accordingly
        
        let colourScheme = Utility.setupColourScheme()
        
        let textColourScheme = colourScheme.textColourScheme
        let podColourScheme = colourScheme.podColourScheme
        
        // Labels
        
        rainNowProbability.textColor = textColourScheme
        nearestRainDistance.textColor = textColourScheme
        
        // Pods
        
        cvBackgroundView.backgroundColor = podColourScheme
        
    }

}

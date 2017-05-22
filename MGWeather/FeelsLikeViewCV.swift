//
//  FeelsLikeViewCV.swift
//  SkyCast
//
//  Created by Mark Gumbs on 19/04/2017.
//  Copyright © 2017 MGSoft. All rights reserved.
//

import UIKit

protocol FeelsLikeViewCVDelegate
{
    func returnRefreshedWeatherDetails() -> Weather
    func isDayTime (dateTime : NSDate) -> Bool

}

class FeelsLikeViewCV: UIViewController {

    var dailyWeather : Weather!  // This is passed in from ParentWeatherVC
    var delegate:FeelsLikeViewCVDelegate?
    
    @IBOutlet weak var cvBackgroundView : UIView!
    @IBOutlet weak var feelsLikeTemp : UILabel!
    @IBOutlet weak var currentWeatherIcon : UIImageView!

    // The following are read in setupView and calculated in setupData
    var feelsLikeTempString: String?
    var currentWeatherIconString: String?
    var currentWeatherIconName: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(FeelsLikeViewCV.weatherDataRefreshed), name: GlobalConstants.todayScreenRefreshFinishedKey, object: nil)
        
        setupData()
        setupView()
        setupColourScheme()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func setupView() {
    
 //       cvBackgroundView.alpha = CGFloat(GlobalConstants.DisplayViewAlpha)
        cvBackgroundView.backgroundColor = UIColor.clear

        feelsLikeTemp.text = feelsLikeTempString
        if !((currentWeatherIconName?.isEmpty)!) {
            currentWeatherIcon.image = UIImage(named: currentWeatherIconName!)
        }
    }
    
    func setupData() {
        
//        var feelsLikeTempString = ""
 //       var currentWeatherIconName = ""
        
        if let todayArray = dailyWeather?.currentBreakdown {
            
            let degreesSymbol = GlobalConstants.degreesSymbol + todayArray.temperatureUnits!
            
            feelsLikeTempString = "Feels Like: " + String(Int(round(todayArray.apparentTemperature! as Float))) + degreesSymbol
            
            // Get the current weather icon
            
            var isItDayOrNight = "NIGHT"
            
            var timeNow = NSDate()
            timeNow = Utility.getTimeInWeatherTimezone(dateAndTime: timeNow)
    // TODO
    //        if (isDayTime(dateTime: timeNow) {
                isItDayOrNight = "DAY"
    //        }
            
            let icon = todayArray.icon
            let enumVal = GlobalConstants.Images.ServiceIcon(rawValue: icon!)
            
            let weatherIconEnumVal = GlobalConstants.Images.ServiceIcon(rawValue: icon!)
            let weatherIconName = Utility.getWeatherIcon(serviceIcon: (weatherIconEnumVal?.rawValue)!, dayOrNight: isItDayOrNight, weatherStats: todayArray)
            
            currentWeatherIconName = weatherIconName
        }

    }
    
    func setupColourScheme() {
        
        // Setup pods and text colour accordingly
        
        let colourScheme = Utility.setupColourScheme()
        
        let textColourScheme = colourScheme.textColourScheme
        let podColourScheme = colourScheme.podColourScheme
        
        // Labels
        
        feelsLikeTemp.textColor = textColourScheme
        
        // Pods
        
 //       cvBackgroundView.backgroundColor = podColourScheme
        
    }

    func weatherDataRefreshed() {
        print("Weather Data Refreshed - FeelsLikeViewCV")
        
        dailyWeather = nil
        dailyWeather = delegate?.returnRefreshedWeatherDetails()
    
        feelsLikeTempString = ""
        currentWeatherIconString = ""
        currentWeatherIconName = ""

        setupData()
        setupView()

    }

}

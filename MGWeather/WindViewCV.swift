//
//  WindViewCV.swift
//  SkyCast
//
//  Created by Mark Gumbs on 19/04/2017.
//  Copyright © 2017 MGSoft. All rights reserved.
//

import UIKit
import CoreLocation

protocol WindViewCVDelegate
{
    func returnRefreshedWeatherDetails() -> Weather
}

class WindViewCV: UIViewController, CLLocationManagerDelegate {

    var dailyWeather : Weather!  // This is passed in from ParentWeatherVC
    var delegate:WindViewCVDelegate?
    var locationManager:CLLocationManager!

    @IBOutlet weak var cvBackgroundView : UIView!
    @IBOutlet weak var currentWindspeed : UILabel!
    @IBOutlet weak var compassView : UIView!
    @IBOutlet weak var compassArrow : UIImageView!
    @IBOutlet weak var compassLine : UIImageView!
    
    @IBOutlet weak var northLabel : UILabel!
    @IBOutlet weak var southLabel : UILabel!
    @IBOutlet weak var westLabel : UILabel!
    @IBOutlet weak var eastLabel : UILabel!

    // The following are read in setupView and calculated in setupData
    var currentWindspeedString : String?
    var currentWindDirectionDegrees : Float?
    var compassIconImage : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupData()
        setupView()
        setupColourScheme()
        
        NotificationCenter.default.addObserver(self, selector: #selector(WindViewCV.weatherDataRefreshed), name: GlobalConstants.todayScreenRefreshFinishedKey, object: nil)

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        locationManager = CLLocationManager()
        locationManager.delegate = self
        //locationManager.startUpdatingHeading()

    }
    
    override func viewWillDisappear(_ animated: Bool) {

        locationManager.stopUpdatingHeading()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func setupView() {
        
     //   cvBackgroundView.alpha = CGFloat(GlobalConstants.DisplayViewAlpha)
        cvBackgroundView.backgroundColor = UIColor.clear
        
        compassView.layer.cornerRadius = compassView.frame.size.width/2
        compassView.clipsToBounds = true
        compassView.layer.borderWidth = 1
        compassView.layer.borderColor = UIColor.white.cgColor
        
        compassArrow.image = UIImage(named: compassIconImage!)

        rotateCompassArrow(angleDegrees: currentWindDirectionDegrees!)
        currentWindspeed.text = currentWindspeedString
    }
    
    func setupData() {
        
        if let todayArray = dailyWeather?.currentBreakdown {
            
            var windDirection = ""
            if (todayArray.windBearing != nil) {
                windDirection = Utility.compassDirectionFromDegrees(degrees: todayArray.windBearing!)
            }
            
            currentWindDirectionDegrees = todayArray.windBearing!
            
            // TODO:  Report KM or MI accordingly.  Create utility to see if units in MPH/KPH from service
            
            let windSpeedUnits = todayArray.windSpeedUnits!
            
            if ( !(windDirection.isEmpty) || windDirection != "") {
                currentWindspeedString = "Wind: " + String(Int(todayArray.windSpeed!))
                //                    currentWindspeed = currentWindspeed + " " + windSpeedUnits + " " + windDirection
                //                   currentWindspeed = String(Int(todayArray.windSpeed!))
                currentWindspeedString = currentWindspeedString! + " " + windSpeedUnits
            }
            
            // Populate with the correct windy icon scheme
            compassIconImage = Utility.getWeatherIcon(serviceIcon: "COMPASS-ARROW", dayOrNight: "", weatherStats: todayArray)
        }

    }
    
    func setupColourScheme() {
        
        // Setup pods and text colour accordingly
        
        let colourScheme = Utility.setupColourScheme()
        
        let textColourScheme = colourScheme.textColourScheme
        let podColourScheme = colourScheme.podColourScheme
        
        // Labels
        
        currentWindspeed.textColor = textColourScheme
        northLabel.textColor = textColourScheme
        southLabel.textColor = textColourScheme
        westLabel.textColor = textColourScheme
        eastLabel.textColor = textColourScheme
        
        // Pods
        
//        cvBackgroundView.backgroundColor = podColourScheme
        compassView.backgroundColor = podColourScheme
    }

    func rotateCompassArrow(angleDegrees : Float) {
        
        var tmpAngleDegrees = angleDegrees
        // 1 degree = 0.0174533 radians
        // Use radans for rotation angle
        
        let degreeToRadians = Float(0.0174533)
        
        
        if (angleDegrees > 180) {
            tmpAngleDegrees = abs((angleDegrees + 180) - 360)
        }
        else {
            tmpAngleDegrees = angleDegrees + 180
        }
        
        let angleRadians = (tmpAngleDegrees * degreeToRadians)
        
        compassArrow.transform = CGAffineTransform(rotationAngle: CGFloat(angleRadians) )
        
    }
    
    func weatherDataRefreshed() {
        print("Weather Data Refreshed - WindViewCV")
        
        dailyWeather = nil
        dailyWeather = delegate?.returnRefreshedWeatherDetails()

        currentWindspeedString = ""
        currentWindDirectionDegrees = 0
        compassIconImage = ""
        
        setupData()
        setupView()

    }

}

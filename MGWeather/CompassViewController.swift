//
//  CompassViewController.swift
//  SkyCast
//
//  Created by Mark Gumbs on 30/05/2017.
//  Copyright © 2017 MGSoft. All rights reserved.
//

import UIKit
import CoreLocation
import DeviceKit

protocol CompassViewDelegate
{
    func returnRefreshedWeatherDetails() -> Weather
}


class CompassViewController: UIViewController, CLLocationManagerDelegate {

    var dailyWeather : Weather!  // This is passed in from ParentWeatherVC
    var delegate:CompassViewDelegate?
    var locationManager:CLLocationManager!
    
    @IBOutlet weak var weatherImage : UIImageView!
    @IBOutlet weak var cvBackgroundView : UIView!
    
    @IBOutlet weak var compassStatsView : UIView!

    @IBOutlet weak var currentWindspeed : UILabel!
    @IBOutlet weak var windspeedDirection : UILabel!
    @IBOutlet weak var compassView : UIView!
    @IBOutlet weak var compassArrow : UIImageView!
    @IBOutlet weak var compassLine : UIImageView!
    
    @IBOutlet weak var northLabel : UILabel!
    @IBOutlet weak var southLabel : UILabel!
    @IBOutlet weak var westLabel : UILabel!
    @IBOutlet weak var eastLabel : UILabel!

    @IBOutlet weak var compassDescriptionView : UIView!
    @IBOutlet weak var instructions : UILabel!
    
    // The following are read in setupView and calculated in setupData
    var currentWindspeedString : String?
    var windspeedDirectionString : String?
    var currentWindDirectionDegrees : Float?
    var compassIconImage : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupData()
        setupView()
        setupColourScheme()
        showCompassInstructions()
        
//        NotificationCenter.default.addObserver(self, selector: #selector(WindViewCV.weatherDataRefreshed), name: GlobalConstants.todayScreenRefreshFinishedKey, object: nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.startUpdatingHeading()
        
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
        //cvBackgroundView.backgroundColor = UIColor.clear
        
        compassView.layer.cornerRadius = compassView.frame.size.width/2
        compassView.clipsToBounds = true
        compassView.layer.borderWidth = 2
        compassView.layer.borderColor = UIColor.white.cgColor

        compassStatsView.clipsToBounds = true
        compassStatsView.layer.cornerRadius = 10

        compassDescriptionView.clipsToBounds = true
        compassDescriptionView.layer.cornerRadius = 10

        compassArrow.image = UIImage(named: compassIconImage!)
        
        rotateCompassArrow(angleDegrees: currentWindDirectionDegrees!)
        currentWindspeed.text = currentWindspeedString
        windspeedDirection.text = windspeedDirectionString
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
                currentWindspeedString = currentWindspeedString! + " " + windSpeedUnits
                windspeedDirectionString = String(Int(currentWindDirectionDegrees!)) + " degrees " + windDirection
                
                //currentWindspeed = currentWindspeed + " " + windSpeedUnits + " " + windDirection
                //currentWindspeed = String(Int(todayArray.windSpeed!))
                //currentWindspeedString = currentWindspeed

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
        windspeedDirection.textColor = textColourScheme
        northLabel.textColor = textColourScheme
        southLabel.textColor = textColourScheme
        westLabel.textColor = textColourScheme
        eastLabel.textColor = textColourScheme
        
        // Pods
        
        //        cvBackgroundView.backgroundColor = podColourScheme
        compassView.backgroundColor = podColourScheme
        compassDescriptionView.backgroundColor = podColourScheme
        compassStatsView.backgroundColor = podColourScheme
    }
    
    func showCompassInstructions () {
        
        var compassInstructions = ""
        
        if compassOnDevice() {
            compassInstructions = "Line up the coloured arrow with North, N.  The wind will be blowing in the direction of the white arrow."
        }
        else {
            compassInstructions = "Your device does not have a compass.  The wind will be blowing from the direction wherever North is to you"
        }
        
        instructions.text = compassInstructions
    }
    
    func compassOnDevice() -> Bool {
        
        var retVal = false
        
        let device = Device()  // Returns real or simulator
        if device.isPod {
            retVal = false
        } else if device.isPhone {
            retVal = true
        }
        
        return retVal
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
    
    
    // This function will be called whenever your heading is updated. Since you asked for best
    // accuracy, this function will be called a lot of times. Better make it very efficient
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        print(newHeading.magneticHeading)
        
        // just need a single snapshot of this
        
        rotateCompassLine(degrees:newHeading.magneticHeading)
    }
    
    func rotateCompassLine(degrees : Double) {
        compassLine.transform = CGAffineTransform(rotationAngle: CGFloat(degrees * M_PI/180));
    }
    
    // MARK:  Button Methods
    
    @IBAction func backButtonPressed(_ sender: AnyObject) {
        
        // Dismiss view
        self.dismiss(animated: true, completion: nil)
    }
    
}

//
//  SunriseSunsetViewController.swift
//  SkyCast
//
//  Created by Mark Gumbs on 08/12/2016.
//  Copyright © 2016 MGSoft. All rights reserved.
//

import UIKit
import GoogleMobileAds

protocol SunriseSunsetViewControllerDelegate
{

}

class SunriseSunsetViewController: UIViewController {
    
    var delegate:SunriseSunsetViewControllerDelegate?
    
    // Variables from calling viewcontroller
    
    var dailyWeather : Weather!  // This is passed in from ParentWeatherVC
    
    var sunriseDateTime : NSDate!
    var sunsetDateTime : NSDate!
    var tempMinDateTime : NSDate!
    var tempMaxDateTime : NSDate!
    var tempMin : Float!
    var tempMax : Float!
    var degreesSymbol : String!
    var moonPhase : Float!
    var tomorrowMoonPhase: Float?
    
    var hoursForToday = Utility.getHoursForToday()
    
    // MARK: Outlets
    
    @IBOutlet weak var weatherImage : UIImageView!
    @IBOutlet weak var sunriseSunsetView: UIView!
    
    @IBOutlet weak var summaryView: UIView!
    @IBOutlet weak var summaryText: UILabel!
    
    @IBOutlet weak var timelineTableView : UITableView!
    
    // The banner view.
    @IBOutlet weak var bannerView: GADBannerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        setupScreen ()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupScreen () {
        
        // Make round corners for the outerviews
        
        summaryView.layer.cornerRadius = 10.0
        summaryView.clipsToBounds = true
        
        timelineTableView.layer.cornerRadius = 10.0
        timelineTableView.clipsToBounds = true
        
        timelineTableView.alpha = CGFloat(GlobalConstants.DisplayViewAlpha)
        
        let today = NSDate()
        
        summaryText.text = "Timeline for " + today.shortDayMonthYear()!
        
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
            request.testDevices = [GlobalConstants.BannerAdTestIDs.Simulator,
                                   GlobalConstants.BannerAdTestIDs.IPhone6]
        }
        
        bannerView.load(request)
    }
    
    // MARK:  Button Methods
    
    @IBAction func backButtonPressed(_ sender: AnyObject) {
        
        // Dismiss view
        self.dismiss(animated: true, completion: nil)
    }
    
    func isSunriseHour (dateTime : NSDate) -> Bool {
        
        var retVal : Bool!
        
        // Calculate whether the sun rises in next hour
        
        let nextHourTime = dateTime.add(minutes: 60) as NSDate
        
        if (sunriseDateTime!.isBetweeen(date: nextHourTime, andDate: dateTime)) {
            retVal = true
        }
        else {
            retVal = false
        }
        
        return retVal
    }
    
    func isSunsetHour (dateTime : NSDate) -> Bool {
        
        var retVal : Bool!
        
        // Calculate whether the sun sets in next hour
        
        let nextHourTime = dateTime.add(minutes: 60) as NSDate
        
        if (sunsetDateTime!.isBetweeen(date: nextHourTime, andDate: dateTime)) {
            retVal = true
        }
        else {
            retVal = false
        }
        
        return retVal
    }
    
    func isDayTime (dateTime : NSDate) -> Bool {
        
        var retVal : Bool!
        
        // Calculate whether current time is in the day or the night
        // Look at tomorrows sunrise and sunset times too incase the results span days
        
        if (dateTime.isBetweeen(date: sunsetDateTime, andDate: sunriseDateTime)) {
            retVal = true
        }
        else {
            retVal = false
        }
        
        return retVal
    }
}

// MARK: UITableViewDataSource
extension SunriseSunsetViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return hoursForToday.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let hourData = hoursForToday[indexPath.row] as! NSDate
        
        let hourStamp = hourData.shortHourTimeString()
        
        let sunriseInHour = isSunriseHour(dateTime: hourData)
        let sunsetInHour = isSunsetHour(dateTime: hourData)
        
        let cell:SunriseSunsetCell = self.timelineTableView.dequeueReusableCell(withIdentifier: "SunriseSunsetCellID") as! SunriseSunsetCell

        // Work out how much daylight today
        
        let interval = sunsetDateTime.timeIntervalSince(sunriseDateTime as Date)
        let (h,m,_) = Utility.secondsToHoursMinutesSeconds(seconds: Int(interval))
        
        var amountOfDaylightToday : String!
        
        if h > 0 {
            amountOfDaylightToday = "\(h)h \(m)m"
        }
        else {
            amountOfDaylightToday = "\(m)m"
        }
        
        if (indexPath.row % 2 == 0) {
            cell.hourLabel.text = hourStamp
            cell.hourLabelTwo.text = ""
        }
        else {
            cell.hourLabel.text = ""
            cell.hourLabelTwo.text = hourStamp
        }
        
        var waxingOrWaining = ""
        if ( CGFloat(moonPhase) < CGFloat(tomorrowMoonPhase!) ) {
//            waxingOrWaining = "waxing"
        }
        else {
//            waxingOrWaining = "waining"
        }
        
        if (sunriseInHour) {
            cell.descriptionLabel.text = "Sunrise " + sunriseDateTime.shortTimeString()
            cell.daylightHoursLabel.text = amountOfDaylightToday + " daylight"
        }        
        else if (sunsetInHour) {
            cell.descriptionLabel.text = "Sunset " + sunsetDateTime.shortTimeString()
            cell.daylightHoursLabel.text = "Moon " + String((moonPhase * 100)) + "% " + waxingOrWaining
        }
        else {
            cell.descriptionLabel.text = ""
            cell.daylightHoursLabel.text = ""
        }
        
        // Colour in the daylight timeline
        if (sunriseInHour || sunsetInHour) {
            cell.graphColourLabel.backgroundColor = GlobalConstants.TwighlightShading
        }
        else if (isDayTime(dateTime: hourData)) {
            cell.graphColourLabel.backgroundColor = GlobalConstants.TableViewAlternateShadingDay.Darker
        }
        else {
            cell.graphColourLabel.backgroundColor = GlobalConstants.TableViewAlternateShadingNight.Darker
        }
        
        if (hourData == tempMinDateTime) {
            
            let temp = String(Int(round(tempMin!))) + degreesSymbol
            
            cell.daylightHoursLabel.text = "Coolest Hour"
            cell.daylightHoursLabel.textColor = GlobalConstants.TableViewAlternateShadingNight.Lighter
            cell.graphColourLabel.text = temp
        }
        else if (hourData == tempMaxDateTime) {
            
            let temp = String(Int(round(tempMax!))) + degreesSymbol
            
            cell.daylightHoursLabel.text = "Warmest Hour"
            cell.daylightHoursLabel.textColor = GlobalConstants.TableViewAlternateShadingDay.Lighter
            cell.graphColourLabel.text = temp
        }
        else {
            // Clear only the colour label.  Other labels may already have text in it
            cell.graphColourLabel.text = ""
        }

        // Setup text colour according to colour scheme
        
        let colourScheme = Utility.setupColourScheme()
        let textColourScheme = colourScheme.textColourScheme
        
        summaryView.backgroundColor = colourScheme.podColourScheme
        timelineTableView.backgroundColor = colourScheme.podColourScheme
        
        summaryText.textColor = textColourScheme
        
        cell.backgroundColor = colourScheme.podColourScheme

        cell.hourLabel.textColor = textColourScheme
        cell.hourLabelTwo.textColor = textColourScheme
        cell.descriptionLabel.textColor = textColourScheme
        cell.daylightHoursLabel.textColor = textColourScheme

        return cell
    }
}

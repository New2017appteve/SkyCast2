//
//  DailyTabVC.swift
//  Weather
//
//  Created by Mark Gumbs on 29/06/2016.
//

import UIKit
import GoogleMobileAds

protocol DailyTabVCDelegate
{
    func switchViewControllers()
    func returnRefreshedWeatherDetails() -> Weather
}

class DailyTabVC: UIViewController {

    var delegate:DailyTabVCDelegate?
    var sunriseTimeStamp: NSDate?
    var sunsetTimeStamp: NSDate?
    var tomorrowSunriseTimeStamp: NSDate?
    var tomorrowSunsetTimeStamp: NSDate?
    var degreesSymbol = ""

    
    // Outlets
    @IBOutlet weak var dailyWeatherTableView : UITableView!
    @IBOutlet weak var outerScreenView : UIView!
    @IBOutlet weak var weatherImage : UIImageView!
    @IBOutlet weak var nextDaysSummary : UITextView!
    
    @IBOutlet weak var dailyWeather : Weather!  // This is passed in from ParentWeatherVC
    @IBOutlet weak var weatherLocation : Location!  // This is passed in from ParentWeatherVC
    
    // The banner views.
    @IBOutlet weak var bannerOuterView: UIView!
    @IBOutlet weak var closeBannerButton : UIButton!
    @IBOutlet weak var bannerView: GADBannerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupScreen()
        setupSwipeGestures()
        populateDailyWeatherDetails()
        bannerOuterView.isHidden = true
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Register to receive notifications
        NotificationCenter.default.addObserver(self, selector: #selector(DailyTabVC.weatherDataRefreshed), name: GlobalConstants.weatherRefreshFinishedKey, object: nil)

        // Ease in the weather image view for effect
        self.weatherImage.alpha = 0.2
        UIView.animate(withDuration: 0.6, delay: 0.0, options: UIViewAnimationOptions.curveEaseIn, animations: {
            self.weatherImage.alpha = 1
            }, completion: nil)

        populateDailyWeatherDetails()
        
        if AppSettings.ShowBannerAds {
            // For this screen we only want to randomly show the banner ad, so thats its an
            // occasional annoyance
            
            bannerOuterView.isHidden = true
            let rand = Int(arc4random_uniform(4))
            if (rand % 3 == 0) {
                loadBannerAd()
                bannerOuterView.isHidden = false
            }
        }

    }

    override func viewDidDisappear(_ animated: Bool) {
 //       NotificationCenter.default.removeObserver(self, name: GlobalConstants.weatherRefreshFinishedKey, object: nil);
    }

    
    func setupScreen () {
        
        nextDaysSummary.backgroundColor = GlobalConstants.ViewShading.Lighter
        
        nextDaysSummary.alpha = 0.8
        nextDaysSummary.layer.cornerRadius = 5.0
        nextDaysSummary.clipsToBounds = true

        dailyWeatherTableView.alpha = CGFloat(GlobalConstants.DisplayViewAlpha)
        dailyWeatherTableView.layer.cornerRadius = 10.0
        dailyWeatherTableView.clipsToBounds = true

    }
    
    func loadBannerAd() {
    
        print("Google Mobile Ads SDK version: \(GADRequest.sdkVersion())")
        bannerView.adUnitID = AppSettings.AdMobBannerID
        bannerView.rootViewController = self
        
        let request = GADRequest()
        if AppSettings.BannerAdsTestMode {
            // Display test banner ads in the simulator
            request.testDevices = [AppSettings.AdTestDeviceID]
        }

        // Make ads more location specific
        if let currentLocation = weatherLocation.currentLocation {
            request.setLocationWithLatitude(CGFloat(currentLocation.coordinate.latitude),
                                            longitude: CGFloat(currentLocation.coordinate.longitude),
                                            accuracy: CGFloat(currentLocation.horizontalAccuracy))
        }
        bannerView.load(request)

    }
    
    
    func populateDailyWeatherDetails() {
        
        if let tmpDailyWeather = dailyWeather {
            
            // Min Temp, Max Temp, Sunrise and Sunset we can get from the 'daily' figures
            let todayArray = dailyWeather?.currentBreakdown
            let dayArray = dailyWeather?.dailyBreakdown.dailyStats
            
            for days in dayArray! {
                
                // If today, populate the relevant fields
                let sameDay = Utility.areDatesSameDay(date1: (todayArray?.dateAndTimeStamp!)!, date2: days.dateAndTimeStamp!)
                
                if sameDay {
                    sunriseTimeStamp = days.sunriseTimeStamp as NSDate?
                    sunsetTimeStamp = days.sunsetTimeStamp as NSDate?                    
                }
                
                // We want tomorrows sunrise and sunset times as well
                
                let tomorrow = Utility.isTomorrow(date1: days.dateAndTimeStamp!)
                
                if tomorrow {
                    tomorrowSunriseTimeStamp = days.sunriseTimeStamp as NSDate?
                    tomorrowSunsetTimeStamp = days.sunsetTimeStamp as NSDate?
                }
            }

            var isItDayOrNight = "NIGHT"
            let timeNow = NSDate()
            if isDayTime(dateTime: timeNow) {
                isItDayOrNight = "DAY"
            }

            // Populate the weather image
            let icon = tmpDailyWeather.currentBreakdown.icon
            let enumVal = GlobalConstants.Images.ServiceIcon(rawValue: icon!)
            let nextDaysSummaryString = tmpDailyWeather.dailyBreakdown.summary
            
            var backgroundImageName = ""
            
            if AppSettings.SpecialThemedBackgroundsForEvents {
                // Get a special background if its a 'themed day (e.g Chrisrmas etc)
                backgroundImageName = Utility.getSpecialDayWeatherImage(dayOrNight: isItDayOrNight)
            }
            
            if backgroundImageName == "" {
                backgroundImageName = Utility.getWeatherImage(serviceIcon: (enumVal?.rawValue)!, dayOrNight: isItDayOrNight)
            }
            
            if String(backgroundImageName).isEmpty != nil {
                weatherImage.image = UIImage(named: backgroundImageName)!
            }
            
            if nextDaysSummaryString?.isEmpty != nil {
                nextDaysSummary.text = nextDaysSummaryString
            }
            
            dailyWeatherTableView.reloadData()
        }
    }
    
    func isDayTime (dateTime : NSDate) -> Bool {
        
        var retVal : Bool!
        
        // Calculate whether current time is in the day or the night
        // Look at tomorrows sunrise and sunset times too incase the results span days
        
        if (dateTime.isBetweeen(date: sunsetTimeStamp!, andDate: sunriseTimeStamp!) ||
            dateTime.isBetweeen(date: tomorrowSunsetTimeStamp!, andDate: tomorrowSunriseTimeStamp!) ) {
            retVal = true
        }
        else {
            retVal = false
        }
        
        return retVal
    }

    /// Force the text in a UITextView to always center itself.
    func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutableRawPointer) {
        let textView = object as! UITextView
        var topCorrect = (textView.bounds.size.height - textView.contentSize.height * textView.zoomScale) / 2
        topCorrect = topCorrect < 0.0 ? 0.0 : topCorrect;
        textView.contentInset.top = topCorrect
    }
    
    // MARK:  Swipe Gesture functions
    
    func setupSwipeGestures () {
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(DailyTabVC.swiped(gesture:)))
        swipeDown.direction = .down
        self.view.addGestureRecognizer(swipeDown)
        
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(DailyTabVC.swiped(gesture:)))
        swipeUp.direction = .up
        self.view.addGestureRecognizer(swipeUp)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(DailyTabVC.swiped(gesture:)))
        swipeRight.direction = .right
        self.view.addGestureRecognizer(swipeRight)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(DailyTabVC.swiped(gesture:)))
        swipeLeft.direction = .left
        self.view.addGestureRecognizer(swipeLeft)
    }
    
    func swiped(gesture: UIGestureRecognizer)
    {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer
        {
            switch swipeGesture.direction
            {
                
            case UISwipeGestureRecognizerDirection.right:
                print("Swiped Right")
                
            case UISwipeGestureRecognizerDirection.left:
                print("Swiped Left")
                delegate?.switchViewControllers()
                
            case UISwipeGestureRecognizerDirection.up:
                print("Swiped Up")
                
            case UISwipeGestureRecognizerDirection.down:
                print("Swiped Down")
                
            default:
                break
            }
        }
    }
    
    // MARK:  Button methods
    @IBAction func closeBannerAdButtonPressed(_ sender: AnyObject) {
        
        // Dismiss banner ad view
        bannerOuterView.isHidden = true
    }

    // MARK:  Notification complete methods
    
    func weatherDataRefreshed() {
        print("Weather Data Refreshed - DailyTab")

        dailyWeather = delegate?.returnRefreshedWeatherDetails()

        NotificationCenter.default.removeObserver(self, name: GlobalConstants.weatherRefreshFinishedKey, object: nil);

        // NOTE:  This will be run on a background thread
        DispatchQueue.main.async {
            self.populateDailyWeatherDetails()
            
            // Scroll to the top of the table view
            self.dailyWeatherTableView.contentOffset = CGPoint(x: 0, y: 0 - self.dailyWeatherTableView.contentInset.top)

        }
    }
}

// MARK: UITableViewDataSource

extension DailyTabVC : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        // We dont want 'today' in this list so -1
        return dailyWeather.dailyBreakdown.dailyStats.count - 1
    }
  
    private func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return tableView.rowHeight-2
    }

    func numberOfSectionsInTableView(tableView:UITableView)->Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let lWeather = dailyWeather
        
        if lWeather?.flags.units == "si" {
            degreesSymbol = GlobalConstants.degreesSymbol + "C"
        }
        else {
            degreesSymbol = GlobalConstants.degreesSymbol + "F"
        }
        
        // We dont want 'today' in this list so +1
        let dayWeather = dailyWeather.dailyBreakdown.dailyStats[indexPath.row + 1]
        
        let cell:DailyWeatherCell = self.dailyWeatherTableView.dequeueReusableCell(withIdentifier: "DailyWeatherCellID") as! DailyWeatherCell
        
        cell.dateLabel.text = (dayWeather.dateAndTimeStamp?.shortDayOfTheWeek())! + " " + (dayWeather.dateAndTimeStamp?.getDateSuffix())!

        cell.sunriseLabel.text = dayWeather.sunriseTimeStamp?.shortTimeString()
        cell.sunsetLabel.text = dayWeather.sunsetTimeStamp?.shortTimeString()
        cell.summaryLabel.text = dayWeather.summary
        cell.minTempLabel.text = String(Int(round(dayWeather.temperatureMin!))) + degreesSymbol
        cell.maxTempLabel.text = String(Int(round(dayWeather.temperatureMax!))) + degreesSymbol

        cell.rainProbabilityLabel.text = String(Int(round(dayWeather.precipProbability!*100))) + "%"
        
        let icon = dayWeather.icon
        let iconName = Utility.getWeatherIcon(serviceIcon: icon!)

        if iconName != "" {
            cell.dailyWeatherIcon.image = UIImage(named: iconName)!
        }
        
        let dayDurationSeconds = Int(secondsBetween(date1: dayWeather.sunsetTimeStamp!, date2: dayWeather.sunriseTimeStamp!))
        let (h,m,_) = secondsToHoursMinutesSeconds(seconds: dayDurationSeconds)
        let hoursAndMinutes = String(h) + "h " + String(m) + "m"
        
        cell.dayDurationLabel.text = hoursAndMinutes
        
        // Alternate the shading of each table view cell
        if (indexPath.row % 2 == 0) {
            cell.backgroundColor = GlobalConstants.TableViewAlternateShading.Darker
        }
        else {
            cell.backgroundColor = UIColor.white // GlobalConstants.TableViewAlternateShading.Lightest
        }
  
        return cell
    }
    
    func secondsBetween (date1: NSDate, date2: NSDate) -> TimeInterval {
        
        let timeDiff =  date1.timeIntervalSince(date2 as Date)
        return timeDiff

    }
    
    func secondsToHoursMinutesSeconds (seconds : Int) -> (Int, Int, Int) {
        return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }

}


// MARK: UITableViewDelegate
extension DailyTabVC : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

//        var dailyWeather = super.weather?.dailyBreakdown.dailyStats[indexPath.row]
//        print (super.weather)
    }

    private func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: IndexPath) -> Bool {
        return true
    }
    
    private func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {

    }
}


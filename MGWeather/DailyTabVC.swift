//
//  DailyTabVC.swift
//  Weather
//
//  Created by Mark Gumbs on 29/06/2016.
//  Copyright © 2016 britishairways. All rights reserved.
//

import UIKit

protocol DailyTabVCDelegate
{
    func refreshWeatherDataFromService()
    func refreshWeatherDataFromService2(completionHandler: @escaping GlobalConstants.CompletionHandlerType)
    func switchViewControllers()
}

class DailyTabVC: UIViewController {

    var delegate:DailyTabVCDelegate?
    
    // Outlets
    @IBOutlet weak var dailyWeatherTableView : UITableView!
    @IBOutlet weak var outerScreenView : UIView!
    @IBOutlet weak var weatherImage : UIImageView!
    @IBOutlet weak var nextDaysSummary : UITextView!
    
    @IBOutlet weak var dailyWeather : Weather!  // This is passed in from ParentWeatherVC


    override func viewDidLoad() {
        super.viewDidLoad()

        setupScreen()
        setupSwipeGestures()
        populateDailyWeatherDetails()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Ease in the outer screen view for effect
        self.outerScreenView.alpha = 0.2
        UIView.animate(withDuration: 0.6, delay: 0.0, options: UIViewAnimationOptions.curveEaseIn, animations: {
            self.outerScreenView.alpha = 1
            }, completion: nil)

        populateDailyWeatherDetails()
    }

    
    func setupScreen () {
        
        nextDaysSummary.backgroundColor = GlobalConstants.ViewShading.Lighter
        
        nextDaysSummary.alpha = 0.8
        nextDaysSummary.layer.cornerRadius = 5.0
        nextDaysSummary.clipsToBounds = true

        dailyWeatherTableView.alpha = 0.85
        dailyWeatherTableView.layer.cornerRadius = 10.0
        dailyWeatherTableView.clipsToBounds = true

    //    nextDaysSummary.textAlignment = NSTextAlignment.center
    }
    
    func populateDailyWeatherDetails() {
        
        if let dailyWeather2 = dailyWeather {
            
            // Populate the weather image
            let icon = dailyWeather2.currentBreakdown.icon
            let enumVal = GlobalConstants.Images.ServiceIcon(rawValue: icon!)
            let nextDaysSummaryString = dailyWeather2.dailyBreakdown.summary
            
            let iconName = Utility.getWeatherImage(serviceIcon: (enumVal?.rawValue)!)
            
            if String(iconName).isEmpty != nil {
                weatherImage.image = UIImage(named: iconName)!
            }
            
            if nextDaysSummaryString?.isEmpty != nil {
                nextDaysSummary.text = nextDaysSummaryString
            }
            
            dailyWeatherTableView.reloadData()
        }
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
        
        // We dont want 'today' in this list so +1
        let dayWeather = dailyWeather.dailyBreakdown.dailyStats[indexPath.row + 1]
        
        let cell:DailyWeatherCell = self.dailyWeatherTableView.dequeueReusableCell(withIdentifier: "DailyWeatherCellID") as! DailyWeatherCell
        
        cell.dateLabel.text = (dayWeather.dateAndTimeStamp?.dayOfTheWeek())! + " " + (dayWeather.dateAndTimeStamp?.getDateSuffix())!

        cell.sunriseLabel.text = dayWeather.sunriseTimeStamp?.shortTimeString()
        cell.sunsetLabel.text = dayWeather.sunsetTimeStamp?.shortTimeString()
        cell.summaryLabel.text = dayWeather.summary
        cell.minTempLabel.text = String(Int(round(dayWeather.temperatureMin!))) + GlobalConstants.degreesSymbol
        cell.maxTempLabel.text = String(Int(round(dayWeather.temperatureMax!))) + GlobalConstants.degreesSymbol
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


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

}

class DailyTabVC: UIViewController {

    var delegate:DailyTabVCDelegate?
    
    // Outlets
    @IBOutlet weak var dailyWeatherTableView : UITableView!
    @IBOutlet weak var weatherImage : UIImageView!
    
    @IBOutlet weak var dailyWeather : Weather!  // This is passed in from ParentWeatherVC


    override func viewDidLoad() {
        super.viewDidLoad()

        populateDailyWeatherDetails()
        
    }
    
    func populateDailyWeatherDetails() {
        
        if let dailyWeather2 = dailyWeather {
            
            // Populate the weather image
            let icon = dailyWeather2.currentBreakdown.icon
            let enumVal = GlobalConstants.Images.ServiceIcon(rawValue: icon!)
            
            let iconName = Utility.getWeatherImage(serviceIcon: (enumVal?.rawValue)!)
            
            if String(iconName).isEmpty != nil {
                weatherImage.image = UIImage(named: iconName)!
            }
            
            dailyWeatherTableView.reloadData()
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

extension NSDate {
    
    func dayOfTheWeek() -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        return dateFormatter.string(from: self as Date)
    }
    
    func shortTimeString() -> String
    {
        //Get Short Time String
        let formatter = DateFormatter()
        formatter.timeStyle = .short //.ShortStyle
        let timeString = formatter.string(from: self as Date)
        
        //Return Short Time String
        return timeString
    }
    
    func shortHourTimeString() -> String
    {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a 'on' MMMM dd, yyyy"
        //Get Short hour Time String
        var hour = Calendar.current.component(.hour, from: self as Date)
        if hour == 0 {
            hour = 12
        }
        
        if hour > 12 {
            hour = hour - 12
        }
        
        // look for am or pm in string
        let dateString = formatter.string(from: self as Date)
        
        var amPm = ""
        if dateString.lowercased().range(of: "am") != nil {
            amPm = "am"
        }
        else {
            amPm = "pm"
        }
        
        //Return Short Time String
        return String(hour) + amPm
    }
    
    func getDateSuffix() -> String {
        
        var suffix = ""
        let day = NSCalendar.current.component(.day, from: self as Date)
        
        switch (day){
        case 1, 21, 31:
            suffix = "st"
            break
        case 2, 22:
            suffix = "nd"
            break
        case 3, 23:
            suffix = "rd"
            break
        default:
            suffix = "th"
            break
        }  

        return String(day) + suffix
        
    }

}

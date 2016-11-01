//
//  NSDate+Conversions.swift
//  MGWeather
//
//  Created by Mark Gumbs on 01/11/2016.
//  Copyright © 2016 britishairways. All rights reserved.
//

import Foundation

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
    
    func isBetweeen(date date1: NSDate, andDate date2: NSDate) -> Bool {
        return date1.compare(self as Date) == self.compare(date2 as Date)
    }

}

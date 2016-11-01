//
//  WeatherAlerts.swift
//  MGWeather
//
//  Created by Mark Gumbs on 12/07/2016.
//

import UIKit

class WeatherAlerts: NSObject {

    var title : String?
    var alertDateAndTime : Double?
    var alertDateAndTimeStamp : NSDate?
    var alertExpiryDateAndTime : Double?
    var alertExpiryDateAndTimeStamp : NSDate?
    var alertDescription : String?
    var uri : String?
    
    override init(){
        
    }
    
    init(fromDictionary weatherDict: NSDictionary) {
      
        if let lTitle  = weatherDict["title"] as? String {
            title = lTitle
        }
        
        if let lDateAndTime  = weatherDict["time"] as? Double {
            alertDateAndTime = lDateAndTime
            alertDateAndTimeStamp = NSDate(timeIntervalSince1970: alertDateAndTime!)  // NOTE:  Remember to add offset etc
            
            let formatter = DateFormatter()
            formatter.timeZone = TimeZone(secondsFromGMT: 7 * 3600) as TimeZone!  // original string in GMT
            
        }
        
        if let lDateAndTime  = weatherDict["expires"] as? Double {
            alertExpiryDateAndTime = lDateAndTime
            alertExpiryDateAndTimeStamp = NSDate(timeIntervalSince1970: alertExpiryDateAndTime!)  // NOTE:  Remember to add offset etc
        }
        
        if let lAlertDescription  = weatherDict["description"] as? String {
            alertDescription = lAlertDescription
        }
        
        
        if let lUri  = weatherDict["uri"] as? String {
            uri = lUri
        }
    }
}

//
//  MinuteBreakdown.swift
//  Weather
//
//  Created by Mark Gumbs on 25/06/2016.
//

import UIKit

class MinuteBreakdown: NSObject {

    var summary : String?
    var icon : String?
    var minuteStats = [WeatherStats]()
    
    override init(){
        
    }
    
    init(fromDictionary weatherDict: NSDictionary) {
        
        if let lSummary  = weatherDict["summary"] as? String {
            summary = lSummary
        }
        
        if let lIcon  = weatherDict["icon"] as? String {
            icon = lIcon
        }
        
        if let lMinuteStats = weatherDict["data"] as? [NSDictionary] {
            print("...minuteStats dict")
            
            minuteStats = lMinuteStats.flatMap({ WeatherStats(fromDictionary: $0) })
        }
    }
}

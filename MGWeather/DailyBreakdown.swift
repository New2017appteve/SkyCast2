//
//  DailyBreakdown.swift
//  Weather
//
//  Created by Mark Gumbs on 25/06/2016
//

import UIKit

class DailyBreakdown: NSObject {

    var summary : String?
    var icon : String?
    var dailyStats = [WeatherStats]()
    
    override init(){
        
    }
    
    init(fromDictionary weatherDict: NSDictionary) {
        
        if let lSummary  = weatherDict["summary"] as? String {
            summary = lSummary
        }
        
        if let lIcon  = weatherDict["icon"] as? String {
            icon = lIcon
        }
        
        if let lDailyStats = weatherDict["data"] as? [NSDictionary] {
            print("...dailyStats dict")
            
            dailyStats = lDailyStats.flatMap({ WeatherStats(fromDictionary: $0) })
        }
    }
}

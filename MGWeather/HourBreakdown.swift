//
//  HourBreakdown.swift
//  Weather
//
//  Created by Mark Gumbs on 25/06/2016.
//

import UIKit

class HourBreakdown: NSObject {

    var summary : String?
    var icon : String?
    var hourStats = [WeatherStats]()
    
    override init(){
        
    }
    
    init(fromDictionary weatherDict: NSDictionary) {
        
        if let lSummary  = weatherDict["summary"] as? String {
            summary = lSummary
        }
        
        if let lIcon  = weatherDict["icon"] as? String {
            icon = lIcon
        }
        
        if let lHourStats = weatherDict["data"] as? [NSDictionary] {
            print("...hourStats dict")
            
            hourStats = lHourStats.flatMap({ WeatherStats(fromDictionary: $0) })
        }
    }
}

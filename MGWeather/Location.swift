//
//  Location.swift
//  MGWeather
//
//  Created by Mark Gumbs on 02/09/2016.
//

import UIKit
import CoreLocation

class Location: NSObject {
    
    var currentLatitude: Double?
    var currentLongitude: Double?
    var currentPostcode: String?
    var currentStreet: String?
    var currentCity: String?
    var currentCountry: String?
    
    var currentLocation: CLLocation?
//    var compareLocation: CLLocation?

}

//
//  Location.swift
//  MGWeather
//
//  Created by Mark Gumbs on 02/09/2016.
//

import UIKit
import CoreLocation

class Location: NSObject {
    
    var name: String?
    var currentLatitude: Double?
    var currentLongitude: Double?
    var currentPostcode: String?
    var currentStreet: String?
    var currentCity: String?
    var currentCountry: String?
    var currentCountryCode: String?
    var currentAltitude: Double?
    
    var currentLocation: CLLocation?
//    var compareLocation: CLLocation?

}

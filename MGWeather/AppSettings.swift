//
//  AppSettings.swift
//  SkyCast
//
//  Created by Mark Gumbs on 09/11/2016.
//

import UIKit

class AppSettings: NSObject {

    static let DemoMode = false
    
    static let ShowBannerAds = true
    static let SpecialThemedBackgroundsForEvents = true
    
    static let BannerAdsTestMode = false     // Set this to TRUE to show test ads
    static let AdMobAppID = GlobalConstants.AdMobAppID
    static let AdMobBannerID = GlobalConstants.AdMobBannerID
    
    static let AdTestDeviceID = GlobalConstants.BannerAdTestIDs.Simulator
}

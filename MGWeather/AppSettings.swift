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
    
    static let BannerAdsTestMode = false    // Set this to TRUE to show test ads
    static let AdMobAppID = GlobalConstants.AdMobAppID
    static let AdMobBannerID = GlobalConstants.AdMobBannerID
    
    static let showTimelineAndLastYear = true
    
    // Change this depending on if using simulator or test device
//    static var AdTestDeviceID = GlobalConstants.BannerAdTestIDs.Simulator
    
//    override init() {
//        
//        #if (TARGET_IPHONE_SIMULATOR)
//            AppSettings.AdTestDeviceID = GlobalConstants.BannerAdTestIDs.Simulator
//        #else
//            AppSettings.AdTestDeviceID = GlobalConstants.BannerAdTestIDs.IPhone6
//        #endif
//    }
}

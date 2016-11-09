//
//  InfoPopupViewController.swift
//  MGWeather
//
//  Created by Mark Gumbs on 20/07/2016.
//  Copyright © 2016 britishairways. All rights reserved.
//

import UIKit
import GoogleMobileAds

protocol InfoPopupViewControllerDelegate
{
    
}

class InfoPopupViewController: UIViewController {
    
    var delegate:InfoPopupViewControllerDelegate?
    
    // MARK: Outlets
    
    @IBOutlet weak var outerView: UIView!
    @IBOutlet weak var weatherImage : UIImageView!
    @IBOutlet weak var informationText: UITextView!

    /// The banner view.
    @IBOutlet weak var bannerView: GADBannerView!

    var informationString : String!
    var informationTitleString : String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        initialScreenSetup ()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Ease in the weather image view for effect
        self.weatherImage.alpha = 0.2
        UIView.animate(withDuration: 0.6, delay: 0.0, options: UIViewAnimationOptions.curveEaseIn, animations: {
            self.weatherImage.alpha = 1
        }, completion: nil)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initialScreenSetup () {
        
        informationText.backgroundColor = GlobalConstants.ViewShading.Lighter
        informationText.alpha = CGFloat(GlobalConstants.DisplayViewAlpha)

        informationText.layer.cornerRadius = 10.0
        informationText.clipsToBounds = true
        
        informationText.text = informationString
        if AppSettings.ShowBannerAds {
            loadBannerAd()
        }
    }
    
    func loadBannerAd() {
        
        print("Google Mobile Ads SDK version: \(GADRequest.sdkVersion())")
        bannerView.adUnitID = AppSettings.AdMobBannerID
        bannerView.rootViewController = self
        
        let request = GADRequest()
        if AppSettings.BannerAdsTestMode {
            // Display test banner ads in the simulator
            request.testDevices = [kGADSimulatorID]
        }
        
        bannerView.load(request)
        
    }

    
    
    // MARK: Button related methods
    
    @IBAction func backButtonPressed(_ sender: AnyObject) {
        
        // Dismiss view
        self.dismiss(animated: true, completion: nil)

    }
}


//
//  InfoPopupViewController.swift
//  MGWeather
//
//  Created by Mark Gumbs on 20/07/2016.
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
    @IBOutlet weak var alertInfoOuterView: UIView!
    @IBOutlet weak var informationText: UITextView!
    @IBOutlet weak var weatherAlertSourceButtonOuterView: UIView!
    @IBOutlet weak var weatherAlertSourceButton: UIButton!

    /// The banner view.
    @IBOutlet weak var bannerView: GADBannerView!

    var informationString : String!
    var informationTitleString : String!
    var weatherAlertSourceURL : String!
    
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

        alertInfoOuterView.layer.cornerRadius = 10.0
        alertInfoOuterView.clipsToBounds = true
        
        informationText.text = informationString
        
        setupColourScheme()

        if AppSettings.ShowBannerAds {
            loadBannerAd()
        }
    }
    
    func setupColourScheme() {
        
        // Setup pods and text colour accordingly
        
        let colourScheme = Utility.setupColourScheme()
        
        let textColourScheme = colourScheme.textColourScheme
        let podColourScheme = colourScheme.podColourScheme
        let titleViewColourScheme = colourScheme.titleViewColourScheme
       
        // Labels
        informationText.textColor = textColourScheme
        
        // Pods
        alertInfoOuterView.backgroundColor = podColourScheme
        alertInfoOuterView.alpha = CGFloat(GlobalConstants.DisplayViewAlpha) + 5.0

        weatherAlertSourceButtonOuterView.backgroundColor = podColourScheme
        
        // Buttons and Title Labels
        weatherAlertSourceButton.backgroundColor = titleViewColourScheme
        weatherAlertSourceButton.titleEdgeInsets.right = 10 // Add right padding of text
        
    }

    func loadBannerAd() {
        
        print("Google Mobile Ads SDK version: \(GADRequest.sdkVersion())")
        bannerView.adUnitID = AppSettings.AdMobBannerID
        bannerView.rootViewController = self
        
        let request = GADRequest()
        if AppSettings.BannerAdsTestMode {
            // Display test banner ads in the simulator
//            request.testDevices = [AppSettings.AdTestDeviceID]
            request.testDevices = [GlobalConstants.BannerAdTestIDs.Simulator,
                                   GlobalConstants.BannerAdTestIDs.IPhone6]

        }
        
        bannerView.load(request)
        
    }

    
    // MARK: Button related methods
    
    @IBAction func backButtonPressed(_ sender: AnyObject) {
        
        // Dismiss view
        self.dismiss(animated: true, completion: nil)

    }
    
    @IBAction func weatherAlertSourceButton(_ sender: AnyObject) {
        
        // Display the weather alert from its source on the net
        UIApplication.shared.openURL(URL(string: weatherAlertSourceURL)!)
    }
}


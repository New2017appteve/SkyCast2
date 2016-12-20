//
//  AboutViewController.swift
//  MGWeather
//
//  Created by Mark Gumbs on 20/07/2016.
//

import UIKit
import MessageUI
import GoogleMobileAds

class AboutViewController: UIViewController, MFMailComposeViewControllerDelegate {

    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var weatherImage : UIImageView!
    @IBOutlet weak var aboutView: UIView!
    @IBOutlet weak var aboutTitle: UILabel!
    @IBOutlet weak var aboutVersion: UILabel!
    @IBOutlet weak var aboutAuthor: UILabel!
    @IBOutlet weak var aboutDescription: UILabel!

    @IBOutlet weak var emailView: UIView!
    @IBOutlet weak var supportFeedbackTitle: UILabel!
    @IBOutlet weak var emailButton: UIButton!
    
    @IBOutlet weak var creditsView: UIView!
    @IBOutlet weak var creditsTitle: UILabel!
    @IBOutlet weak var weatherSource: UITextView!
    @IBOutlet weak var iconSource: UITextView!
    @IBOutlet weak var photoSource: UITextView!
    
    /// The banner view.
    @IBOutlet weak var bannerView: GADBannerView!
    
    var DisplayViewAlphaForSettingsScreen = GlobalConstants.DisplayViewAlpha - 0.15
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupScreen()
        setupColourScheme()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    
        // Ease in the outer screen view for effect
        self.weatherImage.alpha = 0.2
        UIView.animate(withDuration: 1.0, delay: 0.5, options: UIViewAnimationOptions.curveEaseIn, animations: {
            
                self.weatherImage.alpha = CGFloat(self.DisplayViewAlphaForSettingsScreen)
            
            }, completion: nil)
        
        setupColourScheme()
        
        // Ease in the two pods
        self.aboutView.alpha = 0.0
        UIView.animate(withDuration: 1.0, delay: 1.5, options: UIViewAnimationOptions.curveEaseIn, animations: {
            self.aboutView.alpha = CGFloat(self.DisplayViewAlphaForSettingsScreen)
        }, completion: nil)
        
        self.emailView.alpha = 0.0
        UIView.animate(withDuration: 1.0, delay: 2.0, options: UIViewAnimationOptions.curveEaseIn, animations: {
            self.emailView.alpha = CGFloat(self.DisplayViewAlphaForSettingsScreen)
        }, completion: nil)
        
        self.creditsView.alpha = 0.0
        UIView.animate(withDuration: 1.0, delay: 2.5, options: UIViewAnimationOptions.curveEaseIn, animations: {
            self.creditsView.alpha = CGFloat(self.DisplayViewAlphaForSettingsScreen)
        }, completion: nil)
        
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupScreen () {

        // Make round corners for the outerviews
        
        aboutView.layer.cornerRadius = 10.0
        aboutView.clipsToBounds = true
        
        emailView.layer.cornerRadius = 10.0
        emailView.clipsToBounds = true
        
        creditsView.layer.cornerRadius = 10.0
        creditsView.clipsToBounds = true
        
        // Make corners for the textviews, for effect
        emailButton.layer.cornerRadius = 10.0
        emailButton.clipsToBounds = true
        
        weatherSource.layer.cornerRadius = 10.0
        weatherSource.clipsToBounds = true
        
        iconSource.layer.cornerRadius = 10.0
        iconSource.clipsToBounds = true
        
        photoSource.layer.cornerRadius = 10.0
        photoSource.clipsToBounds = true

        aboutTitle.text = GlobalConstants.AppName
        aboutVersion.text = "Version " + Utility.getBuildVersion()
        aboutDescription.text = "The latest forecast for your area, utilising Dark Sky data and great photos."
        
        // Make the label to the credits clickable
        let urlString = "Weather API Powered By Dark Sky"
        let attributedString = NSMutableAttributedString(string: urlString)
        attributedString.addAttribute(NSLinkAttributeName, value: GlobalConstants.DarkSkyURL, range: NSRange(location: 0, length: urlString.characters.count))
        weatherSource.attributedText = attributedString

        let iconUrlString = "Weather icons from Icons8"
        let iconAttributedString = NSMutableAttributedString(string: iconUrlString)
        iconAttributedString.addAttribute(NSLinkAttributeName, value: GlobalConstants.WeatherIconURL, range: NSRange(location: 0, length: iconUrlString.characters.count))
        iconSource.attributedText = iconAttributedString

        let photosUrlString = "Photos from Pexels"
        let photosAttributedString = NSMutableAttributedString(string: photosUrlString)
        photosAttributedString.addAttribute(NSLinkAttributeName, value: GlobalConstants.WeatherPhotosURL, range: NSRange(location: 0, length: photosUrlString.characters.count))
        photoSource.attributedText = photosAttributedString

        if AppSettings.ShowBannerAds {
            loadBannerAd()
        }
    }
    
    func setupColourScheme() {
        
        changeBackground () 
        // Setup pods and text colour accordingly
        
        let colourScheme = Utility.setupColourScheme()
        
        let textColourScheme = colourScheme.textColourScheme
        let podColourScheme = colourScheme.podColourScheme
        
        // Labels
        aboutTitle.textColor = textColourScheme
        aboutVersion.textColor = textColourScheme
        aboutAuthor.textColor = textColourScheme
        aboutDescription.textColor = textColourScheme
        supportFeedbackTitle.textColor = textColourScheme
        creditsTitle.textColor = textColourScheme
        weatherSource.textColor = textColourScheme
        iconSource.textColor = textColourScheme
        photoSource.textColor = textColourScheme
        
        // Pods
        creditsView.backgroundColor = podColourScheme
        aboutView.backgroundColor = podColourScheme
        emailView.backgroundColor = podColourScheme
        
        creditsView.alpha = CGFloat(GlobalConstants.DisplayViewAlpha) - 0.2
        aboutView.alpha = CGFloat(GlobalConstants.DisplayViewAlpha) - 0.2
        emailView.alpha = CGFloat(GlobalConstants.DisplayViewAlpha) - 0.2

        // Buttons and Title Labels
        emailButton.backgroundColor = podColourScheme
        
        weatherSource.backgroundColor = podColourScheme
        iconSource.backgroundColor = podColourScheme
        photoSource.backgroundColor = podColourScheme
        
    }

    func changeBackground () {
        
        // Change the background between three different types
        
        var backgroundImageName : String!
        
        let rand = Int(arc4random_uniform(3))
        switch (rand) {
        case 0:
            backgroundImageName = GlobalConstants.AboutScreenBackground.One.rawValue
        case 1:
            backgroundImageName = GlobalConstants.AboutScreenBackground.Two.rawValue
        case 2:
            backgroundImageName = GlobalConstants.AboutScreenBackground.Three.rawValue
        default:
            backgroundImageName = GlobalConstants.AboutScreenBackground.One.rawValue
        }
        
        weatherImage.image = UIImage(named: backgroundImageName)!
        
    }

    func loadBannerAd() {
        
        print("Google Mobile Ads SDK version: \(GADRequest.sdkVersion())")
        bannerView.adUnitID = AppSettings.AdMobBannerID
        bannerView.rootViewController = self
        
        let request = GADRequest()
        if AppSettings.BannerAdsTestMode {
            // Display test banner ads in the simulator
            request.testDevices = [GlobalConstants.BannerAdTestIDs.Simulator,
                                   GlobalConstants.BannerAdTestIDs.IPhone6]
        }
        
        bannerView.load(request)
    }
    
    @IBAction func emailButtonPressed(_ sender: AnyObject) {
        sendEmail()
    }
    
    func sendEmail() {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients([GlobalConstants.SupportEmailAddress])
            
            //  Send some device information in the email
            
            let deviceHardware = UIDeviceHardware.platformString()
            
            let majorVersion = ProcessInfo.processInfo.operatingSystemVersion.majorVersion
            let minorVersion = ProcessInfo.processInfo.operatingSystemVersion.minorVersion
            
            let iosVersion = String(majorVersion) + "." + String(minorVersion)
            
            var messageBody = "<p>Device Type: " + deviceHardware + "</p>"
            messageBody = messageBody + "<p>iOS Version: " + iosVersion + "</p>"
            
            mail.setMessageBody(messageBody, isHTML: true)
            
            present(mail, animated: true)
        } else {
            // show failure alert
            
            let messageText = "Sorry, your device has not been set up to send emails."
            Utility.showMessage(titleString: "Email Error", messageString: messageText )
            


        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
    
    @IBAction func backButtonPressed(_ sender: AnyObject) {
        // Dismiss view
        self.dismiss(animated: true, completion: nil)
    }

}

//
//  AboutViewController.swift
//  MGWeather
//
//  Created by Mark Gumbs on 20/07/2016.
//  Copyright © 2016 britishairways. All rights reserved.
//

import UIKit
import MessageUI

class AboutViewController: UIViewController, MFMailComposeViewControllerDelegate {

    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var aboutView: UIView!
    @IBOutlet weak var aboutTitle: UILabel!
    @IBOutlet weak var aboutVersion: UILabel!
    @IBOutlet weak var aboutAuthor: UILabel!
    @IBOutlet weak var aboutDescription: UILabel!

    @IBOutlet weak var emailView: UIView!
    @IBOutlet weak var emailButton: UIButton!
    
    @IBOutlet weak var creditsView: UIView!
    @IBOutlet weak var weatherSource: UITextView!
    @IBOutlet weak var iconSource: UITextView!
    @IBOutlet weak var photoSource: UITextView!
    
    @IBOutlet weak var aboutCredits: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupScreen()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupScreen () {
    
        aboutView.backgroundColor = GlobalConstants.ViewShading.Lighter
        emailView.backgroundColor = GlobalConstants.ViewShading.Lighter
        creditsView.backgroundColor = GlobalConstants.ViewShading.Lighter
        
        aboutView.alpha = 0.6
        emailView.alpha = 0.6
        creditsView.alpha = 0.6

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
        
        emailButton.backgroundColor = GlobalConstants.ViewShading.Darker
        weatherSource.backgroundColor = GlobalConstants.ViewShading.Darker
        iconSource.backgroundColor = GlobalConstants.ViewShading.Darker
        photoSource.backgroundColor = GlobalConstants.ViewShading.Darker

        aboutTitle.text = GlobalConstants.AppName
        
        // Make the label to the credits clickable
        let urlString = "Weather API powered By Dark Sky API"
        let attributedString = NSMutableAttributedString(string: urlString)
        attributedString.addAttribute(NSLinkAttributeName, value: GlobalConstants.DarkSkyURL, range: NSRange(location: 0, length: urlString.characters.count))
        weatherSource.attributedText = attributedString

        let iconUrlString = "Weather icons from Icons8"
        let iconAttributedString = NSMutableAttributedString(string: iconUrlString)
        iconAttributedString.addAttribute(NSLinkAttributeName, value: GlobalConstants.WeatherIconURL, range: NSRange(location: 0, length: iconUrlString.characters.count))
        iconSource.attributedText = iconAttributedString

        let photosUrlString = "Weather photos from FreeDigitalPhotos"
        let photosAttributedString = NSMutableAttributedString(string: photosUrlString)
        photosAttributedString.addAttribute(NSLinkAttributeName, value: GlobalConstants.WeatherPhotosURL, range: NSRange(location: 0, length: photosUrlString.characters.count))
        photoSource.attributedText = photosAttributedString
        
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
            let alertView = UIAlertView(title: "Email Error", message: messageText, delegate: nil, cancelButtonTitle: "OK")
            alertView.show()

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

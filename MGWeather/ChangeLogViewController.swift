//
//  ChangeLogViewController.swift
//  SkyCast
//
//  Created by Mark Gumbs on 06/02/2017.
//  Copyright © 2017 MGSoft. All rights reserved.
//

import UIKit

class ChangeLogViewController: UIViewController {

    // MARK: Outlets
    
    @IBOutlet weak var titleBar: UINavigationBar!
    @IBOutlet weak var backBarButton: UIBarButtonItem!
    @IBOutlet weak var okBarButton: UIBarButtonItem!
    
    @IBOutlet weak var webView: UIWebView!
    
    // State how the screen will be invoked (on STARTUP or ABOUT_SCREEN)
    var startupMode : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        setupScreen()
        
        var changeFileName = ""
        if startupMode == "STARTUP" {
            changeFileName = "SkyCast WhatsNew"
        }
        else {
            changeFileName = "SkyCast ChangeLog"
//            changeFileName = "SkyCast WhatsNew"
        }
        
        webView.loadRequest(URLRequest(url: URL(fileURLWithPath: Bundle.main.path(forResource: changeFileName, ofType: "htm")!)))
        
    }
    
    func setupScreen() {
        
        // Make round corners for the outerviews
        
        webView.layer.cornerRadius = 15.0
        webView.clipsToBounds = true
        
        setViewControllerTitle()
        
        if startupMode == "STARTUP" {
            backBarButton.isEnabled = false
            backBarButton.title = ""
            okBarButton.isEnabled = true
        }
        else if startupMode == "ABOUT_SCREEN" {
            backBarButton.isEnabled = true
            okBarButton.isEnabled = false
            okBarButton.title = ""
        }
        
    }

    func setViewControllerTitle () {
        
        let titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: view.frame.size.width - 120, height: 44))
        titleLabel.backgroundColor = UIColor.clear
        titleLabel.numberOfLines = 1
        titleLabel.textAlignment = NSTextAlignment.center
        titleLabel.text = GlobalConstants.AppName
        
        if startupMode == "STARTUP" {
            titleLabel.text = titleLabel.text! + " - Whats New"
        }
        else {
            titleLabel.text = titleLabel.text! + " - Changes"
        }
        titleBar.topItem?.titleView = titleLabel
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    func saveAcknowledgementOfWhatsNew() {
        
        let appVersion = Utility.getBuildVersion()
        
        // Save the version number of the app so we know the WhatsNew screen has been shown
        // at least once
        
        let userDefaults = UserDefaults.standard
        userDefaults.set(appVersion, forKey: GlobalConstants.Defaults.WhatsNewLastVersion)

    }
    
    // MARK: Button methods
    
    @IBAction func backButtonPressed(_ sender: AnyObject) {
        // Dismiss view
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func okButtonPressed(_ sender: AnyObject) {
        
        // Save the fact that the user has seen the 'Whats New' screen so we don't show it to
        // them again, until the next app release
        
        if AppSettings.ChangeLogAcknowledgementSavingOn {
            saveAcknowledgementOfWhatsNew()
        }
        
        // Dismiss view
        self.dismiss(animated: true, completion: nil)
    }

}

//
//  FeelsLikeViewCV.swift
//  SkyCast
//
//  Created by Mark Gumbs on 19/04/2017.
//  Copyright © 2017 MGSoft. All rights reserved.
//

import UIKit

class FeelsLikeViewCV: UIViewController {

    @IBOutlet weak var cvBackgroundView : UIView!
    @IBOutlet weak var feelsLikeTemp : UILabel!
    @IBOutlet weak var currentWeatherIcon : UIImageView!

    var feelsLikeTempString: String?
    var currentWeatherIconString: String?
    var currentWeatherIconName: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        setupView()
        setupColourScheme()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func setupView() {
    
        feelsLikeTemp.text = feelsLikeTempString
        if !((currentWeatherIconName?.isEmpty)!) {
            currentWeatherIcon.image = UIImage(named: currentWeatherIconName!)
        }
    }
    
    func setupColourScheme() {
        
        // Setup pods and text colour accordingly
        
        let colourScheme = Utility.setupColourScheme()
        
        let textColourScheme = colourScheme.textColourScheme
        let podColourScheme = colourScheme.podColourScheme
        
        // Labels
        
        feelsLikeTemp.textColor = textColourScheme
        
        // Pods
        
        cvBackgroundView.backgroundColor = podColourScheme
        
    }

}

//
//  WindViewCV.swift
//  SkyCast
//
//  Created by Mark Gumbs on 19/04/2017.
//  Copyright © 2017 MGSoft. All rights reserved.
//

import UIKit

class WindViewCV: UIViewController {

    @IBOutlet weak var cvBackgroundView : UIView!
    @IBOutlet weak var currentWindspeed : UILabel!
    @IBOutlet weak var compassView : UIView!
    @IBOutlet weak var compassArrow : UIImageView!
    
    @IBOutlet weak var northLabel : UILabel!
    @IBOutlet weak var southLabel : UILabel!
    @IBOutlet weak var westLabel : UILabel!
    @IBOutlet weak var eastLabel : UILabel!

    var currentWindspeedString : String?
    var currentWindDirectionDegrees : Float?
    var compassIconImage : String?
    
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
        
        compassView.layer.cornerRadius = compassView.frame.size.width/2
        compassView.clipsToBounds = true
        compassView.layer.borderWidth = 1
        compassView.layer.borderColor = UIColor.white.cgColor
        
        compassArrow.image = UIImage(named: compassIconImage!)

        rotateCompassArrow(angleDegrees: currentWindDirectionDegrees!)
        currentWindspeed.text = currentWindspeedString
    }
    
    func setupColourScheme() {
        
        // Setup pods and text colour accordingly
        
        let colourScheme = Utility.setupColourScheme()
        
        let textColourScheme = colourScheme.textColourScheme
        let podColourScheme = colourScheme.podColourScheme
        
        // Labels
        
        currentWindspeed.textColor = textColourScheme
        northLabel.textColor = textColourScheme
        southLabel.textColor = textColourScheme
        westLabel.textColor = textColourScheme
        eastLabel.textColor = textColourScheme
        
        // Pods
        
        cvBackgroundView.backgroundColor = podColourScheme
        compassView.backgroundColor = podColourScheme
    }

    func rotateCompassArrow(angleDegrees : Float) {
        
        // 1 degree = 0.0174533 radians
        // Use radans for rotation angle
        
        let degreeToRadians = Float(0.0174533)
        
        let angleRadians = angleDegrees * degreeToRadians
        compassArrow.transform = CGAffineTransform(rotationAngle: CGFloat(angleRadians) )
        
    }
}

//
//  LaunchScreenVC.swift
//  SkyCast
//
//  Created by Mark Gumbs on 12/12/2016.
//  Copyright © 2016 MGSoft. All rights reserved.
//

import UIKit

class LaunchScreenVC: UIViewController {

    @IBOutlet weak var weatherImage : UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupScreen()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func setupScreen() {
        
        let lastLoadedBackground = Utility.getLastLoadedBackground()
        
        // Ease in the image view
        self.weatherImage.alpha = 0.2
        weatherImage.image = UIImage(named: lastLoadedBackground)!
        
        UIView.animate(withDuration: 0.6, delay: 0.0, options: UIViewAnimationOptions.curveEaseIn, animations: {
            self.weatherImage.alpha = 1
        }, completion: nil)
        
    }

}

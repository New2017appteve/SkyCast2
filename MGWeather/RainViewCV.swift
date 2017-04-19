//
//  RainViewCV.swift
//  SkyCast
//
//  Created by Mark Gumbs on 19/04/2017.
//  Copyright © 2017 MGSoft. All rights reserved.
//

import UIKit

class RainViewCV: UIViewController {

    @IBOutlet weak var rainNowIcon : UIImageView!
    @IBOutlet weak var rainNowProbability : UILabel!
    @IBOutlet weak var nearestRainDistance : UILabel!

    var rainNowIconString: String?
    var rainNowProbabilityString: String?
    var nearestRainDistanceString: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


}

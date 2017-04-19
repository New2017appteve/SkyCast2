//
//  FeelsLikeView.swift
//  SkyCast
//
//  Created by Mark Gumbs on 19/04/2017.
//  Copyright © 2017 MGSoft. All rights reserved.
//

import UIKit

class FeelsLikeView: UIViewController {

    @IBOutlet weak var feelsLikeTemp : UILabel!
    @IBOutlet weak var currentWeatherIcon : UIImageView!

    var feelsLikeTempString: String?
    var currentWeatherIconString: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

//
//  HourlyWeatherCell.swift
//  MGWeather
//
//  Created by Mark Gumbs on 28/08/2016.
//

import UIKit

class HourlyWeatherCell: UITableViewCell {

    @IBOutlet weak var hourLabel : UILabel!
    @IBOutlet weak var temperatureLabel : UILabel!
    @IBOutlet weak var rainInfoStackView : UIStackView!
    @IBOutlet weak var rainIcon : UIImageView!
    @IBOutlet weak var rainProbabilityLabel : UILabel!
    @IBOutlet weak var summaryIcon : UIImageView!
    
    var count = 0
    
    func showSunriseSunsetDetails() {
        
        setupDisplayTimer()
    }
    
    func setupDisplayTimer() {
        
        count = 0
        
        _ = Timer.scheduledTimer(timeInterval: 4.0, target: self, selector: #selector(updateCell), userInfo: nil, repeats: true)
        
    }
    
    func updateCell() {
        
        count += 1
        
        let countMod = count % 2
        switch (countMod) {
        case 0:
            hourLabel.text = "1 BLAH"
        case 1:
            hourLabel.text = "2 BLAH"
        default:
            hourLabel.text = ""
        }

    }

}

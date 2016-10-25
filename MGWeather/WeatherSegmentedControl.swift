//
//  WeatherSegmentedControl.swift
//  MGWeather
//
//  Created by Mark Gumbs on 30/08/2016.
//  Copyright © 2016 britishairways. All rights reserved.
//

import UIKit

class WeatherSegmentedControl: UISegmentedControl {
    
    func initUI(){
        setupBackground()
        setupFonts()
    }
    
    func setupBackground(){
        let backgroundImage = UIImage(named: "segmented_unselected_bg")
        let dividerImage = UIImage(named: "segmented_separator_bg")
        let backgroundImageSelected = UIImage(named: "segmented_selected_bg")
        
        self.setBackgroundImage(backgroundImage, for: .normal, barMetrics: .default)
        self.setBackgroundImage(backgroundImageSelected, for: .highlighted, barMetrics: .default)
        self.setBackgroundImage(backgroundImageSelected, for: .selected, barMetrics: .default)
        
        self.setDividerImage(dividerImage, forLeftSegmentState: .normal, rightSegmentState: .selected, barMetrics: .default)
        self.setDividerImage(dividerImage, forLeftSegmentState: .selected, rightSegmentState: .normal, barMetrics: .default)
        self.setDividerImage(dividerImage, forLeftSegmentState: .normal, rightSegmentState: .normal, barMetrics: .default)
        
        
//        var subViewOfSegment: UIView = self.subviews[0] as UIView
//        subViewOfSegment.tintColor = UIColor.blue
    }
    
    func setupFonts(){
        let font = UIFont.systemFont(ofSize: 15.0)
        
        let normalTextAttributes = [
            NSForegroundColorAttributeName: UIColor.black,
            NSFontAttributeName: font
        ]
        
        self.setTitleTextAttributes(normalTextAttributes, for: .normal)
        self.setTitleTextAttributes(normalTextAttributes, for: .highlighted)
        self.setTitleTextAttributes(normalTextAttributes, for: .selected)
    }


}

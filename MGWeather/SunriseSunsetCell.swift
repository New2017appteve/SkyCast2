//
//  SunriseSunsetCell.swift
//  SkyCast
//
//  Created by Mark Gumbs on 08/12/2016.
//  Copyright © 2016 MGSoft. All rights reserved.
//

import UIKit

class SunriseSunsetCell: UITableViewCell {

    @IBOutlet weak var descriptionLabel : UILabel!
    @IBOutlet weak var hourLabel : UILabel!
    @IBOutlet weak var hourLabelTwo : UILabel!
    @IBOutlet weak var graphColourLabel : UILabel!
    @IBOutlet weak var daylightHoursLabel : UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

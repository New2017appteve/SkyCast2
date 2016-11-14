//
//  Flags.swift
//  SkyCast
//
//  Created by Mark Gumbs on 14/11/2016.
//  Copyright © 2016 britishairways. All rights reserved.
//

import UIKit

class Flags: NSObject {

    var units : String?

    override init(){
        
    }
    
    init(fromDictionary weatherDict: NSDictionary) {
        
        if let lUnits = weatherDict["units"] as? String {
            units = lUnits
        }

    }
}

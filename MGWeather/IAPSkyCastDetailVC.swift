//
//  IAPSkyCastDetailVC.swift
//  SkyCast
//
//  Created by Mark Gumbs on 23/06/2017.
//  Copyright © 2017 MGSoft. All rights reserved.
//

import UIKit

class IAPSkyCastDetailVC: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView?
    
    var image: UIImage? {
        didSet {
            configureView()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureView()
    }
    
    func configureView() {
        imageView?.image = image
    }
}

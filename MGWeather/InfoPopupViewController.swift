//
//  InfoPopupViewController.swift
//  MGWeather
//
//  Created by Mark Gumbs on 20/07/2016.
//  Copyright © 2016 britishairways. All rights reserved.
//

import UIKit

protocol InfoPopupViewControllerDelegate
{
    
}

class InfoPopupViewController: UIViewController {
    
    var delegate:InfoPopupViewControllerDelegate?
    
    // MARK: Outlets
    
    @IBOutlet weak var outerView: UIView!
    //@IBOutlet weak var informationTitle: UILabel!
    @IBOutlet weak var informationText: UITextView!
    
    var informationString : String!
    var informationTitleString : String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        initialScreenSetup ()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initialScreenSetup () {
        
        informationText.layer.cornerRadius = 10.0
        informationText.clipsToBounds = true
        
       // informationTitle.text = informationTitleString
        informationText.text = informationString
    }
    
    
    // MARK: Button related methods
    
    @IBAction func backButtonPressed(_ sender: AnyObject) {
        
        // Dismiss view
        self.dismiss(animated: true, completion: nil)

    }
}


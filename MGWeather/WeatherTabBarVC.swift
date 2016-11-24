//
//  WeatherTabBarVC.swift
//  Weather
//
//  Created by Mark Gumbs on 26/06/2016.
//

import UIKit

class WeatherTabBarVC: UITabBarController {
    
    // Outlets
    @IBOutlet weak var weatherTabBars : UITabBar!
    
    var weather = Weather()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        // let dict = getWeatherData2()
        initialScreenSetup ()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func initialScreenSetup () {
        
        let tabItems = self.tabBar.items! as [UITabBarItem]
        let tabItem0 = tabItems[0] as UITabBarItem
        let tabItem1 = tabItems[1] as UITabBarItem
        
        tabItem0.title = "Today"
        tabItem1.title = "Daily"
        
        
        
        //  tabItem0.image = UIImage(named: "Search")
        //  tabItem1.image = UIImage(named: "Search")
        
        // Alter font size of tab descriptions
        let font = UIFont(name: "Helvetica Neue", size: 16)
        let objs = NSArray(objects: font!, UIColor.black)
        let keys = NSArray(objects: NSFontAttributeName, NSForegroundColorAttributeName)
        UITabBarItem.appearance().setTitleTextAttributes(NSDictionary(objects: objs as [AnyObject], forKeys: keys as! [NSCopying]) as? [String : AnyObject], for: UIControlState.normal)
        
        self.selectedIndex = 0  // Today Tab
        let selectedObjs = NSArray(objects: font!, UIColor.red)
        tabItem0.setTitleTextAttributes(NSDictionary(objects: selectedObjs as [AnyObject], forKeys: keys as! [NSCopying]) as? [String : AnyObject], for: UIControlState.normal)

        
    }
    
    
    
    //    func getWeatherData2 () -> NSDictionary {
    //
    //        var returnDictionary : NSDictionary = [:]
    //
    //        let defaultSession = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
    //        var dataTask: NSURLSessionDataTask?
    //
    //        if dataTask != nil {
    //            dataTask?.cancel()
    //        }
    //
    //        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    //
    //        let url = NSURL(string: "https://api.forecast.io/forecast/2dd6883f4f06cd2acdd6b3b0771a9b7c/51.5175,0.6432?units=si")
    //
    //        dataTask = defaultSession.dataTaskWithURL(url!) {
    //            data, response, error in
    //            // 6
    //            dispatch_async(dispatch_get_main_queue()) {
    //                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
    //            }
    //
    //            if let error = error {
    //                print(error.localizedDescription)
    //            } else if let httpResponse = response as? NSHTTPURLResponse {
    //                if httpResponse.statusCode == 200 {
    //
    //                    // Valid Response
    //                    let response = NSString (data: data!, encoding: NSUTF8StringEncoding)
    //                    print("Response = \(response)")
    //
    //                    // Get JSON
    //                    do {
    //                        let getResponse = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments)
    //                        print (getResponse)
    //
    //                        returnDictionary = getResponse as! NSDictionary
    //                    } catch {
    //                        print("error serializing JSON: \(error)")
    //                    }
    //
    //                }
    //            }
    //        }
    //        // 8
    //        dataTask?.resume()
    //        
    //        return returnDictionary
    //    }
    
}

//
//  GetWeatherData.swift
//  Weather
//
//  Created by Mark Gumbs on 26/06/2016.
//

import UIKit

class GetWeatherData: NSObject {
    
    override init() {

        super.init()
    }
    
    
    func getData( urlAndParameters: String!, completionBlock:@escaping ((String?, NSError?,[NSObject : AnyObject]?, Int) -> Void) ){
        
        if AppSettings.DemoMode {
            
            let demoDataFileName = GlobalConstants.DemoWeatherFile
            
//            handleDemoResponse(statusCode: 200, responseFileName: demoDataFileName, demoBlock: completionBlock)
            return
        }
        
        getResourceFromUrl(url: urlAndParameters, block: completionBlock)
        
    }
    
    
//    func handleDemoResponse(statusCode : Int, responseFileName : String, demoBlock:@escaping ((String?, NSError?,[NSObject : AnyObject]?, Int) -> Void) ){
//        
//        // TODO:  Check to see if this is only going to work in IOS10
//        let dispatchTime: DispatchTime = DispatchTime.now() + Double(Int64(0.5 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
//
//        let delayTime = DispatchTime.now(dispatch_time_t(DispatchTime.now), Int64(0.5 * Double(NSEC_PER_SEC)))
//        
//        if let filePath = Bundle.main.path(forResource: responseFileName, ofType: "json"){
//            do { let responseString = try String(contentsOfFile: filePath, encoding:String.Encoding.utf8)
//                dispatch_after(delayTime, dispatch_get_main_queue()) {
//                    
//                    demoBlock(responseString,nil,nil,statusCode)
//                }
//            } catch {
//                dispatch_after(delayTime, dispatch_get_main_queue()) {
//                    
//                    demoBlock("",nil,nil,statusCode)
//                }
//            }
//        } else{
//            dispatch_after(delayTime, dispatch_get_main_queue()) {
//                
//                demoBlock("",nil,nil,statusCode)
//            }
//            
//        }
//    }
 

    func getResourceFromUrl(url: String!, block: ((String?, NSError?, [NSObject : AnyObject]?, Int) -> Void)!) {
        
        let configuration = URLSessionConfiguration .default
        let session = URLSession(configuration: configuration)
        let request : NSMutableURLRequest = NSMutableURLRequest()
        
        var urlString = url
        request.url = NSURL(string: NSString(format: "%@", urlString!) as String) as URL?

        // Use the 2 lines below to test a custom URL
        if (GlobalConstants.UseTestWeatherURLs) {
            urlString = GlobalConstants.WeatherURL
            request.url = NSURL(string: NSString(format: "%@", urlString!) as String) as URL?
        }
        
        request.httpMethod = "GET"
        request.timeoutInterval = 30
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let dataTask = session.dataTask(with: request as URLRequest) {
            data, response, error in

            
            // 1: Check HTTP Response for successful GET request
            guard let httpResponse = response as? HTTPURLResponse, let receivedData = data
                else {
                    print("Skycast: error not a valid http response or timed out: \(error ?? "" as! Error)")
                    block("", nil,nil,2000)
                    
                    return
            }
            
            switch (httpResponse.statusCode)
            {
            case 200:
                
                // Valid Response
                let response = String (data: receivedData, encoding: String.Encoding.utf8)
                print("Response = \(response)")
                
                // Get JSON
                do {
                    // TODO:  Review below, not using the getResponse variable
                    let getResponse = try JSONSerialization.jsonObject(with: receivedData, options: .allowFragments)
                    print (getResponse)
                    
                    block(response, nil,nil,httpResponse.statusCode)

                    
                } catch {
                    print("Skycast: error serializing JSON: \(error)")
                    block(response, nil,nil,httpResponse.statusCode)
                }
                
                break
            case 400:
                
                break
            default:
                print("GET request got response \(httpResponse.statusCode)")

            }
        }
        dataTask.resume()
        
    }

}

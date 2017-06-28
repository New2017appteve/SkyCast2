//
//  SkyCastProducts.swift
//  SkyCast
//
//  Created by Mark Gumbs on 22/06/2017.
//  Copyright © 2017 MGSoft. All rights reserved.
//

/** Notes
 *
 *
 * https://www.raywenderlich.com/122144/in-app-purchase-tutorial
 *
 */
 
import Foundation

public struct SkyCastProducts {
    
    // com.MGSoft.SkyCast.RemoveBannerAds
    public static let RemoveBannerAds = "com.MGSoft.SkyCast.RemoveBannerAds"
    
    fileprivate static let productIdentifiers: Set<ProductIdentifier> = [SkyCastProducts.RemoveBannerAds]
    
    public static let store = IAPHelper(productIds: SkyCastProducts.productIdentifiers)
}

func resourceNameForProductIdentifier(_ productIdentifier: String) -> String? {
    return productIdentifier.components(separatedBy: ".").last
}

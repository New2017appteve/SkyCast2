//
//  IAPSkyCastMainVC.swift
//  SkyCast
//
//  Created by Mark Gumbs on 28/06/2017.
//  Copyright © 2017 MGSoft. All rights reserved.
//

import UIKit
import StoreKit

class IAPSkyCastMainVC: UIViewController {

    // Outlets
    @IBOutlet weak var productsNaviBar : UINavigationBar!
//    @IBOutlet weak var rightBarButtonItem : UIBarButtonItem!
    
    @IBOutlet weak var itemsAvailableTitleLabel : UILabel!
    @IBOutlet weak var productsTableView : UITableView!
    @IBOutlet weak var refreshControl : UIRefreshControl!

    @IBOutlet weak var purchasesLabel : UILabel!
    @IBOutlet weak var restorePurchaseOuterView : UIView!
    @IBOutlet weak var restorePurchasesLabel : UILabel!
    @IBOutlet weak var restorePurchases : UIButton!
    
    let showDetailSegueIdentifier = "showDetail"
    
    var products = [SKProduct]()
    var purchasedProducts = [SKProduct]()
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == showDetailSegueIdentifier {
            guard let indexPath = productsTableView.indexPathForSelectedRow else {
                return false
            }
            
            let product = products[(indexPath as NSIndexPath).row]
            
            return SkyCastProducts.store.isProductPurchased(product.productIdentifier)
        }
        
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showDetailSegueIdentifier {
            guard let indexPath = productsTableView.indexPathForSelectedRow else { return }
            
            let product = products[(indexPath as NSIndexPath).row]
            
            if let name = resourceNameForProductIdentifier(product.productIdentifier),
                let detailViewController = segue.destination as? IAPSkyCastDetailVC {
                let image = UIImage(named: name)
                detailViewController.image = image
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "SkyCast"
        
  //      refreshControl = UIRefreshControl()
   //     refreshControl?.addTarget(self, action: #selector(IAPSkyCastMainVC.reload), for: .valueChanged)
        
//        let restoreButton = UIBarButtonItem(title: "Restore",
//                                            style: .plain,
//                                            target: self,
//                                            action: #selector(IAPSkyCastMainVC.restoreTapped(_:)))
// //       rightBarButtonItem = restoreButton
        
        NotificationCenter.default.addObserver(self, selector: #selector(IAPSkyCastMainVC.handlePurchaseNotification(_:)),
                                               name: NSNotification.Name(rawValue: IAPHelper.IAPHelperPurchaseNotification),
                                               object: nil)
        
        // Do any additional setup after loading the view.
        setupScreen()
        setupColourScheme()
        populatePurchasesLabel()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        reload()
    }
    
    func setupScreen () {
        
        // Make round corners for the outerviews
        
        itemsAvailableTitleLabel.layer.cornerRadius = 10.0
        itemsAvailableTitleLabel.clipsToBounds = true

        productsTableView.layer.cornerRadius = 10.0
        productsTableView.clipsToBounds = true
        
        restorePurchaseOuterView.layer.cornerRadius = 10.0
        restorePurchaseOuterView.clipsToBounds = true
        
        purchasesLabel.layer.cornerRadius = 10.0
        purchasesLabel.clipsToBounds = true
        
    }
    
    func setupColourScheme() {
        
        // Setup pods and text colour accordingly
        
        let colourScheme = Utility.setupColourScheme()
        
        let textColourScheme = colourScheme.textColourScheme
        let podColourScheme = colourScheme.podColourScheme
        
        // Labels
        restorePurchasesLabel.textColor = textColourScheme
        itemsAvailableTitleLabel.textColor = textColourScheme
        purchasesLabel.textColor = textColourScheme
        
        // Pods
        restorePurchaseOuterView.backgroundColor = podColourScheme
        productsTableView.backgroundColor = podColourScheme
        itemsAvailableTitleLabel.backgroundColor = podColourScheme
        purchasesLabel.backgroundColor = podColourScheme
    
        restorePurchaseOuterView.alpha = CGFloat(GlobalConstants.DisplayViewAlpha)
        productsTableView.alpha = CGFloat(GlobalConstants.DisplayViewAlpha)
        itemsAvailableTitleLabel.alpha = CGFloat(GlobalConstants.DisplayViewAlpha)
        purchasesLabel.alpha = CGFloat(GlobalConstants.DisplayViewAlpha)
        
        // Buttons and Title Labels
        
    }

    func populatePurchasesLabel() {
        
        NSLog (" Purchased Products count = " + purchasedProducts.count.description)
        var purchasesString = ""
        
        for i in purchasedProducts {
            purchasesString = purchasesString + "  - " + i.localizedTitle + "\n"
        }
        
        if purchasesString == "" {
            purchasesString = "  None"
        }
        purchasesLabel.text = "  Purchases:\n\n" + purchasesString
    }
    
    
    // In-App Purchase methods
    
    func reload() {
        products = []
        
        // Make a toast to say data is refreshing
        self.view.makeToast("Obtaining purchases", duration: 1.0, position: .bottom)
        self.view.makeToastActivity(.center)

        productsTableView.reloadData()
        
        SkyCastProducts.store.requestProducts{success, products in
            if success {
                self.products = products!
                
                self.productsTableView.reloadData()
                self.getPurchasedProducts()
            }
            
            self.refreshControl?.endRefreshing()
            self.view.hideToastActivity()
        }
    }
    
    func getPurchasedProducts() {
        
        // NOTE:  This is called on a background thread
        for product in products {
            
            if SkyCastProducts.store.isProductPurchased(product.productIdentifier) {
                
                NSLog("Product purchased")
                purchasedProducts .append(product)
            }
            else {
                // Remove after testing
               // purchasedProducts .append(product)
            }
        }
        
        populatePurchasesLabel()
    }
    


    func handlePurchaseNotification(_ notification: Notification) {
        guard let productID = notification.object as? String else { return }
        
        for (index, product) in products.enumerated() {
            guard product.productIdentifier == productID else { continue }
            
            productsTableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .fade)
        }
    }
    
    // MARK: Button related methods
    
    @IBAction func backButtonPressed(_ sender: AnyObject) {
        
        // Dismiss view
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func restoreButtonPressed(_ sender: AnyObject) {
        
        NSLog("Restore pressed")
        SkyCastProducts.store.restorePurchases()
        
    }


}  /////  End Class  /////

// MARK: - UITableViewDataSource

extension IAPSkyCastMainVC : UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return products.count
    }
   

    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:ProductCell = self.productsTableView.dequeueReusableCell(withIdentifier: "Cell") as! ProductCell
        
        let product = products[(indexPath as NSIndexPath).row]
        
        cell.product = product
        cell.buyButtonHandler = { product in
            SkyCastProducts.store.buyProduct(product)
        }
        
        // Setup text colour according to colour scheme
        
        let colourScheme = Utility.setupColourScheme()
        let textColourScheme = colourScheme.textColourScheme
        
        cell.textLabel?.textColor = textColourScheme
        cell.detailTextLabel?.textColor = textColourScheme
        
        // Alternate the shading of each table view cell
        if (colourScheme.type == GlobalConstants.ColourScheme.Dark) {
            if (indexPath.row % 2 == 0) {
                cell.backgroundColor = GlobalConstants.TableViewAlternateShadingDayDarkTheme.Darker
            }
            else {
                cell.backgroundColor = GlobalConstants.TableViewAlternateShadingDayDarkTheme.Lighter
            }
        }
        else {
            if (indexPath.row % 2 == 0) {
                cell.backgroundColor = GlobalConstants.TableViewAlternateShading.Darker
            }
            else {
                cell.backgroundColor = UIColor.white // GlobalConstants.TableViewAlternateShading.Lightest
            }
        }

        
        return cell
    }

}

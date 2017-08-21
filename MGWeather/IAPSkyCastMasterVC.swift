//
//  IAPSkyCastMasterVC.swift
//  SkyCast
//
//  Created by Mark Gumbs on 23/06/2017.
//  Copyright © 2017 MGSoft. All rights reserved.
//


import UIKit
import StoreKit

class IAPSkyCastMasterVC: UITableViewController {
    let showDetailSegueIdentifier = "showDetail"
    
    var products = [SKProduct]()
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == showDetailSegueIdentifier {
            guard let indexPath = tableView.indexPathForSelectedRow else {
                return false
            }
            
            let product = products[(indexPath as NSIndexPath).row]
            
            return SkyCastProducts.store.isProductPurchased(product.productIdentifier)
        }
        
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showDetailSegueIdentifier {
            guard let indexPath = tableView.indexPathForSelectedRow else { return }
            
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
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(IAPSkyCastMasterVC.reload), for: .valueChanged)
        
        let restoreButton = UIBarButtonItem(title: "Restore",
                                            style: .plain,
                                            target: self,
                                            action: #selector(IAPSkyCastMasterVC.restoreTapped(_:)))
        navigationItem.rightBarButtonItem = restoreButton
        
        NotificationCenter.default.addObserver(self, selector: #selector(IAPSkyCastMasterVC.handlePurchaseNotification(_:)),
                                               name: NSNotification.Name(rawValue: IAPHelper.IAPHelperPurchaseNotification),
                                               object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        reload()
    }
    
    func reload() {
        products = []
        
        tableView.reloadData()
        
        SkyCastProducts.store.requestProducts{success, products in
            if success {
                self.products = products!
                
                self.tableView.reloadData()
            }
            
            self.refreshControl?.endRefreshing()
        }
    }
    
    func restoreTapped(_ sender: AnyObject) {
        SkyCastProducts.store.restorePurchases()
    }
    
    func handlePurchaseNotification(_ notification: Notification) {
        guard let productID = notification.object as? String else { return }
        
        for (index, product) in products.enumerated() {
            guard product.productIdentifier == productID else { continue }
            
            tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .fade)
        }
    }
}

// MARK: - UITableViewDataSource

extension IAPSkyCastMasterVC {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return products.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
//         let cell:DailyWeatherCell = self.dailyWeatherTableView.dequeueReusableCell(withIdentifier: "DailyWeatherCellID") as! DailyWeatherCell
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell2", for: indexPath) as! ProductCell
        
        let product = products[(indexPath as NSIndexPath).row]
        
        cell.product = product
        cell.buyButtonHandler = { product in
            SkyCastProducts.store.buyProduct(product)
        }
        
        return cell
    }
}

//
//  MarketDetailViewController.swift
//  loopr-ios
//
//  Created by Xiao Dou Dou on 2/3/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit
import PopupDialog

class MarketDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var market: Market? = nil
    
    @IBOutlet weak var tableView: UITableView!
    
    let interactor = Interactor()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.dataSource = self
        tableView.delegate = self
        
        self.title = market?.description
        
        let backButton = UIBarButtonItem()
        backButton.title = ""
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
        
        udpateStarButton()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func udpateStarButton() {
        var icon: UIImage?
        if market!.isFavorite() {
            icon = UIImage (named: "Star")?.withRenderingMode(.alwaysOriginal)
        } else {
            icon = UIImage (named: "StarOutline")?.withRenderingMode(.alwaysOriginal)
        }
        
        let starButton = UIBarButtonItem(image: icon, style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.pressStarButton(_:)))
        self.navigationItem.rightBarButtonItem = starButton
    }
    
    @objc func pressStarButton(_ button: UIBarButtonItem) {
        print("pressStarButton")
        
        guard let market = market else {
            return
        }

        if market.isFavorite() {
            MarketDataManager.shared.removeFavoriteMarket(market: market)
        } else {
            MarketDataManager.shared.setFavoriteMarket(market: market)
        }
        udpateStarButton()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return OrderDataManager.shared.getOrders(orderStatuses: [.new, .partial]).count
        default:
            return OrderDataManager.shared.getOrders(orderStatuses: [.finished]).count
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return nil
        case 1:
            return "Open Orders"
        case 2:
            return "Recent Trade"
        default:
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0:
            return 0
        case 1:
            return 45
        case 2:
            return 45
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 && indexPath.row == 0 {
            // TODO: Simplify the code and make it reusable in other places.
            // window only available after iOS 11.0
            guard #available(iOS 11.0, *),
                let window = UIApplication.shared.keyWindow else {
                    let navBarHeight = (self.navigationController?.navigationBar.intrinsicContentSize.height)!
                        + UIApplication.shared.statusBarFrame.height
                    return MarketLineChartTableViewCell.getHeight(navigationBarHeight: navBarHeight)
            }

            let safeAreaHeight = window.safeAreaInsets.top + window.safeAreaInsets.bottom
            // Check if it's an iPhone X
            if safeAreaHeight > 0 {
                let navBarHeight = (self.navigationController?.navigationBar.intrinsicContentSize.height)!
                return MarketLineChartTableViewCell.getHeight(navigationBarHeight: navBarHeight) - safeAreaHeight
            } else {
                let navBarHeight = (self.navigationController?.navigationBar.intrinsicContentSize.height)!
                    + UIApplication.shared.statusBarFrame.height
                return MarketLineChartTableViewCell.getHeight(navigationBarHeight: navBarHeight)
            }

        } else if indexPath.section == 1 {
            return OpenOrderTableViewCell.getHeight()
        } else {
            return TradeTableViewCell.getHeight()
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 && indexPath.row == 0 {
            var cell = tableView.dequeueReusableCell(withIdentifier: MarketLineChartTableViewCell.getCellIdentifier()) as? MarketLineChartTableViewCell
            if cell == nil {
                let nib = Bundle.main.loadNibNamed("MarketLineChartTableViewCell", owner: self, options: nil)
                cell = nib![0] as? MarketLineChartTableViewCell
                cell?.selectionStyle = .none
            }
            
            cell!.pressedBuyButtonClosure = {
                let buyViewController = BuyViewController()
                buyViewController.transitioningDelegate = self
                buyViewController.interactor = self.interactor
                self.present(buyViewController, animated: true) {
                    
                }
            }
            
            cell!.pressedSellButtonClosure = {
                let sellViewController = SellViewController()
                sellViewController.transitioningDelegate = self
                sellViewController.interactor = self.interactor
                self.present(sellViewController, animated: true) {
                    
                }
            }
            return cell!

        } else if indexPath.section == 1 {
            var cell = tableView.dequeueReusableCell(withIdentifier: OpenOrderTableViewCell.getCellIdentifier()) as? OpenOrderTableViewCell
            if cell == nil {
                let nib = Bundle.main.loadNibNamed("OpenOrderTableViewCell", owner: self, options: nil)
                cell = nib![0] as? OpenOrderTableViewCell
                cell?.selectionStyle = .none
            }
            
            cell?.order = OrderDataManager.shared.getOrders(orderStatuses: [.new, .partial])[indexPath.row]
            cell?.update()
            return cell!

        } else {            
            var cell = tableView.dequeueReusableCell(withIdentifier: TradeTableViewCell.getCellIdentifier()) as? TradeTableViewCell
            if cell == nil {
                let nib = Bundle.main.loadNibNamed("TradeTableViewCell", owner: self, options: nil)
                cell = nib![0] as? TradeTableViewCell
                cell?.selectionStyle = .none
            }
            
            cell?.order = OrderDataManager.shared.getOrders(orderStatuses: [.finished])[indexPath.row]
            cell?.update()
            return cell!
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // TODO: Use UIAlertController or PopupDialog
        if indexPath.section == 1 {
            // TODO: Pass a view controller to PopupDialog https://github.com/Orderella/PopupDialog#custom-view-controller
            
            let dialogAppearance = PopupDialogDefaultView.appearance()
            dialogAppearance.titleFont = .boldSystemFont(ofSize: 17)
            dialogAppearance.titleColor = UIColor(white: 0, alpha: 1)
            dialogAppearance.titleTextAlignment = .center
            dialogAppearance.messageFont = .systemFont(ofSize: 17)
            dialogAppearance.messageTextAlignment = .left
            dialogAppearance.messageColor = UIColor(white: 0.2, alpha: 1)
            
            // Prepare the popup assets
            let title = "Order"
            let message = "This is the message section of the popup dialog default view"
            let image = UIImage(named: "Logo")
            
            // Create the dialog
            let popup = PopupDialog(title: title, message: message, image: image, transitionStyle: PopupDialogTransitionStyle.zoomIn)

            // Present dialog
            self.present(popup, animated: true, completion: nil)
        } else if indexPath.section == 2 {
            let alert = UIAlertController(title: "My Alert", message: "This is an alert.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .`default`, handler: { _ in
                NSLog("The \"OK\" alert occured.")
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }

}

extension MarketDetailViewController: UIViewControllerTransitioningDelegate {
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return DismissAnimator()
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactor.hasStarted ? interactor : nil
    }
}

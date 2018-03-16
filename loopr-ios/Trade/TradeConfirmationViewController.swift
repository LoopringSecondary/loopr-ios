//
//  TradeConfirmationViewController.swift
//  loopr-ios
//
//  Created by xiaoruby on 3/13/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

class TradeConfirmationViewController: UIViewController {

    @IBOutlet weak var placeOrderButton: UIButton!
    
    var marginSplitLabel: UILabel = UILabel()
    var marginSplitValueLabel: UILabel = UILabel()
    
    var LRCFeeLabel: UILabel = UILabel()
    var LRCFeeValueLabel: UILabel = UILabel()
    var LRCFeeUnderLine: UIView = UIView()
    
    var priceLabel: UILabel = UILabel()
    var priceValueLabel: UILabel = UILabel()
    var priceUnderLine: UIView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let backButton = UIBarButtonItem()
        backButton.title = ""
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
        
        self.navigationItem.title = NSLocalizedString("Confirmation", comment: "")
        
        placeOrderButton.title = NSLocalizedString("Place Order", comment: "")
        placeOrderButton.backgroundColor = UIColor.black
        placeOrderButton.layer.cornerRadius = 23
        placeOrderButton.titleLabel?.font = UIFont(name: FontConfigManager.shared.getBold(), size: 16.0)
        
        // Setup UI in the scroll view
        let screensize: CGRect = UIScreen.main.bounds
        let screenWidth = screensize.width
        // let screenHeight = screensize.height
        
        let originY: CGFloat = 60
        let padding: CGFloat = 25

        marginSplitLabel.text = "Margin Split"
        marginSplitLabel.textColor = UIColor.black
        marginSplitLabel.font = FontConfigManager.shared.getLabelFont()
        marginSplitLabel.frame = CGRect(x: padding, y: placeOrderButton.frame.minY - padding - originY - 40, width: 160, height: 40)
        view.addSubview(marginSplitLabel)
        
        marginSplitValueLabel.text = "3.4%"
        marginSplitValueLabel.textColor = UIColor.black
        marginSplitValueLabel.textAlignment = .right
        marginSplitValueLabel.font = FontConfigManager.shared.getLabelFont()
        marginSplitValueLabel.frame = CGRect(x: screenWidth - padding - 160, y: placeOrderButton.frame.minY - padding - originY - 40, width: 160, height: 40)
        view.addSubview(marginSplitValueLabel)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func pressedPlaceOrderButton(_ sender: Any) {
        print("pressedPlaceOrderButton")
    }
    
}

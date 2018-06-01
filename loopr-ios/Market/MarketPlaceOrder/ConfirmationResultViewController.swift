//
//  ConfirmationResultViewController.swift
//  loopr-ios
//
//  Created by kenshin on 2018/4/16.
//  Copyright © 2018年 Loopring. All rights reserved.
//

import UIKit

class ConfirmationResultViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var placedLabel: UILabel!
    @IBOutlet weak var placeInfoLabel: UILabel!
    @IBOutlet weak var detailsButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    
    // Need TokenA
    var needATipLabel: UILabel = UILabel()
    var needAInfoLabel: UILabel = UILabel()
    var needAUnderline: UIView = UIView()
    // Need TokenB
    var needBTipLabel: UILabel = UILabel()
    var needBInfoLabel: UILabel = UILabel()
    
    var order: OriginalOrder?
    var orderHash: String?
    var errorTipInfo: [String] = []
    var verifyInfo: [String: Double]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = NSLocalizedString("Confirmation", comment: "")
        // Do any additional setup after loading the view.
        setupErrorInfo()
        setBackButton()
        setupLabels()
        setupRows()
        setupButtons()
    }
    
    func setupLabels() {
        placedLabel.font = UIFont(name: FontConfigManager.shared.getBold(), size: 40.0)
        placedLabel.text = NSLocalizedString("Placed!", comment: "")
        placeInfoLabel.font = FontConfigManager.shared.getRegularFont(size: 20)
        placeInfoLabel.textColor = UIColor(red: 216/255, green: 216/255, blue: 216/255, alpha: 1)
        if isBalanceEnough() {
            placeInfoLabel.text = NSLocalizedString("Congradualations! Your order has been submited!", comment: "")
        } else {
            placeInfoLabel.text = NSLocalizedString("Your order has not been submited! Please make sure you have enough balance to complete the trade.", comment: "")
        }
    }
    
    func setupRows() {
        guard !isBalanceEnough() else { return }
        let screensize: CGRect = UIScreen.main.bounds
        let screenWidth = screensize.width
        let padding: CGFloat = 15
        
        // 1st row: need A token
        needATipLabel.font = FontConfigManager.shared.getLabelFont()
        needATipLabel.text = NSLocalizedString("You Need More", comment: "")
        needATipLabel.frame = CGRect(x: padding, y: padding, width: 150, height: 40)
        scrollView.addSubview(needATipLabel)
        needAInfoLabel.font = FontConfigManager.shared.getLabelFont()
        needAInfoLabel.textColor = .red
        needAInfoLabel.text = errorTipInfo[0]
        needAInfoLabel.textAlignment = .right
        needAInfoLabel.frame = CGRect(x: padding + 150, y: needATipLabel.frame.origin.y, width: screenWidth - padding * 2 - 150, height: 40)
        scrollView.addSubview(needAInfoLabel)
        needAUnderline.frame = CGRect(x: padding, y: needATipLabel.frame.maxY, width: screenWidth - padding * 2, height: 1)
        needAUnderline.backgroundColor = UIStyleConfig.underlineColor
        scrollView.addSubview(needAUnderline)
        
        guard errorTipInfo.count == 2 else { return }
        
        // 2nd row: need B token
        needBTipLabel.font = FontConfigManager.shared.getLabelFont()
        needBTipLabel.text = NSLocalizedString("You Need More", comment: "")
        needBTipLabel.frame = CGRect(x: padding, y: needATipLabel.frame.maxY + padding, width: 150, height: 40)
        scrollView.addSubview(needBTipLabel)
        needBInfoLabel.font = FontConfigManager.shared.getLabelFont()
        needBInfoLabel.textColor = .red
        needBInfoLabel.textAlignment = .right
        needBInfoLabel.frame = CGRect(x: padding + 150, y: needBTipLabel.frame.origin.y, width: screenWidth - padding * 2 - 150, height: 40)
        scrollView.addSubview(needBInfoLabel)
    }
    
    func setupButtons() {
        detailsButton.title = NSLocalizedString("Check Details", comment: "")
        detailsButton.layer.borderColor = UIColor(red: 204/255, green: 204/255, blue: 204/255, alpha: 1).cgColor
        detailsButton.layer.borderWidth = 1
        detailsButton.layer.cornerRadius = 23
        detailsButton.titleColor = UIColor.black
        detailsButton.titleLabel?.font = UIFont(name: FontConfigManager.shared.getBold(), size: 16.0)
        if isBalanceEnough() {
            detailsButton.isEnabled = true
            detailsButton.backgroundColor = UIColor.white
        } else {
            detailsButton.isEnabled = false
            detailsButton.backgroundColor = UIColor(red: 204/255, green: 204/255, blue: 204/255, alpha: 1)
        }
        doneButton.title = NSLocalizedString("Done", comment: "")
        doneButton.setupRoundBlack()
    }
    
    func setupErrorInfo() {
        if let info = self.verifyInfo {
            for item in info {
                if item.key.starts(with: "MINUS_") {
                    let key = item.key.components(separatedBy: "_")[1]
                    self.errorTipInfo.append(item.value.description + " " + key)
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func isBalanceEnough() -> Bool {
        return errorTipInfo.count == 0
    }
    
    func constructOrder(order: OriginalOrder) -> Order? {
        if let orderHash = self.orderHash {
            order.hash = orderHash
            let result = Order(originalOrder: order, orderStatus: .opened, dealtAmountB: "", dealtAmountS: "")
            return result
        }
        return nil
    }
    
    @IBAction func pressedDetailsButton(_ sender: UIButton) {
        if let order = self.order {
            let vc = OrderDetailViewController()
            vc.order = constructOrder(order: order)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func pressedDoneButton(_ sender: UIButton) {
        for controller in self.navigationController!.viewControllers as Array {
            if controller.isKind(of: MarketDetailViewController.self) || controller.isKind(of: AssetDetailViewController.self) {
                self.navigationController!.popToViewController(controller, animated: true)
                break
            }
        }
    }
}

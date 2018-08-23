//
//  ConfirmationResultViewController.swift
//  loopr-ios
//
//  Created by kenshin on 2018/4/16.
//  Copyright © 2018年 Loopring. All rights reserved.
//

import UIKit

class ConfirmationResultViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var resultHeaderImage: UIImageView!
    @IBOutlet weak var exchangedInfoLabel: UILabel!
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
    var needBUnderline: UIView = UIView()
    
    var order: OriginalOrder?
    var errorTipInfo: [String] = []
    var verifyInfo: [String: Double]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        // self.navigationController?.setNavigationBarHidden(true, animated: false)
        setBackButton()
        setupErrorInfo()
        setupLabels()
        setupRows()
        setupButtons()
    }
    
    func setupRows() {
        guard !isBalanceEnough() else { return }
        let screensize: CGRect = UIScreen.main.bounds
        let screenWidth = screensize.width
        let padding: CGFloat = 24
        
        // 1st row: need A token
        needATipLabel.setTitleCharFont()
        needATipLabel.text = LocalizedString("You Need More", comment: "")
        needATipLabel.frame = CGRect(x: padding, y: padding, width: 150, height: 40)
        scrollView.addSubview(needATipLabel)
        needAInfoLabel.setTitleDigitFont()
        needAInfoLabel.textColor = .fail
        needAInfoLabel.text = errorTipInfo[0]
        needAInfoLabel.textAlignment = .right
        needAInfoLabel.frame = CGRect(x: padding + 150, y: needATipLabel.frame.origin.y, width: screenWidth - padding * 2 - 150, height: 40)
        scrollView.addSubview(needAInfoLabel)
        
        guard errorTipInfo.count == 2 else { return }
        
        needAUnderline.frame = CGRect(x: padding, y: needATipLabel.frame.maxY, width: screenWidth - padding * 2, height: 1)
        needAUnderline.theme_backgroundColor = ColorPicker.cardBackgroundColor
        scrollView.addSubview(needAUnderline)
        
        // 2nd row: need B token
        needBTipLabel.setTitleCharFont()
        needBTipLabel.text = LocalizedString("You Need More", comment: "")
        needBTipLabel.frame = CGRect(x: padding, y: needATipLabel.frame.maxY + padding, width: 150, height: 40)
        scrollView.addSubview(needBTipLabel)
        needBInfoLabel.setTitleDigitFont()
        needBInfoLabel.textColor = .fail
        needBInfoLabel.text = errorTipInfo[1]
        needBInfoLabel.textAlignment = .right
        needBInfoLabel.frame = CGRect(x: padding + 150, y: needBTipLabel.frame.origin.y, width: screenWidth - padding * 2 - 150, height: 40)
        scrollView.addSubview(needBInfoLabel)
        
        needBUnderline.frame = CGRect(x: padding, y: needBInfoLabel.frame.maxY, width: screenWidth - padding * 2, height: 1)
        needBUnderline.theme_backgroundColor = ColorPicker.cardBackgroundColor
        scrollView.addSubview(needBUnderline)
    }
    
    func setupLabels() {
        exchangedInfoLabel.setTitleCharFont()
        if isBalanceEnough() {
            resultHeaderImage.image = #imageLiteral(resourceName: "Result-header-success")
            exchangedInfoLabel.text = LocalizedString("Congradualations! Your order has been submited!", comment: "")
        } else {
            resultHeaderImage.image = UIImage.init(named: "Result-header-fail")
            exchangedInfoLabel.text = LocalizedString("Your order has not been submited! Please make sure you have enough balance to complete the trade.", comment: "")
        }
    }
    
    func isBalanceEnough() -> Bool {
        return errorTipInfo.count == 0
    }
    
    func setupButtons() {
        detailsButton.title = LocalizedString("Check Details", comment: "")
        detailsButton.setupPrimary(height: 44)
        if isBalanceEnough() {
            detailsButton.isHidden = false
        } else {
            detailsButton.isHidden = true
        }
        doneButton.title = LocalizedString("Done", comment: "")
        doneButton.titleLabel?.setTitleCharFont()
    }
    
    func setupErrorInfo() {
        if let info = self.verifyInfo {
            for item in info {
                if item.key.starts(with: "MINUS_") {
                    let key = item.key.components(separatedBy: "_")[1]
                    self.errorTipInfo.append("\(item.value.withCommas()) \(key)")
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func pressedDetailsButton(_ sender: UIButton) {
        let vc = OrderHistorySwipeViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func pressedDoneButton(_ sender: Any) {
        for controller in self.navigationController!.viewControllers as Array {
            if controller.isKind(of: BuyAndSellSwipeViewController.self) {
                self.navigationController!.popToViewController(controller, animated: true)
                break
            }
        }
    }
}

//
//  TradeCompleteViewController.swift
//  loopr-ios
//
//  Created by xiaoruby on 3/17/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

class TradeCompleteViewController: UIViewController {

    @IBOutlet weak var exchangedLabel: UILabel!
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
    
    var order: OriginalOrder?
    var errorTipInfo: [String] = []
    var verifyInfo: [String: Double]?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
        needAUnderline.backgroundColor = UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1)
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
    
    func setupLabels() {
        guard let order = self.order else { return }
        exchangedLabel.font = UIFont(name: FontConfigManager.shared.getBold(), size: 40.0)
        exchangedLabel.text = NSLocalizedString("Completed!", comment: "")
        exchangedLabel.font = UIFont(name: FontConfigManager.shared.getRegular(), size: 20.0)
        exchangedInfoLabel.textColor = UIColor(red: 216/255, green: 216/255, blue: 216/255, alpha: 1)
        let text = NSLocalizedString("Congradualations! You exchanged \(order.amountSell) \(order.tokenSell) with \(order.amountBuy) \(order.tokenBuy)!", comment: "")
        if isBalanceEnough() {
            exchangedInfoLabel.text = text
        } else {
            let errorInfo = NSLocalizedString("However, please make sure you have enough balance to complete the trade.", comment: "")
            exchangedInfoLabel.text = text + errorInfo
        }
    }
    
    func isBalanceEnough() -> Bool {
        return errorTipInfo.count == 0
    }
    
    func setupButtons() {
        detailsButton.title = NSLocalizedString("Check Details", comment: "")
        detailsButton.setupRoundWhite()
        if isBalanceEnough() {
            detailsButton.isEnabled = true
            detailsButton.backgroundColor = UIColor.white
        } else {
            detailsButton.isEnabled = false
            detailsButton.layer.borderColor = UIColor.clear.cgColor
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
    
    @IBAction func pressedDetailsButton(_ sender: UIButton) {
        if let order = self.order {
            let vc = TradeReviewViewController()
            vc.order = order
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func pressedDoneButton(_ sender: Any) {
        for controller in self.navigationController!.viewControllers as Array {
            if controller.isKind(of: TradeViewController.self) {
                self.navigationController!.popToViewController(controller, animated: true)
                break
            }
        }
    }
}

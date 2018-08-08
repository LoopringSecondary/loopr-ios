//
//  InitialViewController.swift
//  loopr-ios
//
//  Created by kenshin on 2018/8/8.
//  Copyright © 2018年 Loopring. All rights reserved.
//

import UIKit

class SetupPartnerViewController: UIViewController {
    
    @IBOutlet weak var customerButton: UIButton!
    @IBOutlet weak var customerIcon: UIImageView!
    @IBOutlet weak var customerTipLabel: UILabel!
    @IBOutlet weak var partnerButton: UIButton!
    @IBOutlet weak var partnerIcon: UIImageView!
    @IBOutlet weak var partnerTipLabel: UILabel!
    @IBOutlet weak var totalMaskView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        customerTipLabel.setTitleCharFont()
        customerTipLabel.text = LocalizedString("Customer_Tip", comment: "")
        partnerTipLabel.setTitleCharFont()
        partnerTipLabel.text = LocalizedString("Partner_Tip", comment: "")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func pressedCustomerButton(_ sender: UIButton) {
        partnerIcon.isHidden = true
        customerIcon.isHidden = false
        CityPartnerDataManager.shared.role = .customer
        let vc = SetupWalletViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func pressedPartnerButton(_ sender: UIButton) {
        partnerIcon.isHidden = false
        customerIcon.isHidden = true
        CityPartnerDataManager.shared.role = .cityPartner
        presentAlert()
    }
    
    func presentAlert() {
        totalMaskView.alpha = 0.75
        let vc = ActivateCodeViewController()
        vc.dismissClosure = {
             self.totalMaskView.alpha = 0
        }
        vc.view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
        vc.parentNavController = self.navigationController
        self.present(vc, animated: true, completion: nil)
    }
}

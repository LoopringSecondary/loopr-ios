//
//  MnemonicEnterDerivationPathViewController.swift
//  loopr-ios
//
//  Created by xiaoruby on 4/15/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

class MnemonicEnterDerivationPathViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var nextButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setBackButton()
        self.navigationItem.title = LocalizedString("Select Your Wallet Type", comment: "")
        view.theme_backgroundColor = ColorPicker.backgroundColor
        tableView.theme_backgroundColor = ColorPicker.backgroundColor

        nextButton.setTitle(LocalizedString("Next", comment: ""), for: .normal)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView(frame: .zero)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return WalletType.getList().count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return MnemonicDerivationPathTableViewCell.getHeight()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: MnemonicDerivationPathTableViewCell.getCellIdentifier()) as? MnemonicDerivationPathTableViewCell
        if cell == nil {
            let nib = Bundle.main.loadNibNamed("MnemonicDerivationPathTableViewCell", owner: self, options: nil)
            cell = nib![0] as? MnemonicDerivationPathTableViewCell
            cell?.selectionStyle = .none
            cell?.tintColor = UIColor.black
        }
        
        if WalletType.getList()[indexPath.row] == ImportWalletUsingMnemonicDataManager.shared.walletType {
            cell?.enabledIcon.isHidden = false
        } else {
            cell?.enabledIcon.isHidden = true
        }

        cell?.pathDescriptionLabel.text = WalletType.getList()[indexPath.row].name
        cell?.pathValueLabel.text = WalletType.getList()[indexPath.row].derivationPath

        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        ImportWalletUsingMnemonicDataManager.shared.walletType = WalletType.getList()[indexPath.row]
        tableView.reloadData()
    }
    
    @IBAction func pressedNextButton(_ sender: Any) {
        ImportWalletUsingMnemonicDataManager.shared.generateAddresses()
        let viewController = MnemonicSelectAddressViewController()
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
}

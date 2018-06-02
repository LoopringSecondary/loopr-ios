//
//  MnemonicSelectAddressViewController.swift
//  loopr-ios
//
//  Created by xiaoruby on 4/15/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

class MnemonicSelectAddressViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var nextButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setBackButton()
        self.navigationItem.title = NSLocalizedString("Select your address", comment: "")
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()

        nextButton.setupRoundBlack()
        nextButton.setTitle(NSLocalizedString("Next", comment: ""), for: .normal)

        view.theme_backgroundColor = GlobalPicker.backgroundColor
        tableView.theme_backgroundColor = GlobalPicker.backgroundColor
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return MnemonicAddressTableViewCell.getHeight()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ImportWalletUsingMnemonicDataManager.shared.addresses.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: MnemonicAddressTableViewCell.getCellIdentifier()) as? MnemonicAddressTableViewCell
        if cell == nil {
            let nib = Bundle.main.loadNibNamed("MnemonicAddressTableViewCell", owner: self, options: nil)
            cell = nib![0] as? MnemonicAddressTableViewCell
            cell?.selectionStyle = .none
            cell?.tintColor = UIColor.black
        }

        cell?.indexLabel.text = "\(indexPath.row+1)."
        cell?.addressLabel.text = ImportWalletUsingMnemonicDataManager.shared.addresses[indexPath.row].eip55String

        if ImportWalletUsingMnemonicDataManager.shared.selectedKey == indexPath.row {
            cell?.accessoryType = .checkmark
        } else {
            cell?.accessoryType = .none
        }

        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        ImportWalletUsingMnemonicDataManager.shared.selectedKey = indexPath.row
        tableView.reloadData()
    }
    
    @IBAction func pressedNextButton(_ sender: Any) {
        print("Enter wallet")
        let viewController = ImportWalletEnterWalletNameViewController(setupWalletMethod: .importUsingMnemonic)
        self.navigationController?.pushViewController(viewController, animated: true)
    }

}

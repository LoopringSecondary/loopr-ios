//
//  MnemonicEnterDerivationPathViewController.swift
//  loopr-ios
//
//  Created by xiaoruby on 4/15/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

class MnemonicEnterDerivationPathViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let derivationPaths = ["m/44'/60'/0'/0",
                           "m/44'/60'/0'",
                           "m/44'/61'/0'/0",
                           "m/44'/60'/160720'/0'",
                           "m/0'/0'/0'",
                           "m/44'/1'/0'/0",
                           "m/44'/40'/0'/0",
                           "m/44'/108'/0'/0",
                           "m/44'/163'/0'/0"]
    let derivationPathDescriptions = ["Loopring Wallet, Metamask, imtoken, TREZOR (ETH)",
                                      "Ledger (ETH)",
                                      "TREZOR (ETC)",
                                      "Ledger (ETC)",
                                      "SingularDTV",
                                      "Network: Testnets",
                                      "Network: Expanse",
                                      "Network: Ubiq",
                                      "Network: Ellaism"]

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var nextButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setBackButton()
        self.navigationItem.title = NSLocalizedString("Select Your Wallet Type", comment: "")

        nextButton.setupRoundBlack()
        nextButton.setTitle(NSLocalizedString("Next", comment: ""), for: .normal)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return derivationPaths.count
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
        
        if derivationPaths[indexPath.row] == ImportWalletUsingMnemonicDataManager.shared.derivationPathValue {
            cell?.accessoryType = .checkmark
        } else {
            cell?.accessoryType = .none
        }
        
        cell?.pathValueLabel.text = derivationPaths[indexPath.row]
        cell?.pathDescriptionLabel.text = derivationPathDescriptions[indexPath.row]

        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        ImportWalletUsingMnemonicDataManager.shared.derivationPathValue = derivationPaths[indexPath.row]
        tableView.reloadData()
    }
    
    @IBAction func pressedNextButton(_ sender: Any) {
        ImportWalletUsingMnemonicDataManager.shared.clearAddresses()
        ImportWalletUsingMnemonicDataManager.shared.generateAddresses()

        let viewController = MnemonicSelectAddressViewController()
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
}

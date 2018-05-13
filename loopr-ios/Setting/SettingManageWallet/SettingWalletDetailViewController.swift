//
//  SettingWalletDetailViewController.swift
//  loopr-ios
//
//  Created by xiaoruby on 4/6/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

class SettingWalletDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var appWallet: AppWallet!

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var switchWalletButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setBackButton()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        
        switchWalletButton.title = NSLocalizedString("Switch to this Wallet", comment: "")
        switchWalletButton.setupRoundBlack()
    }

    override func viewWillAppear(_ animated: Bool) {
        print(appWallet.name)
        self.tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func pressedSwitchWalletButton(_ sender: Any) {
        print("pressedSwitchWalletButton")
        CurrentAppWalletDataManager.shared.setCurrentAppWallet(appWallet)
        self.navigationController?.popViewController(animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 45
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // TODO: Update the UITableViewCell.
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "title")
        
        if indexPath.row == 0 {
            cell.textLabel?.text = NSLocalizedString("Wallet Name", comment: "")
            cell.detailTextLabel?.text = appWallet.name
        } else if indexPath.row == 1 {
            cell.textLabel?.text = NSLocalizedString("Backup Mnemonic", comment: "")
        } else if indexPath.row == 2 {
            cell.textLabel?.text = NSLocalizedString("Export Private Key", comment: "")
        } else if indexPath.row == 3 {
            cell.textLabel?.text = NSLocalizedString("Export Keystore", comment: "")
        } else if indexPath.row == 4 {
            cell.textLabel?.text = NSLocalizedString("Clear Records of this Wallet", comment: "")
            cell.textLabel?.textColor = UIColor.init(rgba: "#F52929")
        }
        
        cell.accessoryType = .disclosureIndicator
        
        cell.textLabel?.font = FontConfigManager.shared.getLabelFont()
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row == 0 {
            let viewController = SettingChangeWalletNameViewController()
            viewController.appWallet = appWallet
            self.navigationController?.pushViewController(viewController, animated: true)
        } else if indexPath.row == 1 {
            let viewController = BackupMnemonicViewController()
            viewController.isExportMode = true
            viewController.mnemonics = CurrentAppWalletDataManager.shared.getCurrentAppWallet()?.mnemonics ?? []
            self.navigationController?.pushViewController(viewController, animated: true)
        } else if indexPath.row == 2 {
            let viewController = DisplayPrivateKeyViewController()
            viewController.appWallet = appWallet
            self.navigationController?.pushViewController(viewController, animated: true)
        } else if indexPath.row == 3 {
            let viewController = ExportKeystoreEnterPasswordViewController()
            viewController.appWallet = appWallet
            self.navigationController?.pushViewController(viewController, animated: true)
        } else if indexPath.row == 4 {
            let alertController = UIAlertController(title: "You are going to clear records of \(appWallet.name) on this device.",
                message: nil,
                preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: NSLocalizedString("Confirm", comment: ""), style: .default, handler: { _ in
                AppWalletDataManager.shared.logout(appWallet: self.appWallet)
                if AppWalletDataManager.shared.getWallets().isEmpty {
                    self.navigationToSetupNavigationController()
                } else {
                    self.navigationController?.popViewController(animated: true)
                }
            })
            alertController.addAction(defaultAction)
            let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: { _ in
            })
            alertController.addAction(cancelAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func navigationToSetupNavigationController() {
        let alertController = UIAlertController(title: "No wallet is found in the device. Navigate to the wallet creation view.",
            message: nil,
            preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: { _ in
            SetupDataManager.shared.hasPresented = false
            UIApplication.shared.keyWindow?.rootViewController = SetupNavigationController(nibName: nil, bundle: nil)
        })
        alertController.addAction(defaultAction)
        self.present(alertController, animated: true, completion: nil)
    }

}

//
//  SettingWalletDetailViewController.swift
//  loopr-ios
//
//  Created by xiaoruby on 4/6/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit
import SVProgressHUD
import NotificationBannerSwift

class SettingWalletDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var appWallet: AppWallet!

    @IBOutlet weak var tableView: UITableView!

    @IBOutlet weak var switchWalletButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setBackButton()
        self.navigationItem.title = appWallet.name

        view.theme_backgroundColor = ColorPicker.backgroundColor
        tableView.theme_backgroundColor = ColorPicker.backgroundColor

        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 10))
        headerView.theme_backgroundColor = ColorPicker.backgroundColor
        tableView.tableHeaderView = headerView
        
        switchWalletButton.title = LocalizedString("Switch to this Wallet", comment: "")
        switchWalletButton.setupSecondary(height: 44)
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
        CurrentAppWalletDataManager.shared.setCurrentAppWallet(self.appWallet, completionHandler: {})
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            // Pop to SettingViewController
            for controller in self.navigationController!.viewControllers as Array {
                // Switch the current wallet from setting view
                if controller.isKind(of: SettingViewController.self) {
                    self.navigationController!.popToViewController(controller, animated: false)
                    // Jump to WalletViewController
                    let appDelegate = UIApplication.shared.delegate as? AppDelegate
                    // Post a notification
                    NotificationCenter.default.post(name: .needRelaunchCurrentAppWallet, object: nil)
                    if let tabBarController = appDelegate?.window?.rootViewController as? UITabBarController {
                        tabBarController.selectedIndex = 0
                    }
                    break
                }
                // Switch the current wallet from WalletViewController
                if controller.isKind(of: WalletViewController.self) {
                    // Post a notification
                    NotificationCenter.default.post(name: .needRelaunchCurrentAppWallet, object: nil)
                    self.navigationController!.popToViewController(controller, animated: true)
                    break
                }
            }
        }
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return getNumberOfRowsInWalletSection()
        case 1:
            return 1
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 1 {
            return 20
        }
        return 0
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 20))
        headerView.theme_backgroundColor = ColorPicker.backgroundColor
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return SettingStyleTableViewCell.getHeight()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return getTableViewCell(cellForRowAt: indexPath)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let cell = tableView.cellForRow(at: indexPath) as? SettingStyleTableViewCell else {
            return
        }
        switch cell.contentType {
        case .walletName:
            let viewController = SettingChangeWalletNameViewController()
            viewController.didChangeWalletName = { (newWaleltName) in
                self.navigationItem.title = newWaleltName
            }
            viewController.appWallet = appWallet
            self.navigationController?.pushViewController(viewController, animated: true)
        case .backupMnemonic:
            // Ask for device password
            AuthenticationDataManager.shared.authenticate(reason: LocalizedString("Authenticate to access your mnemonic", comment: "")) { (error) in
                guard error == nil else {
                    print(error.debugDescription)
                    return
                }
                let viewController = BackupMnemonicViewController()
                viewController.hideButtons = true
                viewController.mnemonics = self.appWallet.mnemonics
                self.navigationController?.pushViewController(viewController, animated: true)
            }
        case .exportPrivateKey:
            // Ask for device password
            AuthenticationDataManager.shared.authenticate(reason: LocalizedString("Authenticate to access your private key", comment: "")) { (error) in
                guard error == nil else {
                    print(error.debugDescription)
                    return
                }

                let viewController = DisplayPrivateKeyViewController()
                var isSucceeded: Bool = false
                SVProgressHUD.show(withStatus: LocalizedString("Exporting private key", comment: "") + "...")
                let dispatchGroup = DispatchGroup()
                dispatchGroup.enter()
                DispatchQueue.global().async {
                    do {
                        let decoder = JSONDecoder()
                        let newkeystoreData: Data = self.appWallet.getKeystore().data(using: .utf8)!
                        let newkeystore = try decoder.decode(NewKeystore.self, from: newkeystoreData)
                        let privateKey = try newkeystore.privateKey(password: self.appWallet.getKeystorePassword())
                        viewController.displayValue = privateKey.toHexString()

                        isSucceeded = true
                        dispatchGroup.leave()
                    } catch {
                        isSucceeded = false
                        dispatchGroup.leave()
                    }
                }
                
                dispatchGroup.notify(queue: .main) {
                    SVProgressHUD.dismiss()
                    if isSucceeded {
                        self.navigationController?.pushViewController(viewController, animated: true)
                    } else {
                        let banner = NotificationBanner.generate(title: "Wrong password", style: .danger)
                        banner.duration = 1.5
                        banner.show()
                    }
                }

            }
        case .exportKeystore:
            // Will ask for device password in ExportKeystoreEnterPasswordViewController
            let viewController = ExportKeystoreEnterPasswordViewController()
            viewController.appWallet = appWallet
            self.navigationController?.pushViewController(viewController, animated: true)
        
        case .viewAddressOnEtherscan:
            if let url = URL(string: "https://etherscan.io/address/\(appWallet.address)") {
                let viewController = DefaultWebViewController()
                viewController.navigationTitle = "Etherscan.io"
                viewController.url = url
                viewController.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(viewController, animated: true)
            }
        case .clearRecords:
            presentAlertControllerToConfirmClearRecords()
        default:
            return
        }
    }

    func presentAlertControllerToConfirmClearRecords() {
        let header = LocalizedString("You are going to clear records of", comment: "")
        let footer = LocalizedString("on this device.", comment: "")
        let alertController = UIAlertController(title: "\(header) \(appWallet.name) \(footer)", message: nil, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: LocalizedString("Confirm", comment: ""), style: .default, handler: { _ in
            AppWalletDataManager.shared.logout(appWallet: self.appWallet)
            if AppWalletDataManager.shared.getWallets().isEmpty {
                self.navigationToSetupNavigationController()
            } else {
                self.navigationController?.popViewController(animated: true)
            }
        })
        alertController.addAction(defaultAction)
        let cancelAction = UIAlertAction(title: LocalizedString("Cancel", comment: ""), style: .cancel, handler: { _ in
        })
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func navigationToSetupNavigationController() {
        let alertController = UIAlertController(title: LocalizedString("No wallet is found in the device. Navigate to the wallet creation view.", comment: ""), message: nil, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: { _ in
            UIApplication.shared.keyWindow?.rootViewController = SetupNavigationController(nibName: nil, bundle: nil)
        })
        alertController.addAction(defaultAction)
        self.present(alertController, animated: true, completion: nil)
    }

}

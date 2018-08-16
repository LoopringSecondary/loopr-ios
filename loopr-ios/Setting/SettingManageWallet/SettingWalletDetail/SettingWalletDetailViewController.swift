//
//  SettingWalletDetailViewController.swift
//  loopr-ios
//
//  Created by xiaoruby on 4/6/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit
import MessageUI

class SettingWalletDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MFMessageComposeViewControllerDelegate {
    
    var appWallet: AppWallet!

    @IBOutlet weak var tableView: UITableView!

    @IBOutlet weak var switchWalletButton: UIButton!
    @IBOutlet weak var shareAddressThroughSMSButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setBackButton()
        self.navigationItem.title = appWallet.name

        view.theme_backgroundColor = GlobalPicker.backgroundColor
        tableView.theme_backgroundColor = GlobalPicker.backgroundColor

        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        
        switchWalletButton.title = LocalizedString("Switch to this Wallet", comment: "")
        switchWalletButton.setupSecondary(height: 44)
        
        shareAddressThroughSMSButton.title = LocalizedString("Share Address through SMS", comment: "")
        shareAddressThroughSMSButton.setupSecondary(height: 44)
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
        headerView.theme_backgroundColor = GlobalPicker.backgroundColor
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
            let viewController = BackupMnemonicViewController()
            viewController.hideButtons = true
            viewController.mnemonics = appWallet.mnemonics
            self.navigationController?.pushViewController(viewController, animated: true)
        case .exportPrivateKey:
            let viewController = DisplayPrivateKeyViewController()
            viewController.displayValue = appWallet.privateKey
            self.navigationController?.pushViewController(viewController, animated: true)
        case .exportKeystore:
            let viewController = ExportKeystoreEnterPasswordViewController()
            viewController.appWallet = appWallet
            self.navigationController?.pushViewController(viewController, animated: true)
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
        let alertController = UIAlertController(title: "No wallet is found in the device. Navigate to the wallet creation view.", message: nil, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: { _ in
            SetupDataManager.shared.hasPresented = false
            UIApplication.shared.keyWindow?.rootViewController = SetupNavigationController(nibName: nil, bundle: nil)
        })
        alertController.addAction(defaultAction)
        self.present(alertController, animated: true, completion: nil)
    }

    @IBAction func pressedShareAddressThroughSMS(_ sender: Any) {
        if MFMessageComposeViewController.canSendText() {
            let controller = MFMessageComposeViewController()
            controller.body = appWallet.address
            controller.recipients = []
            controller.messageComposeDelegate = self
            self.present(controller, animated: true, completion: nil)
        }
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        //... handle sms screen actions
        self.dismiss(animated: true, completion: nil)
    }
}

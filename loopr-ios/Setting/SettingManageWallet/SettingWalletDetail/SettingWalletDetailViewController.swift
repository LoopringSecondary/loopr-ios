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
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        
        switchWalletButton.title = NSLocalizedString("Switch to this Wallet", comment: "")
        switchWalletButton.setupRoundBlack()
        
        shareAddressThroughSMSButton.title = NSLocalizedString("Share Address through SMS", comment: "")
        shareAddressThroughSMSButton.setupRoundWhite()
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
        return getNumberOfRowsInSection()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return SettingWalletDetailTableViewCell.getHeight()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // TODO: Update the UITableViewCell.
        return getTableViewCell(cellForRowAt: indexPath)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let cell = tableView.cellForRow(at: indexPath) as? SettingWalletDetailTableViewCell else {
            return
        }
        switch cell.contentType {
        case .walletName:
            let viewController = SettingChangeWalletNameViewController()
            viewController.appWallet = appWallet
            self.navigationController?.pushViewController(viewController, animated: true)
        case .backupMnemonic:
            let viewController = BackupMnemonicViewController()
            viewController.isExportMode = true
            viewController.mnemonics = appWallet.mnemonics
            self.navigationController?.pushViewController(viewController, animated: true)
        case .exportPrivateKey:
            let viewController = DisplayPrivateKeyViewController()
            viewController.appWallet = appWallet
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
        let alertController = UIAlertController(title: "You are going to clear records of \(appWallet.name) on this device.", message: nil, preferredStyle: .alert)
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
    
    func navigationToSetupNavigationController() {
        let alertController = UIAlertController(title: "No wallet is found in the device. Navigate to the wallet creation view.", message: nil, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: { _ in
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
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController!, didFinishWith result: MessageComposeResult) {
        //... handle sms screen actions
        self.dismiss(animated: true, completion: nil)
    }
}

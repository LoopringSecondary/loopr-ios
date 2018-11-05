//
//  SettingManageWalletViewController.swift
//  loopr-ios
//
//  Created by xiaoruby on 4/6/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

class SettingManageWalletViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!

    @IBOutlet weak var importButton: UIButton!
    @IBOutlet weak var createButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.theme_backgroundColor = ColorPicker.backgroundColor
        tableView.theme_backgroundColor = ColorPicker.backgroundColor

        self.navigationItem.title = LocalizedString("Manage Wallets", comment: "")
        setBackButton()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.theme_backgroundColor = ColorPicker.backgroundColor
        tableView.delaysContentTouches = false
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 5))
        headerView.theme_backgroundColor = ColorPicker.backgroundColor
        tableView.tableHeaderView = headerView
        
        let iconTitlePadding: CGFloat = 20
        importButton.addTarget(self, action: #selector(self.pressedImportButton(_:)), for: .touchUpInside)
        importButton.set(image: UIImage.init(named: "SetupWallet-import")?.alpha(0.6), title: LocalizedString("Import Wallet", comment: ""), titlePosition: .right, additionalSpacing: iconTitlePadding, state: .highlighted)
        importButton.set(image: UIImage.init(named: "SetupWallet-import"), title: LocalizedString("Import Wallet", comment: ""), titlePosition: .right, additionalSpacing: iconTitlePadding, state: .normal)
        importButton.titleLabel?.font = FontConfigManager.shared.getRegularFont(size: 13)
        importButton.titleLabel?.theme_textColor = GlobalPicker.textLightColor
        importButton.theme_setTitleColor(GlobalPicker.textColor, forState: .normal)

        createButton.addTarget(self, action: #selector(self.pressedCreateButton(_:)), for: .touchUpInside)
        createButton.set(image: UIImage.init(named: "SetupWallet-generate")?.alpha(0.6), title: LocalizedString("Generate Wallet", comment: ""), titlePosition: .right, additionalSpacing: iconTitlePadding, state: .highlighted)
        createButton.set(image: UIImage.init(named: "SetupWallet-generate"), title: LocalizedString("Generate Wallet", comment: ""), titlePosition: .right, additionalSpacing: iconTitlePadding, state: .normal)
        createButton.titleLabel?.font = FontConfigManager.shared.getRegularFont(size: 13)
        createButton.titleLabel?.theme_textColor = GlobalPicker.textLightColor
        createButton.theme_setTitleColor(GlobalPicker.textColor, forState: .normal)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        getAllBalanceFromRelay()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func getAllBalanceFromRelay() {
        for wallet in AppWalletDataManager.shared.getWallets() {
            AppWalletDataManager.shared.getTotalCurrencyValue(address: wallet.address, getPrice: false, completionHandlerInBackgroundThread: { (totalCurrencyValue, error) in
                print("SettingManageWalletViewController getAllBalanceFromRelay \(totalCurrencyValue)")
                wallet.totalCurrency = totalCurrencyValue
                AppWalletDataManager.shared.updateAppWalletsInLocalStorage(newAppWallet: wallet)
                
                // TODO: a hack to reload table view.
                if totalCurrencyValue > 0 {
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            })
        }
    }
    
    @objc func pressedImportButton(_ button: UIButton) {
        let viewController = UnlockWalletSwipeViewController()
        self.navigationController?.pushViewController(viewController, animated: true)
    }

    @objc func pressedCreateButton(_ button: UIButton) {
        let viewController = GenerateWalletEnterNameViewController()
        self.navigationController?.pushViewController(viewController, animated: true)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return AppWalletDataManager.shared.getWallets().count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return SettingManageWalletTableViewCell.getHeight()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: SettingManageWalletTableViewCell.getCellIdentifier()) as? SettingManageWalletTableViewCell
        if cell == nil {
            let nib = Bundle.main.loadNibNamed("SettingManageWalletTableViewCell", owner: self, options: nil)
            cell = nib![0] as? SettingManageWalletTableViewCell
        }
        cell?.delegate = self
        cell?.wallet = AppWalletDataManager.shared.getWallets()[indexPath.row]
        cell?.update()
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let viewController = SettingWalletDetailViewController()
        viewController.appWallet = AppWalletDataManager.shared.getWallets()[indexPath.row]
        self.navigationController?.pushViewController(viewController, animated: true)
    }
}

extension SettingManageWalletViewController: SettingManageWalletTableViewCellDelegate {
    func pressedQACodeButtonInWalletBalanceTableViewCell(wallet: AppWallet) {
        if CurrentAppWalletDataManager.shared.getCurrentAppWallet() != nil {
            let viewController = QRCodeViewController()
            viewController.hidesBottomBarWhenPushed = true
            viewController.address = wallet.address
            viewController.navigationTitle = LocalizedString("Wallet Address", comment: "")
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }
}

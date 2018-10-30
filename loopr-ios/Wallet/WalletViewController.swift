//
//  WalletViewController.swift
//  loopr-ios
//
//  Created by Xiao Dou Dou on 2/1/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit
import NotificationBannerSwift
import MKDropdownMenu
import SVProgressHUD

class WalletViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, QRCodeScanProtocol {

    @IBOutlet weak var assetTableView: UITableView!
    private let refreshControl = UIRefreshControl()

    var isLaunching: Bool = true
    var isListeningSocketIO: Bool = false
    var numberOfRowsInSection1: Int = 0
    
    var isDropdownMenuExpanded: Bool = false
    let dropdownMenu = MKDropdownMenu(frame: .zero)
    
    var pasteboardValue: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        view.theme_backgroundColor = ColorPicker.backgroundColor
        
        assetTableView.dataSource = self
        assetTableView.delegate = self

        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 10))
        footerView.theme_backgroundColor = ColorPicker.backgroundColor
        assetTableView.tableFooterView = footerView
        assetTableView.separatorStyle = .none
        assetTableView.delaysContentTouches = false
        
        // Avoid dragging a cell to the top makes the tableview shake
        assetTableView.estimatedRowHeight = 0
        assetTableView.estimatedSectionHeaderHeight = 0
        assetTableView.estimatedSectionFooterHeight = 0

        assetTableView.theme_backgroundColor = ColorPicker.backgroundColor

        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: .add, target: self, action: #selector(self.pressAddButton(_:)))
        // self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: .organize, target: self, action: #selector(self.pressSwitchWallet(_:)))
        
        dropdownMenu.dataSource = self
        dropdownMenu.delegate = self
        dropdownMenu.disclosureIndicatorImage = nil
        
        dropdownMenu.dropdownShowsTopRowSeparator = false
        dropdownMenu.dropdownBouncesScroll = false
        dropdownMenu.backgroundDimmingOpacity = 0
        dropdownMenu.dropdownCornerRadius = 6
        dropdownMenu.dropdownRoundedCorners = UIRectCorner.allCorners
        dropdownMenu.dropdownBackgroundColor = UIColor.dark2
        dropdownMenu.rowSeparatorColor = UIColor.dark2
        dropdownMenu.componentSeparatorColor = UIColor.dark2
        dropdownMenu.dropdownShowsTopRowSeparator = false
        dropdownMenu.dropdownShowsBottomRowSeparator = false
        dropdownMenu.dropdownShowsBorder = false
        
        self.view.addSubview(dropdownMenu)
        
        // Add Refresh Control to Table View
        assetTableView.refreshControl = refreshControl
        refreshControl.theme_tintColor = GlobalPicker.textColor
        refreshControl.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
        
        // Creating view for extending background color
        var frame = assetTableView.bounds
        frame.origin.y = -frame.size.height
        let backgroundView = UIView(frame: frame)
        backgroundView.autoresizingMask = .flexibleWidth
        backgroundView.theme_backgroundColor = ColorPicker.backgroundColor
        
        // Adding the view below the refresh control
        assetTableView.insertSubview(backgroundView, at: 0)
        
        NotificationCenter.default.addObserver(self, selector: #selector(needRelaunchCurrentAppWalletReceivedNotification), name: .needRelaunchCurrentAppWallet, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(processPasteboard), name: .needCheckStringInPasteboard, object: nil)
    }
    
    @objc func needRelaunchCurrentAppWalletReceivedNotification() {
        self.isLaunching = true
    }
    
    @objc private func refreshData(_ sender: Any) {
        // Fetch Data
        getDataFromRelay()
    }
    
    func getDataFromRelay() {
        guard CurrentAppWalletDataManager.shared.getCurrentAppWallet() != nil else {
            return
        }

        // isLaunching is true at any of the following situations:
        // 1. Launch app
        // 2. Create wallet
        // 3. Import wallet
        // 4. Switch the current wallet.
        if self.isLaunching {
            // Remove backgrond image
            let appDelegate = UIApplication.shared.delegate as? AppDelegate
            if let splashImageView = appDelegate?.window?.viewWithTag(1234) as? SplashImageView {
                if !splashImageView.isUIViewAnimating {
                    splashImageView.isUIViewAnimating = true
                    UIView.animate(withDuration: 0.3, delay: 0.8, options: .curveEaseIn, animations: { () -> Void in
                        splashImageView.alpha = 0
                    }, completion: { _ in
                        splashImageView.isUIViewAnimating = false
                        splashImageView.removeFromSuperview()
                        if self.isLaunching {
                            SVProgressHUD.show(withStatus: LocalizedString("Loading Data", comment: ""))
                        }
                    })
                } else {
                    // Disable user touch when loading data
                    SVProgressHUD.show(withStatus: LocalizedString("Loading Data", comment: ""))
                }
            } else {
                // Disable user touch when loading data
                SVProgressHUD.show(withStatus: LocalizedString("Loading Data", comment: ""))
            }
        }
        
        let dispatchGroup = DispatchGroup()
        
        // tokens.json contains 67 tokens.
        if TokenDataManager.shared.getTokens().count < 70 {
            dispatchGroup.enter()
            TokenDataManager.shared.loadCustomTokensForCurrentWallet(completionHandler: {
                dispatchGroup.leave()
            })
        }

        dispatchGroup.enter()
        CurrentAppWalletDataManager.shared.getBalanceAndPriceQuoteAndNonce(getPrice: true, completionHandler: { _, error in
            print("receive CurrentAppWalletDataManager.shared.getBalanceAndPriceQuote() in WalletViewController")
            guard error == nil else {
                print("error=\(String(describing: error))")
                let banner = NotificationBanner.generate(title: "Sorry. Network error", style: .info)
                banner.duration = 2.0
                banner.show()
                self.refreshControl.endRefreshing()
                return
            }
            dispatchGroup.leave()
        })
        
        dispatchGroup.notify(queue: .main) {
            if self.isLaunching {
                self.isLaunching = false

                // Then get all balance. It takes times.
                AppWalletDataManager.shared.getAllBalanceFromRelayInBackgroundThread()
                // Setup socket io at the end of the launch
                LoopringSocketIORequest.setup()

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    SVProgressHUD.dismiss()
                    
                    // Ask for permission
                    PushNotificationSettingManager.shared.registerForPushNotifications()
                    
                    // Check app version
                    AppServiceManager.shared.getLatestAppVersion(completion: {(shouldDisplayUpdateNotification) in
                        if shouldDisplayUpdateNotification {
                            self.displayUpdateNotification()
                        }
                    })
                    
                    // Get user config
                    /*
                    AppServiceManager.shared.getUserConfig(completion: { (shouldDisplayUpdateNotification) in
                        AppServiceManager.shared.updateUserConfig(completion: { (_) in
                            
                        })
                    })
                    */
                }
                
                self.processPasteboard()
            }
            self.assetTableView.reloadData()
            self.refreshControl.endRefreshing()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        assetTableView.isUserInteractionEnabled = true

        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.navigationItem.title = CurrentAppWalletDataManager.shared.getCurrentAppWallet()?.name ?? LocalizedString("Wallet", comment: "")

        if let cell = assetTableView.cellForRow(at: IndexPath.init(row: 0, section: 0)) as? WalletBalanceTableViewCell {
            cell.setup(animated: false)
            cell.startUpdateBalanceLabelTimer()
        }
        
        assetTableView.reloadData()
        getDataFromRelay()
        
        let screensize: CGRect = UIScreen.main.bounds
        let screenWidth = screensize.width
        dropdownMenu.frame = CGRect(x: screenWidth-160-9, y: 0, width: 160, height: 0)

        let spaceView = UIImageView.init(image: UIImage.init(named: "dropdown-triangle"))
        spaceView.contentMode = .center
        dropdownMenu.spacerView = spaceView
        dropdownMenu.spacerViewOffset = UIOffset.init(horizontal: self.dropdownMenu.bounds.size.width - 95, vertical: 1)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        isListeningSocketIO = true
        CurrentAppWalletDataManager.shared.startGetBalance()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        guard CurrentAppWalletDataManager.shared.getCurrentAppWallet() != nil else {
            return
        }
        CurrentAppWalletDataManager.shared.stopGetBalance()
        isListeningSocketIO = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func processPasteboard() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            // Check if the view is visible
            guard self.isViewLoaded && (self.view.window != nil) else {
                return
            }

            // Avoid show banner in isLaunching state.
            if UIPasteboard.general.hasStrings && !self.isLaunching {
                if let string = UIPasteboard.general.string {
                    if self.pasteboardValue != string && QRCodeMethod.isAddress(content: string) && !AppWalletDataManager.shared.isDuplicatedAddress(address: string) {
                        // Update
                        self.pasteboardValue = string
                        
                        let banner = NotificationBanner.generate(title: "Send tokens to the address in pasteboard?", style: .success, hasLeftImage: false)
                        banner.duration = 2
                        banner.show()
                        banner.onTap = {
                            // Limit to WalletViewController.
                            guard self.isViewLoaded && (self.view.window != nil) else {
                                return
                            }
                            let vc = SendAssetViewController()
                            vc.address = string
                            vc.hidesBottomBarWhenPushed = true
                            self.navigationController?.pushViewController(vc, animated: true)
                        }
                    }
                }
            }
        }
    }
    
    func processExternalUrl() {
        guard let value = AuthorizeDataManager.shared.value,
            let type = AuthorizeDataManager.shared.type else { return }
        self.setResultOfScanningQRCode(valueSent: value, type: type)
    }
    
    func setResultOfScanningQRCode(valueSent: String, type: QRCodeType) {
        let manager = AuthorizeDataManager.shared
        if let data = valueSent.data(using: .utf8) {
            let json = JSON(data)
            switch type {
            case .submitOrder:
                manager.submitHash = json["value"].stringValue
                manager.getSubmitOrder { (_, error) in
                    guard error == nil, let order = manager.submitOrder else { return }
                    DispatchQueue.main.async {
                        let vc = PlaceOrderConfirmationViewController()
                        vc.view.theme_backgroundColor = ColorPicker.backgroundColor
                        vc.order = order
                        vc.isSigning = true
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                }
            case .login:
                manager.loginUUID = json["value"].stringValue
                manager._authorizeLogin { (_, error) in
                    let result = error == nil ? true : false
                    DispatchQueue.main.async {
                        let vc = LoginResultViewController()
                        vc.result = result
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                }
            case .cancelOrder:
                manager.cancelHash = json["value"].stringValue
                manager.getCancelOrder { (_, error) in
                    let result = error == nil ? true : false
                    DispatchQueue.main.async {
                        let vc = LoginResultViewController()
                        vc.result = result
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                }
            case .convert:
                manager.convertHash = json["value"].stringValue
                manager.getConvertTx { (_, error) in
                    let result = error == nil ? true : false
                    DispatchQueue.main.async {
                        let vc = LoginResultViewController()
                        vc.result = result
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                }
                
            case .approve:
                manager.approveHash = json["value"].stringValue
                manager.getApproveTxs { (_, error) in
                    let result = error == nil ? true : false
                    DispatchQueue.main.async {
                        let vc = LoginResultViewController()
                        vc.result = result
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                }
            case .p2pOrder:
                TradeDataManager.shared.handleResult(of: json["value"])
                let vc = TradeConfirmationViewController()
                vc.view.theme_backgroundColor = ColorPicker.backgroundColor
                vc.parentNavController = self.navigationController
                vc.order = TradeDataManager.shared.orders[1]
                self.navigationController?.pushViewController(vc, animated: true)

            case .address:
                let vc = SendAssetViewController()
                vc.address = valueSent
                vc.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(vc, animated: true)

            case .keystore, .mnemonic, .privateKey:
                let vc = UnlockWalletSwipeViewController()
                vc.hidesBottomBarWhenPushed = true
                vc.setResultOfScanningQRCode(valueSent: valueSent, type: type)
                self.navigationController?.pushViewController(vc, animated: true)
            default:
                return
            }
        }
    }

    @objc func pressQRCodeButton(_ button: UIBarButtonItem) {
        print("pressQRCodeButton")
        if CurrentAppWalletDataManager.shared.getCurrentAppWallet() != nil {
            let viewController = QRCodeViewController()
            viewController.hidesBottomBarWhenPushed = true
            viewController.address = CurrentAppWalletDataManager.shared.getCurrentAppWallet()!.address
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    @objc func pressSwitchWallet(_ button: UIBarButtonItem) {
        let viewController = SettingManageWalletViewController()
        viewController.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    @objc func pressAddButton(_ button: UIBarButtonItem) {
        if !isDropdownMenuExpanded {
            dropdownMenu.openComponent(0, animated: true)
            isDropdownMenuExpanded = true
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        print("scrollViewWillBeginDragging")
        CurrentAppWalletDataManager.shared.stopGetBalance()
        isListeningSocketIO = false
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        print("scrollViewDidEndDecelerating")
        isListeningSocketIO = true
        CurrentAppWalletDataManager.shared.startGetBalance()
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        if isLaunching {
            return 2
        }
        return 3
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return 1
        case 2:
            numberOfRowsInSection1 = CurrentAppWalletDataManager.shared.getAssetsWithHideSmallAssetsOption().count
            return numberOfRowsInSection1
        default:
            return  0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return WalletBalanceTableViewCell.getHeight()
        } else if indexPath.section == 1 {
            return WalletButtonTableViewCell.getHeight()
        } else {
            return AssetTableViewCell.getHeight()
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            var cell = tableView.dequeueReusableCell(withIdentifier: WalletBalanceTableViewCell.getCellIdentifier()) as? WalletBalanceTableViewCell
            if cell == nil {
                let nib = Bundle.main.loadNibNamed("WalletBalanceTableViewCell", owner: self, options: nil)
                cell = nib![0] as? WalletBalanceTableViewCell
                cell?.delegate = self
            }
            cell?.setup(animated: true)
            if isLaunching {
                cell?.balanceLabel.setText("", animated: false)
            }
            return cell!
        } else if indexPath.section == 1 {
            var cell = tableView.dequeueReusableCell(withIdentifier: WalletButtonTableViewCell.getCellIdentifier()) as? WalletButtonTableViewCell
            if cell == nil {
                let nib = Bundle.main.loadNibNamed("WalletButtonTableViewCell", owner: self, options: nil)
                cell = nib![0] as? WalletButtonTableViewCell
                cell?.delegate = self
            }
            return cell!
        } else {
            var cell = tableView.dequeueReusableCell(withIdentifier: AssetTableViewCell.getCellIdentifier()) as? AssetTableViewCell
            if cell == nil {
                let nib = Bundle.main.loadNibNamed("AssetTableViewCell", owner: self, options: nil)
                cell = nib![0] as? AssetTableViewCell
            }
            cell?.asset = CurrentAppWalletDataManager.shared.getAssetsWithHideSmallAssetsOption()[indexPath.row]
            cell?.update()
            return cell!
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
        
        } else if indexPath.section == 1 {
        
        } else {
            // Avoid pushing AssetSwipeViewController mutiple times
            assetTableView.isUserInteractionEnabled = false

            tableView.deselectRow(at: indexPath, animated: true)
            let asset = CurrentAppWalletDataManager.shared.getAssetsWithHideSmallAssetsOption()[indexPath.row]
            let viewController = AssetSwipeViewController()
            viewController.asset = asset
            viewController.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
}

extension WalletViewController: WalletBalanceTableViewCellDelegate {
    func pressedQACodeButtonInWalletBalanceTableViewCell() {
        if CurrentAppWalletDataManager.shared.getCurrentAppWallet() != nil {
            let viewController = QRCodeViewController()
            viewController.hidesBottomBarWhenPushed = true
            viewController.address = CurrentAppWalletDataManager.shared.getCurrentAppWallet()!.address
            viewController.navigationTitle = LocalizedString("Wallet Address", comment: "")
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }
}

extension WalletViewController: WalletButtonTableViewCellDelegate {

    func navigationToScanViewController() {
        let viewController = ScanQRCodeViewController()
        viewController.expectedQRCodeTypes = [.mnemonic, .keystore, .privateKey, .submitOrder, .login, .cancelOrder, .convert, .approve, .p2pOrder, .address]
        viewController.delegate = self
        viewController.shouldPop = false
        viewController.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func navigationToReceiveViewController() {
        if CurrentAppWalletDataManager.shared.getCurrentAppWallet() != nil {
            let viewController = QRCodeViewController()
            viewController.hidesBottomBarWhenPushed = true
            viewController.address = CurrentAppWalletDataManager.shared.getCurrentAppWallet()!.address
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    func navigationToSendViewController() {
        let viewController = SendAssetViewController()
        viewController.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func navigationToTradeViewController() {
        let viewController = TradeSwipeViewController()
        viewController.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(viewController, animated: true)
    }

}

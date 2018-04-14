//
//  WalletViewController.swift
//  loopr-ios
//
//  Created by Xiao Dou Dou on 2/1/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

class WalletViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, WalletBalanceTableViewCellDelegate, ContextMenuDelegate {

    private var assets: [Asset] = []

    @IBOutlet weak var assetTableView: UITableView!
    
    var shouldRefresh: Bool = true
    var isReordering: Bool = false

    var contextMenuSourceView: UIView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        assetTableView.dataSource = self
        assetTableView.delegate = self
        assetTableView.reorder.delegate = self
        assetTableView.tableFooterView = UIView()
        assetTableView.separatorStyle = .none

        view.theme_backgroundColor = GlobalPicker.backgroundColor
        assetTableView.theme_backgroundColor = GlobalPicker.backgroundColor

        let qrCodebutton = UIButton(type: UIButtonType.custom)
        
        // TODO: smaller images.
        qrCodebutton.theme_setImage(["QRCode-black", "QRCode-white"], forState: UIControlState.normal)
        qrCodebutton.setImage(UIImage(named: "QRCode-black")?.alpha(0.3), for: .highlighted)
        qrCodebutton.addTarget(self, action: #selector(self.pressQRCodeButton(_:)), for: UIControlEvents.touchUpInside)
        qrCodebutton.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        let qrCodeBarButton = UIBarButtonItem(customView: qrCodebutton)
        self.navigationItem.leftBarButtonItem = qrCodeBarButton

        let addBarButton = UIBarButtonItem.init(barButtonSystemItem: .add, target: self, action: #selector(self.pressAddButton(_:)))
        self.navigationItem.rightBarButtonItem = addBarButton
        
        // Add observer.
        NotificationCenter.default.addObserver(self, selector: #selector(receivedBalanceResponseReceivedNotification), name: .balanceResponseReceived, object: nil)
        setup()
    }
    
    func setup() {
        // TODO: putting getMarketsFromServer() here may cause a race condition.
        // It's not perfect, but works. Need improvement in the future.
        DispatchQueue.main.async {
            self.assets = CurrentAppWalletDataManager.shared.getAssets()
            self.assetTableView.reloadData()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let button =  UIButton(type: .custom)
        button.frame = CGRect(x: 0, y: 0, width: 120, height: 40)
        
        var buttonTitle = CurrentAppWalletDataManager.shared.getCurrentAppWallet()?.name
        if buttonTitle == nil {
            buttonTitle = NSLocalizedString("Wallet", comment: "")
        }
        
        // TODO: Use an elegant method to set the title to center.
        button.setTitle("      " + buttonTitle! + "  ", for: .normal)
        button.titleLabel?.font = UIFont(name: FontConfigManager.shared.getLight(), size: 16.0)
        button.theme_setTitleColor(["#000", "#fff"], forState: .normal)
        button.setTitleColor(UIColor.init(white: 0.8, alpha: 1), for: .highlighted)
        
        button.theme_setImage(["Arrow-down-black", "Arrow-down-white"], forState: .normal)
        button.setImage(UIImage.init(named: "Arrow-down-black")?.alpha(0.3), for: .highlighted)
        
        button.semanticContentAttribute = .forceRightToLeft
        // button.imageEdgeInsets = UIEdgeInsets.init(top: 0, left: 50, bottom: 0, right: -50)
        
        button.addTarget(self, action: #selector(self.clickNavigationTitleButton(_:)), for: .touchUpInside)
        self.navigationItem.titleView = button
        
        // assetTableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func clickNavigationTitleButton(_ button: UIButton) {
        print("select another wallet.")
        let viewController = SelectWalletViewController()
        viewController.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    @objc func pressQRCodeButton(_ button: UIBarButtonItem) {
        print("pressQRCodeButton")
        if CurrentAppWalletDataManager.shared.getCurrentAppWallet() != nil {
            let viewController = QRCodeViewController()
            viewController.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    @objc func pressAddButton(_ button: UIBarButtonItem) {
        contextMenuSourceView.frame = CGRect(x: self.view.frame.width-10, y: -5, width: 1, height: 1)
        view.addSubview(contextMenuSourceView)

        let menuViewController = AddMenuViewController()
        menuViewController.didSelectRowClosure = { (index) -> Void in
            if index == 0 {
                print("Selected Scan QR code")
                let viewController = ScanQRCodeViewController()
                viewController.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(viewController, animated: true)
            } else if index == 1 {
                print("Selected Add Token")
                let viewController = AddTokenViewController()
                viewController.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(viewController, animated: true)
            }
        }

        ContextMenu.shared.show(
            sourceViewController: self,
            viewController: menuViewController,
            options: ContextMenu.Options(containerStyle: ContextMenu.ContainerStyle(backgroundColor: UIColor.black), menuStyle: .minimal),
            sourceView: contextMenuSourceView,
            delegate: self
        )
    }
    
    func contextMenuWillDismiss(viewController: UIViewController, animated: Bool) {
        print("will dismiss")
    }
    
    func contextMenuDidDismiss(viewController: UIViewController, animated: Bool) {
        print("did dismiss")
        
        contextMenuSourceView.removeFromSuperview()
    }
    
    @objc func receivedBalanceResponseReceivedNotification() {
        // print("receivedBalanceResponseReceivedNotification")
        // TODO: Perform a diff algorithm
        
        if shouldRefresh && !isReordering {
            print("reload table")
            self.assets = CurrentAppWalletDataManager.shared.getAssets()
            assetTableView.reloadData()
            shouldRefresh = false
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1 + (assets.count)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return WalletBalanceTableViewCell.getHeight()
        } else {
            return AssetTableViewCell.getHeight()
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            var cell = tableView.dequeueReusableCell(withIdentifier: WalletBalanceTableViewCell.getCellIdentifier()) as? WalletBalanceTableViewCell
            if cell == nil {
                let nib = Bundle.main.loadNibNamed("WalletBalanceTableViewCell", owner: self, options: nil)
                cell = nib![0] as? WalletBalanceTableViewCell
                cell?.selectionStyle = .none
                cell?.delegate = self
            }
            cell?.setup()
            return cell!
        } else {
            if let spacer = assetTableView.reorder.spacerCell(for: indexPath) {
                return spacer
            }
            var cell = tableView.dequeueReusableCell(withIdentifier: AssetTableViewCell.getCellIdentifier()) as? AssetTableViewCell
            if cell == nil {
                let nib = Bundle.main.loadNibNamed("AssetTableViewCell", owner: self, options: nil)
                cell = nib![0] as? AssetTableViewCell
            }
            cell?.asset = CurrentAppWalletDataManager.shared.getAssets()[indexPath.row - 1]
            cell?.update()
            return cell!
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            
        } else {
            tableView.deselectRow(at: indexPath, animated: true)
            let asset = assets[indexPath.row - 1]
            let assetDetailViewController = AssetDetailViewController()
            assetDetailViewController.asset = asset
            assetDetailViewController.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(assetDetailViewController, animated: true)
        }
    }

    // TODO: no used
    func navigatToAddAssetViewController() {
        print("navigatToAddAssetViewController")
        let viewController = AddCustomizedTokenViewController()
        viewController.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(viewController, animated: true)
    }

}

extension WalletViewController: TableViewReorderDelegate {
    // MARK: - Reorder Delegate
    func tableView(_ tableView: UITableView, reorderRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        print("tableView reorderRowAt")
        CurrentAppWalletDataManager.shared.exchange(at: sourceIndexPath.row-1, to: destinationIndexPath.row-1)
    }

    func tableView(_ tableView: UITableView, canReorderRowAt indexPath: IndexPath) -> Bool {
        if indexPath.row >= 1 {
            return true
        } else {
            return false
        }
    }
    
    func tableViewDidBeginReordering(_ tableView: UITableView) {
        print("tableViewDidBeginReordering")
        isReordering = true
    }
    
    func tableViewDidFinishReordering(_ tableView: UITableView, from initialSourceIndexPath: IndexPath, to finalDestinationIndexPath: IndexPath) {
        print("tableViewDidFinishReordering")
        isReordering = false
        
    }

}

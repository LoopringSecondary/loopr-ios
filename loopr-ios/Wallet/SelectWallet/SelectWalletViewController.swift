//
//  SelectWalletViewController.swift
//  loopr-ios
//
//  Created by xiaoruby on 2/18/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit
import FoldingCell

struct CellHeight {
    static let close: CGFloat = 96
    static let open: CGFloat = 288
}

class SelectWalletViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var walletTableView: UITableView!
    
    var appWallet: AppWallet?
    var cellHeights: [CGFloat] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.theme_backgroundColor = GlobalPicker.backgroundColor
        walletTableView.theme_backgroundColor = GlobalPicker.backgroundColor
        
        self.navigationItem.title = NSLocalizedString("Select Wallet", comment: "")
        setBackButton()
        
        let addButton = UIBarButtonItem.init(barButtonSystemItem: .add, target: self, action: #selector(self.pressAddButton(_:)))
        self.navigationItem.rightBarButtonItem = addButton
        
        let cellCount = AppWalletDataManager.shared.getWallets().count
        cellHeights = (0 ..< cellCount).map { _ in CellHeight.close }

        walletTableView.delegate = self
        walletTableView.dataSource = self
        walletTableView.estimatedRowHeight = 2.0
        walletTableView.separatorStyle = .none
        walletTableView.rowHeight = UITableViewAutomaticDimension
        walletTableView.tableFooterView = UIView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        walletTableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func pressAddButton(_ button: UIBarButtonItem) {
        let setupViewController: SetupNavigationController? = SetupNavigationController(nibName: nil, bundle: nil)
        setupViewController?.isCreatingFirstWallet = false
        self.present(setupViewController!, animated: true) {
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return AppWalletDataManager.shared.getWallets().count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row < cellHeights.count {
            return cellHeights[indexPath.row]
        } else {
            return CellHeight.close
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: SelectWalletTableViewCell.getCellIdentifier()) as? SelectWalletTableViewCell
        if cell == nil {
            let nib = Bundle.main.loadNibNamed("SelectWalletTableViewCell", owner: self, options: nil)
            cell = nib![0] as? SelectWalletTableViewCell
        }
        
        // Configure the cell...
        cell?.wallet = AppWalletDataManager.shared.getWallets()[indexPath.row]
        cell?.update()
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? SelectWalletTableViewCell else { return }
        self.appWallet = AppWalletDataManager.shared.getWallets()[indexPath.row]
        cell.wallet = appWallet
        let duration = 0.3
        if cellHeights[indexPath.row] == CellHeight.close {
            cellHeights[indexPath.row] = CellHeight.open
            cell.openAnimation(nil)
        } else {
            cellHeights[indexPath.row] = CellHeight.close
            cell.closeAnimation(nil)
        }
        cell.update()
        cell.enterButton.addTarget(self, action: #selector(pressedEnterButton), for: .touchUpInside)
        UIView.animate(withDuration: duration, delay: 0, options: .curveEaseOut, animations: { () -> Void in
            tableView.beginUpdates()
            tableView.endUpdates()
        }, completion: nil)
    }
    
    @objc func pressedEnterButton() {
        if let appWallet = self.appWallet {
            let alertController = UIAlertController(title: NSLocalizedString("Choose Wallet", comment: "") + ": \(appWallet.name)",
                message: nil,
                preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: NSLocalizedString("Confirm", comment: ""), style: .default, handler: { _ in
                CurrentAppWalletDataManager.shared.setCurrentAppWallet(appWallet)
                self.navigationController?.popViewController(animated: true)
            })
            alertController.addAction(defaultAction)
            let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: { _ in
            })
            alertController.addAction(cancelAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
}

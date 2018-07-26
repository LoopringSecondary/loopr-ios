//
//  SettingWalletDetailViewControllerDataSource.swift
//  loopr-ios
//
//  Created by xiaoruby on 5/14/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import Foundation
import UIKit

extension SettingWalletDetailViewController {

    func getNumberOfRowsInWalletSection() -> Int {
        if appWallet.setupWalletMethod == .create || appWallet.setupWalletMethod == .importUsingMnemonic {
            return 4
        } else {
            return 3
        }
    }

    func getTableViewCell(cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: SettingWalletDetailTableViewCell.getCellIdentifier()) as? SettingWalletDetailTableViewCell
        if cell == nil {
            let nib = Bundle.main.loadNibNamed("SettingWalletDetailTableViewCell", owner: self, options: nil)
            cell = nib![0] as? SettingWalletDetailTableViewCell
        }

        cell?.accessoryType = .disclosureIndicator
        cell?.textLabel?.setTitleDigitFont()
        
        if indexPath.section == 0 {
            if appWallet.setupWalletMethod == .create || appWallet.setupWalletMethod == .importUsingMnemonic {
                if indexPath.row == 0 {
                    cell?.contentType = .walletName
                    cell?.textLabel?.text = LocalizedString("Wallet Name", comment: "")
                    cell?.detailTextLabel?.text = appWallet.name
                } else if indexPath.row == 1 {
                    cell?.contentType = .backupMnemonic
                    cell?.textLabel?.text = LocalizedString("Backup Mnemonic", comment: "")
                } else if indexPath.row == 2 {
                    cell?.contentType = .exportPrivateKey
                    cell?.textLabel?.text = LocalizedString("Export Private Key", comment: "")
                } else if indexPath.row == 3 {
                    cell?.contentType = .exportKeystore
                    cell?.textLabel?.text = LocalizedString("Export Keystore", comment: "")
                }
            } else {
                if indexPath.row == 0 {
                    cell?.contentType = .walletName
                    cell?.textLabel?.text = LocalizedString("Wallet Name", comment: "")
                    cell?.detailTextLabel?.text = appWallet.name
                } else if indexPath.row == 1 {
                    cell?.contentType = .exportPrivateKey
                    cell?.textLabel?.text = LocalizedString("Export Private Key", comment: "")
                } else if indexPath.row == 2 {
                    cell?.contentType = .exportKeystore
                    cell?.textLabel?.text = LocalizedString("Export Keystore", comment: "")
                }
            }
        } else if indexPath.section == 1 {
            if indexPath.row == 0 {
                cell?.contentType = .clearRecords
                cell?.textLabel?.text = LocalizedString("Clear Records of this Wallet", comment: "")
                cell?.textLabel?.textColor = UIStyleConfig.red
            }
        }
        return cell!
    }

}

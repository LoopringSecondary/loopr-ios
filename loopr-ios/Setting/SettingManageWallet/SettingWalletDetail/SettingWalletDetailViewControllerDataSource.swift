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
            return 5
        } else {
            return 4
        }
    }

    func getTableViewCell(cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: SettingStyleTableViewCell.getCellIdentifier()) as? SettingStyleTableViewCell
        if cell == nil {
            let nib = Bundle.main.loadNibNamed("SettingStyleTableViewCell", owner: self, options: nil)
            cell = nib![0] as? SettingStyleTableViewCell
        }
        
        if indexPath.section == 0 {
            if appWallet.setupWalletMethod == .create || appWallet.setupWalletMethod == .importUsingMnemonic {
                if indexPath.row == 0 {
                    cell?.contentType = .walletName
                    cell?.leftLabel.text = LocalizedString("Wallet Name", comment: "")
                } else if indexPath.row == 1 {
                    cell?.contentType = .backupMnemonic
                    cell?.leftLabel.text = LocalizedString("Backup Mnemonic", comment: "")
                } else if indexPath.row == 2 {
                    cell?.contentType = .exportPrivateKey
                    cell?.leftLabel.text = LocalizedString("Export Private Key", comment: "")
                } else if indexPath.row == 3 {
                    cell?.contentType = .exportKeystore
                    cell?.leftLabel.text = LocalizedString("Export Keystore", comment: "")
                } else if indexPath.row == 4 {
                    cell?.contentType = .viewAddressOnEtherscan
                    cell?.leftLabel.text = LocalizedString("View Address on Etherscan", comment: "")
                }
            } else {
                if indexPath.row == 0 {
                    cell?.contentType = .walletName
                    cell?.leftLabel.text = LocalizedString("Wallet Name", comment: "")
                } else if indexPath.row == 1 {
                    cell?.contentType = .exportPrivateKey
                    cell?.leftLabel.text = LocalizedString("Export Private Key", comment: "")
                } else if indexPath.row == 2 {
                    cell?.contentType = .exportKeystore
                    cell?.leftLabel.text = LocalizedString("Export Keystore", comment: "")
                } else if indexPath.row == 3 {
                    cell?.contentType = .viewAddressOnEtherscan
                    cell?.leftLabel.text = LocalizedString("View Address on Etherscan", comment: "")
                }
            }
            
            if indexPath.row == getNumberOfRowsInWalletSection()-1 {
                cell?.trailingSeperateLineDown.constant = 0
            } else {
                cell?.trailingSeperateLineDown.constant = 15
            }

        } else if indexPath.section == 1 {
            if indexPath.row == 0 {
                cell?.contentType = .clearRecords
                cell?.leftLabel.text = LocalizedString("Clear Records of this Wallet", comment: "")
                cell?.leftLabel.textColor = UIColor.fail
                cell?.leftLabel.textAlignment = .left
                // cell?.disclosureIndicator.isHidden = true
                cell?.trailingSeperateLineDown.constant = 0
            }
        }
        
        if indexPath.row == 0 {
            cell?.seperateLineUp.isHidden = false
        } else {
            cell?.seperateLineUp.isHidden = true
        }

        return cell!
    }

}

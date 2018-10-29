//
//  WalletViewControllerDropdownMenu.swift
//  loopr-ios
//
//  Created by xiaoruby on 10/29/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import Foundation
import UIKit
import MKDropdownMenu

extension WalletViewController: MKDropdownMenuDataSource {
    func numberOfComponents(in dropdownMenu: MKDropdownMenu) -> Int {
        return 1
    }
    
    func dropdownMenu(_ dropdownMenu: MKDropdownMenu, numberOfRowsInComponent component: Int) -> Int {
        return 3
    }
}

extension WalletViewController: MKDropdownMenuDelegate {
    
    func dropdownMenu(_ dropdownMenu: MKDropdownMenu, rowHeightForComponent component: Int) -> CGFloat {
        return 50
    }
    
    func dropdownMenu(_ dropdownMenu: MKDropdownMenu, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let baseView = UIView(frame: CGRect(x: 0, y: 0, width: 160, height: 50))
        baseView.backgroundColor = UIColor.dark2
        
        let iconImageView = UIImageView(frame: CGRect(x: 21, y: 12, width: 24, height: 24))
        iconImageView.contentMode = .scaleAspectFit
        baseView.addSubview(iconImageView)
        
        let titleLabel = UILabel(frame: CGRect(x: 55, y: 0, width: 610-55, height: 50))
        titleLabel.font = FontConfigManager.shared.getRegularFont(size: 16)
        titleLabel.theme_textColor = GlobalPicker.textColor
        baseView.addSubview(titleLabel)
        
        var icon: UIImage?
        switch row {
        case 0:
            titleLabel.text = LocalizedString("Scan", comment: "")
            icon = UIImage.init(named: "dropdown-scan")
        case 1:
            titleLabel.text = LocalizedString("Add Token", comment: "")
            icon = UIImage.init(named: "dropdown-add-token")
        case 2:
            titleLabel.text = LocalizedString("Wallet", comment: "")
            icon = UIImage.init(named: "dropdown-wallet")
        default:
            break
        }
        
        iconImageView.image = icon
        
        return baseView
    }
    
    func dropdownMenu(_ dropdownMenu: MKDropdownMenu, didSelectRow row: Int, inComponent component: Int) {
        dropdownMenu.closeAllComponents(animated: false)
        switch row {
        case 0:
            let viewController = ScanQRCodeViewController()
            viewController.expectedQRCodeTypes = [.submitOrder, .login, .cancelOrder, .convert, .approve, .p2pOrder, .address]
            viewController.delegate = self
            viewController.shouldPop = false
            viewController.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(viewController, animated: true)
        case 1:
            let viewController = AddTokenViewController()
            viewController.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(viewController, animated: true)
        case 2:
            let viewController = SettingManageWalletViewController()
            viewController.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(viewController, animated: true)
        default:
            break
        }
    }
    
    func dropdownMenu(_ dropdownMenu: MKDropdownMenu, backgroundColorForHighlightedRowsInComponent component: Int) -> UIColor? {
        return UIColor.dark4
    }
    
    func dropdownMenu(_ dropdownMenu: MKDropdownMenu, didCloseComponent component: Int) {
        isDropdownMenuExpanded = false
    }
    
}

//
//  SettingViewController.swift
//  loopr-ios
//
//  Created by Xiao Dou Dou on 2/3/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

class SettingViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var settingsTableView: UITableView!
    
    let sectionTitles = [LocalizedString("User Preferences", comment: ""), LocalizedString("Trading", comment: ""), LocalizedString("Security", comment: ""), LocalizedString("About", comment: "")]
    let sectionRows = [1, 5, 2, Production.getSocialMedia().count + 1]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationItem.title = LocalizedString("Settings", comment: "")
        
        view.theme_backgroundColor = ColorPicker.backgroundColor
        settingsTableView.separatorStyle = .none
        settingsTableView.tableFooterView = UIView(frame: .zero)
        settingsTableView.delaysContentTouches = false
        settingsTableView.theme_backgroundColor = ColorPicker.backgroundColor
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 10))
        headerView.theme_backgroundColor = ColorPicker.backgroundColor
        settingsTableView.tableHeaderView = headerView

        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 10))
        footerView.theme_backgroundColor = ColorPicker.backgroundColor
        settingsTableView.tableFooterView = footerView
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        settingsTableView.reloadData()
        self.navigationItem.title = LocalizedString("Settings", comment: "")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //Table view configuration
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionRows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            return partnerSectionForCell(indexPath: indexPath)
        case 1:
            return userPreferencesSectionForCell(indexPath: indexPath)
        case 2:
            return tradingSectionForCell(indexPath: indexPath)
        case 3:
            return aboutSectionForCell(indexPath: indexPath)
        default:
            return UITableViewCell(frame: .zero)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch indexPath.section {
        case 0:
            if indexPath.row == 0 {
                print("Setting partner")
                let viewController = SettingPartnerViewController()
                viewController.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(viewController, animated: true)
            }
        case 1:
            userPreferencesSectionForCellDidSelected(indexPath: indexPath)
        case 2:
            switch indexPath.row {
            case 0:
                print("contract version")
                let viewController = DisplayContractVersionViewController()
                viewController.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(viewController, animated: true)
            case 1:
                print("LRC Fee ratio")
                let viewController = SettingLRCFeeRatioViewController()
                viewController.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(viewController, animated: true)
            case 2:
                // TODO: Trade FAQ is not ready.
                print("Trade FAQ")
                let viewController = TradeFAQViewController()
                viewController.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(viewController, animated: true)
            default:
                break
            }
        case 3:
            // About
            switch indexPath.row {
            case 0..<Production.getSocialMedia().count:
                if let url = Production.getSocialMedia()[indexPath.row].url {
                    UIApplication.shared.open(url)
                }
            default:
                break
            }
        default:
            break
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            if FeatureConfigDataManager.shared.getShowTradingFeature() {
                return 1
            } else {
                return 0
            }
        } else if section == 1 {
            var numberOfRows: Int = 0
            if BiometricType.get() == .none {
                numberOfRows = 4
            } else {
                numberOfRows = 5
            }
            if !FeatureConfigDataManager.shared.getShowTradingFeature() {
                numberOfRows -= 1
            }
            
            // TODO: Disable third party in App Store version.
            numberOfRows -= 1
            
            return numberOfRows
        } else if section == 2 {
            if FeatureConfigDataManager.shared.getShowTradingFeature() {
                return 2
            } else {
                return 0
            }
        } else {
            return sectionRows[section]
        }
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 20))
        headerView.theme_backgroundColor = ColorPicker.backgroundColor
        return headerView
    }
    
    // Sections
    func partnerSectionForCell(indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            var cell = settingsTableView.dequeueReusableCell(withIdentifier: SettingStyleTableViewCell.getCellIdentifier()) as? SettingStyleTableViewCell
            if cell == nil {
                let nib = Bundle.main.loadNibNamed("SettingStyleTableViewCell", owner: self, options: nil)
                cell = nib![0] as? SettingStyleTableViewCell
            }
            
            cell?.leftLabel.textColor = .success
            cell?.leftLabel.font = FontConfigManager.shared.getRegularFont(size: 14)
            cell?.leftLabel.text = LocalizedString("Partner_Slogan", comment: "")
            cell?.rightLabel.isHidden = true
            cell?.disclosureIndicator.isHidden = false
            
            if indexPath.row == 0 {
                cell?.seperateLineUp.isHidden = false
            } else {
                cell?.seperateLineUp.isHidden = true
            }
            
            if indexPath.row == sectionRows[indexPath.section]-1 {
                cell?.trailingSeperateLineDown.constant = 0
            } else {
                cell?.trailingSeperateLineDown.constant = 15
            }
            return cell!
        default:
            return UITableViewCell(frame: .zero)
        }
    }
    
    func userPreferencesSectionForCell(indexPath: IndexPath) -> UITableViewCell {
        if BiometricType.get() == .none {
            switch indexPath.row {
            case 0:
                var currentWalletName = CurrentAppWalletDataManager.shared.getCurrentAppWallet()?.name
                if currentWalletName == nil {
                    currentWalletName = ""
                }
                return createDetailTableCell(indexPath: indexPath, title: LocalizedString("Manage Wallets", comment: ""))
            case 1:
                return createDetailTableCell(indexPath: indexPath, title: LocalizedString("Currency", comment: ""))
            case 2:
                return createDetailTableCell(indexPath: indexPath, title: LocalizedString("Language", comment: ""))
            case 3:
                let title: String
                if UserDefaults.standard.bool(forKey: UserDefaultsKeys.thirdParty.rawValue) {
                    title = LocalizedString("Third", comment: "")
                } else {
                    title = LocalizedString("Unthird", comment: "")
                }
                return createDetailTableCell(indexPath: indexPath, title: title)
            default:
                return UITableViewCell(frame: .zero)
            }
        } else {
            switch indexPath.row {
            case 0:
                var currentWalletName = CurrentAppWalletDataManager.shared.getCurrentAppWallet()?.name
                if currentWalletName == nil {
                    currentWalletName = ""
                }
                return createDetailTableCell(indexPath: indexPath, title: LocalizedString("Manage Wallets", comment: ""))
            case 1:
                return createDetailTableCell(indexPath: indexPath, title: LocalizedString("Currency", comment: ""))
            case 2:
                return createDetailTableCell(indexPath: indexPath, title: LocalizedString("Language", comment: ""))
            case 3:
                return createSettingPasscodeTableView(indexPath: indexPath)
            case 4:
                let title: String
                if UserDefaults.standard.bool(forKey: UserDefaultsKeys.thirdParty.rawValue) {
                    title = LocalizedString("Third", comment: "")
                } else {
                    title = LocalizedString("Unthird", comment: "")
                }
                return createDetailTableCell(indexPath: indexPath, title: title)
            default:
                return UITableViewCell(frame: .zero)
            }
        }
    }

    func userPreferencesSectionForCellDidSelected(indexPath: IndexPath) {
        if BiometricType.get() == .none {
            switch indexPath.row {
            case 0:
                print("Setting wallet")
                let viewController = SettingManageWalletViewController()
                viewController.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(viewController, animated: true)
            case 1:
                print("Setting currency")
                let viewController = SettingCurrencyViewController()
                viewController.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(viewController, animated: true)
            case 2:
                print("Setting language")
                let viewController = SettingLanguageViewController()
                viewController.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(viewController, animated: true)
            case 3:
                pressedThirdPartyButton()
            default:
                break
            }
        } else {
            switch indexPath.row {
            case 0:
                print("Setting wallet")
                let viewController = SettingManageWalletViewController()
                viewController.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(viewController, animated: true)
            case 1:
                print("Setting currency")
                let viewController = SettingCurrencyViewController()
                viewController.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(viewController, animated: true)
            case 2:
                print("Setting language")
                let viewController = SettingLanguageViewController()
                viewController.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(viewController, animated: true)
            case 3:
                print("Touch id")
                if !AuthenticationDataManager.shared.devicePasscodeEnabled() {
                    let title: String
                    if BiometricType.get() == .touchID {
                        title = LocalizedString("Please turn on Touch ID in settings", comment: "")
                    } else {
                        title = LocalizedString("Please turn on Face ID in settings", comment: "")
                    }
                    let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: LocalizedString("OK", comment: ""), style: .default, handler: { _ in
                        
                    }))
                    UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
                }
            case 4:
                pressedThirdPartyButton()
            default:
                break
            }
        }
    }

    func tradingSectionForCell(indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            return createDetailTableCell(indexPath: indexPath, title: LocalizedString("Contract Version", comment: ""))
        case 1:
            return createDetailTableCell(indexPath: indexPath, title: LocalizedString("LRC Fee Ratio", comment: ""))
        case 2:
            return createDetailTableCell(indexPath: indexPath, title: LocalizedString("Trade FAQ", comment: ""))
        default:
            return UITableViewCell(frame: .zero)
        }
    }

    func aboutSectionForCell(indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0..<Production.getSocialMedia().count:
            return createDetailTableCell(indexPath: indexPath, title: Production.getSocialMedia()[indexPath.row].description)
        case Production.getSocialMedia().count:
            var cell = settingsTableView.dequeueReusableCell(withIdentifier: SettingStyleTableViewCell.getCellIdentifier()) as? SettingStyleTableViewCell
            if cell == nil {
                let nib = Bundle.main.loadNibNamed("SettingStyleTableViewCell", owner: self, options: nil)
                cell = nib![0] as? SettingStyleTableViewCell
            }
            cell?.selectionStyle = .none
            cell?.leftLabel.text = title
            cell?.rightLabel.isHidden = false
            cell?.disclosureIndicator.isHidden = true
            if indexPath.row == 0 {
                cell?.seperateLineUp.isHidden = false
            } else {
                cell?.seperateLineUp.isHidden = true
            }
            
            if indexPath.row == sectionRows[indexPath.section]-1 {
                cell?.trailingSeperateLineDown.constant = 0
            } else {
                cell?.trailingSeperateLineDown.constant = 15
            }
            cell?.leftLabel.text = LocalizedString("App Version", comment: "")
            cell?.rightLabel.text = AppServiceUpdateManager.shared.getAppVersionAndBuildVersion()

            return cell!
        default:
            return UITableViewCell(frame: .zero)
        }
    }
    
    // Cell Types
    func createSettingPasscodeTableView(indexPath: IndexPath) -> UITableViewCell {
        var cell = settingsTableView.dequeueReusableCell(withIdentifier: SettingPasscodeTableViewCell.getCellIdentifier()) as? SettingPasscodeTableViewCell
        if cell == nil {
            let nib = Bundle.main.loadNibNamed("SettingPasscodeTableViewCell", owner: self, options: nil)
            cell = nib![0] as? SettingPasscodeTableViewCell
            cell?.selectionStyle = .none
        }

        if indexPath.row == 0 {
            cell?.seperateLineUp.isHidden = false
        } else {
            cell?.seperateLineUp.isHidden = true
        }
        
        if indexPath.row == sectionRows[indexPath.section]-1 {
            cell?.trailingSeperateLineDown.constant = 0
        } else {
            cell?.trailingSeperateLineDown.constant = 15
        }

        return cell!
    }
    
    func createThemeMode(indexPath: IndexPath) -> UITableViewCell {
        var cell = settingsTableView.dequeueReusableCell(withIdentifier: SettingThemeModeTableViewCell.getCellIdentifier()) as? SettingThemeModeTableViewCell
        if cell == nil {
            let nib = Bundle.main.loadNibNamed("SettingThemeModeTableViewCell", owner: self, options: nil)
            cell = nib![0] as? SettingThemeModeTableViewCell
            cell?.selectionStyle = .none
        }

        if indexPath.row == 0 {
            cell?.seperateLineUp.isHidden = false
        } else {
            cell?.seperateLineUp.isHidden = true
        }
        
        if indexPath.row == sectionRows[indexPath.section]-1 {
            cell?.trailingSeperateLineDown.constant = 0
        } else {
            cell?.trailingSeperateLineDown.constant = 15
        }

        return cell!
    }
    
    func createDetailTableCell(indexPath: IndexPath, title: String) -> UITableViewCell {
        var cell = settingsTableView.dequeueReusableCell(withIdentifier: SettingStyleTableViewCell.getCellIdentifier()) as? SettingStyleTableViewCell
        if cell == nil {
            let nib = Bundle.main.loadNibNamed("SettingStyleTableViewCell", owner: self, options: nil)
            cell = nib![0] as? SettingStyleTableViewCell
        }
        
        cell?.leftLabel.text = title
        cell?.rightLabel.isHidden = true
        cell?.disclosureIndicator.isHidden = false

        if indexPath.row == 0 {
            cell?.seperateLineUp.isHidden = false
        } else {
            cell?.seperateLineUp.isHidden = true
        }
        
        if indexPath.row == sectionRows[indexPath.section]-1 {
            cell?.trailingSeperateLineDown.constant = 0
        } else {
            cell?.trailingSeperateLineDown.constant = 15
        }
        
        return cell!
    }
    
    func createBasicTableCell(title: String, detailTitle: String) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: title)
        cell.accessoryType = .none
        cell.selectionStyle = .none
        cell.textLabel?.text = title
        cell.textLabel?.font = FontConfigManager.shared.getMediumFont(size: 14)
        cell.textLabel?.textColor = Themes.isDark() ? UIColor.white : UIColor.dark2
        cell.detailTextLabel?.text = detailTitle
        cell.detailTextLabel?.font = FontConfigManager.shared.getRegularFont(size: 14)
        cell.textLabel?.textColor = Themes.isDark() ? UIColor.white : UIColor.dark2
        cell.backgroundColor = Themes.isDark() ? UIColor.dark2 : UIColor.white
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0
        } else if (section == 1 || section == 3) && !FeatureConfigDataManager.shared.getShowTradingFeature() {
            return 0
        } else {
            return 10
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 51
    }
    
    // TODO: Disable third party in App Store version.
    func pressedThirdPartyButton() {
        if UserDefaults.standard.bool(forKey: UserDefaultsKeys.thirdParty.rawValue) {
            let vc = ThirdPartyViewController()
            vc.fromSettingViewController = true
            self.present(vc, animated: true, completion: nil)
        } else if let openID = UserDefaults.standard.string(forKey: UserDefaultsKeys.openID.rawValue) {
            let title = LocalizedString("Third party title", comment: "")
            let message = LocalizedString("Third party message", comment: "")
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: LocalizedString("Confirm", comment: ""), style: .default, handler: { _ in
                UserDefaults.standard.set(true, forKey: UserDefaultsKeys.thirdParty.rawValue)
                DispatchQueue.main.async {
                    self.settingsTableView.reloadData()
                }
                AppServiceUserManager.shared.deleteUserConfig(openID: openID)
            }))
            alert.addAction(UIAlertAction(title: LocalizedString("Cancel", comment: ""), style: .cancel, handler: { _ in
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }

}

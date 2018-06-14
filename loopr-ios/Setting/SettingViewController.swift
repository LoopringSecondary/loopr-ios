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
    
    let sectionTitles = [NSLocalizedString("User Preferences", comment: ""), NSLocalizedString("Trading", comment: ""), NSLocalizedString("Security", comment: ""), NSLocalizedString("About", comment: "")]
    let sectionRows = [3, 3, 1, 1]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationItem.title = NSLocalizedString("Settings", comment: "")
        
        view.theme_backgroundColor = GlobalPicker.backgroundColor
        settingsTableView.tableFooterView = UIView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        settingsTableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //Table view configuration
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionTitles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            return userPreferencesSectionForCell(row: indexPath.row)
        case 1:
            return tradingSectionForCell(row: indexPath.row)
        case 2:
            return securitySectionForCell(row: indexPath.row)
        case 3:
            return aboutSectionForCell(row: indexPath.row)
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                print("Setting wallet")
                let viewController = SettingManageWalletViewController()
                viewController.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(viewController, animated: true)
            /*
            case 2:
                print("Setting language")
                let viewController = SettingLanguageViewController()
                viewController.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(viewController, animated: true)
            */
            case 1:
                print("Setting currency")
                let viewController = SettingCurrencyViewController()
                viewController.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(viewController, animated: true)
            case 2:
                print("Setting security")
                let viewController = SettingSecurityViewController()
                viewController.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(viewController, animated: true)
            default:
                break
            }
        case 1:
            switch indexPath.row {
            case 0:
                print("contract version")
            case 1:
                print("LRC Fee ratio")
                let viewController = SettingLRCFeeRatioViewController()
                viewController.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(viewController, animated: true)
            case 2:
                print("Margin split")
                let viewController = SettingMarginSplitViewController()
                viewController.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(viewController, animated: true)
            default:
                break
            }
        case 2:
            // Security
            switch indexPath.row {
            default:
                break
            }
        /*
        case 3:
            switch indexPath.row {
            case 1:
                let viewController = DefaultWebViewController()
                viewController.navigationTitle = "loopring.org"
                viewController.url = URL(string: "https://loopring.org")
                viewController.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(viewController, animated: true)
            default:
                break
            }
        */
        default:
            break
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sectionRows[section]
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionTitles[section]
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let padding: CGFloat = 15
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 45))
        headerView.backgroundColor = UIColor.init(rgba: "#F8F8F8")
        
        let label = UILabel(frame: CGRect(x: padding, y: 0, width: view.frame.size.width, height: 45))
        label.theme_textColor = GlobalPicker.textColor
        label.font = FontConfigManager.shared.getRegularFont()
        headerView.addSubview(label)
        
        label.text = sectionTitles[section]
        return headerView
    }
    
    // Sections
    func userPreferencesSectionForCell(row: Int) -> UITableViewCell {
        switch row {
        case 0:
            var currentWalletName = CurrentAppWalletDataManager.shared.getCurrentAppWallet()?.name
            if currentWalletName == nil {
                currentWalletName = ""
            }
            return createDetailTableCell(title: NSLocalizedString("Manage Wallet", comment: ""), detailTitle: currentWalletName!)
        case 1:
            return createDetailTableCell(title: NSLocalizedString("Currency", comment: ""), detailTitle: SettingDataManager.shared.getCurrentCurrency().name)
        case 2:
            return createThemeMode()
        /*
        case 2:
             return createDetailTableCell(title: NSLocalizedString("Security", comment: ""), detailTitle: "")
        case 1:
            return createThemeMode()
        case 2:
            return createDetailTableCell(title: NSLocalizedString("Language", comment: ""), detailTitle: SettingDataManager.shared.getCurrentLanguage().displayName)
        case 3:
            
        case 4:
            return createDetailTableCell(title: "Timzone", detailTitle: TimeZone.current.identifier)
        */
        default:
            return UITableViewCell()
        }
        
    }

    func tradingSectionForCell(row: Int) -> UITableViewCell {
        switch row {
        case 0:
            return createBasicTableCell(title: NSLocalizedString("Contract Version", comment: ""), detailTitle: RelayAPIConfiguration.delegateAddress)
        case 1:
            return createDetailTableCell(title: NSLocalizedString("LRC Fee Ratio", comment: ""), detailTitle: SettingDataManager.shared.getLrcFeeRatioDescription())
        case 2:
            return createDetailTableCell(title: NSLocalizedString("Margin Split", comment: ""), detailTitle: SettingDataManager.shared.getMarginSplitDescription())
        default:
            return UITableViewCell()
        }
    }
    
    func securitySectionForCell(row: Int) -> UITableViewCell {
        switch row {
        case 0:
            return createSettingPasscodeTableView()
        default:
            return UITableViewCell()
        }
    }
    
    func section3Cell(row: Int) -> UITableViewCell {
        switch row {
        case 0:
            return createBasicTableCell(title: NSLocalizedString("Default Relay", comment: ""), detailTitle: RelayAPIConfiguration.baseURL)
        /*
        case 1:
            return createBasicTableCell(title: "Backup Loopring Relay", detailTitle: "27.0.0.01")
        case 2:
            return createBasicTableCell(title: "Test Loopring Relay", detailTitle: "27.0.0.01")
        */
        default:
            return UITableViewCell()
        }
        
    }
    
    func aboutSectionForCell(row: Int) -> UITableViewCell {
        switch row {
        case 0:
            return createBasicTableCell(title: NSLocalizedString("App Version", comment: ""), detailTitle: getAppVersion())
        /*
        case 1:
            return createDetailTableCell(title: "Website", detailTitle: "loopring.org")
        /*
        case 2:
            return createDetailTableCell(title: "Privacy Policy")
        case 3:
            return createDetailTableCell(title: "Terms Of Service")
        */
        case 2:
            return createBasicTableCell(title: NSLocalizedString("Support", comment: ""), detailTitle: "help@loopring.org")
        case 3:
            return createBasicTableCell(title: "Copyright", detailTitle: "Loopring 2018")
        */
        default:
            return UITableViewCell()
        }
    }
    
    // Cell Types
    func createSettingPasscodeTableView() -> UITableViewCell {
        var cell = settingsTableView.dequeueReusableCell(withIdentifier: SettingPasscodeTableViewCell.getCellIdentifier()) as? SettingPasscodeTableViewCell
        if cell == nil {
            let nib = Bundle.main.loadNibNamed("SettingPasscodeTableViewCell", owner: self, options: nil)
            cell = nib![0] as? SettingPasscodeTableViewCell
            cell?.selectionStyle = .none
        }
        return cell!
    }
    
    func createThemeMode() -> UITableViewCell {
        var cell = settingsTableView.dequeueReusableCell(withIdentifier: SettingThemeModeTableViewCell.getCellIdentifier()) as? SettingThemeModeTableViewCell
        if cell == nil {
            let nib = Bundle.main.loadNibNamed("SettingThemeModeTableViewCell", owner: self, options: nil)
            cell = nib![0] as? SettingThemeModeTableViewCell
            cell?.selectionStyle = .none
        }
        return cell!
    }
    
    func createDetailTableCell(title: String, detailTitle: String) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: title)
        cell.accessoryType = .disclosureIndicator
        cell.selectionStyle = .blue
        cell.textLabel?.text = title
        cell.textLabel?.font = FontConfigManager.shared.getLabelFont()
        cell.detailTextLabel?.text = detailTitle
        cell.detailTextLabel?.font = FontConfigManager.shared.getLabelFont()
        return cell
    }
    
    func createDetailTableCell(title: String) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: title)
        cell.accessoryType = .detailButton
        cell.selectionStyle = .blue
        cell.textLabel?.text = title
        cell.textLabel?.font = FontConfigManager.shared.getLabelFont()
        return cell
    }
    
    func createBasicTableCell(title: String, detailTitle: String) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: title)
        cell.accessoryType = .none
        cell.selectionStyle = .none
        cell.textLabel?.text = title
        cell.textLabel?.font = FontConfigManager.shared.getLabelFont()
        cell.detailTextLabel?.text = detailTitle
        cell.detailTextLabel?.font = FontConfigManager.shared.getLabelFont()
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 45
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 45
    }
    
    func getAppVersion() -> String {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        let build = Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as! String
        return version + " (" + build + ")"
    }
}

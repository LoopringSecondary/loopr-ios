//
//  SettingViewController.swift
//  loopr-ios
//
//  Created by Xiao Dou Dou on 2/3/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit
import Lottie

class SettingViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var settingsTableView: UITableView!
    
    let sectionTitles = ["User Preferences", "Tools", "Trading", "Relay", "About"]
    let sectionRows = [3, 3, 3, 3, 6]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // playSampleLottieAnimation()

        self.navigationController?.navigationBar.topItem?.title = "Settings"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // TODO: Remove unused code
    func playSampleLottieAnimation() {
        let animationView = LOTAnimationView(name: "button1")
        animationView.transform = CGAffineTransform(scaleX: 0.4, y: 0.4)
        self.view.addSubview(animationView)
        animationView.play {(_) in
            // Do Something
        }
    }
    
    //Table view configuration
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionTitles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            return section0Cell(row: indexPath.row)
        case 1:
            return section1Cell(row: indexPath.row)
        case 2:
            return section2Cell(row: indexPath.row)
        case 3:
            return section3Cell(row: indexPath.row)
        case 4:
            return section4Cell(row: indexPath.row)
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sectionRows[section]
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionTitles[section]
    }
    
    // Sections
    func section0Cell(row: Int) -> UITableViewCell {
        switch row {
        case 0:
            return createDetailTableCell(title: "Language", detailTitle: "English")
        case 1:
            return createDetailTableCell(title: "Currency", detailTitle: "USD")
        case 2:
            return createDetailTableCell(title: "Timzone", detailTitle: TimeZone.current.identifier)
        default:
            return UITableViewCell()
        }
        
    }
    
    func section1Cell(row: Int) -> UITableViewCell {
        switch row {
        case 0:
            return createDetailTableCell(title: "Backup Wallet")
        case 1:
            return createDetailTableCell(title: "Display Private Keys")
        case 2:
            return createDetailTableCell(title: "Pair Devices")
        default:
            return UITableViewCell()
        }
        
    }
    
    func section2Cell(row: Int) -> UITableViewCell {
        switch row {
        case 0:
            return createBasicTableCell(title: "Contract Version", detailTitle: "1.0.1")
        case 1:
            return createDetailTableCell(title: "LRC Fee", detailTitle: "12.3020%")
        case 2:
            return createDetailTableCell(title: "Margin Split", detailTitle: "0.0000")
        default:
            return UITableViewCell()
        }
        
    }
    
    func section3Cell(row: Int) -> UITableViewCell {
        switch row {
        case 0:
            return createBasicTableCell(title: "Default Loopring Relay", detailTitle: "27.0.0.01")
        case 1:
            return createBasicTableCell(title: "Backup Loopring Relay", detailTitle: "27.0.0.01")
        case 2:
            return createBasicTableCell(title: "Test Loopring Relay", detailTitle: "27.0.0.01")
        default:
            return UITableViewCell()
        }
        
    }
    
    func section4Cell(row: Int) -> UITableViewCell {
        switch row {
        case 0:
            return createBasicTableCell(title: "App Version", detailTitle: "1.0.1")
        case 1:
            return createDetailTableCell(title: "Website", detailTitle: "loopring.org")
        case 2:
            return createDetailTableCell(title: "Privacy Policy")
        case 3:
            return createDetailTableCell(title: "Terms Of Service")
        case 4:
            return createBasicTableCell(title: "Support", detailTitle: "help@loopring.org")
        case 5:
            return createBasicTableCell(title: "Copyright", detailTitle: "Loopring 2018")
        default:
            return UITableViewCell()
        }
    }
    
    // Cell Types
    func createDetailTableCell(title: String, detailTitle: String) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: title)
        cell.accessoryType = .disclosureIndicator
        cell.selectionStyle = .blue
        cell.textLabel?.text = title
        cell.detailTextLabel?.text = detailTitle
        return cell
    }
    
    func createDetailTableCell(title: String) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: title)
        cell.accessoryType = .detailButton
        cell.selectionStyle = .blue
        cell.textLabel?.text = title
        return cell
    }
    
    func createBasicTableCell(title: String, detailTitle: String) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: title)
        cell.accessoryType = .none
        cell.selectionStyle = .none
        cell.selectionStyle = .blue
        cell.textLabel?.text = title
        cell.detailTextLabel?.text = detailTitle
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 45
    }

}

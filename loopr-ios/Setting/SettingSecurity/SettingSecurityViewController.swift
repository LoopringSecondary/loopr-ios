//
//  SettingSecurityViewController.swift
//  loopr-ios
//
//  Created by xiaoruby on 5/23/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

class SettingSecurityViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    let options: [AuthenticationTimingType] = [.disable, .immediately, .oneMin, .fiveMins, .fifteenMins, .oneHour, .fourHours]
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationItem.title = NSLocalizedString("Security Settings", comment: "")
        setBackButton()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 45
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "SettingSecurityTableViewCell")
        cell.accessoryType = .disclosureIndicator
        cell.selectionStyle = .blue
        cell.textLabel?.font = FontConfigManager.shared.getLabelFont()
        let option = options[indexPath.row]
        if option == .disable {
            cell.textLabel?.text = "Eable Touch ID"
        } else {
            cell.textLabel?.text = options[indexPath.row].description
        }
        return cell
    }

}

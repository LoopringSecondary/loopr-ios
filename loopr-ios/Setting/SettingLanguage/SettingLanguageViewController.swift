//
//  SettingLanguageViewController.swift
//  loopr-ios
//
//  Created by xiaoruby on 3/2/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

class SettingLanguageViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    let languages = ["English", "简体中文"]

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.dataSource = self
        tableView.delegate = self

        self.navigationItem.title = "Language"
        let backButton = UIBarButtonItem()
        backButton.title = ""
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
        
        view.theme_backgroundColor = GlobalPicker.backgroundColor
        tableView.theme_backgroundColor = GlobalPicker.backgroundColor
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return languages.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: SettingLanguageTableViewCell.getCellIdentifier()) as? SettingLanguageTableViewCell
        if cell == nil {
            let nib = Bundle.main.loadNibNamed("SettingLanguageTableViewCell", owner: self, options: nil)
            cell = nib![0] as? SettingLanguageTableViewCell
            cell?.selectionStyle = .none
            cell?.accessoryType = UITableViewCellAccessoryType.checkmark
        }
        
        cell?.textLabel?.text = languages[indexPath.row]
        
        return cell!
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

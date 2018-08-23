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
    
    var languages: [Language] = SettingDataManager.shared.getSupportedLanguages()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView()

        self.navigationItem.title = LocalizedString("Language", comment: "")
        setBackButton()
        
        view.theme_backgroundColor = ColorPicker.backgroundColor
        tableView.theme_backgroundColor = ColorPicker.backgroundColor
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return languages.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return SettingCurrencyTableViewCell.getHeight()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: SettingCurrencyTableViewCell.getCellIdentifier()) as? SettingCurrencyTableViewCell
        if cell == nil {
            let nib = Bundle.main.loadNibNamed("SettingCurrencyTableViewCell", owner: self, options: nil)
            cell = nib![0] as? SettingCurrencyTableViewCell
        }

        cell?.currencyDisplayLabel.text = languages[indexPath.row].displayName
        
        if SettingDataManager.shared.getCurrentLanguage() == languages[indexPath.row] {
            cell?.enabledIcon.isHidden = false
        } else {
            cell?.enabledIcon.isHidden = true
        }
        cell?.update()
        
        if indexPath.row == 0 {
            cell?.seperateLineUp.isHidden = false
        } else {
            cell?.seperateLineUp.isHidden = true
        }

        return cell!
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let result = SetLanguage(languages[indexPath.row].name)
        print(result)
        
        tableView.deselectRow(at: indexPath, animated: true)
        tableView.reloadData()
        self.navigationItem.title = LocalizedString("Language", comment: "")
    }

}

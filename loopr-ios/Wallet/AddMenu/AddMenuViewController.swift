//
//  AddMenuViewController.swift
//  loopr-ios
//
//  Created by sunnywheat on 3/18/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

class AddMenuViewController: UITableViewController {
    
    let rows = 2
    
    var didSelectRowClosure: ((_ index: Int) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        // tableView.register(AddMenuTableViewCell.self, forCellReuseIdentifier: AddMenuTableViewCell.getCellIdentifier())
        tableView.reloadData()
        tableView.layoutIfNeeded()
        preferredContentSize = CGSize(width: 141, height: tableView.contentSize.height)
        navigationItem.backBarButtonItem = UIBarButtonItem(title: " ", style: .plain, target: nil, action: nil)
        tableView.backgroundColor = .clear
        tableView.isScrollEnabled = false
        tableView.separatorStyle = .none
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Int(rows)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 45
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: AddMenuTableViewCell.getCellIdentifier()) as? AddMenuTableViewCell
        if cell == nil {
            let nib = Bundle.main.loadNibNamed("AddMenuTableViewCell", owner: self, options: nil)
            cell = nib![0] as? AddMenuTableViewCell
        }
        
        if indexPath.row == 0 {
            cell?.iconImageView.image = UIImage(named: "Scan-white")
            cell?.titleLabel.text = NSLocalizedString("Scan QR Code", comment: "")
        } else {
            cell?.iconImageView.image = UIImage(named: "Add-token")
            cell?.titleLabel.text = NSLocalizedString("Add Token", comment: "")
            cell?.seperateLabel.isHidden = true
        }

        return cell!
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        self.dismiss(animated: true) {
            if let btnAction = self.didSelectRowClosure {
                btnAction(indexPath.row)
            }
        }
    }

}

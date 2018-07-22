//
//  AddMenuViewController.swift
//  loopr-ios
//
//  Created by sunnywheat on 3/18/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

class AddMenuViewController: UITableViewController {
    
    var rows: UInt8
    var titles: [String]
    var icons: [UIImage]
    
    var didSelectRowClosure: ((_ index: Int) -> Void)?

    convenience init(rows: UInt8, titles: [String], icons: [UIImage]) {
        self.init(nibName: nil, bundle: nil)
        self.rows = rows
        self.titles = titles
        self.icons = icons
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        self.rows = 2
        self.titles = []
        self.icons = []
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        // tableView.register(AddMenuTableViewCell.self, forCellReuseIdentifier: AddMenuTableViewCell.getCellIdentifier())
        tableView.reloadData()
        tableView.layoutIfNeeded()
        preferredContentSize = CGSize(width: 160, height: tableView.contentSize.height)
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
        return 50
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: AddMenuTableViewCell.getCellIdentifier()) as? AddMenuTableViewCell
        if cell == nil {
            let nib = Bundle.main.loadNibNamed("AddMenuTableViewCell", owner: self, options: nil)
            cell = nib![0] as? AddMenuTableViewCell
        }
        cell?.iconImageView.image = icons[indexPath.row]
        cell?.titleLabel.text = titles[indexPath.row]
        if indexPath.row == rows - 1 {
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

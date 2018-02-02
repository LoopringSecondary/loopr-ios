//
//  WalletViewController.swift
//  loopr-ios
//
//  Created by Xiao Dou Dou on 2/1/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

class WalletViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var assetTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        assetTableView.dataSource = self
        assetTableView.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return AssetTableViewCell.getHeight()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "AssetCellIdentifier"
        
        var cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? AssetTableViewCell
        if (cell == nil) {
            let nib = Bundle.main.loadNibNamed("AssetTableViewCell", owner: self, options: nil)
            cell = nib![0] as? AssetTableViewCell
            
            // TODO: Tried to have a better animation when the user clicks the cell
            cell?.selectionStyle = .none
        }
        
        // Configure the cell...
        
        return cell!
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

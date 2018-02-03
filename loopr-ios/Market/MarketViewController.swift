//
//  MarketViewController.swift
//  loopr-ios
//
//  Created by Xiao Dou Dou on 2/2/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

class MarketViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var marketTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        marketTableView.dataSource = self
        marketTableView.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return MarketTableViewCell.getHeight()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MarketDataManager.shared.getMarkets().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "MarketCellIdentifier"
        
        var cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? MarketTableViewCell
        if (cell == nil) {
            let nib = Bundle.main.loadNibNamed("MarketTableViewCell", owner: self, options: nil)
            cell = nib![0] as? MarketTableViewCell
            
            // TODO: Tried to have a better animation when the user clicks the cell
            cell?.selectionStyle = .none
        }
        
        // Configure the cell...
        cell?.market = MarketDataManager.shared.getMarkets()[indexPath.row]
        cell?.update()
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let marketDetailViewController = MarketDetailViewController();
        let market = MarketDataManager.shared.getMarkets()[indexPath.row]
        marketDetailViewController.market = market
        marketDetailViewController.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(marketDetailViewController, animated: true)
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

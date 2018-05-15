//
//  SwitchTradeTokenViewController.swift
//  loopr-ios
//
//  Created by xiaoruby on 3/14/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

enum SwitchTradeTokenType {
    case tokenS
    case tokenB
}

class SwitchTradeTokenViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var type: SwitchTradeTokenType = .tokenS
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // self.navigationController?.isNavigationBarHidden = false

        setBackButton()

        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // self.navigationController?.isNavigationBarHidden = false
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return TokenDataManager.shared.getTokens().count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return SwitchTradeTokenTableViewCell.getHeight()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: SwitchTradeTokenTableViewCell.getCellIdentifier()) as? SwitchTradeTokenTableViewCell
        if cell == nil {
            let nib = Bundle.main.loadNibNamed("SwitchTradeTokenTableViewCell", owner: self, options: nil)
            cell = nib![0] as? SwitchTradeTokenTableViewCell
        }

        let token = TokenDataManager.shared.getTokens()[indexPath.row]
        cell?.token = token
        cell?.update()

        if (type == .tokenS && token.symbol == TradeDataManager.shared.tokenS.symbol) || (type == .tokenB && token.symbol == TradeDataManager.shared.tokenB.symbol) {
            cell?.accessoryType = .checkmark
        } else {
            cell?.accessoryType = .none
        }

        return cell!
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let token = TokenDataManager.shared.getTokens()[indexPath.row]
        
        switch type {
        case .tokenS:
            TradeDataManager.shared.changeTokenS(token)
        case .tokenB:
            TradeDataManager.shared.changeTokenB(token)
        }

        self.navigationController?.popViewController(animated: true)
    }
}

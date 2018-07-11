//
//  OrderNoDataTableViewCell.swift
//  loopr-ios
//
//  Created by xiaoruby on 5/11/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

class OrderNoDataTableViewCell: UITableViewCell {

    @IBOutlet weak var noDataLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        selectionStyle = .none
        
        noDataLabel.text = LocalizedString("No Data", comment: "")
        noDataLabel.textColor = UIColor.black
        noDataLabel.font = UIFont(name: FontConfigManager.shared.getLight(), size: 17.0*UIStyleConfig.scale)        
    }
    
    class func getCellIdentifier() -> String {
        return "OrderNoDataTableViewCell"
    }
    
    class func getHeight() -> CGFloat {
        return 45
    }
}

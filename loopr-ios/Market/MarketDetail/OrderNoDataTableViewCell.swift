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
        
        noDataLabel.text = NSLocalizedString("No Data", comment: "")
        noDataLabel.textColor = UIColor.black
        noDataLabel.font = UIFont(name: FontConfigManager.shared.getLight(), size: 17.0*UIStyleConfig.scale)        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    class func getCellIdentifier() -> String {
        return "OrderNoDataTableViewCell"
    }
    
    class func getHeight() -> CGFloat {
        return 45
    }
}

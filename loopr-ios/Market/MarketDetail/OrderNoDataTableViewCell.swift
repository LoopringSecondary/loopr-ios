//
//  OrderNoDataTableViewCell.swift
//  loopr-ios
//
//  Created by xiaoruby on 5/11/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

class OrderNoDataTableViewCell: UITableViewCell {

    @IBOutlet weak var noDataImageView: UIImageView!
    @IBOutlet weak var noDataLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        selectionStyle = .none
        self.backgroundColor = .clear
        noDataLabel.setTitleCharFont()
        noDataLabel.setSubTitleCharFont()
    }
    
    class func getCellIdentifier() -> String {
        return "OrderNoDataTableViewCell"
    }
    
    class func getHeight() -> CGFloat {
        return 450
    }
}

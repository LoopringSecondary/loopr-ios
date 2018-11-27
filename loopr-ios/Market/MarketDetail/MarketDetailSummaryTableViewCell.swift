//
//  MarketDetailSummaryTableViewCell.swift
//  loopr-ios
//
//  Created by Ruby on 11/27/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

class MarketDetailSummaryTableViewCell: UITableViewCell {

    @IBOutlet weak var baseView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        selectionStyle = .none
        theme_backgroundColor = ColorPicker.backgroundColor
        
        baseView.cornerRadius = 6
        baseView.theme_backgroundColor = ColorPicker.cardBackgroundColor

    }
    
    func setup() {
        
    }
    
    class func getCellIdentifier() -> String {
        return "MarketDetailSummaryTableViewCell"
    }
    
    class func getHeight() -> CGFloat {
        return 120
    }
}

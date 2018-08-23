//
//  SearchTokenNoDataTableViewCell.swift
//  loopr-ios
//
//  Created by xiaoruby on 8/20/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

class SearchTokenNoDataTableViewCell: UITableViewCell {

    @IBOutlet weak var noTokenInfoLabel: UILabel!
    @IBOutlet weak var addTokenButton: UIButton!
    
    var pressedAddTokenButtonClosure: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        selectionStyle = .none
        theme_backgroundColor = ColorPicker.backgroundColor
        
        noTokenInfoLabel.setTitleCharFont()
        noTokenInfoLabel.text = LocalizedString("No search result", comment: "")
        
        addTokenButton.theme_setTitleColor(GlobalPicker.textColor, forState: .normal)
        addTokenButton.titleLabel?.font = FontConfigManager.shared.getCharactorFont(size: 13)
        addTokenButton.title = LocalizedString("Add custom token", comment: "")
    }

    @IBAction func pressedAddTokenButton(_ sender: Any) {
        pressedAddTokenButtonClosure?()
    }
    
    class func getCellIdentifier() -> String {
        return "SearchTokenNoDataTableViewCell"
    }
    
    class func getHeight() -> CGFloat {
        return 100
    }

}

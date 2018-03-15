//
//  NumericKeyboardProtocol.swift
//  loopr-ios
//
//  Created by xiaoruby on 3/14/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import Foundation
import UIKit

protocol NumericKeyboardProtocol: class {
    
    func getActiveTextField() -> UITextField?
    func showKeyboard(textField: UITextField)
    func hideKeyboard()
    
}

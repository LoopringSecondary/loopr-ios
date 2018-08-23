//
//  ColorTheme.swift
//  loopr-ios
//
//  Created by xiaoruby on 8/20/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import Foundation

enum ColorTheme: Int {
    
    // TODO: We will have blue color configuration.
    case red = 0
    case yellow = 1

    // Only need to change this line of code
    static let current: ColorTheme = .yellow
    
    static func getTheme() -> String {
        switch current {
        case .red:
            return "-red"
        case .yellow:
            return "-yellow"
        }
    }

}

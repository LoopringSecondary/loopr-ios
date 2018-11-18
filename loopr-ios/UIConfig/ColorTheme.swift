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
    case green = 2
    case blue = 3

    // Only need to change this line of code
    static let current: ColorTheme = getCurrent()
    
    static func getCurrent() -> ColorTheme {
        switch Production.getCurrent() {
        case .upwallet:
            return .yellow
        case .vivwallet:
            return .green
        }
    }
    
    static func getTheme() -> String {
        switch current {
        case .red:
            return "-red"
        case .yellow:
            return "-yellow"
        case .green:
            return "-green"
        case .blue:
            return "-blue"
        }
    }
}

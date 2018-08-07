//
//  CityPartnerRole.swift
//  loopr-ios
//
//  Created by kenshin on 2018/8/7.
//  Copyright © 2018年 Loopring. All rights reserved.
//

import Foundation

enum CityPartnerRole: String, CustomStringConvertible {
    
    case partner = "Partner"
    case client = "Client"
    
    var description: String {
        switch self {
        case .partner: return "Partner"
        case .client: return "Client"
        }
    }
}

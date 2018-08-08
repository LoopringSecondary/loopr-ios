//
//  CityPartnerRole.swift
//  loopr-ios
//
//  Created by kenshin on 2018/8/7.
//  Copyright © 2018年 Loopring. All rights reserved.
//

import Foundation

enum CityPartnerRole: String, CustomStringConvertible {
    
    // city partner: one for one city
    case cityPartner = "Partner"
    // city client: many for one city
    case cityClient = "Client"
    // common user: as user as before
    case customer = "Customer"
    
    var description: String {
        switch self {
        case .cityPartner: return "Partner"
        case .cityClient: return "Client"
        case .customer: return "Customer"
        }
    }
}

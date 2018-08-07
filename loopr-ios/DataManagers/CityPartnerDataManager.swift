//
//  CityPartnerDataManager.swift
//  loopr-ios
//
//  Created by kenshin on 2018/8/7.
//  Copyright © 2018年 Loopring. All rights reserved.
//

import Foundation

class CityPartnerDataManager {
    
    static let shared = CityPartnerDataManager()
    
    func getClientRole() -> CityPartnerRole {
        return .client  // TODO: modify according users wallet addresses
    }
    
}

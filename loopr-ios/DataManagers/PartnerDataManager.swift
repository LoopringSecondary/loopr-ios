//
//  CityPartnerDataManager.swift
//  loopr-ios
//
//  Created by kenshin on 2018/8/7.
//  Copyright © 2018年 Loopring. All rights reserved.
//

import Foundation

class PartnerDataManager {

    static let shared = PartnerDataManager()
    
    var partner: String?
    var partnerAddress: String?
    let loopringAddress = "0xb94065482ad64d4c2b9252358d746b39e820a582"
    
    func activateInvitation() {
        LoopringAPIRequest.activateInvitation(completionHandler: { result, error in
            guard let result = result, error == nil else {
                return
            }
            self.partner = result["cityPartner"].stringValue
            self.partnerAddress = result["walletAddress"].stringValue
        })
    }
    
    func getWalletAddress() -> String {
        if let address = self.partnerAddress {
            return address == "" ? loopringAddress : address
        }
        return loopringAddress
    }
}

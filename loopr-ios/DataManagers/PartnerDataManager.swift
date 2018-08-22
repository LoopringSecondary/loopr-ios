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
    
    var partnerTo: Partner?
    var partnerFrom: Partner?
    let loopringAddress = "0x8E63Bb7Af326de3fc6e09F4c8D54A75c6e236abA"
    let baseUrl = "https://upwallet.io/"
    
    func activatePartner() {
        LoopringAPIRequest.activateInvitation(completionHandler: { result, error in
            guard let result = result, error == nil else {
                return
            }
            self.partnerFrom = result
        })
    }
    
    func createPartner() {
        guard let owner = CurrentAppWalletDataManager.shared.getCurrentAppWallet()?.address else { return }
        LoopringAPIRequest.createPartner(owner: owner) { (result, error) in
            guard let result = result, error == nil else {
                return
            }
            self.partnerTo = result
        }
    }
    
    func getWalletAddress() -> String {
        if let address = self.partnerFrom?.walletAddress {
            return address == "" ? loopringAddress : address
        }
        return loopringAddress
    }
    
    func generateUrl() -> String {
        if let partner = self.partnerTo {
            return "\(self.baseUrl)?cityPartner=\(partner.partner)"
        }
        return self.baseUrl
    }
}

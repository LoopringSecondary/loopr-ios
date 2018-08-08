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
    
    var invitationCode: String?
    var partnerAddress: String?
    var role: CityPartnerRole = .customer
    
    func getClientRole() -> CityPartnerRole {
        return self.role
    }
    
    func submitCode(code: String, handler: @escaping (_ error: Error?) -> Void) {
        LoopringAPIRequest.activateCustumerInvitation(activateCode: code, completionHandler: { result, error in
            guard let result = result, error == nil else {
                handler(error!)
                return
            }
            self.invitationCode = result["invitationCode"].stringValue
            self.partnerAddress = result["walletAddress"].stringValue
            self.updateClientRole()
            handler(nil)
        })
    }
    
    func updateClientRole() {
        let wallets = AppWalletDataManager.shared.getWallets()
        if wallets.contains(where: { (wallet) -> Bool in
            return wallet.address.lowercased() == self.partnerAddress?.lowercased()
        }) {
            self.role = .cityPartner
        } else {
            self.role = .cityClient
        }
    }
}

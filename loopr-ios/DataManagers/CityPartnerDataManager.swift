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
    
    func submitCode(code: String, handler: @escaping (_ error: Error?) -> Void) {
        LoopringAPIRequest.activateCustumerInvitation(activateCode: code, completionHandler: { result, error in
            guard let result = result, error == nil else {
                handler(error!)
                return
            }
            self.invitationCode = result["invitationCode"].stringValue
            self.partnerAddress = result["walletAddress"].stringValue
            handler(nil)
        })
    }
}

//
//  SocialMedia.swift
//  loopr-ios
//
//  Created by xiaoruby on 10/14/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import Foundation

class SocialMedia: CustomStringConvertible {
    
    var type: String
    var account: String
    var link: String
    var url: URL?
    var description: String
    
    init(type: String, account: String, link: String) {
        self.type = type
        self.account = account
        self.link = link
        self.url = URL(string: link)
        self.description = "\(self.type) \(self.account)"
    }

}

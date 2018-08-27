//
//  Language.swift
//  loopr-ios
//
//  Created by xiaoruby on 3/2/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import Foundation

class Language: Equatable {
    
    let name: String
    let displayName: String
    
    // This function will be called many times.
    init(name: String) {
        self.name = name
        if let displayName = Localizator.map[name] {
            self.displayName = displayName
        } else {
            self.displayName = "Undefined"
        }
    }

    static func == (lhs: Language, rhs: Language) -> Bool {
        return lhs.name == rhs.name
    }

}

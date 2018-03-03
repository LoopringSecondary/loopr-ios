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

    let map = [
        "en": "English",
        "zh-Hans": "简体中文"
    ]
    
    init(name: String) {
        self.name = name
        if let displayName = map[name] {
            self.displayName = displayName
        } else {
            self.displayName = "Undefined"
        }
    }

    static func == (lhs: Language, rhs: Language) -> Bool {
        return lhs.name == rhs.name
    }

}

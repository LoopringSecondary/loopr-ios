//
//  FoundationArray+Extension.swift
//  loopr-ios
//
//  Created by xiaoruby on 4/19/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import Foundation

func unique<S: Sequence, T: Hashable >(_ source: S) -> [T] where S.Iterator.Element == T {
    var buffer = [T]()
    var added = Set<T>()
    for elem in source {
        if !added.contains(elem) {
            buffer.append(elem)
            added.insert(elem)
        }
    }
    return buffer
}

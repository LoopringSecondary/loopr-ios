//
//  Bytes+SecureRandom.swift
//  Keystore
//
//  Created by xiaoruby on 8/24/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import Foundation

extension Array where Element == UInt8 {

    static func secureRandom(count: Int) -> [UInt8]? {
        var array = [UInt8](repeating: 0, count: count)

        let fd = open("/dev/urandom", O_RDONLY)
        guard fd != -1 else {
            return nil
        }
        defer {
            close(fd)
        }

        let ret = read(fd, &array, MemoryLayout<UInt8>.size * array.count)
        guard ret > 0 else {
            return nil
        }

        return array
    }
}

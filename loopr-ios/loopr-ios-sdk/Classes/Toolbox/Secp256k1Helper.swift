//
//  Secp256k1Helper.swift
//  Keystore
//
//  Created by xiaoruby on 8/24/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import Foundation
import secp256k1_ios
import CryptoSwift

struct Secp256k1Helper {

    static func address(for privateKey: [UInt8]) throws -> [UInt8] {
        if privateKey.count != 32 {
            return []
        }
        let ctx = try secp256k1_default_ctx_create(errorThrowable: Error.internalError)
        defer {
            secp256k1_default_ctx_destroy(ctx: ctx)
        }

        // Generate public key
        guard let pubKey = malloc(MemoryLayout<secp256k1_pubkey>.size)?.assumingMemoryBound(to: secp256k1_pubkey.self) else {
            throw Error.internalError
        }
        // Cleanup
        defer {
            free(pubKey)
        }

        var secret = privateKey
        if secp256k1_ec_pubkey_create(ctx, pubKey, &secret) != 1 {
            return []
        }

        var pubOut = [UInt8](repeating: 0, count: 65)
        var pubOutLen = 65
        _ = secp256k1_ec_pubkey_serialize(ctx, &pubOut, &pubOutLen, pubKey, UInt32(SECP256K1_EC_UNCOMPRESSED))
        guard pubOutLen == 65 else {
            return []
        }

        // First byte is header byte 0x04
        pubOut.remove(at: 0)

        // Generate ethereum address
        var hash = SHA3(variant: .keccak256).calculate(for: pubOut)
        guard hash.count == 32 else {
            throw Error.internalError
        }
        hash = Array(hash[12...])

        return hash
    }

    static func secp256k1_default_ctx_create(errorThrowable: Swift.Error) throws -> OpaquePointer {
        let c = secp256k1_context_create(UInt32(SECP256K1_CONTEXT_SIGN) | UInt32(SECP256K1_CONTEXT_VERIFY))
        guard let ctx = c else {
            throw errorThrowable
        }

        guard var rand = [UInt8].secureRandom(count: 32) else {
            throw errorThrowable
        }

        guard secp256k1_context_randomize(ctx, &rand) == 1 else {
            throw errorThrowable
        }

        return ctx
    }

    static func secp256k1_default_ctx_destroy(ctx: OpaquePointer) {
        secp256k1_context_destroy(ctx)
    }

    enum Error: Swift.Error {

        case internalError
    }
}

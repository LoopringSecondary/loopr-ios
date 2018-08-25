//
//  KeystoreFactory.swift
//  Keystore
//
//  Created by xiaoruby on 8/24/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import Foundation
import CryptoSwift

public struct KeystoreFactory {

    /// Extracts the private key from the given keystore
    ///
    /// - parameter keystore: The keystore.
    /// - parameter password: The password to use for the decryption.
    ///
    /// - returns: The extracted private key.
    ///
    /// - throws: Some `KeystoreFactory.Error` if any step fails.
    public static func privateKey(from keystore: NewKeystore, password: String) throws -> Array<UInt8> {
        let key = try deriveKey(password: password, kdf: keystore.crypto.kdf, kdfparams: keystore.crypto.kdfparams)

        guard key.count >= 32 else {
            throw Error.kdfFailed
        }

        let ivData = try keystore.crypto.cipherparams.iv.dataWithHexString()
        let ciphertextData = try keystore.crypto.ciphertext.dataWithHexString()
        let cipher = keystore.crypto.cipher

        var macContent = key[16..<32]
        macContent.append(ciphertextData)
        let mac = Data(SHA3(variant: .keccak256).calculate(for: [UInt8](macContent)))

        guard mac.hexString == keystore.crypto.mac else {
            throw Error.passwordWrong
        }

        let usableKey: Data
        if keystore.version == 1 {
            usableKey = Data(SHA3(variant: .keccak256).calculate(for: [UInt8](key[0..<16])))[0..<16]
        } else {
            usableKey = key[0..<16]
        }

        let splittedCipher = cipher.split(separator: "-")
        guard splittedCipher.count == 3, splittedCipher[0] == "aes", splittedCipher[1] == "128" else {
            throw Error.cipherNotAvailable
        }
        guard let blockmode = IVBlockModeType(rawValue: splittedCipher[2].lowercased())?.blockMode(iv: [UInt8](ivData)) else {
            throw Error.cipherNotAvailable
        }

        let aes = try AES(key: [UInt8](usableKey), blockMode: blockmode, padding: .pkcs7)

        return try aes.decrypt([UInt8](ciphertextData))
    }

    /// Creates a keystore for the given privateKey with the given password.
    ///
    /// - parameter privateKey: The privateKey to encrypt into the keystore.
    /// - parameter password: The password to use for the encryption.
    /// - parameter kdf: The key derivation function to use. Defaults to `scrypt`.
    /// - parameter cipher: The cipher to use for the encryption. Defaults to `ctr`.
    ///
    /// - returns: The created instance of `Keystore`.
    ///
    /// - throws: Some `KeystoreFactory.Error` if any step fails.
    public static func keystore(from privateKey: [UInt8], password: String, kdf: NewKeystore.Crypto.KDFType = .scrypt, cipher: IVBlockModeType = .ctr) throws -> NewKeystore {
        guard let iv = [UInt8].secureRandom(count: 16), let salt = [UInt8].secureRandom(count: 32) else {
            throw Error.bytesGenerationFailed
        }

        let kdfparams: NewKeystore.Crypto.KDFParams
        switch kdf {
        case .scrypt:
            kdfparams = NewKeystore.Crypto.KDFParams(salt: Data(salt).hexString, dklen: 32, n: 8192, r: 8, p: 1)
        case .pbkdf2:
            kdfparams = NewKeystore.Crypto.KDFParams(salt: Data(salt).hexString, dklen: 32, prf: "hmac-sha256", c: 8192)
        }

        let key = try deriveKey(password: password, kdf: kdf, kdfparams: kdfparams)
        guard key.count >= 32 else {
            throw Error.kdfFailed
        }
        let usableKey = key[0..<16]

        let blockMode = cipher.blockMode(iv: iv)
        let aes = try AES(key: [UInt8](usableKey), blockMode: blockMode, padding: .pkcs7)

        let ciphertextData = try Data(aes.encrypt(privateKey))
        let ciphertext = ciphertextData.hexString

        var macContent = key[16..<32]
        macContent.append(ciphertextData)
        let mac = Data(SHA3(variant: .keccak256).calculate(for: [UInt8](macContent)))

        let cipherparams = NewKeystore.Crypto.Cipherparams(iv: Data(iv).hexString)
        let crypto = NewKeystore.Crypto(ciphertext: ciphertext, cipherparams: cipherparams, cipher: "aes-128-\(cipher.rawValue)", kdf: kdf, kdfparams: kdfparams, mac: Data(mac).hexString)

        let address = try Secp256k1Helper.address(for: privateKey)
        guard address.count == 20 else {
            throw Error.privateKeyMalformed
        }

        return NewKeystore(version: 3, id: UUID().uuidString.lowercased(), address: Data(address).hexString, crypto: crypto)
    }

    private static func deriveKey(password: String, kdf: NewKeystore.Crypto.KDFType, kdfparams: NewKeystore.Crypto.KDFParams) throws -> Data {
        guard let passwordData = password.data(using: .utf8) else {
            throw Error.passwordMalformed
        }
        let saltData = try kdfparams.salt.dataWithHexString()

        if kdf == .scrypt {
            guard let n = kdfparams.n, let r = kdfparams.r, let p = kdfparams.p else {
                throw Error.kdfInputsMalformed
            }

            let params = try ScryptParams(salt: saltData, n: n, r: r, p: p, desiredKeyLength: kdfparams.dklen)
            return try Scrypt(params: params).calculate(password: password)
        }

        // PBKDF2
        guard kdf == .pbkdf2 && kdfparams.prf == "hmac-sha256" else {
            throw Error.kdfInputsMalformed
        }
        guard let c = kdfparams.c, c > 0 else {
            throw Error.kdfInputsMalformed
        }

        return try Data(bytes: PKCS5.PBKDF2(password: [UInt8](passwordData), salt: [UInt8](saltData), iterations: c, keyLength: kdfparams.dklen, variant: .sha256).calculate())
    }

    public enum Error: Swift.Error {

        /// The password can't be represented as utf8 data
        case passwordMalformed

        /// The keystore contains values which are not acceptable or misses some values which are needed
        case keystoreMalformed

        /// The kdf values in the keystore are missing values/are not available
        case kdfInputsMalformed

        /// The kdf failed at any point
        case kdfFailed

        /// The password is wrong/mac verification failed
        case passwordWrong

        /// The given cipher is not available
        case cipherNotAvailable

        /// Generating random bytes failed
        case bytesGenerationFailed

        /// The given private key is not a valid secp256k1 private key
        case privateKeyMalformed
    }
}

public enum IVBlockModeType: String {

    case cbc
    case cfb
    case ctr
    case ofb
    case pcbc

    public func blockMode(iv: [UInt8]) -> BlockMode {
        switch self {
        case .cbc:
            return BlockMode.CBC(iv: iv)
        case .cfb:
            return BlockMode.CFB(iv: iv)
        case .ctr:
            return BlockMode.CTR(iv: iv)
        case .ofb:
            return BlockMode.OFB(iv: iv)
        case .pcbc:
            return BlockMode.OFB(iv: iv)
        }
    }
}

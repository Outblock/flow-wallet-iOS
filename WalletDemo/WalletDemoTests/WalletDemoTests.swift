//
//  WalletDemoTests.swift
//  WalletDemoTests
//
//  Created by Hao Fu on 9/12/21.
//

import XCTest
@testable import WalletDemo
import WalletCore
import CryptoKit
import Flow

class WalletDemoTests: XCTestCase {

    let mnemonic = "normal dune pole key case cradle unfold require tornado mercy hospital buyer"
    
    // Why it's this path? Check here
    // https://github.com/satoshilabs/slips/blob/master/slip-0044.md
    let derivationPath = "m/44'/539'/0'/0/0"
    
    func testHDWallet() {
        let wallet = HDWallet(mnemonic: mnemonic, passphrase: "")!
        XCTAssertTrue(Mnemonic.isValid(mnemonic: wallet.mnemonic))
    }

    // MARK: - P256 Test
    func testP256_SHA256() {
        let wallet = HDWallet(mnemonic: mnemonic, passphrase: "")!
        let privateKey = wallet.getCurveKey(curve: .nist256p1, derivationPath: derivationPath)
        let publickKey = privateKey.getPublicKeyNist256p1().uncompressed
        
        // Test Private key and public key
        XCTAssertTrue(PrivateKey.isValid(data: privateKey.data, curve: .nist256p1))
        XCTAssertEqual("638dc9ad0eee91d09249f0fd7c5323a11600e20d5b9105b66b782a96236e74cf", privateKey.data.hexValue)
        
        // Important!!! wallet core using x963 format for public key
        // which will have `04` prefix, we need drop prefix to 128 length hex string
        XCTAssertEqual("04dbe5b4b4416ad9158339dd692002ceddab895e11bd87d90ce7e3e745efef28d2ad6e736fe3d57d52213f397a7ba9f0bc8c65620a872aefedbc1ddd74c605cf58", publickKey.data.hexValue)
        
        let unsignData = "hello schnorr".data(using: .utf8)!
        
        // Use SHA256 here
        let hashedData = Hash.sha256(data: unsignData)
        let signedData = privateKey.sign(digest: hashedData, curve: .nist256p1)
        
        // Important!!! wallet core use (32 + 32 + 1) which is ( r + s + v)
        // However, flow verify signature using (r + s), hence we need drop v
        let formatSignature = signedData!.dropLast()
        XCTAssertTrue(publickKey.verify(signature: formatSignature, message: hashedData))
        
        // Cross validation for private and public key
        let privateKey_CK = try! P256.Signing.PrivateKey(rawRepresentation: privateKey.data)
        let publicKey_CK = privateKey_CK.publicKey
        
        XCTAssertEqual("dbe5b4b4416ad9158339dd692002ceddab895e11bd87d90ce7e3e745efef28d2ad6e736fe3d57d52213f397a7ba9f0bc8c65620a872aefedbc1ddd74c605cf58", publicKey_CK.rawRepresentation.hexValue)
        
        XCTAssertEqual("04dbe5b4b4416ad9158339dd692002ceddab895e11bd87d90ce7e3e745efef28d2ad6e736fe3d57d52213f397a7ba9f0bc8c65620a872aefedbc1ddd74c605cf58", publicKey_CK.x963Representation.hexValue)
        
        // Cross validation for signature
        let ECDSASignature = try! P256.Signing.ECDSASignature(rawRepresentation: formatSignature)
        XCTAssertTrue(privateKey_CK.publicKey.isValidSignature(ECDSASignature, for: unsignData))
    }
    
    func testP256_SHA3_256() {
        let wallet = HDWallet(mnemonic: mnemonic, passphrase: "")!
        let privateKey = wallet.getCurveKey(curve: .nist256p1, derivationPath: derivationPath)
        let publickKey = privateKey.getPublicKeyNist256p1().uncompressed
        
        // Test Private key and public key
        XCTAssertTrue(PrivateKey.isValid(data: privateKey.data, curve: .nist256p1))
        XCTAssertEqual("638dc9ad0eee91d09249f0fd7c5323a11600e20d5b9105b66b782a96236e74cf", privateKey.data.hexValue)
        
        // Important!!! wallet core using x963 format for public key
        // which will have `04` prefix, we need drop prefix to 128 length hex string
        XCTAssertEqual("04dbe5b4b4416ad9158339dd692002ceddab895e11bd87d90ce7e3e745efef28d2ad6e736fe3d57d52213f397a7ba9f0bc8c65620a872aefedbc1ddd74c605cf58", publickKey.data.hexValue)
        
        let unsignData = "hello schnorr".data(using: .utf8)!
        
        // Use SHA3_256 here
        let hashedData = Hash.sha3_256(data: unsignData)
        let signedData = privateKey.sign(digest: hashedData, curve: .nist256p1)
        
        // Important!!! wallet core use (32 + 32 + 1) which is ( r + s + v)
        // However, flow verify signature using (r + s), hence we need drop v
        let formatSignature = signedData!.dropLast()
        XCTAssertTrue(publickKey.verify(signature: formatSignature, message: hashedData))
    }
    
    // MARK: - Secp256k1 Test
    func testSecp256k1_SHA256() {
        let wallet = HDWallet(mnemonic: mnemonic, passphrase: "")!
        let privateKey = wallet.getCurveKey(curve: .secp256k1, derivationPath: derivationPath)
        let publickKey = privateKey.getPublicKeySecp256k1(compressed: false)
        
        // Test Private key and public key
        XCTAssertTrue(PrivateKey.isValid(data: privateKey.data, curve: .nist256p1))
        XCTAssertEqual("9c33a65806715a537d7f67cf7bf8a020cbdac8a1019664a2fa34da42d1ddbc7d", privateKey.data.hexValue)
        
        // Important!!! wallet core using x963 format for public key
        // which will have `04` prefix, we need drop prefix to 128 length hex string
        XCTAssertEqual("04ad94008dea1505863fc92bd2db5b9fbf52a57f2a05d34fedb693c714bdc731cca57be95775517a9df788a564f2d7491d2c9716d1c0411a5a64155895749d47bc", publickKey.data.hexValue)
        
        let unsignData = "hello schnorr".data(using: .utf8)!
        let hashedData = Hash.sha256(data: unsignData)
        let signedData = privateKey.sign(digest: hashedData, curve: .secp256k1)
        
        // Important!!! wallet core use (32 + 32 + 1) which is ( r + s + v)
        // However, flow verify signature using (r + s), hence we need drop v
        let formatSignature = signedData!.dropLast()
        XCTAssertTrue(publickKey.verify(signature: formatSignature, message: hashedData))
    }
    
    func testSecp256k1_SHA3_256() {
        let wallet = HDWallet(mnemonic: mnemonic, passphrase: "")!
        let privateKey = wallet.getCurveKey(curve: .secp256k1, derivationPath: derivationPath)
        let publickKey = privateKey.getPublicKeySecp256k1(compressed: false)
        
        // Test Private key and public key
        XCTAssertTrue(PrivateKey.isValid(data: privateKey.data, curve: .nist256p1))
        XCTAssertEqual("9c33a65806715a537d7f67cf7bf8a020cbdac8a1019664a2fa34da42d1ddbc7d", privateKey.data.hexValue)
        
        // Important!!! wallet core using x963 format for public key
        // which will have `04` prefix, we need drop prefix to 128 length hex string
        XCTAssertEqual("04ad94008dea1505863fc92bd2db5b9fbf52a57f2a05d34fedb693c714bdc731cca57be95775517a9df788a564f2d7491d2c9716d1c0411a5a64155895749d47bc", publickKey.data.hexValue)
        
        let unsignData = "hello schnorr".data(using: .utf8)!
        let hashedData = Hash.sha3_256(data: unsignData)
        let signedData = privateKey.sign(digest: hashedData, curve: .secp256k1)
        
        // Important!!! wallet core use (32 + 32 + 1) which is ( r + s + v)
        // However, flow verify signature using (r + s), hence we need drop v
        let formatSignature = signedData!.dropLast()
        XCTAssertTrue(publickKey.verify(signature: formatSignature, message: hashedData))
    }

}

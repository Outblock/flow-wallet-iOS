//
//  WalletTestnetTest.swift
//  WalletDemoTests
//
//  Created by Hao Fu on 9/12/21.
//

import XCTest
@testable import WalletDemo
import WalletCore
import CryptoKit
import Flow

class WalletTestnetTests: XCTestCase {
    
    let mnemonic = "normal dune pole key case cradle unfold require tornado mercy hospital buyer"
    // Why it's this path? Check here
    // https://github.com/satoshilabs/slips/blob/master/slip-0044.md
    let derivationPath = "m/44'/539'/0'/0/0"
    
    // Testnet address with 4 different type of key
    // Key 1 --> ECDSA_SECP256k1 - SHA3_256
    // Key 2 --> ECDSA_P256 - SHA2_256
    // Key 3 --> ECDSA_P256 - SHA3_256
    // Key 4 --> ECDSA_SECP256k1 - SHA2_256
    let address = Flow.Address(hex: "0x4f05d22690e07938")
    
//    let tx = try! flow.sendTransaction(chainID: .testnet, signer: []) {
//
//    }
    var wallet: HDWallet!
    var privateKey: PrivateKey!
    var P256PrivateKey: PrivateKey!
    
    override func setUp() {
        super.setUp()
        flow.configure(chainID: .testnet)
        wallet = HDWallet(mnemonic: mnemonic, passphrase: "")
        privateKey = wallet.getCurveKey(curve: .secp256k1, derivationPath: derivationPath)
        P256PrivateKey = wallet.getCurveKey(curve: .nist256p1, derivationPath: derivationPath)
    }
    
    func testSecp256k1_SHA256() {
        let signer = WalletCoreSigner(address: address,
                                      keyIndex: 3,
                                      hashAlgo: .SHA2_256,
                                      signatureAlgo: .ECDSA_SECP256k1,
                                      privateKey: privateKey)
        sendSimpleTransaction(signers: [signer])
    }
    
    func testSecp256k1_SHA3_256() {
        let signer = WalletCoreSigner(address: address,
                                      keyIndex: 0,
                                      hashAlgo: .SHA3_256,
                                      signatureAlgo: .ECDSA_SECP256k1,
                                      privateKey: privateKey)
        sendSimpleTransaction(signers: [signer])
    }

    
    func testP256_SHA256() {
        let signer = WalletCoreSigner(address: address,
                                      keyIndex: 1,
                                      hashAlgo: .SHA2_256,
                                      signatureAlgo: .ECDSA_P256,
                                      privateKey: P256PrivateKey)
        sendSimpleTransaction(signers: [signer])
    }
    
    func testP256_SHA3_256() {
        let signer = WalletCoreSigner(address: address,
                                      keyIndex: 2,
                                      hashAlgo: .SHA3_256,
                                      signatureAlgo: .ECDSA_P256,
                                      privateKey: P256PrivateKey)
        sendSimpleTransaction(signers: [signer])
    }
    
    func sendSimpleTransaction(signers: [FlowSigner]) {
        let txId = try! flow.sendTransaction(chainID: .testnet, signers: signers) {
            cadence {
                """
                transaction {
                  execute {
                    log("A transaction happened")
                  }
                }
                """
            }
            
            proposer {
                Flow.TransactionProposalKey(address: address,
                                            keyIndex: signers.first!.keyIndex,
                                            sequenceNumber: -1)
            }

            gasLimit {
                1000
            }
        }.wait()
        
        print("txId --> \(txId.hex)")
        _ = try! txId.onceSealed().wait()
    }
    
    
    // MARK: - Util
    
    func testAddKey() {
        let P256PublicKey = P256PrivateKey.getPublicKeyNist256p1().uncompressed.data.hexValue.dropFirst(2)
        print("P256PublicKey --> \(P256PublicKey)")
        let secondKey = Flow.AccountKey(publicKey: .init(hex: String(P256PublicKey)),
                                       signAlgo: .ECDSA_P256,
                                        hashAlgo: .SHA2_256,
                                        weight: 1000)
        
        let thirdKey = Flow.AccountKey(publicKey: .init(hex: String(P256PublicKey)),
                                       signAlgo: .ECDSA_P256,
                                        hashAlgo: .SHA3_256,
                                        weight: 1000)
        
        let publicKey_secp256k1 = privateKey.getPublicKeySecp256k1(compressed: false).data.hexValue.dropFirst(2)
        print("secp256k1 PublicKey --> \(publicKey_secp256k1)")
        let forthKey = Flow.AccountKey(publicKey: .init(hex: String(publicKey_secp256k1)),
                                        signAlgo: .ECDSA_SECP256k1,
                                        hashAlgo: .SHA2_256,
                                        weight: 1000)
        
        addKeyToAddress(accountKey: forthKey)
        
    }
    
    func addKeyToAddress(accountKey: Flow.AccountKey) {
        let signer = WalletCoreSigner(address: address, keyIndex: 0, hashAlgo: .SHA3_256,
                                       signatureAlgo: .ECDSA_SECP256k1, privateKey: privateKey)
        let txId = try! flow.addKeyToAccount(address: address, accountKey: accountKey, signers: [signer]).wait()
        print("txId --> \(txId.hex)")
        _ = try! txId.onceSealed().wait()
    }
    
}

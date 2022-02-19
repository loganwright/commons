import Foundation
import CommonCrypto

private let appKeyIdentifier: String = {
    if IS_TESTING { return "testing.app.key.identifier" }
    else { return "app.key.identifier" }

}()

public final class KeyChain {

    public static let shared: KeyChain = .init()

    private(set) lazy var appKey: Data = try! loadAppKey()

    private init() {
        /// force load
        _ = appKey
    }

    /// an app key is used to encrypt the user's data locally, it should be generated a single time and stored in the key chain for security
    private func loadAppKey() throws -> Data {
        let existing = try item(kSecClass: kSecClassKey, identifier: appKeyIdentifier)
        if let existing = existing { return existing }

        let uuid = UUID().uuidString
        let passKey = Data(uuid.utf8)
        try insert(kSecClass: kSecClassKey, identifier: appKeyIdentifier, data: passKey)
        return passKey
    }

    public subscript(key: String) -> String? {
        get {
            guard let data = try? item(kSecClass: kSecClassKey, identifier: key) else {
                return nil
            }
            return String(data: data, encoding: .utf8)
        }
        set {
            guard let value = newValue else {
                try? remove(kSecClass: kSecClassKey, identifier: key)
                return
            }
            do {
                guard let data = value.data(using: .utf8, allowLossyConversion: false) else {
                    throw "failed to convert string to data"
                }
                try insert(kSecClass: kSecClassKey, identifier: key, data: data)
            } catch {
                Log.error(error)
            }
        }
    }

    public func deleteAll() throws {
        let secItemClasses =  [
            kSecClassGenericPassword,
            kSecClassInternetPassword,
            kSecClassCertificate,
            kSecClassKey,
            kSecClassIdentity,
        ]
        let statusCodes = secItemClasses.map { [kSecClass: $0] as CFDictionary } .map(SecItemDelete)
        let err = statusCodes.filter { ![errSecSuccess, errSecItemNotFound].contains($0) }
        guard err.isEmpty else { throw "keychain delete failed \(statusCodes.map(String.init).joined(separator: "."))" }
    }

    public func _fatal_reset() throws {
        do { try deleteAll() } catch { Log.error(error) }
        do { try remove(kSecClass: kSecClassKey, identifier: appKeyIdentifier) } catch { Log.error(error) }
        do { appKey = try loadAppKey() } catch { Log.error(error) }
    }

    private func item(kSecClass secClass: CFString, identifier: String) throws -> Data? {
        var item: CFTypeRef?
        let query: [String: Any] = [
            kSecClass as String: secClass,
            kSecAttrType as String: identifier,
            kSecAttrSynchronizable as String: kSecAttrSynchronizableAny,
            kSecReturnAttributes as String: true,
            kSecReturnData as String: true,
        ]
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status != errSecItemNotFound else { return nil }
        guard status == errSecSuccess else { throw "unable to access keychain \(status)" }
        let dict = item as? [String: Any]
        return dict?[kSecValueData as String] as? Data
    }

    private func remove(kSecClass secClass: CFString, identifier: String) throws {
        let query: [String: Any] = [
            kSecClass as String: secClass,
            kSecAttrType as String: identifier,
            kSecAttrSynchronizable as String: kSecAttrSynchronizableAny,
        ]
        let status = SecItemDelete(query as CFDictionary)
        if status == errSecItemNotFound { return }
        guard status == errSecSuccess else { throw "keychain delete failed \(status) - \(secClass) - \(identifier)" }
    }

    private func insert(kSecClass secClass: CFString, identifier: String, data: Data) throws {
        let query: [String: Any] = [
            kSecClass as String: secClass,
            kSecAttrType as String: identifier,
            kSecAttrSynchronizable as String: true,
            kSecValueData as String: data,
        ]
        var status = SecItemCopyMatching(query as CFDictionary, nil)
        switch status {
        case errSecSuccess, errSecInteractionNotAllowed:
            let attributes = [kSecValueData as String: data]
            status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
        case errSecItemNotFound:
            status = SecItemAdd(query as CFDictionary, nil)
        default:
            break
        }
        guard status == errSecSuccess else { throw "unhandled keychain error: \(status)" }
    }
}

extension OSStatus {
    var readable: String {
        switch self {
        case errSecSuccess: return "errSec: Success"
        case errSecUnimplemented: return "errSec: Unimplemented"
        case errSecDiskFull: return "errSecDisk: Full"
        case errSecIO: return "errSec: IO"
        case errSecParam: return "errSec: Param"
        case errSecWrPerm: return "errSecWr: Perm"
        case errSecAllocate: return "errSec: Allocate"
        case errSecUserCanceled: return "errSecUser: Canceled"
        case errSecBadReq: return "errSecBad: Req"
        case errSecInternalComponent: return "errSecInternal: Component"
        case errSecCoreFoundationUnknown: return "errSecCoreFoundation: Unknown"
        case errSecNotAvailable: return "errSecNot: Available"
        case errSecReadOnly: return "errSecRead: Only"
        case errSecAuthFailed: return "errSecAuth: Failed"
        case errSecNoSuchKeychain: return "errSecNoSuch: Keychain"
        case errSecInvalidKeychain: return "errSecInvalid: Keychain"
        case errSecDuplicateKeychain: return "errSecDuplicate: Keychain"
        case errSecDuplicateCallback: return "errSecDuplicate: Callback"
        case errSecInvalidCallback: return "errSecInvalid: Callback"
        case errSecDuplicateItem: return "errSecDuplicate: Item"
        case errSecItemNotFound: return "errSecItemNot: Found"
        case errSecBufferTooSmall: return "errSecBufferToo: Small"
        case errSecDataTooLarge: return "errSecDataToo: Large"
        case errSecNoSuchAttr: return "errSecNoSuch: Attr"
        case errSecInvalidItemRef: return "errSecInvalidItem: Ref"
        case errSecInvalidSearchRef: return "errSecInvalidSearch: Ref"
        case errSecNoSuchClass: return "errSecNoSuch: Class"
        case errSecNoDefaultKeychain: return "errSecNoDefault: Keychain"
        case errSecInteractionNotAllowed: return "errSecInteractionNot: Allowed"
        case errSecReadOnlyAttr: return "errSecReadOnly: Attr"
        case errSecWrongSecVersion: return "errSecWrongSec: Version"
        case errSecKeySizeNotAllowed: return "errSecKeySizeNot: Allowed"
        case errSecNoStorageModule: return "errSecNoStorage: Module"
        case errSecNoCertificateModule: return "errSecNoCertificate: Module"
        case errSecNoPolicyModule: return "errSecNoPolicy: Module"
        case errSecInteractionRequired: return "errSecInteraction: Required"
        case errSecDataNotAvailable: return "errSecDataNot: Available"
        case errSecDataNotModifiable: return "errSecDataNot: Modifiable"
        case errSecCreateChainFailed: return "errSecCreateChain: Failed"
        case errSecACLNotSimple: return "errSecACLNot: Simple"
        case errSecPolicyNotFound: return "errSecPolicyNot: Found"
        case errSecInvalidTrustSetting: return "errSecInvalidTrust: Setting"
        case errSecNoAccessForItem: return "errSecNoAccessFor: Item"
        case errSecInvalidOwnerEdit: return "errSecInvalidOwner: Edit"
        case errSecTrustNotAvailable: return "errSecTrustNot: Available"
        case errSecUnsupportedFormat: return "errSecUnsupported: Format"
        case errSecUnknownFormat: return "errSecUnknown: Format"
        case errSecKeyIsSensitive: return "errSecKeyIs: Sensitive"
        case errSecMultiplePrivKeys: return "errSecMultiplePriv: Keys"
        case errSecPassphraseRequired: return "errSecPassphrase: Required"
        case errSecInvalidPasswordRef: return "errSecInvalidPassword: Ref"
        case errSecInvalidTrustSettings: return "errSecInvalidTrust: Settings"
        case errSecNoTrustSettings: return "errSecNoTrust: Settings"
        case errSecPkcs12VerifyFailure: return "errSecPkcs12Verify: Failure"
        case errSecDecode: return "errSec: Decode"
        case -34018: return "errSec: Something weird with tests/hosts, gl."
        default:
            return "unknown err sec code: \(self)"
        }
    }
}

// MARK: Hasher

public struct GeneralCryptor {
    public static let shared: GeneralCryptor = .init()

    private struct Item: Codable {
        let data: Data
        let iv: Data
        let salt: Data
    }

    private let appKey: Data

    private init() {
        appKey = KeyChain.shared.appKey
    }

    public func encrypt(_ data: Data) throws -> Data {
        let iv = AES256.randomIv()
        let salt = AES256.randomSalt()
        let key = try AES256.createKey(password: appKey, salt: salt)
        let aes = try AES256(key: key, iv: iv)
        let encrypted = try aes.encrypt(data)
        let package = Item(data: encrypted, iv: iv, salt: salt)
        return try package.encode()
    }

    public func decrypt(_ data: Data) throws -> Data {
        let item = try JSONDecoder().decode(Item.self, from: data)
        let key = try AES256.createKey(password: appKey, salt: item.salt)
        let aes = try AES256(key: key, iv: item.iv)
        let decrypted = try aes.decrypt(item.data)
        return decrypted
    }
}

extension FileManager {
    public var userDomain: URL {
        return FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)
            .first!
    }
}

public struct Files {
    public let dir: URL
    public let encrypted: Bool

    public init(folder: String, encrypted: Bool) {
        let url = FileManager.default
            .userDomain
            .appendingPathComponent(folder, isDirectory: true)
        self.dir = url
        self.encrypted = encrypted

        try! createDirectory()
    }

    private func createDirectory() throws {
        try! FileManager.default.createDirectory(
            at: dir,
            withIntermediateDirectories: true,
            attributes: nil)
    }

    public func write<E: Encodable>(filename: String, _ ob: E, pretty: Bool = false) throws {
        var data = try ob.encode(pretty: pretty)
        if encrypted {
            data = try GeneralCryptor.shared.encrypt(data)
        }
        let fileurl = dir.appendingPathComponent(filename, isDirectory: false)
        try data.write(to: fileurl)
    }

    public func read<D: Decodable>(filename: String, as: D.Type = D.self) throws -> D? {
        guard var data = try _unsafe_read(filename: filename) else { return nil }
        if encrypted {
            data = try GeneralCryptor.shared.decrypt(data)
        }
        return try D.decode(data)
    }

    public func _unsafe_read(filename: String) throws -> Data? {
        let fileurl = dir.appendingPathComponent(filename, isDirectory: false)
        guard fileurl.itemExists else { return nil }
        return try Data(contentsOf: fileurl)
    }

    public func delete(filename: String) throws {
        let fileurl = dir.appendingPathComponent(filename, isDirectory: false)
        guard fileurl.itemExists else { return }
        try FileManager.default.removeItem(at: fileurl)
    }

    public func deleteAll() throws {
        try FileManager.default.removeItem(at: dir)
        try createDirectory()
    }


    public func readAll<D: Decodable>(as: D.Type = D.self) throws -> [D] {
        try allFiles().compactMap { file in
            let loaded = try read(filename: file, as: D.self)
            if loaded == nil {
                Log.warn("\(self) failed to read \(file) as \(D.self)")
            }
            return loaded
        }
    }

    public func allFiles() throws -> [String] {
        try FileManager.default.contentsOfDirectory(atPath: dir.path)
    }

    public func allFiles(createdBefore: Date) throws -> [String] {
        let contents = try FileManager.default.contentsOfDirectory(
            at: dir,
            includingPropertiesForKeys: [.creationDateKey],
            options: [])

        return try contents.compactMap { content in
            guard let creation = try content.resourceValues(forKeys: [.creationDateKey]).creationDate else {
                throw "missing creation for: \(content)"
            }

            guard creation < createdBefore else { return nil }
            return content.lastPathComponent
        }
    }

    public func allFiles(createdAfter: Date) throws -> [String] {
        let contents = try FileManager.default.contentsOfDirectory(
            at: dir,
            includingPropertiesForKeys: [.creationDateKey],
            options: [])

        return try contents.compactMap { content in
            guard let creation = try content.resourceValues(forKeys: [.creationDateKey]).creationDate else {
                throw "missing creation for: \(content)"
            }

            guard creation > createdAfter else { return nil }
            return content.lastPathComponent
        }
    }
}

extension URL {
    public var itemExists: Bool {
        FileManager.default.fileExists(atPath: path)
    }
}

// AES FOUND HERE
// https://gist.github.com/hfossli/7165dc023a10046e2322b0ce74c596f8

import Foundation
import CommonCrypto

struct AES256 {
    private var key: Data
    private var iv: Data

    public init(key: Data, iv: Data) throws {
        guard key.count == kCCKeySizeAES256 else {
            throw Error.badKeyLength
        }
        guard iv.count == kCCBlockSizeAES128 else {
            throw Error.badInputVectorLength
        }
        self.key = key
        self.iv = iv
    }

    enum Error: Swift.Error {
        case keyGeneration(status: Int)
        case cryptoFailed(status: CCCryptorStatus)
        case badKeyLength
        case badInputVectorLength
    }

    func encrypt(_ digest: Data) throws -> Data {
        return try crypt(input: digest, operation: CCOperation(kCCEncrypt))
    }

    func decrypt(_ encrypted: Data) throws -> Data {
        return try crypt(input: encrypted, operation: CCOperation(kCCDecrypt))
    }

    private func crypt(input: Data, operation: CCOperation) throws -> Data {
        var outLength = Int(0)
        var outBytes = [UInt8](repeating: 0, count: input.count + kCCBlockSizeAES128)
        var status: CCCryptorStatus = CCCryptorStatus(kCCSuccess)

        input.withUnsafeBytes { encryptedBytes in
            iv.withUnsafeBytes { ivBytes in
                key.withUnsafeBytes { keyBytes in
                    status = CCCrypt(operation,
                                     CCAlgorithm(kCCAlgorithmAES128),            // algorithm
                                     CCOptions(kCCOptionPKCS7Padding),           // options
                                     keyBytes,                                   // key
                                     key.count,                                  // keylength
                                     ivBytes,                                    // iv
                                     encryptedBytes,                             // dataIn
                                     input.count,                                // dataInLength
                                     &outBytes,                                  // dataOut
                                     outBytes.count,                             // dataOutAvailable
                                     &outLength)                                 // dataOutMoved
                }
            }
        }
        guard status == kCCSuccess else {
            throw Error.cryptoFailed(status: status)
        }
        return Data(bytes: outBytes, count: outLength)
    }

    static func createKey(password: Data, salt: Data) throws -> Data {
        let length = kCCKeySizeAES256
        var status = Int32(0)
        var derivedBytes = [UInt8](repeating: 0, count: length)
        password.withUnsafeBytes { passwordBytes in
            salt.withUnsafeBytes { saltBytes in
                status = CCKeyDerivationPBKDF(CCPBKDFAlgorithm(kCCPBKDF2),                  // algorithm
                                              passwordBytes,                                // password
                                              password.count,                               // passwordLen
                                              saltBytes,                                    // salt
                                              salt.count,                                   // saltLen
                                              CCPseudoRandomAlgorithm(kCCPRFHmacAlgSHA1),   // prf
                                              10000,                                        // rounds
                                              &derivedBytes,                                // derivedKey
                                              length)                                       // derivedKeyLen
            }
        }
        guard status == 0 else {
            throw Error.keyGeneration(status: Int(status))
        }
        return Data(bytes: derivedBytes, count: length)
    }

    static func randomIv() -> Data {
        return randomData(length: kCCBlockSizeAES128)
    }

    static func randomSalt() -> Data {
        return randomData(length: 8)
    }

    static func randomData(length: Int) -> Data {
        var data = Data(count: length)
        let status = data.withUnsafeMutableBytes { mutableBytes in
            SecRandomCopyBytes(kSecRandomDefault, length, mutableBytes)
        }
        assert(status == Int32(0))
        return data
    }
}

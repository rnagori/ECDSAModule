
import Foundation
import JavaScriptCore

class PtoyClient {
	private enum PtoyClientError: Error {
		case invalidFilePath
		case invalidFileContent
		case bundleNotFound
		case methodNotFound
	}

	private let JS_FILE_NAME = "bundle"
	private let JS_FILE_EXTENSION = "js"
	private let JS_CALLBACK = "response"
	private let BUNDLE_NAME = "sdk"
	private let MODULE_NAME_CRYPTO = "crypto"
	private let FUNC_GEN_MNEMONIC = "generateMnemonic"
	private let FUNC_GEN_RSA = "generateKeypairRSA"
	private let FUNC_GEN_ECDSA = "generateKeypairECDSA"
	private let FUNC_ENC_AES = "encryptAES"
	private let FUNC_DEC_AES = "decryptAES"
	private let FUNC_ENC_DATA = "encryptData"
	private let FUNC_DEC_DATA = "decryptData"

	private var jsContext: JSContext!
	private var jsSDK: JSValue!
	private var jsCrypto: JSValue!

	init?() {
		self.jsContext = JSContext()
		self.jsContext.exceptionHandler = self.exceptionHandler

		do {
			try self.initJsContext()
		} catch PtoyClientError.invalidFilePath {
			print("PtoyClient Error: Javascript source file is not found.")
			return nil
		} catch PtoyClientError.invalidFileContent {
			print("PtoyClient Error: Javascript source content is invalid")
			return nil
		} catch PtoyClientError.bundleNotFound {
			print("PtoyClient Error: Javascript bundle is not found.")
			return nil
		} catch PtoyClientError.methodNotFound {
			print("PtoyClient Error: Javascript method is not found.")
			return nil
		} catch {
			print("PtoyClient Error: Unknown Error")
			return nil
		}
	}

	private func initJsContext() throws {
		if let filePath = Bundle.main.path(forResource: JS_FILE_NAME, ofType: JS_FILE_EXTENSION) {
			do {
				let fileContent = try String(contentsOfFile: filePath)
				self.jsContext.evaluateScript(fileContent)

				if let sdk = self.jsContext.objectForKeyedSubscript(BUNDLE_NAME) {
					if sdk.toString() == "undefined" {
						throw PtoyClientError.bundleNotFound
					}
					self.jsSDK = sdk
				}

				if let crypto = self.jsSDK.objectForKeyedSubscript(MODULE_NAME_CRYPTO) {
					if crypto.toString() == "undefined" {
						throw PtoyClientError.bundleNotFound
					}
					self.jsCrypto = crypto
				}


			} catch {
				throw PtoyClientError.invalidFileContent
			}
		} else {
			throw PtoyClientError.invalidFilePath
		}
	}

	private func exceptionHandler (context: JSContext?, exception: JSValue?) {
		if let errorMessage = exception?.description {
			print("JS Error: \(errorMessage)")
		} else {
			print("JS Error: Unknown Error.")
		}
	}

	func generateMnemonic() -> String? {
		if let funcGenerateMnemonic = self.jsSDK.objectForKeyedSubscript(FUNC_GEN_MNEMONIC) {
			if let resultMnemonic = funcGenerateMnemonic.call(withArguments: []).toString() {
				return resultMnemonic != "undefined" ? resultMnemonic : nil
			}
			return nil
		}
		return nil
	}

	func generateRSA (response: @escaping ((privateKey: String, publicKey: String)?) -> ()) {
		if let funcGenerateRSA = self.jsSDK.objectForKeyedSubscript(FUNC_GEN_RSA) {
			let responseHandler: @convention(block) ([String: Any]) -> Void = {(keypairRSA) in
				if let privateKey = keypairRSA["private"] as? String,
					let publicKey =  keypairRSA["public"] as? String {
					response((privateKey: privateKey, publicKey: publicKey))
				}
			}
			// Make block available to javasript
			let responseHandlerBlock = unsafeBitCast(responseHandler, to: AnyObject.self)

			self.jsContext
				.setObject(responseHandlerBlock, forKeyedSubscript: JS_CALLBACK as (NSCopying & NSObjectProtocol)!)

			funcGenerateRSA.call(withArguments: [responseHandlerBlock])
		} else {
			response(nil)
		}
	}

	func generateECDSA (mnemonic: String) -> (privateKey: String, publicKey: String, address: String)? {
		if let funcGenerateECDSA = self.jsSDK.objectForKeyedSubscript(FUNC_GEN_ECDSA) {
			if let keypairECDSA = funcGenerateECDSA.call(withArguments: [mnemonic]).toDictionary() {
				if let privateKey = keypairECDSA["private"] as? String,
					let publicKey =  keypairECDSA["public"] as? String,
					let address =  keypairECDSA["address"] as? String {
					return (privateKey: privateKey, publicKey: publicKey, address: address)
				}
			}
			return nil
		}
		return nil
	}

	func encryptKey(keyString: String, mnemonic: String) -> String? {
		if let funcEncryptAES = self.jsCrypto.objectForKeyedSubscript(FUNC_ENC_AES) {
			if let encryptedKeyString = funcEncryptAES.call(withArguments: [keyString, mnemonic]).toString() {
				return encryptedKeyString != "undefined" ? encryptedKeyString : nil
			}
			return nil
		}
		return nil
	}

	func decryptKey(encryptedKeyString: String, mnemonic: String) -> String? {
		if let funcDecryptAES = self.jsCrypto.objectForKeyedSubscript(FUNC_DEC_AES) {
			if let decryptedKeyString = funcDecryptAES.call(withArguments: [encryptedKeyString, mnemonic]).toString() {
				return decryptedKeyString != "undefined" ? decryptedKeyString : nil
			}
			return nil
		}
		return nil
	}

	func encryptData (dataString: String, publicKeyRSA: String)
		-> (encryptedData: String, encryptedSecretKey: String)? {
			if let funcEncryptData = self.jsCrypto.objectForKeyedSubscript(FUNC_ENC_DATA) {
				if let encryptedDataInfo = funcEncryptData.call(withArguments: [dataString, publicKeyRSA]).toDictionary() {
					if let encryptedData =  encryptedDataInfo["encryptedData"] as? String,
						let encryptedSecretKey =  encryptedDataInfo["encryptedSecretKey"] as? String {
						return (encryptedData: encryptedData, encryptedSecretKey: encryptedSecretKey)
					}
				}
				return nil
			}
			return nil
	}

	func decryptData (encryptedData: String, encryptedSecretKey: String, privateKeyRSA: String) -> String? {
		if let funcDecryptData = self.jsCrypto.objectForKeyedSubscript(FUNC_DEC_DATA) {
			if let decryptedDataString = funcDecryptData
				.call(withArguments: [encryptedData, encryptedSecretKey, privateKeyRSA]).toString() {
				return decryptedDataString != "undefined" ? decryptedDataString : nil
			}
			return nil
		}
		return nil
	}

}


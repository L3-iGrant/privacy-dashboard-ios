//
//  PrivacyDashboard.swift
//  PrivacyDashboardiOS
//
//  Created by Mumthasir mohammed on 06/11/23.
//

import Foundation
import UIKit

public enum ViewModeType {
    case fullScreen
    case bottomSheet
}

// Gives an individual access token to the SDK. The host app gets the token
// from its own backend, which calls `POST /v3/service/individual/token` of the
// iGrant.io API. Call the completion one time, with the token or an error.
public typealias PrivacyDashboardTokenProvider = (@escaping (Result<String, Error>) -> Void) -> Void

public class PrivacyDashboard {
    public static var receiveDataBackFromPrivacyDashboard : (([String: Any]) -> Void)?
    
    // Debug logging of the SDK, off by default. The messages are private in the unified log.
    public static var isLoggingEnabled: Bool {
        get { BBConsentLog.isEnabled }
        set { BBConsentLog.isEnabled = newValue }
    }
    
    private static let deprecationLock = NSLock()
    private static var didLogApiKeyDeprecation = false
    
    // MARK: - Token provider
    
    /// Configures the SDK for one individual. The SDK keeps the token in memory only.
    /// It asks `tokenProvider` for a token before the first request, when the token
    /// is less than 60 seconds from expiry, and one time after the API refuses the
    /// token (401). The provider is called on the main queue.
    public static func configure(baseUrl: String, organisationId: String, tokenProvider: @escaping PrivacyDashboardTokenProvider) {
        removeLegacyUserSession()
        BBConsentKeyChainUtils.delete(key: BBConsentKeyChainUtils.apiKeyAccount)
        let dashboard = BBConsentPrivacyDashboardiOS.shared
        dashboard.baseUrl = baseUrl
        dashboard.orgId = organisationId
        dashboard.userId = nil
        dashboard.accessToken = nil
        BBConsentTokenStore.shared.configure(provider: tokenProvider)
    }
    
    /// Configures the SDK for one individual with an async token provider.
    /// See `configure(baseUrl:organisationId:tokenProvider:)`.
    public static func configure(baseUrl: String, organisationId: String, tokenProvider: @escaping () async throws -> String) {
        let provider: PrivacyDashboardTokenProvider = { completion in
            Task {
                do {
                    completion(.success(try await tokenProvider()))
                } catch {
                    completion(.failure(error))
                }
            }
        }
        configure(baseUrl: baseUrl, organisationId: organisationId, tokenProvider: provider)
    }
    
    /// Shows the privacy dashboard. Call `configure(baseUrl:organisationId:tokenProvider:)` first.
    public static func showPrivacyDashboard(withLocale: String = "en", turnOnAskme: Bool, turnOnUserRequest: Bool, turnOnAttributeDetail: Bool, onConsentChange: ((Bool, String, String) -> Void)? = nil, shouldShowAlertOnConsentChange: Bool = true, dataAgreementIDs: [String]? = nil, viewMode: ViewModeType = .fullScreen, withTitle: String? = "Privacy Dashboard") {
        BBConsentPrivacyDashboardiOS.shared.languageCode = withLocale
        BBConsentPrivacyDashboardiOS.shared.turnOnUserRequests = turnOnUserRequest
        BBConsentPrivacyDashboardiOS.shared.turnOnAskMeSection = turnOnAskme
        BBConsentPrivacyDashboardiOS.shared.turnOnAttributeDetailScreen = turnOnAttributeDetail
        BBConsentPrivacyDashboardiOS.shared.onConsentChange = onConsentChange
        BBConsentPrivacyDashboardiOS.shared.shouldShowAlertOnConsentChange = shouldShowAlertOnConsentChange
        BBConsentPrivacyDashboardiOS.shared.dataAgreementIDs = dataAgreementIDs
        BBConsentPrivacyDashboardiOS.shared.show(viewMode: viewMode, title: withTitle)
    }
    
    /// Shows the data sharing screen. Call `configure(baseUrl:organisationId:tokenProvider:)` first.
    public static func showDataSharingUI(dataAgreementId: String, organisationName: String, organisationLogoImageUrl: String, termsOfServiceText : String, termsOfServiceUrl: String, cancelButtonText: String) {
        presentDataSharingUI(dataAgreementId: dataAgreementId, organisationName: organisationName, organisationLogoImageUrl: organisationLogoImageUrl, termsOfServiceText: termsOfServiceText, termsOfServiceUrl: termsOfServiceUrl, cancelButtonText: cancelButtonText)
    }
    
    /// Deletes the in-memory token, the token provider and the Keychain items of the SDK.
    /// Call it when the user of the host app logs out.
    public static func reset() {
        BBConsentTokenStore.shared.reset()
        BBConsentKeyChainUtils.deleteAll()
        removeLegacyUserSession()
        BBConsentPrivacyDashboardiOS.shared.userId = nil
        BBConsentPrivacyDashboardiOS.shared.accessToken = nil
    }
    
    // MARK: - Deprecated API key path
    
    // The API key path stays for existing integrations. It logs one warning.
    static func useApiKeyPath() {
        BBConsentTokenStore.shared.reset()
        removeLegacyUserSession()
        deprecationLock.lock()
        let shouldLog = !didLogApiKeyDeprecation
        didLogApiKeyDeprecation = true
        deprecationLock.unlock()
        if shouldLog {
            BBConsentLog.warning("PrivacyDashboard: the API key and user ID entry points are deprecated. Give a token provider to configure(baseUrl:organisationId:tokenProvider:). The API key must stay on your backend.")
        }
    }
    
    // Older SDK versions stored a user session in the standard user defaults.
    // Delete it only when it is the archived session of the SDK.
    static func removeLegacyUserSession(from defaults: UserDefaults = .standard) {
        let key = Constant.AppSetupConstant.KSavingUSerInfoUserDefaultKey
        guard let data = defaults.data(forKey: key),
              let plist = try? PropertyListSerialization.propertyList(from: data, format: nil) as? [String: Any],
              let objects = plist["$objects"] as? [Any],
              objects.contains(where: { (($0 as? [String: Any])?["$classname"] as? String) == "PrivacyDashboardiOS.UserInfo" }) else {
            return
        }
        defaults.removeObject(forKey: key)
    }
    
    // MARK: - Invoking 'PrivacyDashboard' iOS SDK
    @available(*, deprecated, message: "use your backend: get an individual token there and call configure(baseUrl:organisationId:tokenProvider:), then showPrivacyDashboard(withLocale:turnOnAskme:turnOnUserRequest:turnOnAttributeDetail:...)")
    public static func showPrivacyDashboard(withApiKey: String, withUserId: String, withOrgId: String, withBaseUrl: String, withLocale: String = "en", accessToken: String = "", turnOnAskme: Bool, turnOnUserRequest: Bool, turnOnAttributeDetail: Bool, onConsentChange: ((Bool, String, String) -> Void)? = nil, shouldShowAlertOnConsentChange: Bool = true, dataAgreementIDs: [String]? = nil, viewMode: ViewModeType = .fullScreen, withTitle: String? = "Privacy Dashboard") {
        useApiKeyPath()
        BBConsentPrivacyDashboardiOS.shared.languageCode = withLocale
        BBConsentPrivacyDashboardiOS.shared.turnOnUserRequests = turnOnUserRequest
        BBConsentPrivacyDashboardiOS.shared.turnOnAskMeSection = turnOnAskme
        BBConsentPrivacyDashboardiOS.shared.turnOnAttributeDetailScreen = turnOnAttributeDetail
        BBConsentPrivacyDashboardiOS.shared.baseUrl = withBaseUrl
        BBConsentPrivacyDashboardiOS.shared.onConsentChange = onConsentChange
        BBConsentPrivacyDashboardiOS.shared.shouldShowAlertOnConsentChange = shouldShowAlertOnConsentChange
        BBConsentPrivacyDashboardiOS.shared.dataAgreementIDs = dataAgreementIDs ?? nil
        BBConsentPrivacyDashboardiOS.shared.show(organisationId: withOrgId, apiKey: withApiKey, userId: withUserId, accessToken: accessToken, viewMode: viewMode, title: withTitle)
    }
    
    @available(*, deprecated, message: "use your backend: get an individual token there and call configure(baseUrl:organisationId:tokenProvider:), then showDataSharingUI(dataAgreementId:organisationName:...)")
    public static func showDataSharingUI(apiKey: String, userId: String, accessToken: String? = nil, baseUrlString: String, dataAgreementId: String, organisationName: String, organisationLogoImageUrl: String, termsOfServiceText : String, termsOfServiceUrl: String, cancelButtonText: String) {
        useApiKeyPath()
        // Passing Auth info
        BBConsentPrivacyDashboardiOS.shared.userId = userId
        BBConsentPrivacyDashboardiOS.shared.accessToken = accessToken
        let data = apiKey.data(using: .utf8) ?? Data()
        _ = BBConsentKeyChainUtils.save(key: BBConsentKeyChainUtils.apiKeyAccount, data: data)
        BBConsentPrivacyDashboardiOS.shared.baseUrl = baseUrlString
        presentDataSharingUI(dataAgreementId: dataAgreementId, organisationName: organisationName, organisationLogoImageUrl: organisationLogoImageUrl, termsOfServiceText: termsOfServiceText, termsOfServiceUrl: termsOfServiceUrl, cancelButtonText: cancelButtonText)
    }
    
    private static func presentDataSharingUI(dataAgreementId: String, organisationName: String, organisationLogoImageUrl: String, termsOfServiceText : String, termsOfServiceUrl: String, cancelButtonText: String) {
        let storyboard = UIStoryboard(name: "PrivacyDashboard", bundle: Bundle.module)
        let sharingVC = storyboard.instantiateViewController(withIdentifier: "BBConsentDataSharingVC") as? BBConsentDataSharingVC ?? BBConsentDataSharingVC()
        // Passing other required info
        sharingVC.dataAgreementId = dataAgreementId
        sharingVC.theirOrgName = organisationName
        sharingVC.theirLogoImageUrl = organisationLogoImageUrl
        sharingVC.termsOfServiceText = termsOfServiceText
        sharingVC.termsOFServiceUrl = termsOfServiceUrl
        sharingVC.cancelButtonText = cancelButtonText
        sharingVC.sendDataBack = { data in
            BBConsentLog.debug("\(data)")
            self.receiveDataBackFromPrivacyDashboard?(data)
        }
        
        readDataAgreementRecordApi(dataAgreementId: dataAgreementId) { success, resultVal in
            if resultVal["errorCode"] as? Int != 500 && !(resultVal["consentRecord"] is NSNull) {
                // If existing record found for the data agreement ID
                // Return the records reponse
                self.receiveDataBackFromPrivacyDashboard?(resultVal)
            } else {
                // If no record found for the data agreement ID
                // Navigate to Data sharing UI screen
                let navVC = UINavigationController.init(rootViewController: sharingVC)
                navVC.modalPresentationStyle = .fullScreen
                UIApplication.topViewController()?.present(navVC, animated: true, completion: nil)
            }
        }
    }
    
    @available(*, deprecated, message: "use your backend: get an individual token there and call configure(baseUrl:organisationId:tokenProvider:)")
    public static func configure(withApiKey: String, withUserId: String?, withOrgId: String, withBaseUrl: String, withLocale: String, accessToken: String = "") {
        useApiKeyPath()
        BBConsentPrivacyDashboardiOS.shared.languageCode = withLocale == "" ? "en" : withLocale
        if let withUserId = withUserId, !withUserId.isEmpty {
            BBConsentPrivacyDashboardiOS.shared.userId = withUserId
        } else {
            BBConsentPrivacyDashboardiOS.shared.userId = nil
        }
        BBConsentPrivacyDashboardiOS.shared.accessToken = accessToken
        let data = withApiKey.data(using: .utf8) ?? Data()
        _ = BBConsentKeyChainUtils.save(key: BBConsentKeyChainUtils.apiKeyAccount, data: data)
        BBConsentPrivacyDashboardiOS.shared.baseUrl = withBaseUrl
    }
    
    public static func updateDataAgreementStatus(dataAgreementId: String, status: Bool) {
        readDataAgreementRecordApi(dataAgreementId: dataAgreementId) { success, resultVal in
            if resultVal["errorCode"] as? Int != 500 && !(resultVal["consentRecord"] is NSNull) {
                // If existing record found for the data agreement ID
                let resultDict = resultVal["consentRecord"] as? [String: Any]
                guard let recordId = resultDict?["id"] else { return }
                updateRecordApiCall(dataAgreementId: dataAgreementId, recordId: recordId as! String, status: status) { resultVal in
                    BBConsentLog.debug("\(resultVal)")
                    self.receiveDataBackFromPrivacyDashboard?(resultVal)
                }
            } else {
                // If no record found for the data agreement ID
                createRecordApiCall(dataAgreementId: dataAgreementId) { resultVal in
                    BBConsentLog.debug("\(resultVal)")
                    self.receiveDataBackFromPrivacyDashboard?(resultVal)
                }
            }
        }
    }
    
    private static func createRecordApiCall(dataAgreementId: String, completion: @escaping (_ resultVal: [String: Any]) -> Void) {
        BBConsentBaseWebService.shared.makeAPICall(urlString: Constant.URLStrings.fetchDataAgreementRecord + (dataAgreementId), parameters: [:], method: .post) { success, resultVal in
            if success {
                BBConsentLog.debug("\(resultVal)")
                completion(resultVal)
            } else {
                BBConsentLog.debug("\(resultVal)")
                completion(resultVal)
            }
        }
    }
    
    private static func updateRecordApiCall(dataAgreementId: String, recordId: String, status: Bool, completion: @escaping (_ resultVal: [String: Any]) -> Void) {
        let parameters = ["optIn" : status]
        let url =  BBConsentPrivacyDashboardiOS.shared.baseUrl  + "/service/individual/record/consent-record/" + (recordId) + "?dataAgreementId=" + dataAgreementId
        BBConsentBaseWebService.shared.makeAPICall(urlString: url, parameters: parameters, method: .put) { success, resultVal in
            if success {
                BBConsentLog.debug("\(resultVal)")
                completion(resultVal)
            } else {
                BBConsentLog.debug("\(resultVal)")
                completion(resultVal)
            }
        }
    }
    
    // MARK: - Read data agreement record api call
    public static func readDataAgreementRecordApi(dataAgreementId: String, completionBlock:@escaping (_ success: Bool, _ resultVal: [String: Any]) -> Void){
        BBConsentBaseWebService.shared.makeAPICall(urlString: Constant.URLStrings.fetchDataAgreementRecord + dataAgreementId, parameters: [:], method: .get) { success, resultVal in
            if success {
                BBConsentLog.debug("\(resultVal)")
                completionBlock(true, resultVal)
            } else {
                BBConsentLog.debug("\(resultVal)")
                completionBlock(false, resultVal)
            }
        }
    }
    
    // MARK: - Read data agreement api call
    public static func readDataAgreementApi(dataAgreementId: String, completionBlock:@escaping (_ success: Bool, _ resultVal: [String: Any]) -> Void){
        BBConsentBaseWebService.shared.makeAPICall(urlString: Constant.URLStrings.fetchDataAgreement + dataAgreementId, parameters: [:], method: .get) { success, resultVal in
            if success {
                BBConsentLog.debug("\(resultVal)")
                completionBlock(true, resultVal)
            } else {
                BBConsentLog.debug("\(resultVal)")
                completionBlock(false, resultVal)
            }
        }
    }
    
    public static func showDataAgreementPolicy(dataAgreementDic: [String: Any], viewMode: ViewModeType = .fullScreen) {
        if viewMode == .bottomSheet {
            let frameworkBundle = Bundle(for: BBConsentDataAgreementBottomSheetVC.self)
            let bundleURL = frameworkBundle.resourceURL?.appendingPathComponent("PrivacyDashboardiOS.bundle")
            var storyboard = UIStoryboard()
            if let resourceBundle = Bundle(url: bundleURL!) {
                storyboard = UIStoryboard(name: "PrivacyDashboard", bundle: Bundle.module)
            } else {
                let myBundle = Bundle(for: BBConsentOrganisationBottomSheetViewController.self)
                storyboard = UIStoryboard(name: "PrivacyDashboard", bundle: Bundle.module)
            }
            let dataAgreementVC = storyboard.instantiateViewController(withIdentifier: "BBConsentDataAgreementBottomSheetVC") as! BBConsentDataAgreementBottomSheetVC
            dataAgreementVC.dataAgreementDic = [dataAgreementDic]
            let navVC = UINavigationController.init(rootViewController: dataAgreementVC)
            navVC.modalPresentationStyle = .overFullScreen
            navVC.modalTransitionStyle = .crossDissolve
            UIApplication.topViewController()?.present(navVC, animated: true, completion: nil)
        } else if viewMode == .fullScreen {
            let frameworkBundle = Bundle(for: BBConsentOrganisationViewController.self)
            let bundleURL = frameworkBundle.resourceURL?.appendingPathComponent("PrivacyDashboardiOS.bundle")
            var storyboard = UIStoryboard()
            if let resourceBundle = Bundle(url: bundleURL!) {
                storyboard = UIStoryboard(name: "PrivacyDashboard", bundle: Bundle.module)
            } else {
                let myBundle = Bundle(for: BBConsentOrganisationViewController.self)
                storyboard = UIStoryboard(name: "PrivacyDashboard", bundle: Bundle.module)
            }
            let dataAgreementVC = storyboard.instantiateViewController(withIdentifier: "BBConsentDataAgreementVC") as! BBConsentDataAgreementVC
            dataAgreementVC.dataAgreementDic = [dataAgreementDic]
            dataAgreementVC.showCloseButton = true
            let navVC = UINavigationController.init(rootViewController: dataAgreementVC)
            navVC.modalPresentationStyle = .fullScreen
            UIApplication.topViewController()?.present(navVC, animated: true, completion: nil)
        }
    }
    
    // MARK: - 'Individual' related api calls
    // Admin functions. They need the organisation API key, which must stay on your backend.
    @available(*, deprecated, message: "use your backend")
    public static func createAnIndividual(name: String?, email: String?, phone:String?, pushNotificationToken: String?, deviceType: String?, externalID: String?, completionBlock:@escaping (_ success: Bool, _ resultVal: [String: Any]) -> Void) {
        let individual = Individual(id: nil, externalID: externalID, externalIDType: nil, identityProviderID: nil, name: name, iamID: nil, email: email, phone: phone, pushNotificationToken: pushNotificationToken, deviceType: deviceType)
        let record = IndividualRecord(individual: individual)
        let data = try! JSONEncoder.init().encode(record)
        let dictionary = try! JSONSerialization.jsonObject(with: data) as! [String: Any]
        BBConsentPrivacyDashboardiOS.shared.userId = "NO USER ID NEEDED HERE" // Only for create indvidual call
        
        BBConsentBaseWebService.shared.makeAPICall(urlString: Constant.URLStrings.createIndividual, parameters: dictionary, method: .post) { success, resultVal in
            if success {
                BBConsentLog.debug("\(resultVal)")
                completionBlock(true, resultVal)
                
            } else {
                BBConsentLog.debug("\(resultVal)")
                completionBlock(false, resultVal)
            }
        }
    }
    
    @available(*, deprecated, message: "use your backend")
    public static func deleteAnIndividual(individualId: String, completionBlock: @escaping (_ success: Bool, _ resultVal: [String: Any]) -> Void) {
        
        BBConsentBaseWebService.shared.makeAPICall(
            urlString: Constant.URLStrings.readIndividual + individualId,
            parameters: [:],
            method: .delete
        ) { success, resultVal in
            if success {
                completionBlock(true, resultVal)
            } else {
                completionBlock(false, resultVal)
            }
        }
    }
    
    @available(*, deprecated, message: "use your backend")
    public static func readAnIndividual(individualId: String,  completionBlock:@escaping (_ success: Bool, _ resultVal: [String: Any]) -> Void) {
        BBConsentBaseWebService.shared.makeAPICall(urlString: Constant.URLStrings.readIndividual + individualId, parameters: [:], method: .get) { success, resultVal in
            if success {
                BBConsentLog.debug("\(resultVal)")
                completionBlock(true, resultVal)
            } else {
                BBConsentLog.debug("\(resultVal)")
                completionBlock(false, resultVal)
            }
        }
    }
    
    @available(*, deprecated, message: "use your backend")
    public static func updateAnIndividual(individualId: String, externalId:String?, externalIdType: String?, identityProviderId: String?, name: String, iamId: String?, email: String, phone:String, pushNotificationToken: String?, deviceType: String?, completionBlock:@escaping (_ success: Bool, _ resultVal: [String: Any]) -> Void) {
        let individual = Individual(id: individualId, externalID: externalId, externalIDType: externalId, identityProviderID: identityProviderId, name: name, iamID: iamId, email: email, phone: phone, pushNotificationToken: pushNotificationToken, deviceType: deviceType)
        let record = IndividualRecord(individual: individual)
        let data = try! JSONEncoder.init().encode(record)
        let dictionary = try! JSONSerialization.jsonObject(with: data) as! [String: Any]
        
        BBConsentBaseWebService.shared.makeAPICall(urlString: Constant.URLStrings.readIndividual + individualId, parameters: dictionary ,method: .put) { success, resultVal in
            if success {
                BBConsentLog.debug("\(resultVal)")
                completionBlock(true, resultVal)
            } else {
                BBConsentLog.debug("\(resultVal)")
                completionBlock(false, resultVal)
            }
        }
    }
    
    @available(*, deprecated, message: "use your backend")
    public static func fetchAllIndividuals(externalIndividualId: String?, completionBlock:@escaping (_ success: Bool, _ resultVal: [String: Any]) -> Void) {
        guard var components = URLComponents(string: Constant.URLStrings.fetchAllIndividuals) else {
            completionBlock(false, [:])
            return
        }
        
        components.queryItems = [
            URLQueryItem(name: "externalIndividualId", value: externalIndividualId ?? "")
        ]
        
        guard let finalURL = components.url?.absoluteString else {
            completionBlock(false, [:])
            return
        }
        let url = externalIndividualId?.isEmpty == false ? finalURL : Constant.URLStrings.fetchAllIndividuals
        BBConsentBaseWebService.shared.makeAPICall(urlString: url, parameters: [:] ,method: .get) { success, resultVal in
            if success {
                BBConsentLog.debug("\(resultVal)")
                completionBlock(true, resultVal)
            } else {
                BBConsentLog.debug("\(resultVal)")
                completionBlock(false, resultVal)
            }
        }
    }
    
}

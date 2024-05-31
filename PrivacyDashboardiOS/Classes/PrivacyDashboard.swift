//
//  PrivacyDashboard.swift
//  PrivacyDashboardiOS
//
//  Created by Mumthasir mohammed on 06/11/23.
//

import Foundation

public class PrivacyDashboard {
    public static var receiveDataBackFromPrivacyDashboard : (([String: Any]) -> Void)?
    
    // MARK: - Invoking 'PrivacyDashboard' iOS SDK
    public static func showPrivacyDashboard(withApiKey: String, withUserId: String, withOrgId: String, withBaseUrl: String, withLocale: String = "en", accessToken: String = "", turnOnAskme: Bool, turnOnUserRequest: Bool, turnOnAttributeDetail: Bool) {
        PrivacyDashboardiOS.shared.languageCode = withLocale 
        PrivacyDashboardiOS.shared.turnOnUserRequests = turnOnUserRequest
        PrivacyDashboardiOS.shared.turnOnAskMeSection = turnOnAskme
        PrivacyDashboardiOS.shared.turnOnAttributeDetailScreen = turnOnAttributeDetail
        PrivacyDashboardiOS.shared.baseUrl = withBaseUrl
        PrivacyDashboardiOS.shared.show(organisationId: withOrgId, apiKey: withApiKey, userId: withUserId, accessToken: accessToken)
    }
    
    public static func showDataSharingUI(apiKey: String, userId: String, accessToken: String? = nil, baseUrlString: String, dataAgreementId: String, organisationName: String, organisationLogoImageUrl: String, termsOfServiceText : String, termsOfServiceUrl: String, cancelButtonText: String) {
        let frameworkBundle = Bundle(for: PDOrganisationViewController.self)
        let bundleURL = frameworkBundle.resourceURL?.appendingPathComponent("PrivacyDashboardiOS.bundle")
        var storyboard = UIStoryboard()
        if let resourceBundle = Bundle(url: bundleURL!) {
            storyboard = UIStoryboard(name: "PrivacyDashboard", bundle: resourceBundle)
        } else {
            let myBundle = Bundle(for: PDOrganisationViewController.self)
            storyboard = UIStoryboard(name: "PrivacyDashboard", bundle: myBundle)
        }
        // Passing Auth info
        PrivacyDashboardiOS.shared.userId = userId
        PrivacyDashboardiOS.shared.accessToken = accessToken
        let sharingVC = storyboard.instantiateViewController(withIdentifier: "BBConsentDataSharingVC") as? PDDataSharingVC ?? PDDataSharingVC()
        // Passing other required info
        let data = apiKey.data(using: .utf8) ?? Data()
        _ = PDiOSKeyChainUtils.save(key: "BBConsentApiKey", data: data)
        PrivacyDashboardiOS.shared.baseUrl = baseUrlString
        
        sharingVC.dataAgreementId = dataAgreementId
        sharingVC.theirOrgName = organisationName
        sharingVC.theirLogoImageUrl = organisationLogoImageUrl
        sharingVC.termsOfServiceText = termsOfServiceText
        sharingVC.termsOFServiceUrl = termsOfServiceUrl
        sharingVC.cancelButtonText = cancelButtonText
        sharingVC.sendDataBack = { data in
            debugPrint(data)
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
    
    public static func configure(withApiKey: String, withUserId: String, withOrgId: String, withBaseUrl: String, withLocale: String, accessToken: String = "") {
        let frameworkBundle = Bundle(for: PDOrganisationViewController.self)
        let bundleURL = frameworkBundle.resourceURL?.appendingPathComponent("PrivacyDashboardiOS.bundle")
        var storyboard = UIStoryboard()
        if let resourceBundle = Bundle(url: bundleURL!) {
            storyboard = UIStoryboard(name: "PrivacyDashboard", bundle: resourceBundle)
        } else {
            let myBundle = Bundle(for: PDOrganisationViewController.self)
            storyboard = UIStoryboard(name: "PrivacyDashboard", bundle: myBundle)
        }
        
        PrivacyDashboardiOS.shared.languageCode = withLocale == "" ? "en" : withLocale
        PrivacyDashboardiOS.shared.userId = withUserId
        PrivacyDashboardiOS.shared.accessToken = accessToken
        let sharingVC = storyboard.instantiateViewController(withIdentifier: "BBConsentDataSharingVC") as? PDDataSharingVC ?? PDDataSharingVC()
        // Passing other required info
        let data = withApiKey.data(using: .utf8) ?? Data()
        _ = PDiOSKeyChainUtils.save(key: "BBConsentApiKey", data: data)
        PrivacyDashboardiOS.shared.baseUrl = withBaseUrl
        sharingVC.dataAgreementId = withOrgId
    }
    
    public static func updateDataAgreementStatus(dataAgreementId: String, status: Bool) {
        readDataAgreementRecordApi(dataAgreementId: dataAgreementId) { success, resultVal in
            if resultVal["errorCode"] as? Int != 500 && !(resultVal["consentRecord"] is NSNull) {
                // If existing record found for the data agreement ID
                let resultDict = resultVal["consentRecord"] as? [String: Any]
                guard let recordId = resultDict?["id"] else { return }
                updateRecordApiCall(dataAgreementId: dataAgreementId, recordId: recordId as! String, status: status) { resultVal in
                    debugPrint(resultVal)
                    self.receiveDataBackFromPrivacyDashboard?(resultVal)
                }
            } else {
                // If no record found for the data agreement ID
                createRecordApiCall(dataAgreementId: dataAgreementId) { resultVal in
                    debugPrint(resultVal)
                    self.receiveDataBackFromPrivacyDashboard?(resultVal)
                }
            }
        }
    }
    
    private static func createRecordApiCall(dataAgreementId: String, completion: @escaping (_ resultVal: [String: Any]) -> Void) {
        PDBaseWebService.shared.makeAPICall(urlString: Constant.URLStrings.fetchDataAgreementRecord + (dataAgreementId), parameters: [:], method: .post) { success, resultVal in
            if success {
                debugPrint(resultVal)
                completion(resultVal)
            } else {
                debugPrint(resultVal)
                completion(resultVal)
            }
        }
    }
    
    private static func updateRecordApiCall(dataAgreementId: String, recordId: String, status: Bool, completion: @escaping (_ resultVal: [String: Any]) -> Void) {
        let parameters = ["optIn" : status]
        let url =  PrivacyDashboardiOS.shared.baseUrl  + "/service/individual/record/consent-record/" + (recordId) + "?dataAgreementId=" + dataAgreementId
        PDBaseWebService.shared.makeAPICall(urlString: url, parameters: parameters, method: .put) { success, resultVal in
            if success {
                debugPrint(resultVal)
                completion(resultVal)
            } else {
                debugPrint(resultVal)
                completion(resultVal)
            }
        }
    }
    
    // MARK: - Read data agreement record api call
    public static func readDataAgreementRecordApi(dataAgreementId: String, completionBlock:@escaping (_ success: Bool, _ resultVal: [String: Any]) -> Void){
        PDBaseWebService.shared.makeAPICall(urlString: Constant.URLStrings.fetchDataAgreementRecord + dataAgreementId, parameters: [:], method: .get) { success, resultVal in
            if success {
                debugPrint(resultVal)
                completionBlock(true, resultVal)
            } else {
                debugPrint(resultVal)
                completionBlock(false, resultVal)
            }
        }
    }
    
    // MARK: - Read data agreement api call
    public static func readDataAgreementApi(dataAgreementId: String, completionBlock:@escaping (_ success: Bool, _ resultVal: [String: Any]) -> Void){
        PDBaseWebService.shared.makeAPICall(urlString: Constant.URLStrings.fetchDataAgreement + dataAgreementId, parameters: [:], method: .get) { success, resultVal in
            if success {
                debugPrint(resultVal)
                completionBlock(true, resultVal)
            } else {
                debugPrint(resultVal)
                completionBlock(false, resultVal)
            }
        }
    }
    
    public static func showDataAgreementPolicy(dataAgreementDic: [String: Any]) {
        let frameworkBundle = Bundle(for: PDOrganisationViewController.self)
        let bundleURL = frameworkBundle.resourceURL?.appendingPathComponent("PrivacyDashboardiOS.bundle")
        var storyboard = UIStoryboard()
        if let resourceBundle = Bundle(url: bundleURL!) {
            storyboard = UIStoryboard(name: "PrivacyDashboard", bundle: resourceBundle)
        } else {
            let myBundle = Bundle(for: PDOrganisationViewController.self)
            storyboard = UIStoryboard(name: "PrivacyDashboard", bundle: myBundle)
        }
        let dataAgreementVC = storyboard.instantiateViewController(withIdentifier: "BBConsentDataAgreementVC") as! PDDataAgreementVC
        dataAgreementVC.dataAgreementDic = [dataAgreementDic]
        dataAgreementVC.showCloseButton = true
        let navVC = UINavigationController.init(rootViewController: dataAgreementVC)
        navVC.modalPresentationStyle = .fullScreen
        UIApplication.topViewController()?.present(navVC, animated: true, completion: nil)
    }
    
    // MARK: - 'Individual' related api calls
    public static func createAnIndividual(name: String?, email: String?, phone:String?, completionBlock:@escaping (_ success: Bool, _ resultVal: [String: Any]) -> Void) {
        let individual = Individual(id: nil, externalID: nil, externalIDType: nil, identityProviderID: nil, name: name, iamID: nil, email: email, phone: phone)
        let record = IndividualRecord(individual: individual)
        let data = try! JSONEncoder.init().encode(record)
        let dictionary = try! JSONSerialization.jsonObject(with: data) as! [String: Any]
        PrivacyDashboardiOS.shared.userId = "NO USER ID NEEDED HERE" // Only for create indvidual call
        
        PDBaseWebService.shared.makeAPICall(urlString: Constant.URLStrings.createIndividual, parameters: dictionary, method: .post) { success, resultVal in
            if success {
                debugPrint(resultVal)
                completionBlock(true, resultVal)
                
            } else {
                debugPrint(resultVal)
                completionBlock(false, resultVal)
            }
        }
    }
    
    public static func readAnIndividual(individualId: String,  completionBlock:@escaping (_ success: Bool, _ resultVal: [String: Any]) -> Void) {
        PDBaseWebService.shared.makeAPICall(urlString: Constant.URLStrings.readIndividual + individualId, parameters: [:], method: .get) { success, resultVal in
            if success {
                debugPrint(resultVal)
                completionBlock(true, resultVal)
            } else {
                debugPrint(resultVal)
                completionBlock(false, resultVal)
            }
        }
    }
    
    public static func updateAnIndividual(individualId: String, externalId:String?, externalIdType: String?, identityProviderId: String?, name: String, iamId: String?, email: String, phone:String, completionBlock:@escaping (_ success: Bool, _ resultVal: [String: Any]) -> Void) {
        let individual = Individual(id: individualId, externalID: externalId, externalIDType: externalId, identityProviderID: identityProviderId, name: name, iamID: iamId, email: email, phone: phone)
        let record = IndividualRecord(individual: individual)
        let data = try! JSONEncoder.init().encode(record)
        let dictionary = try! JSONSerialization.jsonObject(with: data) as! [String: Any]
        
        PDBaseWebService.shared.makeAPICall(urlString: Constant.URLStrings.readIndividual + individualId, parameters: dictionary ,method: .put) { success, resultVal in
            if success {
                debugPrint(resultVal)
                completionBlock(true, resultVal)
            } else {
                debugPrint(resultVal)
                completionBlock(false, resultVal)
            }
        }
    }
    
    public static func fetchAllIndividuals(completionBlock:@escaping (_ success: Bool, _ resultVal: [String: Any]) -> Void) {
        PDBaseWebService.shared.makeAPICall(urlString: Constant.URLStrings.fetchAllIndividuals, parameters: [:] ,method: .get) { success, resultVal in
            if success {
                debugPrint(resultVal)
                completionBlock(true, resultVal)
            } else {
                debugPrint(resultVal)
                completionBlock(false, resultVal)
            }
        }
    }
}

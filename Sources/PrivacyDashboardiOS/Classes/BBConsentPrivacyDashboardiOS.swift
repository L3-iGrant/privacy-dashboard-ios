//
//  PrivacyDashboardiOS.swift
//  PrivacyDashboardiOS
//
//  Created by Mumthasir mohammed on 31/08/23.
//

import Foundation
import UIKit

class BBConsentPrivacyDashboardiOS: UIViewController {
    static var shared = BBConsentPrivacyDashboardiOS()
    public var turnOnUserRequests = false
    public var turnOnAskMeSection = false
    public var turnOnAttributeDetailScreen = false
    public var languageCode = "en"
    // Demo server by default
    public var baseUrl = "https://demo-consent-bb-api.igrant.io/v2"
    public var onConsentChange: ((Bool, String, String) -> Void)?
    var shouldShowAlertOnConsentChange: Bool?
    var dataAgreementIDs: [String]? = nil
    
    var orgId: String?
    var userId: String?
    var accessToken: String?
    var hideBackButton = false
    
    func log() {
        debugPrint("### Log from PrivacyDashboardiOS SDK.")
    }
    
    func show(organisationId: String, apiKey: String, userId: String, accessToken: String, animate: Bool = true, viewMode: ViewModeType, title: String?) {
        if #available(iOS 13.0, *) {
            let appearance = UIView.appearance()
            appearance.overrideUserInterfaceStyle = .light
        }
        
        self.orgId = organisationId
        self.userId = userId
        if(!apiKey.isEmpty) {
            let serviceManager = LoginServiceManager()
            serviceManager.getUserDetails()
            let data = apiKey.data(using: .utf8) ?? Data()
            _ = BBConsentKeyChainUtils.save(key: "BBConsentApiKey", data: data)
            var storyboard = UIStoryboard()
            if viewMode == .bottomSheet {
                let frameworkBundle = Bundle(for: BBConsentOrganisationBottomSheetViewController.self)
                let bundleURL = frameworkBundle.resourceURL?.appendingPathComponent("PrivacyDashboardiOS.bundle")
                var storyboard = UIStoryboard()
                if let resourceBundle = Bundle(url: bundleURL!) {
                    storyboard = UIStoryboard(name: "PrivacyDashboard", bundle: .module)
                } else {
                    let myBundle = Bundle(for: BBConsentOrganisationBottomSheetViewController.self)
                    storyboard = UIStoryboard(name: "PrivacyDashboard", bundle: Bundle.module)
                }
                let orgVC = storyboard.instantiateViewController(withIdentifier: "BBConsentOrganisationBottomSheetViewController") as? BBConsentOrganisationBottomSheetViewController ?? BBConsentOrganisationBottomSheetViewController()
                orgVC.organisationId = organisationId
                orgVC.onConsentChange = onConsentChange
                orgVC.dataAgreementIDs = dataAgreementIDs
                orgVC.titleValue = title
                orgVC.shouldShowAlertOnConsentChange = shouldShowAlertOnConsentChange
                orgVC.modalPresentationStyle = .overFullScreen
                UIApplication.topViewController()?.present(orgVC, animated: true, completion: nil)
                return
            } else if viewMode == .fullScreen {
                let frameworkBundle = Bundle(for: BBConsentOrganisationViewController.self)
                let bundleURL = frameworkBundle.resourceURL?.appendingPathComponent("PrivacyDashboardiOS.bundle")
                if let resourceBundle = Bundle(url: bundleURL!) {
                    storyboard = UIStoryboard(name: "PrivacyDashboard", bundle: Bundle.module)
                } else {
                    let myBundle = Bundle(for: BBConsentOrganisationViewController.self)
                    storyboard = UIStoryboard(name: "PrivacyDashboard", bundle: Bundle.module)
                }
                
                let orgVC = storyboard.instantiateViewController(withIdentifier: "BBConsentOrganisationViewController") as? BBConsentOrganisationViewController ?? BBConsentOrganisationViewController()
                orgVC.organisationId = organisationId
                orgVC.onConsentChange = onConsentChange
                orgVC.dataAgreementIDs = dataAgreementIDs
                orgVC.shouldShowAlertOnConsentChange = shouldShowAlertOnConsentChange
                let navVC = UINavigationController.init(rootViewController: orgVC)
                navVC.modalPresentationStyle = .fullScreen
                UIApplication.topViewController()?.present(navVC, animated: animate, completion: nil)
                return
            }
            
        }
        
        if userId != "" {
            if viewMode == .bottomSheet {
                let orgVC = Constant.getStoryboard(vc: self.classForCoder).instantiateViewController(withIdentifier: "BBConsentOrganisationBottomSheetViewController") as! BBConsentOrganisationBottomSheetViewController
                orgVC.organisationId = organisationId
                self.userId = userId
                let navVC = UINavigationController.init(rootViewController: orgVC)
                navVC.modalPresentationStyle = .overCurrentContext
                if !hideBackButton{
                    showBackButton()
                }
                UIApplication.topViewController()?.present(navVC, animated: true, completion: nil)
            } else if viewMode == .fullScreen {
                let orgVC = Constant.getStoryboard(vc: self.classForCoder).instantiateViewController(withIdentifier: "BBConsentOrganisationViewController") as! BBConsentOrganisationViewController
                orgVC.organisationId = organisationId
                self.userId = userId
                let navVC = UINavigationController.init(rootViewController: orgVC)
                navVC.modalPresentationStyle = .fullScreen
                if !hideBackButton{
                    showBackButton()
                }
                UIApplication.topViewController()?.present(navVC, animated: true, completion: nil)
            }
        }
        
        if accessToken != "" {
            self.accessToken = accessToken
        }
    }

    func showBackButton(){
        let btn1 = UIButton(type: .custom)
        btn1.setImage(UIImage(named: "orgback"), for: .normal)
        btn1.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        btn1.addTarget(self, action: #selector(goBack), for: .touchUpInside)
        let item1 = UIBarButtonItem(customView: btn1)
        self.navigationItem.setRightBarButtonItems([item1], animated: true)
    }
    
    @objc func goBack(){
        self.dismiss(animated: true, completion: nil)
    }
}

// MARK: - 'Individual' related api calls
extension BBConsentPrivacyDashboardiOS {
    public func createAnIndividual(id:String?, externalId:String?, externalIdType: String?, identityProviderId: String?, name: String, iamId: String?, email: String, phone:String, pushNotificationToken: String?, deviceType: String?, completionBlock:@escaping (_ success: Bool, _ resultVal: [String: Any]) -> Void) {
        let individual = Individual(id: id, externalID: externalId, externalIDType: externalId, identityProviderID: identityProviderId, name: name, iamID: iamId, email: email, phone: phone, pushNotificationToken: pushNotificationToken, deviceType: deviceType)
        let record = IndividualRecord(individual: individual)
        let data = try! JSONEncoder.init().encode(record)
        let dictionary = try! JSONSerialization.jsonObject(with: data) as! [String: Any]
        
        BBConsentBaseWebService.shared.makeAPICall(urlString: Constant.URLStrings.createIndividual, parameters: dictionary, method: .post) { success, resultVal in
            if success {
                debugPrint(resultVal)
                completionBlock(true, resultVal)
                
            } else {
                debugPrint(resultVal)
                completionBlock(false, resultVal)
            }
        }
    }
    
    public func readAnIndividual(individualId: String,  completionBlock:@escaping (_ success: Bool, _ resultVal: [String: Any]) -> Void) {
        BBConsentBaseWebService.shared.makeAPICall(urlString: Constant.URLStrings.readIndividual + individualId, parameters: [:], method: .get) { success, resultVal in
            if success {
                debugPrint(resultVal)
                completionBlock(true, resultVal)
            } else {
                debugPrint(resultVal)
                completionBlock(false, resultVal)
            }
        }
    }
    
    public func updateAnIndividual(individualId: String, externalId:String?, externalIdType: String?, identityProviderId: String?, name: String, iamId: String?, email: String, phone:String, pushNotificationToken: String?, deviceType: String?, completionBlock:@escaping (_ success: Bool, _ resultVal: [String: Any]) -> Void) {
        let individual = Individual(id: individualId, externalID: externalId, externalIDType: externalId, identityProviderID: identityProviderId, name: name, iamID: iamId, email: email, phone: phone, pushNotificationToken: pushNotificationToken, deviceType: deviceType)
        let record = IndividualRecord(individual: individual)
        let data = try! JSONEncoder.init().encode(record)
        let dictionary = try! JSONSerialization.jsonObject(with: data) as! [String: Any]
        
        BBConsentBaseWebService.shared.makeAPICall(urlString: Constant.URLStrings.readIndividual + individualId, parameters: dictionary ,method: .put) { success, resultVal in
            if success {
                debugPrint(resultVal)
                completionBlock(true, resultVal)
            } else {
                debugPrint(resultVal)
                completionBlock(false, resultVal)
            }
        }
    }
    
    public func fetchAllIndividuals(completionBlock:@escaping (_ success: Bool, _ resultVal: [String: Any]) -> Void) {
        BBConsentBaseWebService.shared.makeAPICall(urlString: Constant.URLStrings.fetchAllIndividuals, parameters: [:] ,method: .get) { success, resultVal in
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

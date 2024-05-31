//
//  PrivacyDashboardiOS.swift
//  PrivacyDashboardiOS
//
//  Created by Mumthasir mohammed on 31/08/23.
//

import Foundation

class PrivacyDashboardiOS: UIViewController {
    static var shared = PrivacyDashboardiOS()
    public var turnOnUserRequests = false
    public var turnOnAskMeSection = false
    public var turnOnAttributeDetailScreen = false
    public var languageCode = "en"
    // Demo server by default
    public var baseUrl = "https://demo-consent-bb-api.igrant.io/v2"

    var orgId: String?
    var userId: String?
    var accessToken: String?
    var hideBackButton = false
    
    func log() {
        debugPrint("### Log from PrivacyDashboardiOS SDK.")
    }
    
    func show(organisationId: String, apiKey: String, userId: String, accessToken: String, animate: Bool = true) {
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
            _ = PDiOSKeyChainUtils.save(key: "BBConsentApiKey", data: data)
            
            let frameworkBundle = Bundle(for: PDOrganisationViewController.self)
            let bundleURL = frameworkBundle.resourceURL?.appendingPathComponent("PrivacyDashboardiOS.bundle") 
            var storyboard = UIStoryboard()
            if let resourceBundle = Bundle(url: bundleURL!) {
                storyboard = UIStoryboard(name: "PrivacyDashboard", bundle: resourceBundle)
            } else {
                let myBundle = Bundle(for: PDOrganisationViewController.self)
                storyboard = UIStoryboard(name: "PrivacyDashboard", bundle: myBundle)
            }
            
            let orgVC = storyboard.instantiateViewController(withIdentifier: "BBConsentOrganisationViewController") as? PDOrganisationViewController ?? PDOrganisationViewController()
            orgVC.organisationId = organisationId
            let navVC = UINavigationController.init(rootViewController: orgVC)
            navVC.modalPresentationStyle = .fullScreen
            UIApplication.topViewController()?.present(navVC, animated: animate, completion: nil)
            return
        }
        
        if userId != "" {
            let orgVC = Constant.getStoryboard(vc: self.classForCoder).instantiateViewController(withIdentifier: "BBConsentOrganisationViewController") as! PDOrganisationViewController
            orgVC.organisationId = organisationId
            self.userId = userId
            let navVC = UINavigationController.init(rootViewController: orgVC)
            navVC.modalPresentationStyle = .fullScreen
            if !hideBackButton{
                showBackButton()
            }
            UIApplication.topViewController()?.present(navVC, animated: true, completion: nil)
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
extension PrivacyDashboardiOS {
    public func createAnIndividual(id:String?, externalId:String?, externalIdType: String?, identityProviderId: String?, name: String, iamId: String?, email: String, phone:String, completionBlock:@escaping (_ success: Bool, _ resultVal: [String: Any]) -> Void) {
        let individual = Individual(id: id, externalID: externalId, externalIDType: externalId, identityProviderID: identityProviderId, name: name, iamID: iamId, email: email, phone: phone)
        let record = IndividualRecord(individual: individual)
        let data = try! JSONEncoder.init().encode(record)
        let dictionary = try! JSONSerialization.jsonObject(with: data) as! [String: Any]
        
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
    
    public func readAnIndividual(individualId: String,  completionBlock:@escaping (_ success: Bool, _ resultVal: [String: Any]) -> Void) {
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
    
    public func updateAnIndividual(individualId: String, externalId:String?, externalIdType: String?, identityProviderId: String?, name: String, iamId: String?, email: String, phone:String, completionBlock:@escaping (_ success: Bool, _ resultVal: [String: Any]) -> Void) {
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
    
    public func fetchAllIndividuals(completionBlock:@escaping (_ success: Bool, _ resultVal: [String: Any]) -> Void) {
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

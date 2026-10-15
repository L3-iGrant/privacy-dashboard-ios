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

    // Deprecated API key path.
    func show(organisationId: String, apiKey: String, userId: String, accessToken: String, animate: Bool = true, viewMode: ViewModeType, title: String?) {
        setLightAppearance()

        self.orgId = organisationId
        self.userId = userId
        if(!apiKey.isEmpty) {
            let data = apiKey.data(using: .utf8) ?? Data()
            _ = BBConsentKeyChainUtils.save(key: BBConsentKeyChainUtils.apiKeyAccount, data: data)
            present(organisationId: organisationId, animate: animate, viewMode: viewMode, title: title)
            return
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

    // Token provider path. `PrivacyDashboard.configure(baseUrl:organisationId:tokenProvider:)` sets the organisation.
    func show(animate: Bool = true, viewMode: ViewModeType, title: String?) {
        setLightAppearance()
        present(organisationId: orgId ?? "", animate: animate, viewMode: viewMode, title: title)
    }

    private func setLightAppearance() {
        if #available(iOS 13.0, *) {
            let appearance = UIView.appearance()
            appearance.overrideUserInterfaceStyle = .light
        }
    }

    private func present(organisationId: String, animate: Bool, viewMode: ViewModeType, title: String?) {
        if viewMode == .bottomSheet {
            let storyboard = UIStoryboard(name: "PrivacyDashboard", bundle: Bundle.module)
            let orgVC = storyboard.instantiateViewController(withIdentifier: "BBConsentOrganisationBottomSheetViewController") as? BBConsentOrganisationBottomSheetViewController ?? BBConsentOrganisationBottomSheetViewController()
            orgVC.organisationId = organisationId
            orgVC.onConsentChange = onConsentChange
            orgVC.dataAgreementIDs = dataAgreementIDs
            orgVC.titleValue = title
            orgVC.shouldShowAlertOnConsentChange = shouldShowAlertOnConsentChange
            orgVC.modalPresentationStyle = .overFullScreen
            UIApplication.topViewController()?.present(orgVC, animated: true, completion: nil)
        } else if viewMode == .fullScreen {
            let storyboard = UIStoryboard(name: "PrivacyDashboard", bundle: Bundle.module)
            let orgVC = storyboard.instantiateViewController(withIdentifier: "BBConsentOrganisationViewController") as? BBConsentOrganisationViewController ?? BBConsentOrganisationViewController()
            orgVC.organisationId = organisationId
            orgVC.onConsentChange = onConsentChange
            orgVC.dataAgreementIDs = dataAgreementIDs
            orgVC.shouldShowAlertOnConsentChange = shouldShowAlertOnConsentChange
            let navVC = UINavigationController.init(rootViewController: orgVC)
            navVC.modalPresentationStyle = .fullScreen
            UIApplication.topViewController()?.present(navVC, animated: animate, completion: nil)
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

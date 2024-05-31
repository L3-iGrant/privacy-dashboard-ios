//
//  PDDataSharingVC.swift
//  AFDateHelper
//
//  Created by Mumthasir mohammed on 09/11/23.
//

import Foundation
import Kingfisher

class PDDataSharingVC: PDBaseViewController, WebServiceTaskManagerProtocol, UITextViewDelegate {
    // MARK: IBOutlets
    @IBOutlet weak var authoriseButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var labelStackView: UIStackView!
    @IBOutlet weak var ourLogoImageView: UIImageView!
    @IBOutlet weak var thierLogoImageView: UIImageView!
    @IBOutlet weak var betweenLogosImageView: UIImageView!
    @IBOutlet weak var textLabelOne: UILabel!
    @IBOutlet weak var textLabelTwo: UILabel!
    @IBOutlet weak var textLabelThree: UILabel!
    @IBOutlet weak var dataAgreementTextView: UITextView!
    
    // MARK: Variables
    var organizationData : Organization?
    var organizationDetailsData : OrganisationDetails?
    var dataAgreementId: String?
    var theirLogoImageUrl: String?
    var theirOrgName: String?
    var termsOfServiceText: String?
    var termsOFServiceUrl: String?
    var cancelButtonText: String?
    var sendDataBack : (([String: Any]) -> Void)?
    
    // MARK: Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUI()
        self.callOrganisationDetailsApi()
    }
    
    func setUI() {
        cancelButton.backgroundColor = .clear
        cancelButton.layer.borderWidth = 1
        cancelButton.layer.borderColor = UIColor.black.cgColor
        cancelButton.setTitle(cancelButtonText, for: .normal)
        cancelButton.isHidden = true
        authoriseButton.isHidden = true
    }
    
    func setOrganisationInfo() {
        setLogoImageView()
        setDynamicTextInfos()
    }
    
    fileprivate func setDynamicTextInfos() {
        arrangeFirstLabel()
        // Second label
        textLabelTwo.text = "By clicking Authorise, \(theirOrgName ?? "") App will be able to read the following data attributes:"
        // Third label
        textLabelThree.text = "Make sure that you trust \(theirOrgName ?? "")"
        arrangeTermsAndServiceTextView()
    }
    
    fileprivate func setLogoImageView() {
        // Our logo image
        let modifier = AnyModifier { request in
            var r = request
            r.setValue("Bearer \(UserInfo.currentUser()?.token ?? "")", forHTTPHeaderField: "Authorization")
            if let tokendata = PDiOSKeyChainUtils.load(key: "BBConsentApiKey") {
                let token = String(data: tokendata, encoding: .utf8) ?? ""
                r.setValue("ApiKey \(token)", forHTTPHeaderField: "Authorization")
                r.setValue(PrivacyDashboardiOS.shared.userId ?? "", forHTTPHeaderField:  "X-ConsentBB-IndividualId")
            }
            return r
        }
        
        self.betweenLogosImageView.image = UIImage(named: "ic_between_logo", in: Bundle(for: type(of:self)), compatibleWith: nil)
        let logoUrlFromOrgData = URL(string: (organizationData?.logoImageURL ?? ""))
        let placeholder = UIImage(named: Constant.Images.iGrantTick, in: Constant.getResourcesBundle(vc: PDBaseViewController().classForCoder), compatibleWith: nil)
        if let logoUrlFromClient = URL(string: theirLogoImageUrl ?? "") {
            self.thierLogoImageView.kf.setImage(with: logoUrlFromClient, placeholder: placeholder, options: [.requestModifier(modifier)])
        }
        self.ourLogoImageView.kf.setImage(with: logoUrlFromOrgData, placeholder: placeholder, options: [.requestModifier(modifier)])
    }
    
    fileprivate func arrangeFirstLabel() {
        // First label
        let boldAttribute = [NSAttributedString.Key.foregroundColor: UIColor.black, NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 17)]
        let normalAttribute = [NSAttributedString.Key.foregroundColor: UIColor.black, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17)]
        
        let partOne = NSMutableAttributedString(string: theirOrgName ?? "", attributes: boldAttribute)
        let partTwo = NSMutableAttributedString(string: " wants to access the following data from ", attributes: normalAttribute)
        partOne.append(partTwo)
        
        var partThree = NSMutableAttributedString()
        var partFour = NSMutableAttributedString()
        partThree = NSMutableAttributedString(string: organizationData?.name ?? "", attributes: boldAttribute)
        partFour = NSMutableAttributedString(string: " for user", attributes: normalAttribute)
        
        partThree.append(partFour)
        partOne.append(partThree)
        textLabelOne.attributedText = partOne
    }
    
    fileprivate func arrangeTermsAndServiceTextView() {
        // Data agreement & Terms of service textview
        let normalAttributeTwo = [NSAttributedString.Key.foregroundColor: UIColor.black, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15)]
        let linkAttribute = [NSMutableAttributedString.Key.foregroundColor: UIColor.systemBlue, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15)]
        let dataAgreementTextOne = NSMutableAttributedString(string: "You may be sharing sensitive info with this site or app. See the ", attributes: normalAttributeTwo)
        let dataAgreementTextTwo = NSMutableAttributedString(string: "data agreement details ", attributes: linkAttribute)
        let dataAgreementTextThree = NSMutableAttributedString(string: "and ", attributes: normalAttributeTwo)
        let dataAgreementTextFour = NSMutableAttributedString(string: termsOfServiceText ?? "", attributes: linkAttribute)
        dataAgreementTextOne.append(dataAgreementTextTwo)
        dataAgreementTextOne.append(dataAgreementTextThree)
        dataAgreementTextOne.append(dataAgreementTextFour)
        
        _ = dataAgreementTextOne.setSubstringAsLink(substring: "data agreement details", linkURL: "dataAgreement://")
        _ = dataAgreementTextOne.setSubstringAsLink(substring: termsOfServiceText ?? "", linkURL: termsOFServiceUrl ?? "")
        dataAgreementTextView.delegate = self
        dataAgreementTextView.attributedText = dataAgreementTextOne
        dataAgreementTextView.isSelectable = true
        dataAgreementTextView.isEditable = false
        dataAgreementTextView.isUserInteractionEnabled = true
    }
    
    func createAttributesView() {
        let purpose = organizationDetailsData?.purposeConsents?.filter({ $0.iD == dataAgreementId })
        let dataAttributes = purpose?.map({ $0.dataAttributes })
        let someArray = dataAttributes?[0]?.map({ $0.name }) ?? []
        for nValue in someArray {
            let label = PaddingLabel()
            label.edgeInset = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)
            label.attributedText = NSAttributedString(string: nValue ?? "", attributes:
                                                        [.underlineStyle: NSUnderlineStyle.single.rawValue])
            label.textColor = .black
            labelStackView.addArrangedSubview(label)
        }
        labelStackView.backgroundColor = .lightGray.withAlphaComponent(0.2)
        labelStackView.layer.cornerRadius = 10
        
    }
    
    // MARK: IBActions
    @IBAction func tapOnCancel(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func tapOnAuthoriseButton(_ sender: Any) {
        // Calling create record Api call then,
        // Return the reponse
        self.createRecordApiCall()
    }
    
    // MARK: API Calls
    func createRecordApiCall() {
        self.addLoadingIndicator()
        PDBaseWebService.shared.makeAPICall(urlString: Constant.URLStrings.fetchDataAgreementRecord + (dataAgreementId ?? ""), parameters: [:], method: .post) { success, resultVal in
            if success {
                debugPrint(resultVal)
                self.sendDataBack?(resultVal)
                self.removeLoadingIndicator()
                self.dismiss(animated: true)
            } else {
                debugPrint(resultVal)
                self.sendDataBack?(resultVal)
                self.removeLoadingIndicator()
                self.dismiss(animated: true)
            }
        }
    }
    
    func callOrganizationApi(){
        self.addLoadingIndicator()
        let serviceManager = OrganisationWebServiceManager()
        serviceManager.managerDelegate = self
        serviceManager.getOrganization(orgId: "")
    }
    
    func callOrganisationDetailsApi(){
        let serviceManager = OrganisationWebServiceManager()
        serviceManager.managerDelegate = self
        serviceManager.getOrganisationDetails(orgId: PrivacyDashboardiOS.shared.orgId ?? "")
    }
    
    // MARK: Delegate methods
    func didFinishTask(from manager: AnyObject, response: (data: RestResponse?, error: String?)) {
        if response.error != nil {
            if let serviceManager = manager as? OrganisationWebServiceManager {
                if serviceManager.serviceType == .Organization {
                    
                }
            }
            showErrorAlert(message: (response.error)!)
            return
        }
        
        if let serviceManager = manager as? OrganisationWebServiceManager {
            if serviceManager.serviceType == .Organization {
                if let data = response.data?.responseModel as? Organization {
                    organizationData = data
                    setOrganisationInfo()
                }
            } else if serviceManager.serviceType == .OrgDetails {
                if let data = response.data?.responseModel as? OrganisationDetails {
                    organizationDetailsData = data
                    let dataAgreementRecord = organizationDetailsData?.purposeConsents?.filter({ $0.iD == dataAgreementId })
                    if dataAgreementRecord?.count ?? 0 > 0, dataAgreementRecord?[0].methodOfUse == "data_source" &&  dataAgreementRecord?[0].thirdPartyDisclosure == "true" {
                        callOrganizationApi()
                        createAttributesView()
                        cancelButton.isHidden = false
                        authoriseButton.isHidden = false
                        self.removeLoadingIndicator()
                    } else {
                        self.dismiss(animated: false)
                    }
                }
            }
        }
    }
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        if (URL.absoluteString == "dataAgreement://") {
            let dataAgreementRecord = organizationDetailsData?.purposeConsents?.filter({ $0.iD == dataAgreementId })
            let dataAgreementVC = Constant.getStoryboard(vc: self.classForCoder).instantiateViewController(withIdentifier: "BBConsentDataAgreementVC") as! PDDataAgreementVC
            dataAgreementVC.dataAgreement = dataAgreementRecord
            self.navigationController?.pushViewController(dataAgreementVC, animated: true)
        } else if (URL.absoluteString == termsOFServiceUrl) {
            let url = Foundation.URL(string: termsOFServiceUrl ?? "")!
            UIApplication.shared.open(url)
        }
        return false
    }
}

// Padding Label
class PaddingLabel: UILabel {
    var edgeInset: UIEdgeInsets = .zero
    override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets.init(top: edgeInset.top, left: edgeInset.left, bottom: edgeInset.bottom, right: edgeInset.right)
        super.drawText(in: rect.inset(by: insets))
    }

    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + edgeInset.left + edgeInset.right, height: size.height + edgeInset.top + edgeInset.bottom)
    }
}

//
//  BBConsentAttributesViewController.swift
//  PrivacyDashboardiOS
//
//  Created by Mumthasir mohammed on 08/09/23.
//

import UIKit
import ExpandableLabel

class BBConsentAttributesViewController: BBConsentBaseViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var disAllowAllBtn: UIButton!
    @IBOutlet  var disAllowAllBtnHeightCostrint: NSLayoutConstraint!
   
    var overViewCollpased = true
    var dataAgreementsModel : DataAgreementsModel?
    var organization : OrganisationModel?
    var purposeInfo : DataAgreements?
    var consentslist : [ConsentDetails]?
    var consentslistInfo : ConsentListingResponse?
    var dataAttributes: [DataAttribute]?
    var count: Count?
    var consentVal: Bool?
    var isNeedToRefresh = false
    var isFromQR = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        addRefershNotification()
        callConsentListApi()
        manageDisallowButton()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        managePolicyButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
        self.title = purposeInfo?.purpose.unCamelCased
        if isNeedToRefresh == true {
            isNeedToRefresh = false
            callConsentListApi()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
    }
    
    func addRefershNotification() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self,
                                       selector: #selector(BBConsentAttributesViewController.consentValueModified),
                                       name: .consentChange,
                                       object: nil)
    }
    
    
    func managePolicyButton() {
        self.tableView.reloadData()
    }
    
    func manageDisallowButton() {
        if self.consentslistInfo?.consents?.purpose?.lawfulUsage == false {
            if count?.consented != nil {
                if (count?.consented )! < 1 {
                    disAllowAllBtn.isHidden = true
                    disAllowAllBtnHeightCostrint.constant = 0
                } else {
                    disAllowAllBtn.isHidden = false
                    disAllowAllBtnHeightCostrint.constant = 45
                }
            }
        } else {
            disAllowAllBtn.isHidden = true
            disAllowAllBtnHeightCostrint.constant = 0
        }
    }
    
    @objc func consentValueModified() {
        isNeedToRefresh = true
    }
    
    @IBAction func policyBtnClicked() {
        if let url = dataAgreementsModel?.dataAgreements[0].policy.url {
            if url.isValidString{
                let webviewVC = self.storyboard?.instantiateViewController(withIdentifier: Constant.ViewControllerID.webViewVC) as! BBConsentWebViewViewController
                webviewVC.urlString = url
                self.navigationController?.pushViewController(webviewVC, animated: true)
            }else{
                self.showErrorAlert(message: Constant.Alert.invalidURL)
            }
        }
    }
    
    @IBAction func disallowallBtnClicked() {
        showConfirmationAlert()
    }
    
    func callConsentListApi() {
        self.addLoadingIndicator()
        let serviceManager = OrganisationWebServiceManager()
        serviceManager.managerDelegate = self
        serviceManager.consentList(dataAgreementId: purposeInfo?.id ?? "")
    }
    
    func showConfirmationAlert() {
        let alerController = UIAlertController(title: Constant.AppSetupConstant.KAlertTitle, message: Constant.Alert.areYouWantToDisallowAll, preferredStyle: .alert)
        alerController.addAction(UIAlertAction(title: Constant.Alert.disallowAll.localized, style: .destructive, handler: {(action:UIAlertAction) in
            self.callDisallowAllApi()
        }));
        alerController.addAction(UIAlertAction(title: Constant.Strings.cancel.localized, style: .cancel, handler: {(action:UIAlertAction) in
        }));
        present(alerController, animated: true, completion: nil)
    }
    
    func callDisallowAllApi(){
        self.addLoadingIndicator()
        let serviceManager = OrganisationWebServiceManager()
        serviceManager.managerDelegate = self
        let value = "Disallow"
        NotificationCenter.default.post(name: .consentChange, object: nil)
//        serviceManager.updatePurpose(orgId: self.organisaionDeatils?.organization?.iD ?? "", consentID:  self.organisaionDeatils?.consentID ?? "" , attributeId: "", purposeId: purposeInfo?.iD ?? "", status: value)
    }
}

extension BBConsentAttributesViewController: WebServiceTaskManagerProtocol {
    
    func didFinishTask(from manager:AnyObject, response:(data:RestResponse?,error:String?)){
        self.removeLoadingIndicator()
        
        if response.error != nil {
            self.showErrorAlert(message: (response.error)!)
            return
        }
        
        if let serviceManager = manager as? OrganisationWebServiceManager {
            if serviceManager.serviceType == .AllowAlConsent{
                //  self.callOrganisationDetailsApi()
            }
            else if serviceManager.serviceType == .UpdatePurpose{
                disAllowAllBtn.isHidden = true
                disAllowAllBtnHeightCostrint.constant = 0
                callConsentListApi()
            }
        }
        
        if let data = response.data?.responseModel as? ConsentListingResponse {
            self.consentslistInfo = data
            self.dataAttributes = data.dataAttributes
            self.consentslist = data.consents?.consentslist
            self.tableView.reloadData()
            manageDisallowButton()
            managePolicyButton()
        }
    }
}

extension  BBConsentAttributesViewController : UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if dataAttributes == nil {
            return 0
        } else {
            if section == 0 {
                return 2
            }
            return (dataAttributes?.count)!
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNonzeroMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return UITableView.automaticDimension
        }
        return 70
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            switch indexPath.row {
            case 0:
                let orgOverViewCell = tableView.dequeueReusableCell(withIdentifier: Constant.CustomTabelCell.KOrgDetailedOverViewCellID, for: indexPath) as! BBConsentDashBoardOverviewCell
                //    orgOverViewCell.overViewLbl.text = organisaionDeatils?.organization?.descriptionField
                
                orgOverViewCell.overViewLbl.delegate = self
                orgOverViewCell.layoutIfNeeded()
                orgOverViewCell.overViewLbl.shouldCollapse = true
                orgOverViewCell.overViewTitleLbl?.text = "bb_consent_dashboard_overview".localized

                if overViewCollpased == true {
                    //   orgOverViewCell.overViewLbl.collapsed = overViewCollpased
                    //   orgOverViewCell.overViewLbl.numberOfLines = 3
                    orgOverViewCell.overViewLbl.collapsed = true
                    
                } else {
                    orgOverViewCell.overViewLbl.collapsed = false
                    //   orgOverViewCell.overViewLbl.numberOfLines = 0
                }
                orgOverViewCell.overViewLbl.textReplacementType = .word
                if purposeInfo?.purposeDescription != nil {
                    let desc = purposeInfo?.purposeDescription
                    orgOverViewCell.overViewLbl.text = desc
                }
                return orgOverViewCell
            default:
                let consentHeaderCell = tableView.dequeueReusableCell(withIdentifier: Constant.CustomTabelCell.consentHeaderTableViewCell,for: indexPath) as! BBConsentAttributesHeaderCell
                
                if let url = dataAgreementsModel?.dataAgreements[0].policy.url {
                    if url.isValidString{
                        consentHeaderCell.policyButton.isHidden = false
                    }else{
                        consentHeaderCell.policyButton.isHidden = true
                    }
                }else{
                    consentHeaderCell.policyButton.isHidden = true
                }
                consentHeaderCell.policyButton.showRoundCorner(roundCorner: 3.0)
                consentHeaderCell.policyButton.layer.borderColor = UIColor(red:0.62, green:0.62, blue:0.62, alpha:1).cgColor
                consentHeaderCell.policyButton.layer.borderWidth = 0.5
                consentHeaderCell.policyButton.addTarget(self, action: #selector(policyBtnClicked), for: .touchUpInside)
                consentHeaderCell.policyButton.setTitle("bb_consent_data_attribute_read_policy".localized, for: .normal)
                return consentHeaderCell
                
            }
        }
                
        let consentCell = tableView.dequeueReusableCell(withIdentifier:Constant.CustomTabelCell.consentCell ,for: indexPath) as! BBConsentAttributeTableViewCell
        consentCell.rightArrow.isHidden = BBConsentPrivacyDashboardiOS.shared.turnOnAttributeDetailScreen == true ? false : true
        consentCell.consentInfo = dataAttributes?[indexPath.row]
        consentCell.consent = consentVal
        consentCell.showData()
        if isFromQR {
            consentCell.consentTypeLbl.text =  Constant.Alert.allow.localized
            //  consentCell.rightArrow.isHidden = true
        }
        return consentCell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 && BBConsentPrivacyDashboardiOS.shared.turnOnAttributeDetailScreen {
            if self.consentslistInfo?.consents?.purpose?.lawfulUsage == false && !isFromQR {
                let consentVC = self.storyboard?.instantiateViewController(withIdentifier: Constant.ViewControllerID.consentVC) as! BBConsentAttributesDetailViewController
                consentVC.consent = consentslist?[indexPath.row]
                consentVC.orgID = self.consentslistInfo?.orgID
                consentVC.purposeDetails = self.consentslistInfo
                consentVC.purposeName = self.purposeInfo?.controllerName ?? ""
                self.navigationController?.pushViewController(consentVC, animated: true)
            }
        }
    }
}

extension BBConsentAttributesViewController: ExpandableLabelDelegate {
    func willExpandLabel(_ label: ExpandableLabel) {
        overViewCollpased = false
        tableView.reloadData()
    }
    
    func didExpandLabel(_ label: ExpandableLabel) {}
    
    func willCollapseLabel(_ label: ExpandableLabel) {}
    
    func didCollapseLabel(_ label: ExpandableLabel) {
        overViewCollpased = true
        tableView.reloadData()
    }
}

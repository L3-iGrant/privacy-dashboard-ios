//
//  BBConsentAttributesBottomSheetViewController.swift
//  Pods
//
//  Created by iGrant on 30/04/25.
//

import Foundation
import UIKit

protocol BBConsentAttributesBottomSheetDelegate: AnyObject {
    func consentAttributesBottomSheetDidTapClose()
}

class BBConsentAttributesBottomSheetViewController: BBConsentBaseViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var dataAttributeLabel: UILabel!
    
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var parentViewheight: NSLayoutConstraint!
    
    @IBOutlet weak var readPolicyButton: UIButton!
    
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
        setDecriptionText()
        tableView.dataSource = self
        tableView.delegate = self
        addRefershNotification()
        callConsentListApi()
        setPolicyButton()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(baseViewTapped))
        tapGesture.delegate = self
        self.view.addGestureRecognizer(tapGesture)
    }
    
    @objc func baseViewTapped() {}
    
    func setPolicyButton() {
        if let url = dataAgreementsModel?.dataAgreements[0].policy.url {
            if url.isValidString{
                readPolicyButton.isHidden = false
            }else{
                readPolicyButton.isHidden = true
            }
        }else{
            readPolicyButton.isHidden = true
        }
        readPolicyButton.showRoundCorner(roundCorner: 3.0)
        readPolicyButton.layer.borderColor = UIColor(red:0.62, green:0.62, blue:0.62, alpha:1).cgColor
        readPolicyButton.layer.borderWidth = 0.5
        readPolicyButton.setTitle("bb_consent_data_attribute_read_policy".localized, for: .normal)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let screenHeight = UIScreen.main.bounds.height
        let sheetHeight = screenHeight * 0.85
        parentViewheight.constant = sheetHeight
        if isNeedToRefresh == true {
            isNeedToRefresh = false
            callConsentListApi()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        managePolicyButton()
    }
    
    func callConsentListApi() {
        self.addLoadingIndicator()
        let serviceManager = OrganisationWebServiceManager()
        serviceManager.managerDelegate = self
        serviceManager.consentList(dataAgreementId: purposeInfo?.id ?? "")
    }
    
    @IBAction func readPolicyButtonTapped(_ sender: Any) {
        if let url = dataAgreementsModel?.dataAgreements[0].policy.url {
            if url.isValidString{
                let webviewVC = self.storyboard?.instantiateViewController(withIdentifier: "BBConsentWebViewBottomSheetVC") as! BBConsentWebViewBottomSheetVC
                webviewVC.urlString = url
                webviewVC.modalPresentationStyle = .overFullScreen
                present(webviewVC, animated: true)
            }else{
                self.showErrorAlert(message: Constant.Alert.invalidURL)
            }
        }
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
    
    func setDecriptionText() {
        titleLabel.text = purposeInfo?.purpose.unCamelCased
        if purposeInfo?.purposeDescription != nil {
            let desc = purposeInfo?.purposeDescription
            descriptionLabel.text = desc
        }
    }
    
    @IBAction func closeTapped(_ sender: Any) {
        dismiss(animated: true)
    }
    
    
}

extension BBConsentAttributesBottomSheetViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataAttributes?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let consentCell = tableView.dequeueReusableCell(withIdentifier:Constant.CustomTabelCell.consentCell ,for: indexPath) as! BBConsentAttributeTableViewCell
        consentCell.rightArrow.isHidden = BBConsentPrivacyDashboardiOS.shared.turnOnAttributeDetailScreen == true ? false : true
        consentCell.consentInfo = dataAttributes?[indexPath.row]
        consentCell.consent = consentVal
        consentCell.showData()
        let isLastCell = indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1
        consentCell.divider.isHidden = isLastCell
        if isFromQR {
            consentCell.consentTypeLbl.text =  Constant.Alert.allow.localized
            //  consentCell.rightArrow.isHidden = true
        }
        return consentCell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }
    
}

extension BBConsentAttributesBottomSheetViewController: WebServiceTaskManagerProtocol {
    
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
                
                callConsentListApi()
            }
        }
        
        if let data = response.data?.responseModel as? ConsentListingResponse {
            self.consentslistInfo = data
            self.dataAttributes = data.dataAttributes
            self.consentslist = data.consents?.consentslist
            self.tableView.reloadData()
            updateTableViewHeight()
            managePolicyButton()
        }
    }
    
    private func updateTableViewHeight() {
            let rowHeight = 65.0
            let numberOfRows = tableView.numberOfRows(inSection: 0)
            let totalHeight = CGFloat(numberOfRows) * rowHeight
            
            tableViewHeightConstraint.constant = totalHeight
            UIView.animate(withDuration: 0.1) {
                self.view.layoutIfNeeded()
            }
        }
}

extension BBConsentAttributesBottomSheetViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        // Ignore taps inside the table view
        if let touchedView = touch.view, touchedView.isDescendant(of: tableView) {
            return false
        }
        return true
    }
}

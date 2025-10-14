//
//  BBConsentOrganisationBottomSheetViewController.swift
//  PrivacyDashboardiOS
//
//  Created by iGrant on 30/04/25.
//

import Foundation
import UIKit

class BBConsentOrganisationBottomSheetViewController: BBConsentBaseViewController, PurposeCellDelegate {
    
    func purposeSwitchValueChanged(status:Bool,purposeInfo:PurposeConsent?,cell:BBConsentDashboardUsagePurposeCell, shouldShowPopup: Bool) {
        
        let performAction = {
            let filteredRecord = self.consentRecordsObj?.consentRecords.filter { $0.dataAgreementID == self.dataAgreementsObj?.dataAgreements[cell.tag].id }
            
            if status == false {
                if let record = filteredRecord?.first {
                    self.callUpdatePurposeApi(dataAgreementRecordId: record.id , dataAgreementId: record.dataAgreementID , status: status) { success, consentRecordID in
                        if success {
                            if let onConsentChange = self.onConsentChange {
                                onConsentChange(status, record.dataAgreementID , consentRecordID )
                            }
                            record.optIn = status
                            self.tableView.reloadData()
                        }
                    }
                }
            } else {
                if let record = filteredRecord?.first {
                    self.callUpdatePurposeApi(dataAgreementRecordId: record.id , dataAgreementId: record.dataAgreementID , status: status) { success, consentRecordID in
                        if success {
                            if let onConsentChange = self.onConsentChange {
                                onConsentChange(status, record.dataAgreementID , consentRecordID )
                            }
                            record.optIn = status
                            self.tableView.reloadData()
                        }
                    }
                } else {
                    self.callCreateDataAgreementApi(dataAgreementId: self.dataAgreementsObj?.dataAgreements[cell.tag].id ?? "") { model in
                        if let consentRecordModel = model {
                            if let onConsentChange = self.onConsentChange {
                                onConsentChange(status, self.dataAgreementsObj?.dataAgreements[cell.tag].id ?? "" , consentRecordModel.id )
                            }
                            self.consentRecordsObj?.consentRecords.append(consentRecordModel)
                            self.tableView.reloadData()
                        }
                    }
                }
            }
        }
        if shouldShowPopup {
            let alrtMsg = status ? Constant.Alert.areYouSureYouWantToAllow.localized : Constant.Alert.areYouSureYouWantToDisAllow.localized
            let value = status ? Constant.Alert.allow.localized : Constant.Alert.disallow.localized
            
            let alertController = UIAlertController(title: Constant.AppSetupConstant.KAlertTitle, message: alrtMsg, preferredStyle: .alert)
            
            alertController.addAction(UIAlertAction(title: Constant.Strings.cancel.localized, style: status ? .destructive : .cancel) { _ in
                cell.statusSwitch.isOn = !cell.statusSwitch.isOn
            })
            
            alertController.addAction(UIAlertAction(title: value, style: status ? .default : .destructive) { _ in
                performAction()
            })
            
            present(alertController, animated: true, completion: nil)
        } else {
            performAction()
        }
    }
    
    
    @IBOutlet weak var parentView: UIView!
    @IBOutlet weak var closeButton: UIButton!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var moreButton: UIButton!
    
    @IBOutlet weak var overviewTitle: UILabel!
    
    @IBOutlet weak var overViewDescription: UILabel!
    
    @IBOutlet weak var dataAgreementsLabel: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var parentViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var noDataAgreementsLbl: UILabel!
    
    @IBOutlet weak var dimmedView: UIView!
    
    var organisationId = ""
    var isNeedToRefresh = false
    var overViewCollpased = true
    let popover = BBConsentPopOver()
    
    let baseUrl = BBConsentPrivacyDashboardiOS.shared.baseUrl
    let api = OrganisationWebService()
    var dataAgreementsObj: DataAgreementsModel?
    var consentRecordsObj : RecordsModel?
    var organizationObj : OrganisationModel?
    var titleValue: String?
    
    public var onConsentChange: ((Bool, String, String) -> Void)?
    var shouldShowAlertOnConsentChange: Bool?
    var dataAgreementIDs: [String]? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupInitialState()
        self.noDataAgreementsLbl.isHidden = true
        tableView.delegate = self
        tableView.dataSource = self
        parentView.layer.cornerRadius = 15
        callDataAgreementsApi { _ in
            if self.dataAgreementsObj?.dataAgreements.count == 0 {
                self.noDataAgreementsLbl.isHidden = false
                self.noDataAgreementsLbl.text = "No active data agreements available"
            } else {
                self.noDataAgreementsLbl.isHidden = true
            }
            self.callRecordsApi()
        }
        callOrganisationApi()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(baseViewTapped))
        tapGesture.delegate = self
        self.view.addGestureRecognizer(tapGesture)
    }
    
    @objc func baseViewTapped() {}
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animatePresentation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let screenHeight = UIScreen.main.bounds.height
       // let sheetHeight = screenHeight * 0.75
        let sheetHeight = screenHeight * 0.85
        parentViewHeight.constant = sheetHeight
        if isNeedToRefresh == true{
            isNeedToRefresh = false
            callDataAgreementsApi { _ in }
        }
        titleLabel.text = titleValue
    }
    
    private func setupViews() {
        // Ensure main view is clear
        self.view.backgroundColor = UIColor.clear
        
        // Add dimming view
        let dimmingView = UIView()
        dimmingView.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        dimmingView.frame = self.view.bounds
        dimmingView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        dimmingView.alpha = 0 // Start invisible
        dimmingView.tag = 999 // For easy reference
        self.view.insertSubview(dimmingView, at: 0)
        
    }

    
    private func animatePresentation() {
        // First animate the dimming view
        UIView.animate(withDuration: 0.2) {
            if let dimmingView = self.view.viewWithTag(999) {
                dimmingView.alpha = 1
            }
        }
        
        // Then animate the bottom sheet
        UIView.animate(withDuration: 0.3, delay: 0.1, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: .curveEaseOut) {
            self.parentView.transform = .identity
        }
    }

    private func setupInitialState() {
        // Start with bottom sheet off-screen
        let screenHeight = UIScreen.main.bounds.height
        parentView.transform = CGAffineTransform(translationX: 0, y: screenHeight)
    }
    
    func callOrganisationApi() {
        let url =  baseUrl + "/service/organisation"
        self.api.makeAPICall(urlString: url, method:.get) { status, result in
            if status {
                let jsonDecoder = JSONDecoder()
                if let data = try? JSONSerialization.data(withJSONObject: result, options: .prettyPrinted) {
                    let model = try? jsonDecoder.decode(OrganisationModel.self, from: data)
                    debugPrint("### Organiosation:\(String(describing: model))")
                    self.organizationObj = model
                    self.setOverviewText()
                }
            }
        }
    }
    
    @IBAction func closeButtonTapped(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @IBAction func moreButtonTapped(_ sender: Any) {
        
        let actionSheetController: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        // Create an action
        let firstAction: UIAlertAction = UIAlertAction(title: Constant.Strings.privacyPolicy.localized, style: .default) { action -> Void in
            
            if let privacyPolicy =  self.organizationObj?.organisation.policyURL {
                if self.verifyUrl(urlString: privacyPolicy) {
                    let webviewVC = self.storyboard?.instantiateViewController(withIdentifier: "BBConsentWebViewBottomSheetVC") as! BBConsentWebViewBottomSheetVC
                    webviewVC.urlString = privacyPolicy
                    webviewVC.modalPresentationStyle = .overFullScreen
                    self.present(webviewVC, animated: true)
                } else {
                    self.showWarningAlert(message: Constant.Alert.KPromptMsgNotConfigured)
                }
            }
        }
        
        let secondAction: UIAlertAction = UIAlertAction(title: Constant.Strings.userRequests.localized, style: .default) { action -> Void in
            self.showRequestedStatus()
        }
        
        let thirdAction: UIAlertAction = UIAlertAction(title: Constant.Strings.consentHistory.localized, style: .default) { action -> Void in
            self.showConsentHistory()
        }
        
        let cancelAction: UIAlertAction = UIAlertAction(title: Constant.Strings.cancel.localized, style: .cancel) { action -> Void in }
        
        // Add actions
        actionSheetController.addAction(firstAction)
        if BBConsentPrivacyDashboardiOS.shared.turnOnUserRequests {
            actionSheetController.addAction(secondAction)
        }
        actionSheetController.addAction(thirdAction)
        actionSheetController.addAction(cancelAction)
        
        actionSheetController.popoverPresentationController?.sourceView = moreButton
        
        present(actionSheetController, animated: true) {
            debugPrint("#Option menu presented")
        }
        
    }
    
    func verifyUrl(urlString: String?) -> Bool {
        guard let urlString = urlString,
              let url = URL(string: urlString) else {
            return false
        }
        return UIApplication.shared.canOpenURL(url)
    }
    
    func showRequestedStatus() {
        let RequestStatusHistoryVC = Constant.getStoryboard(vc: self.classForCoder).instantiateViewController(withIdentifier: Constant.ViewControllerID.requestStatusHistoryVC) as! BBConsentRequestStatusViewController
        RequestStatusHistoryVC.orgId = organisationId
        navigationController?.pushViewController(RequestStatusHistoryVC, animated: true)
    }
    
    func showConsentHistory() {
        let ConsentHistoryVC = Constant.getStoryboard(vc: self.classForCoder).instantiateViewController(withIdentifier: "BBConsentHistoryBottomSheetViewController") as! BBConsentHistoryBottomSheetViewController
        ConsentHistoryVC.orgId = organisationId
        ConsentHistoryVC.modalPresentationStyle = .overFullScreen
        present(ConsentHistoryVC, animated: true)
    }
    
    func callDataAgreementsApi(completion: @escaping(Bool)-> Void) {
        let url = baseUrl + "/service/data-agreements?offset=0&limit=500"
        self.api.makeAPICall(urlString: url, method:.get) { status, result in
            if status {
                let jsonDecoder = JSONDecoder()
                if let data = try? JSONSerialization.data(withJSONObject: result, options: .prettyPrinted) {
                    let model = try? jsonDecoder.decode(DataAgreementsModel.self, from: data)
                    debugPrint("### DataAgreements:\(String(describing: model))")
                    if self.dataAgreementIDs ==  nil {
                        self.dataAgreementsObj = model
                    } else {
                        guard let model = model, let dataAgreementIDs = self.dataAgreementIDs else {
                            return
                        }
                        let record = model.dataAgreements.filter({dataAgreementIDs.contains( $0.id)})
                        let pagination = model.pagination
                        self.dataAgreementsObj = DataAgreementsModel(dataAgreements: record, pagination: pagination)
                    }
                    completion(true)
                }
            }
        }
    }
    
    func callRecordsApi() {
        let url = baseUrl + "/service/individual/record/consent-record?offset=0&limit=500"
        self.api.makeAPICall(urlString: url, method:.get) { status, result in
            if status {
                let jsonDecoder = JSONDecoder()
                if let data = try? JSONSerialization.data(withJSONObject: result, options: .prettyPrinted) {
                    let model = try? jsonDecoder.decode(RecordsModel.self, from: data)
                    debugPrint("### Records:\(String(describing: model))")
                    self.consentRecordsObj = model
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                    self.CheckAndCreateRecordForContractType()
                }
            }
        }
    }
    
    func callCreateDataAgreementApi(dataAgreementId: String, completion: @escaping(ConsentRecordModel?)-> Void) {
        let url = baseUrl + "/service/individual/record/data-agreement/" + dataAgreementId
        self.api.makeAPICall(urlString: url, method:.post) { status, result in
            if status {
                let jsonDecoder = JSONDecoder()
                debugPrint(result["consentRecord"] ?? [:])
                if let data = try? JSONSerialization.data(withJSONObject: result["consentRecord"] ?? [:], options: .prettyPrinted) {
                    let model = try? jsonDecoder.decode(ConsentRecordModel.self, from: data)
                    debugPrint("### ConsentRecordModel:\(String(describing: model))")
                    completion(model)
                }
            }
        }
    }
    
    func callUpdatePurposeApi(dataAgreementRecordId: String, dataAgreementId: String, status: Bool, updateCompletion: @escaping (Bool, String) -> ()) {
        let url = baseUrl + "/service/individual/record/consent-record/" + dataAgreementRecordId + "?dataAgreementId=" + dataAgreementId
        let params  = ["optIn" : status]
        self.api.makeAPICall(urlString: url,parameters: params, method:.put) { status, result in
            if status {
                let resultDict = result["consentRecord"] as? [String: Any]
                let consentRecordID = resultDict?["id"] as? String
                updateCompletion(true, consentRecordID ?? "")
            }
        }
    }
    
    
    func CheckAndCreateRecordForContractType() {
        let dataAgreementIDs = dataAgreementsObj?.dataAgreements.filter({ $0.lawfulBasis != "consent" && $0.lawfulBasis != "legitimate_interest"  }).map({ $0.id }) ?? []
        let idsWithAttributeRecords = consentRecordsObj?.consentRecords.map({ $0.dataAgreementID }) ?? []
        let recordIds = consentRecordsObj?.consentRecords.map({ $0.id }) ?? []
        
        for item in dataAgreementIDs {
            // If item doesnt have record already
            if !idsWithAttributeRecords.contains(item) {
                // Create add record api call
                callCreateDataAgreementApi(dataAgreementId: item) { model in
                    if let consentRecordModel = model {
                        self.consentRecordsObj?.consentRecords.append(consentRecordModel)
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                    }
                }
            } else {
                // Update record api call
                let indexOfItem = idsWithAttributeRecords.firstIndex(of: item) ?? 0
                callUpdatePurposeApi(dataAgreementRecordId: recordIds[indexOfItem], dataAgreementId: item, status: true) { success, _  in
                    if success {
                        self.consentRecordsObj?.consentRecords[indexOfItem].optIn = true
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                    }
                }
            }
        }
    }
    
    func setOverviewText() {
        if organizationObj?.organisation.description != nil {
            let desc = organizationObj?.organisation.description
            overViewDescription.text = desc
        }
        overviewTitle.text = "bb_consent_dashboard_overview".localized.uppercased()
    }
    
}

extension BBConsentOrganisationBottomSheetViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (dataAgreementsObj?.dataAgreements.count ?? 0) > 0 {
            return  dataAgreementsObj?.dataAgreements.count ?? 0
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let consentCell = tableView.dequeueReusableCell(withIdentifier:Constant.CustomTabelCell.purposeCell,for: indexPath) as! BBConsentDashboardUsagePurposeCell
        consentCell.tag = indexPath.row
        consentCell.consentInfo = dataAgreementsObj?.dataAgreements[indexPath.row]
        consentCell.shouldShowAlertOnConsentChange = shouldShowAlertOnConsentChange
        // Note: filtering dataAgreement from records to check 'optIn' value (both are getting from two api's)
        let dataAgreementIdsFromOrg =  dataAgreementsObj?.dataAgreements.map({ $0.id })
        let record = consentRecordsObj?.consentRecords.filter({ $0.dataAgreementID == dataAgreementIdsFromOrg?[indexPath.row]})
        consentCell.swictOn = record?.count ?? 0 > 0 ?  record?[0].optIn ?? false : false
        
        var consentedCount = dataAgreementsObj?.dataAgreements[indexPath.row].dataAttributes.count
        var totalCount = dataAgreementsObj?.dataAgreements[indexPath.row].dataAttributes.count
        
        if record?.count ?? 0 > 0, record?[0].optIn  == false {
            consentedCount = 0
            totalCount = 0
        } else if record?.count == 0 || record?.count == nil {
            consentedCount = 0
            totalCount = 0
        }
        
        consentCell.consentedCount = consentedCount
        consentCell.totalCount = totalCount
        consentCell.delegate = self
        consentCell.showData()
        return consentCell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let consentVC = Constant.getStoryboard(vc: self.classForCoder).instantiateViewController(withIdentifier: "BBConsentAttributesBottomSheetViewController") as! BBConsentAttributesBottomSheetViewController
        consentVC.dataAgreementsModel = self.dataAgreementsObj
        consentVC.organization = self.organizationObj
        consentVC.purposeInfo = dataAgreementsObj?.dataAgreements[indexPath.row]
        
        // Note: filtering dataAgreement from records to check 'optIn' value (both are getting from different api's)
        let dataAgreementIdsFromOrg = dataAgreementsObj?.dataAgreements.map({ $0.id })
        let record = consentRecordsObj?.consentRecords.filter({ $0.dataAgreementID == dataAgreementIdsFromOrg?[indexPath.row]})
        consentVC.consentVal = record?.count ?? 0 > 0 ? record?[0].optIn ?? false : false
        consentVC.modalPresentationStyle = .overFullScreen
        present(consentVC, animated: true)
    }
    
}

extension BBConsentOrganisationBottomSheetViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        // Ignore taps inside the table view
        if let touchedView = touch.view, touchedView.isDescendant(of: tableView) {
            return false
        }
        return true
    }
}

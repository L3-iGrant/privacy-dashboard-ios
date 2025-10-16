//
//  BBConsentDataAgreementBottomSheetVC.swift
//  PrivacyDashboardiOS
//
//  Created by iGrant on 02/05/25.
//

import Foundation
import UIKit

class BBConsentDataAgreementBottomSheetVC: BBConsentBaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var parentViewHeight: NSLayoutConstraint!
    @IBOutlet weak var parentView: UIView!
    
    var dataAgreement: [PurposeConsentWrapperV2]?
    var purposeSectionDic = [String:Any]()
    var policySectionDict = [String:Any]()
    var DPIASectionDic = [String:Any]()
    var dataAgreementDic = [[String: Any]]()
    var instance: DAPolicy?
    var showCloseButton = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupInitialState()
        tableView.delegate = self
        tableView.dataSource = self
        do {
            if !dataAgreementDic.isEmpty {
                let jsonData = try JSONSerialization.data(withJSONObject: dataAgreementDic[0])
                instance = try JSONDecoder().decode(DAPolicy.self, from: jsonData)
            }
        } catch {
            debugPrint(error)
        }
        let bundle = Bundle(for: DataAgreementCellV2.self)
        tableView.register(UINib(nibName: "DataAgreementCellV2", bundle: Bundle.module), forCellReuseIdentifier: "DataAgreementCellV2")
        setUI()
        setData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let screenHeight = UIScreen.main.bounds.height
        //let sheetHeight = screenHeight * 0.75
        let sheetHeight = screenHeight * 0.85
        parentViewHeight.constant = sheetHeight
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animatePresentation()
    }
    
    private func setupViews() {
        self.view.backgroundColor = UIColor.clear
        let dimmingView = UIView()
        dimmingView.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        dimmingView.frame = self.view.bounds
        dimmingView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        dimmingView.alpha = 0
        dimmingView.tag = 999
        self.view.insertSubview(dimmingView, at: 0)
        
    }
    
    private func setupInitialState() {
        let screenHeight = UIScreen.main.bounds.height
        parentView.transform = CGAffineTransform(translationX: 0, y: screenHeight)
    }
    
    private func animatePresentation() {
        UIView.animate(withDuration: 0.2) {
            if let dimmingView = self.view.viewWithTag(999) {
                dimmingView.alpha = 1
            }
        }
        
        UIView.animate(withDuration: 0.3, delay: 0.1, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: .curveEaseOut) {
            self.parentView.transform = .identity
        }
    }
    
    @IBAction func closeButtonTapped(_ sender: Any) {
        dismiss(animated: true)
    }
    
    
    func setUI() {
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "DAcell")
    }
    
    func setData() {
        if dataAgreement?.count ?? 0 > 0 {
            let years = (Int(dataAgreement?[0].retentionPeriod ?? "") ?? 0)/365
            let retenetionPeriod = (years > 1) ? "\(years )" + "bb_consent_data_agreement_years".localized : "\(years )" + "bb_consent_data_agreement_years".localized

            purposeSectionDic = ["bb_consent_data_agreement_policy_purpose": dataAgreement?[0].name ?? "", "bb_consent_data_agreement_policy_purpose_description": dataAgreement?[0].descriptionField ?? "", "bb_consent_data_agreement_policy_lawful_basis_of_processing": dataAgreement?[0].lawfulBasis ?? ""]
            policySectionDict = ["bb_consent_data_agreement_policy_policy_url": dataAgreement?[0].policyURL ?? "", "bb_consent_data_agreement_policy_jurisdiction": dataAgreement?[0].jurisdiction ?? "", "bb_consent_data_agreement_policy_third_party_disclosure": dataAgreement?[0].thirdPartyDisclosure ?? "", "bb_consent_data_agreement_policy_industry_scope": dataAgreement?[0].industryScope ?? "", "bb_consent_data_agreement_policy_geographic_restriction": dataAgreement?[0].geaographicRestriction ?? "", "bb_consent_data_agreement_policy_retention_period": retenetionPeriod, "bb_consent_data_agreement_policy_storage_location": dataAgreement?[0].storageLocation ?? ""]
            DPIASectionDic = ["bb_consent_data_agreement_policy_dpia_date": dataAgreement?[0].DPIAdate ?? "", "bb_consent_data_agreement_policy_dpia_summary": dataAgreement?[0].DPIASummary ?? ""]
            dataAgreementDic = [purposeSectionDic, policySectionDict, DPIASectionDic]

        } else {
            let years = Int(instance?.policy?.dataRetentionPeriodDays ?? 0)/365
            let retenetionPeriod = (years > 1) ? "\(years )"+"bb_consent_data_agreement_years".localized : "\(years )" + "bb_consent_data_agreement_years".localized
            
            purposeSectionDic = ["bb_consent_data_agreement_policy_purpose": instance?.purpose ?? "", "bb_consent_data_agreement_policy_purpose_description": instance?.purposeDescription ?? "", "bb_consent_data_agreement_policy_lawful_basis_of_processing": instance?.lawfulBasis ?? ""]
            policySectionDict = ["Policy URL": instance?.policy?.url ?? "", "bb_consent_data_agreement_policy_jurisdiction": instance?.policy?.jurisdiction ?? "", "bb_consent_data_agreement_policy_third_party_disclosure": instance?.policy?.thirdPartyDataSharing ?? 0, "bb_consent_data_agreement_policy_industry_scope": instance?.policy?.industrySector ?? "", "bb_consent_data_agreement_policy_geographic_restriction": instance?.policy?.geographicRestriction ?? "", "bb_consent_data_agreement_policy_retention_period": retenetionPeriod, "bb_consent_data_agreement_policy_storage_location": instance?.policy?.storageLocation ?? ""]
            DPIASectionDic = ["bb_consent_data_agreement_policy_dpia_date":instance?.dpiaDate ?? "", "bb_consent_data_agreement_policy_dpia_summary": instance?.dpiaSummaryUrl ?? ""]
            dataAgreementDic = [purposeSectionDic, policySectionDict, DPIASectionDic]
        }
    }
    
    // MARK: TableView delegates & datasources
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        dataAgreementDic.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataAgreementDic[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DataAgreementCellV2", for: indexPath) as! DataAgreementCellV2
        cell.contentBack.backgroundColor = UIColor(red: 0.9725, green: 0.9725, blue: 0.9725, alpha: 1.0)
        let item = dataAgreementDic[indexPath.section]
        let totalRowsInSection = item.count
        let keys = item.map({ $0.key })
        let values = item.map({ $0.value })
        cell.mainLbl.text = keys[indexPath.row].localized
        let val = "\(values[indexPath.row])"
        cell.valueLabel.text = val.localized
        if let url = URL(string: val), UIApplication.shared.canOpenURL(url) {
            cell.url = url.absoluteString
            let attributedString = NSMutableAttributedString(string: values[indexPath.row] as! String)
            attributedString.addAttribute(.link, value: attributedString, range: NSRange(location: 0, length: attributedString.length))
            cell.valueLabel.attributedText = attributedString
        }
        cell.renderUI(index: indexPath.row, tot: totalRowsInSection)
        cell.arrangeStackForDataAgreement()
        cell.layoutIfNeeded()
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNonzeroMagnitude
    }
}

//
//  BBConsentDataAgreementVC.swift
//  PrivacyDashboardiOS
//
//  Created by Mumthasir mohammed on 10/11/23.
//

import Foundation
import UIKit

// MARK: Custom cell
class DACell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descLabel: UITextView!
}

class BBConsentDataAgreementVC: UITableViewController {
    var dataAgreement: [PurposeConsentWrapperV2]?
    var purposeSectionDic = [String:Any]()
    var policySectionDict = [String:Any]()
    var DPIASectionDic = [String:Any]()
    var dataAgreementDic = [[String: Any]]()
    var instance: DAPolicy?
    var showCloseButton = false
    
    override func viewDidLoad() {
        do {
            if !dataAgreementDic.isEmpty {
                let jsonData = try JSONSerialization.data(withJSONObject: dataAgreementDic[0])
                instance = try JSONDecoder().decode(DAPolicy.self, from: jsonData)
            }
        } catch {
            debugPrint(error)
        }
        let bundle = Bundle(for: DataAgreementCellV2.self)
        tableView.register(UINib(nibName: "DataAgreementCellV2", bundle: bundle), forCellReuseIdentifier: "DataAgreementCellV2")
        setUI()
        setData()
    }
    
    func setUI() {
        if showCloseButton {
            let button1 = UIBarButtonItem(image: UIImage(systemName: "xmark.circle"), style: .plain, target: self, action: #selector(tapOnClose))
            self.navigationItem.rightBarButtonItem  = button1
        }
        
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "DAcell")
        self.navigationItem.title = "bb_consent_data_agreement_policy_data_agreement".localized
        self.navigationItem.leftItemsSupplementBackButton = true
        self.navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.tintColor = .black
    }
    
    @objc func tapOnClose() {
        self.dismiss(animated: true)
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
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        dataAgreementDic.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataAgreementDic[section].count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DataAgreementCellV2", for: indexPath) as! DataAgreementCellV2
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
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNonzeroMagnitude
    }

}

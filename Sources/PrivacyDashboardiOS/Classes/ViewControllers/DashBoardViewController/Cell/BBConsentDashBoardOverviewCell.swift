
//
//  BBConsentDashBoardOverviewCell.swift
//  PrivacyDashboardiOS
//
//  Created by Mumthasir mohammed on 04/09/23.
//

import UIKit
import ExpandableLabel

class BBConsentDashBoardOverviewCell: UITableViewCell {
    @IBOutlet weak var overViewLbl: ExpandableLabel!
    @IBOutlet weak var overViewTitleLbl: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: "bb_consent_dashboard_read_more".localized)
        let colorRange = NSMakeRange(0,"bb_consent_dashboard_read_more".localized.count)
        attributeString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor(red:0.59, green:0.59, blue:0.61, alpha:1), range:colorRange)
        overViewLbl.collapsedAttributedLink = attributeString
        
        let readLessattributeString: NSMutableAttributedString =  NSMutableAttributedString(string: "bb_consent_dashboard_read_less".localized)
        let colorRangeReadLess = NSMakeRange(0,"bb_consent_dashboard_read_less".localized.count)
        readLessattributeString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor(red:1, green:0.53, blue:0.54, alpha:1), range:colorRangeReadLess)
        overViewLbl.expandedAttributedLink = readLessattributeString
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

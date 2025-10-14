//
//  RequestStatusTableViewCell.swift
//  PrivacyDashboardiOS
//
//  Created by Mumthasir mohammed on 19/09/23.
//

import UIKit

class BBConsentRequestStatusTableViewCell: UITableViewCell {
    @IBOutlet weak var statusType: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var statusDetail: UILabel!
    @IBOutlet weak var cancelButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func showDate(dateval: String) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        let date = dateFormatter.date(from: dateval.replacingOccurrences(of: " +0000 UTC", with: ""))
        dateFormatter.dateFormat = "yyyy-MM-dd hh:mm a"
        dateFormatter.timeZone = TimeZone.current
        let timeStamp = dateFormatter.string(from: date!)
        self.date.text = timeStamp
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

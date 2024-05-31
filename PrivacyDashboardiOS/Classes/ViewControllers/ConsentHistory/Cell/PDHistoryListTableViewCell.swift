
//
//  PDHistoryListTableViewCell.swift
//  PrivacyDashboardiOS
//
//  Created by Mumthasir mohammed on 14/09/23.
//


import UIKit
import AFDateHelper

class PDHistoryListTableViewCell: UITableViewCell {
    @IBOutlet weak var contentLbl: UILabel!
    @IBOutlet weak var timeLbl: UILabel!
    @IBOutlet weak var typeLbl: UILabel!
    var history : ConsentHistory?
   
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func showData() {
        if let dateval = history?.timeStamp {
            let date = dateval.dateFromISO8601
            let day = date?.component(.day)
            
            let month = date?.toString(style: .shortMonth)
            var monthVal : String!
            if month != nil {
                monthVal  = month!
            }
            timeLbl.text = monthVal
            if day != nil {
                let dayVal  : Int = day!
                timeLbl.text = monthVal + " \(dayVal)"
            }
            let isToday = date?.compare(.isToday)
            if isToday == true {
                let today = Date()
                let secondsSince = date?.since(today, in: .hour)
                if secondsSince != nil {
                    let hourVal : Int = Int(abs(secondsSince!))
                    timeLbl.text = "\(String(describing: hourVal))h"
                    if hourVal < 1 {
                        let minuteInfo = date?.since(today, in: .minute)
                        if minuteInfo != nil {
                            let minuteVal : Int = Int(abs(minuteInfo!))
                            timeLbl.text = "\(String(describing: minuteVal))m"
                            if minuteVal < 1 {
                                let secondInfo = date?.since(today, in: .second)
                                if secondInfo != nil {
                                    let scondVal : Int = Int(abs(secondInfo!))
                                    timeLbl.text = "\(String(describing: scondVal))s"
                                }
                            }
                        }
                    }
                }
            } else {
                timeLbl.text = PDiOSUtilityMethods.relationalDateToString(dateString: dateval)
            }
        }
        contentLbl.text = history?.log
    }
}


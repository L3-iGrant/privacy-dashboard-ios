//
//  BBUtilityMethods.swift
//  PrivacyDashboardiOS
//
//  Created by Mumthasir mohammed on 06/09/23.
//

import Foundation
import UIKit

class BBConsentUtilityMethods: NSObject {

    class func setView(view: UIView, hidden: Bool) {
        UIView.transition(with: view, duration: 0.5, options: .transitionCrossDissolve, animations: {
            view.isHidden = hidden
        })
    }
    
    class func showBlueAndBackColorText(blackColorWord:String, blueColorWord:String) -> NSMutableAttributedString{
        let fullText = blueColorWord  + " | " + blackColorWord
        let themBlueColorRange = NSMakeRange(0,blueColorWord.count)
        let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: fullText)
        attributeString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor(red:0.13, green:0.38, blue:0.6, alpha:1), range:themBlueColorRange)
        let themBlackColorRange = NSMakeRange(blueColorWord.count,blackColorWord.count + 3)
        attributeString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.themeTextBlackColor(), range:themBlackColorRange)
        return attributeString
    }
    
    static func relationalDateToString(dateString: String) -> String {
        let dateFrmtr = DateFormatter()
        dateFrmtr.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        dateFrmtr.timeZone = TimeZone.init(identifier: "UTC")
        dateFrmtr.locale = Locale.init(identifier: "en")
        let date = dateFrmtr.date(from: dateString)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.doesRelativeDateFormatting = true
        
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "h:mm a"
        
        let time = "\(dateFormatter.string(from: date!)), \(timeFormatter.string(from: date!))"
        return time
    }
}

//
//  File.swift
//  PrivacyDashboardiOS
//
//  Created by iGrant on 30/03/26.
//

import Foundation
import UIKit
@IBDesignable

extension UIButton {
    
    func applyBottomSheetCloseStyle(imageName: String = "xmark") {
        let size: CGFloat = 32
        // Remove any button configuration that adds insets (iOS 15+)
        if #available(iOS 15.0, *) {
            var config = UIButton.Configuration.plain()
            config.contentInsets = .zero
            configuration = config
        }
        contentEdgeInsets = .zero
        imageEdgeInsets = .zero
        setImage(UIImage(systemName: imageName, withConfiguration: UIImage.SymbolConfiguration(pointSize: 12, weight: .bold)), for: .normal)
        tintColor = .black
        backgroundColor = UIColor.black.withAlphaComponent(0.08)
        layer.cornerRadius = size / 2
        clipsToBounds = true
        for constraint in constraints {
            if constraint.firstAttribute == .width { constraint.constant = size }
            if constraint.firstAttribute == .height { constraint.constant = size }
        }
    }
}

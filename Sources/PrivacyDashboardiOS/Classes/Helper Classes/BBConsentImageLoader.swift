//
//  BBConsentImageLoader.swift
//  PrivacyDashboardiOS
//

import UIKit
import Kingfisher

// Loads the logo and cover images. The image URLs come from organisation data
// and from the host app, so the requests get no authorisation headers.
@MainActor
enum BBConsentImageLoader {
    static func setImage(_ imageView: UIImageView, url: URL?, placeholder: UIImage?) {
        imageView.kf.setImage(with: url, placeholder: placeholder)
    }
}

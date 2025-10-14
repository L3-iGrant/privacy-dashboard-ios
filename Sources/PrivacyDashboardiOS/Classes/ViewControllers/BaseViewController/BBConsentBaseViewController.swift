//
//  BBConsentBaseViewController.swift
//  PrivacyDashboardiOS
//
//  Created by Mumthasir mohammed on 04/09/23.
//


import UIKit

class BBConsentBaseViewController: UIViewController {
    var spinner = UIActivityIndicatorView(style: .large)
    var loadingView: UIView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .darkContent
    }
    
    func addLoadingIndicator() {
        DispatchQueue.main.async {
            self.loadingView = UIView()
                   self.loadingView.frame = CGRect(x: 0.0, y: 0.0, width: 100.0, height: 100.0)
                   self.loadingView.center = self.view.center
                   self.loadingView.backgroundColor = UIColor(named: "#444444")
                   self.loadingView.alpha = 0.7
                   self.loadingView.clipsToBounds = true
                   self.loadingView.layer.cornerRadius = 10

                   self.spinner = UIActivityIndicatorView(style: .large)
                   self.spinner.frame = CGRect(x: 0.0, y: 0.0, width: 80.0, height: 80.0)
                   self.spinner.center = CGPoint(x:self.loadingView.bounds.size.width / 2, y:self.loadingView.bounds.size.height / 2)

                   self.loadingView.addSubview(self.spinner)
                   self.view.addSubview(self.loadingView)
                   self.spinner.startAnimating()
        }
    }
    
    func removeLoadingIndicator() {
        DispatchQueue.main.async {
            self.spinner.stopAnimating()
            self.loadingView.removeFromSuperview()
        }
    }
}

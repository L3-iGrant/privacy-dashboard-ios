//
//  BBConsentWebViewBottomSheetVC.swift
//  PrivacyDashboardiOS
//
//  Created by iGrant on 05/05/25.
//

import Foundation
import WebKit

final class BBConsentWebViewBottomSheetVC: BBConsentBaseViewController, WKNavigationDelegate, WKUIDelegate {
    
    @IBOutlet weak var webView: WKWebView!
    
    @IBOutlet weak var parentViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    var urlString  = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        webView.navigationDelegate = self
        webView.uiDelegate = self
        let backButton = UIButton(type: UIButton.ButtonType.custom)
        backButton.frame =  CGRect.init(x: 0, y: 0, width: 10, height: 40)
        backButton.setTitle(" ", for: .normal)
       
        if let url =  URL.init(string: urlString){
            self.addLoadingIndicator()
            webView.load(URLRequest.init(url: url))
        }
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(baseViewTapped))
        tapGesture.delegate = self
        self.view.addGestureRecognizer(tapGesture)
    }
    
    @objc func baseViewTapped() {}
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = false
        let screenHeight = UIScreen.main.bounds.height
        let sheetHeight = screenHeight * 0.85
        parentViewHeight.constant = sheetHeight
        titleLabel.text = Constant.Strings.privacyPolicy.localized
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func closeButtonTapped(_ sender: Any) {
        dismiss(animated: true)
    }
    
    //Equivalent of webViewDidFinishLoad:
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.removeLoadingIndicator()
        debugPrint("didFinish - webView.url: \(String(describing: webView.url?.description))")
    }
    
    //Equivalent of didFailLoadWithError:
       func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
           let nserror = error as NSError
           self.removeLoadingIndicator()
           if nserror.code != NSURLErrorCancelled {
               webView.loadHTMLString("Page Not Found", baseURL: URL(string: "https://developer.apple.com/"))
           }
       }
}

extension BBConsentWebViewBottomSheetVC: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        // Ignore taps inside the table view
        if let touchedView = touch.view, touchedView.isDescendant(of: webView) {
            return false
        }
        return true
    }
}

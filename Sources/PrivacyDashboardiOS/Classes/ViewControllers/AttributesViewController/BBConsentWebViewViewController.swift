//
//  BBConsentWebViewViewController.swift
//  PrivacyDashboardiOS
//
//  Created by Mumthasir mohammed on 08/09/23.
//


import UIKit
import WebKit

class BBConsentWebViewViewController: BBConsentBaseViewController, WKNavigationDelegate, WKUIDelegate {
    @IBOutlet weak var webview : WKWebView!
    var urlString  = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        webview.navigationDelegate = self
        webview.uiDelegate = self
        let backButton = UIButton(type: UIButton.ButtonType.custom)
        backButton.frame =  CGRect.init(x: 0, y: 0, width: 10, height: 40)
        backButton.setTitle(" ", for: .normal)
       
        if let url =  URL.init(string: urlString){
            self.addLoadingIndicator()
            webview.load(URLRequest.init(url: url))
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = false
        self.title = Constant.Strings.privacyPolicy.localized
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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

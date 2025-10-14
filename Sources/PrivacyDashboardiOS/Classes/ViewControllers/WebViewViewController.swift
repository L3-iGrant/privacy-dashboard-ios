//
//  WebViewViewController.swift
//  Lubax
//
//  Created by Ajeesh T S on 18/06/18.
//  Copyright © 2018 iGrant.com. All rights reserved.
//

import UIKit
import WebKit

class WebViewViewController: BBConsentBaseViewController, WKNavigationDelegate, WKUIDelegate {
    @IBOutlet weak var webview : WKWebView!
    var urlString  = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        webview.navigationDelegate = self
        webview.uiDelegate = self
        let backButton = UIButton(type: UIButton.ButtonType.custom)
        backButton.frame =  CGRect.init(x: 0, y: 0, width: 10, height: 40)
        backButton.setTitle(" ", for: .normal)
//        let backButtonBar = UIBarButtonItem(customView:backButton)
//        self.navigationItem.rightBarButtonItem = backButtonBar
        self.navigationController?.navigationBar.isHidden = false
        self.title = "Policy"
        if let url =  URL.init(string: urlString){
            //self.addLoadingIndicator()
            webview.load(URLRequest.init(url: url))
        }


//        webview.loadRequest(URLRequest.init(url: URL.init(string: urlString)!))
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
//    func webViewDidFinishLoad(_ webView: UIWebView){
//    }
    
    //Equivalent of webViewDidFinishLoad:
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        // self.removeLoadingIndicator()
        print("didFinish - webView.url: \(String(describing: webView.url?.description))")
    }
    
    
//    func webView(_ webView: UIWebView, didFailLoadWithError error: Error){
//    }
    //Equivalent of didFailLoadWithError:
       func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
           let nserror = error as NSError
            // self.removeLoadingIndicator()
           if nserror.code != NSURLErrorCancelled {
               webView.loadHTMLString("Page Not Found", baseURL: URL(string: "https://developer.apple.com/"))
           }
       }

  

}

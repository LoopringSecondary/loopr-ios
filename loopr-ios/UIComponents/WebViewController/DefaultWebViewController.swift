//
//  AssetTransactionWebViewController.swift
//  loopr-ios
//
//  Created by kenshin on 2018/4/25.
//  Copyright © 2018年 Loopring. All rights reserved.
//

import UIKit
import WebKit

class DefaultWebViewController: UIViewController {

    @IBOutlet weak var wkWebView: WKWebView!
    var url: URL?
    var navigationTitle: String = ""
    
    private var progressKVOhandle: NSKeyValueObservation?
    @IBOutlet weak var progressView: UIProgressView!
    var showProgressView: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        setBackButton()
        self.navigationItem.title = navigationTitle
        view.theme_backgroundColor = ["#fff", "#000"]
        progressView.tintColor = UIColor.black
        progressView.setProgress(0, animated: false)
        progressView.alpha = 0.0
        
        let request = URLRequest(url: url!)
        wkWebView.navigationDelegate = self
        wkWebView.load(request)
        
        wkWebView.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil) // add observer for key path
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        progressView.progress = Float(wkWebView.estimatedProgress)
    }

}

extension DefaultWebViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        if showProgressView {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            
            progressView.alpha = 0.0
            UIView.animate(withDuration: 0.33, delay: 0.0, options: .curveEaseInOut, animations: {
                self.progressView.alpha = 1.0
            })
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        showProgressView = false
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        progressView.alpha = 1.0
        UIView.animate(withDuration: 0.33, delay: 0.0, options: .curveEaseInOut, animations: {
            self.progressView.alpha = 0.0
        })
    }
}

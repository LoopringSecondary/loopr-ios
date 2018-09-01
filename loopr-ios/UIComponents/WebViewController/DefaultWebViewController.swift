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
    @IBOutlet weak var progressView: UIProgressView!

    var url: URL?
    var navigationTitle: String = ""
    var showProgressView: Bool = true
    var progressKVOhandle: NSKeyValueObservation?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        setBackButton()
        self.navigationItem.title = navigationTitle
        view.theme_backgroundColor = ["#fff", "#000"]
        progressView.tintColor = UIColor.black
        progressView.setProgress(0, animated: false)
        progressView.alpha = 0.0
        
        setupSafariButton()
        
        let request = URLRequest(url: url!)
        wkWebView.navigationDelegate = self
        wkWebView.load(request)
        
        wkWebView.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil) // add observer for key path
    }
    
    func setupSafariButton() {
        let safariButton = UIButton(type: UIButtonType.custom)
        safariButton.setImage(UIImage(named: "Safari-item-button"), for: .normal)
        safariButton.setImage(UIImage(named: "Safari-item-button")?.alpha(0.3), for: .highlighted)
        safariButton.imageEdgeInsets = UIEdgeInsets.init(top: 0, left: 8, bottom: 0, right: -8)
        safariButton.addTarget(self, action: #selector(pressedSafariButton(_:)), for: UIControlEvents.touchUpInside)
        // The size of the image.
        safariButton.frame = CGRect(x: 0, y: 0, width: 23, height: 23)
        let shareBarButton = UIBarButtonItem(customView: safariButton)
        self.navigationItem.rightBarButtonItem = shareBarButton
    }
    
    @objc func pressedSafariButton(_ button: UIBarButtonItem) {
        if let url = self.url {
            UIApplication.shared.open(url)
        }
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

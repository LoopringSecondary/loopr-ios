//
//  AssetTransactionWebViewController.swift
//  loopr-ios
//
//  Created by kenshin on 2018/4/25.
//  Copyright © 2018年 Loopring. All rights reserved.
//

import UIKit
import WebKit

class AssetTransactionWebViewController: UIViewController {

    @IBOutlet weak var wkWebView: WKWebView!
    var url: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setBackButton()
        let request = URLRequest(url: url!)
        wkWebView.load(request)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

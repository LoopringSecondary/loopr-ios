//
//  DisplayPrivateKeyViewController.swift
//  loopr-ios
//
//  Created by xiaoruby on 4/7/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit
import NotificationBannerSwift

class DisplayPrivateKeyViewController: UIViewController {

    @IBOutlet weak var privateKeyTextView: UITextView!
    @IBOutlet weak var copyButton: GradientButton!

    var navigationTitle = LocalizedString("Export Private Key", comment: "")
    var copyButtonTitle = LocalizedString("Copy Private Key", comment: "")
    var bannerMessage = LocalizedString("Private key copied to clipboard successfully!", comment: "")
    var displayValue: String = ""
    
    var blurVisualEffectView = UIView(frame: .zero)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationItem.title = navigationTitle
        setBackButton()
        view.theme_backgroundColor = ColorPicker.backgroundColor
        privateKeyTextView.contentInset = UIEdgeInsets.init(top: 17, left: 20, bottom: 15, right: 20)
        privateKeyTextView.cornerRadius = 6
        privateKeyTextView.font = UIFont(name: "Menlo", size: 14)
        privateKeyTextView.theme_backgroundColor = ColorPicker.cardBackgroundColor
        privateKeyTextView.theme_textColor = GlobalPicker.textLightColor
        privateKeyTextView.isEditable = false
        // privateKeyTextView.isScrollEnabled = false
        
        copyButton.title = copyButtonTitle

        blurVisualEffectView.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        blurVisualEffectView.alpha = 1
        blurVisualEffectView.frame = UIScreen.main.bounds
        displayWarning()
        
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: .UIApplicationWillEnterForeground, object: nil)
    }
    
    @objc func willEnterForeground() {
        displayWarning()
    }
    
    func displayWarning() {
        let vc = PreventScreenShotViewController()
        vc.modalPresentationStyle = .overFullScreen
        vc.dismissClosure = {
            UIView.animate(withDuration: 0.1, animations: {
                self.blurVisualEffectView.alpha = 0.0
            }, completion: { (_) in
                self.blurVisualEffectView.removeFromSuperview()
                self.privateKeyTextView.text = self.displayValue
            })
        }
        self.present(vc, animated: true, completion: nil)
        
        self.navigationController?.view.addSubview(self.blurVisualEffectView)
        UIView.animate(withDuration: 0.3, animations: {
            self.blurVisualEffectView.alpha = 1.0
        }, completion: {(_) in
            
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    @IBAction func pressedCopyButton(_ sender: Any) {
        print("pressedCopyButton")
        UIPasteboard.general.string = displayValue
        let banner = NotificationBanner.generate(title: bannerMessage, style: .success)
        banner.duration = 1
        banner.show()
    }
    
}

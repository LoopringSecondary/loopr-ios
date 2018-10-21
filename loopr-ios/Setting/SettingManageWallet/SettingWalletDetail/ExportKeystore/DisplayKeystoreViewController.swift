//
//  DisplayKeystoreViewController.swift
//  loopr-ios
//
//  Created by xiaoruby on 4/7/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit
import NotificationBannerSwift

class DisplayKeystoreViewController: UIViewController {
    
    @IBOutlet weak var keystoreTextView: UITextView!
    @IBOutlet weak var copyButton: GradientButton!
    
    var keystore: String = ""
    var blurVisualEffectView = UIView(frame: .zero)

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.theme_backgroundColor = ColorPicker.backgroundColor

        keystoreTextView.contentInset = UIEdgeInsets.init(top: 15, left: 15, bottom: 15, right: 15)
        // privateKeyTextView.contentOffset = CGPoint(x: 0, y: -10)
        
        keystoreTextView.cornerRadius = 12
        keystoreTextView.font = UIFont.init(name: FontConfigManager.shared.getLight(), size: 12.0)
        keystoreTextView.backgroundColor = UIColor.init(rgba: "#F8F8F8")
        keystoreTextView.textColor = UIColor.black
        keystoreTextView.isEditable = false
        
        keystoreTextView.contentInset = UIEdgeInsets.init(top: 17, left: 20, bottom: 15, right: 20)
        keystoreTextView.cornerRadius = 6
        keystoreTextView.font = FontConfigManager.shared.getRegularFont(size: 14)
        keystoreTextView.theme_backgroundColor = ColorPicker.cardBackgroundColor
        keystoreTextView.theme_textColor = GlobalPicker.textLightColor
        keystoreTextView.isEditable = false
        
        copyButton.title = LocalizedString("Copy Keystore", comment: "")
        
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
                self.keystoreTextView.text = self.keystore
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
        keystoreTextView.clipsToBounds = true
        keystoreTextView.setContentOffset(CGPoint.zero, animated: false)
    }

    @IBAction func pressedCopyButton(_ sender: Any) {
        print("pressedCopyButton")
        UIPasteboard.general.string = keystore
        let banner = NotificationBanner.generate(title: "Keystore copied to clipboard successfully!", style: .success)
        banner.duration = 1
        banner.show()
    }
    
}

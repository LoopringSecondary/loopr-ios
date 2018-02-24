//
//  TradeViewController.swift
//  loopr-ios
//
//  Created by xiaoruby on 2/9/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit
import pop

class TradeViewController: UIViewController, TradePlaceOrderDelegate {
    
    let tradePlaceOrderViewController: TradePlaceOrderViewController = TradePlaceOrderViewController()
    let tradePlaceOrderBackgroundView: UIView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationController?.navigationBar.topItem?.title = "Trade"

        tradePlaceOrderViewController.delegate = self
        
        // tradePlaceOrderViewController will be added to the window.
        // self.addChildViewController(tradePlaceOrderViewController)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func pressedBuyButton(_ sender: Any) {
        print("pressedBuyButton")
        
        let beforeAnimationRect = CGRect(x: 0, y: self.view.bounds.height * 1.2, width: self.view.bounds.width, height: self.view.bounds.height*0.8)
        let AfterAnimationRect = CGRect(x: 0, y: self.view.bounds.height*0.2, width: self.view.bounds.width, height: self.view.bounds.height*0.9)
        
        tradePlaceOrderViewController.view.frame = beforeAnimationRect
        
        let window = UIApplication.shared.keyWindow!
        window.addSubview(tradePlaceOrderViewController.view)

        // Pop
        // Show tradePlaceOrderViewController
        let basicAnimation = POPSpringAnimation()
        basicAnimation.springBounciness = 10
        basicAnimation.springSpeed = 8
        basicAnimation.dynamicsFriction = 25 // The value of 25 seems ok too.
        
        basicAnimation.property = POPAnimatableProperty.property(withName: kPOPViewFrame) as! POPAnimatableProperty

        basicAnimation.toValue = NSValue(cgRect: AfterAnimationRect)
        basicAnimation.name = "loopring_animation"
        
        basicAnimation.delegate = self
        
        tradePlaceOrderViewController.view.pop_add(basicAnimation, forKey: "loopring_animation")
        
        // Add tradePlaceOrderBackgroundView
        tradePlaceOrderBackgroundView.frame = CGRect(x: 0, y: -100, width: self.view.bounds.width, height: self.view.bounds.height)
        
        window.insertSubview(tradePlaceOrderBackgroundView, belowSubview: tradePlaceOrderViewController.view)
        // window.addSubview(tradePlaceOrderBackgroundView)
        
        // background color before the animation
        tradePlaceOrderBackgroundView.backgroundColor = UIColor(white: 0, alpha: 0)

        UIView.animate(withDuration: 0.2) {
            // statusBarView and UIView use different methods to render. So the values in UIColor are different.
            // UIApplication.shared.statusBarView?.backgroundColor = UIColor(white: 178/255, alpha: 1)
            self.tradePlaceOrderBackgroundView.backgroundColor = UIColor(white: 0, alpha: 0.3)
        }
        
    }
    
    func closeTradePlaceOrderViewController() {
        print("close TradePlaceOrderViewController")
        
        let beforeAnimationRect = CGRect(x: 0, y: self.view.bounds.height * 1.2, width: self.view.bounds.width, height: self.view.bounds.height*0.8)

        // Pop
        let basicAnimation = POPSpringAnimation()
        basicAnimation.springBounciness = 10
        basicAnimation.springSpeed = 10
        basicAnimation.dynamicsFriction = 22
        
        basicAnimation.property = POPAnimatableProperty.property(withName: kPOPViewFrame) as! POPAnimatableProperty
        
        basicAnimation.toValue = NSValue(cgRect: beforeAnimationRect)
        basicAnimation.name = "loopring_animation"
        
        basicAnimation.delegate = self
        
        tradePlaceOrderViewController.view.pop_add(basicAnimation, forKey: "loopring_animation")

        tradePlaceOrderBackgroundView.backgroundColor = UIColor(white: 1, alpha: 0)
        tradePlaceOrderBackgroundView.removeFromSuperview()
        
        // UIApplication.shared.statusBarView?.backgroundColor = UIColor(white: 1, alpha: 1)
    }

}

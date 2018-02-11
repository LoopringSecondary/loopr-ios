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
        self.addChildViewController(tradePlaceOrderViewController)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func pressedBuyButton(_ sender: Any) {
        print("pressedBuyButton")
        
        let beforeAnimationRect = CGRect(x: 0, y: self.view.bounds.height, width: self.view.bounds.width, height: self.view.bounds.height*0.8)
        let AfterAnimationRect = CGRect(x: 0, y: self.view.bounds.height*0.2, width: self.view.bounds.width, height: self.view.bounds.height*0.8)
        
        tradePlaceOrderViewController.view.frame = beforeAnimationRect
        
        self.view.addSubview(tradePlaceOrderViewController.view)

        // UIView default animation
        /*
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0.1, options: UIViewAnimationOptions.curveLinear, animations: {
            
            self.tmpView!.center.y -= self.tmpView!.bounds.height
            
        }) { (finished) in
            print("Animation completed.")
            
            // self.tmpView?.removeFromSuperview()
        }
        */
        
        /*
        UIView.animate(withDuration: 0.5) {
            
        }
        */

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
        tradePlaceOrderBackgroundView.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height)
        self.view.insertSubview(tradePlaceOrderBackgroundView, belowSubview: tradePlaceOrderViewController.view)
        
        // background color before the animation
        tradePlaceOrderBackgroundView.backgroundColor = UIColor(white: 0, alpha: 0)
        
        let backgroundColorAnimation = POPBasicAnimation()
        backgroundColorAnimation.property = POPAnimatableProperty.property(withName: kPOPViewBackgroundColor) as! POPAnimatableProperty
        backgroundColorAnimation.toValue = UIColor(white: 0, alpha: 0.3)

        backgroundColorAnimation.name = "loopring_background_color"
        backgroundColorAnimation.delegate = self
        tradePlaceOrderBackgroundView.pop_add(backgroundColorAnimation, forKey: "loopring_background_color")
    }
    
    func closeTradePlaceOrderViewController() {
        print("close TradePlaceOrderViewController")
        
        let beforeAnimationRect = CGRect(x: 0, y: self.view.bounds.height, width: self.view.bounds.width, height: self.view.bounds.height*0.8)

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
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

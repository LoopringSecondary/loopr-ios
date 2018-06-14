//
//  TabBarItemAnimateTipsContentView.swift
//  loopr-ios
//
//  Created by xiaoruby on 6/13/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

class TabBarItemAnimateTipsContentView: TabBarItemBackgroundContentView {
    
    var duration = 0.3
    
    override func selectAnimation(animated: Bool, completion: (() -> ())?) {
        notificationAnimation()
        completion?()
    }
    
    override func reselectAnimation(animated: Bool, completion: (() -> ())?) {
        notificationAnimation()
        completion?()
    }
    
    override func badgeChangedAnimation(animated: Bool, completion: (() -> ())?) {
        super.badgeChangedAnimation(animated: animated, completion: nil)
        notificationAnimation()
    }
    
    func notificationAnimation() {
        let impliesAnimation = CAKeyframeAnimation(keyPath: "transform.translation.y")
        impliesAnimation.values = [0.0, -2.0, 1.0, -1.0, -0.5, 0.0]
        impliesAnimation.duration = duration * 2
        impliesAnimation.calculationMode = kCAAnimationCubic
        
        imageView.layer.add(impliesAnimation, forKey: nil)
    }
}

//
//  TabBarItemBackgroundContentView.swift
//  loopr-ios
//
//  Created by xiaoruby on 6/13/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

class TabBarItemBackgroundContentView: TabBarItemBasicContentView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // textColor = UIColor.black
        highlightTextColor = UIColor.black
        // iconColor = UIColor.black
        highlightIconColor = UIColor.black
    }
    
    public convenience init(specialWithAutoImplies implies: Bool) {
        self.init(frame: CGRect.zero)
        // textColor = UIColor.black
        highlightTextColor = UIColor.black
        // iconColor = UIColor.black
        highlightIconColor = UIColor.black

        if implies {
            let timer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(TabBarItemBackgroundContentView.playImpliesAnimation(_:)), userInfo: nil, repeats: true)
            RunLoop.current.add(timer, forMode: .commonModes)
        }
        
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc internal func playImpliesAnimation(_ sender: AnyObject?) {
        if self.selected == true || self.highlighted == true {
            return
        }
        let view = self.imageView
        let impliesAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
        impliesAnimation.values = [1.15, 0.8, 1.15]
        impliesAnimation.duration = 0.3
        impliesAnimation.calculationMode = kCAAnimationCubic
        impliesAnimation.isRemovedOnCompletion = true
        view.layer.add(impliesAnimation, forKey: nil)
    }

}

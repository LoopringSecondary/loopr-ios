//
//  DefaultStepSlider.swift
//  loopr-ios
//
//  Created by xiaoruby on 8/15/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import Foundation
import StepSlider

extension StepSlider {
    
    class func getDefault() -> StepSlider {
        let stepSlider = StepSlider()
        stepSlider.labelFont = FontConfigManager.shared.getRegularFont(size: 12)
        stepSlider.trackHeight = 2
        stepSlider.trackCircleRadius = 3
        stepSlider.labelColor = UIColor.dark4
        stepSlider.trackColor = UIColor.init(rgba: "#444444")
        stepSlider.tintColor = UIColor.themeGreen
        stepSlider.sliderCircleRadius = 8
        stepSlider.sliderCircleColor = UIColor.themeGreen
        stepSlider.labelOffset = 10
        stepSlider.isDotsInteractionEnabled = true
        stepSlider.adjustLabel = true
        return stepSlider
    }

}


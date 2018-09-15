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
        stepSlider.labelFont = FontConfigManager.shared.getDigitalFont(size: 12)
        stepSlider.trackHeight = 2
        stepSlider.trackCircleRadius = 3
        stepSlider.labelColor = UIColor.text2
        stepSlider.trackColor = UIColor.dark4
        stepSlider.tintColor = UIColor.theme
        stepSlider.sliderCircleRadius = 8
        stepSlider.sliderCircleColor = UIColor.theme
        stepSlider.labelOffset = 10
        stepSlider.isDotsInteractionEnabled = true
        stepSlider.adjustLabel = true
        return stepSlider
    }

}


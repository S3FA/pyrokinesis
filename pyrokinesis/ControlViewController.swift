//
//  ControlViewController.swift
//  pyrokinesis
//
//  Created by Callum Hay on 2015-07-19.
//  Copyright (c) 2015 s3fa. All rights reserved.
//

import Foundation
import UIKit

class ControlViewController : UIViewController {
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        self.checkFlameEffectTouches(touches, touchOn: true)
        super.touchesBegan(touches, withEvent:event)
    }
    override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
        self.checkFlameEffectTouches(touches, touchOn: true)
        super.touchesMoved(touches, withEvent: event)
    }
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        self.checkFlameEffectTouches(touches, touchOn: false)
        super.touchesEnded(touches, withEvent: event)
    }
    override func touchesCancelled(touches: Set<NSObject>!, withEvent event: UIEvent!) {
        self.checkFlameEffectTouches(touches, touchOn: false)
        super.touchesCancelled(touches, withEvent: event)
    }
    
    private func checkFlameEffectTouches(touches: Set<NSObject>, touchOn: Bool) {
        if let touch = touches.first as? UITouch {
            
            let touchLocation = touch.locationInView(self.view)
            
            for view in self.view.subviews {
                if let flameEffect = view as? UIFlameEffect {
                    if flameEffect.containsPoint(touchLocation) {
                        flameEffect.setTouched(touchOn)
                    }
                    else {
                        flameEffect.setTouched(false)
                    }
                }
            }
        }
    }
    
}
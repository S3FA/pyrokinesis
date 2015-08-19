//
//  ControlViewController.swift
//  pyrokinesis
//
//  Created by Callum Hay on 2015-07-19.
//  Copyright (c) 2015 s3fa. All rights reserved.
//

import Foundation
import UIKit

class ControlViewController : UIViewController, UINavigationControllerDelegate, FireSimulatorDelegate {
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let navCtrl = self.navigationController {
            navCtrl.delegate = self
        }
        
        // Make this view a delegate of the fire simulator
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.fireSimulator.delegate = self
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
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
    
    // FireSimulatorDelegate Protocol
    func flameEffectChanged(flameIdx: Int, isOn: Bool) {
        for view in self.view.subviews {
            if let flameEffect = view as? UIFlameEffect {
                if flameEffect.index == flameIdx {
                    flameEffect.simulateTouchWithoutSendingData(isOn)
                    return
                }
            }
        }
    }
    
    static let MAX_BUTTON_HOLD_TIME_S: NSTimeInterval = 2.0
    private var buttonHoldDownStartTimestamp: NSTimeInterval = 0.0
    @IBAction func onPinwheelButtonDown(sender: UIButton) {
        self.buttonHoldDownStartTimestamp = NSDate.timeIntervalSinceReferenceDate()
    }
    @IBAction func onPinwheelButtonUp(sender: UIButton) {
        let currTimestamp = NSDate.timeIntervalSinceReferenceDate()
        let timeDiff = min(currTimestamp - self.buttonHoldDownStartTimestamp, ControlViewController.MAX_BUTTON_HOLD_TIME_S)
        
        var numPinwheels = Int(MathHelper.lerp(timeDiff, x0: 0.0, x1: ControlViewController.MAX_BUTTON_HOLD_TIME_S, y0: 1.0, y1: 4.0))
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        var anims = FireAnimatorManager.buildPinwheelFireAnimators(0.0, burstTimeInSecs: 0.1, clockwise: MathHelper.randomBool(), numPinwheels: numPinwheels)
        
        if let fireMgr = appDelegate.fireAnimatorManager {
            fireMgr.clearAnimators()
            fireMgr.addAnimators(anims)
        }
    }
    
    
    @IBAction func onEruptionButtonDown(sender: UIButton) {
        self.buttonHoldDownStartTimestamp = NSDate.timeIntervalSinceReferenceDate()
    }
    @IBAction func onEruptionButtonUp(sender: UIButton) {
        let currTimestamp = NSDate.timeIntervalSinceReferenceDate()
        let timeDiff = min(currTimestamp - self.buttonHoldDownStartTimestamp, ControlViewController.MAX_BUTTON_HOLD_TIME_S)
        
        var eruptionLengthInS = MathHelper.lerp(timeDiff, x0: 0.0, x1: ControlViewController.MAX_BUTTON_HOLD_TIME_S, y0: 0.5, y1: 1.9)
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        var anims = FireAnimatorManager.buildEruptionFireAnimators(0.0, burstTimeInSecs: eruptionLengthInS)
        
        if let fireMgr = appDelegate.fireAnimatorManager {
            fireMgr.clearAnimators()
            fireMgr.addAnimators(anims)
        }
    }
    
    
    @IBAction func onRandomButtonDown(sender: UIButton) {
        self.buttonHoldDownStartTimestamp = NSDate.timeIntervalSinceReferenceDate()
    }
    @IBAction func onRandomButtonUp(sender: UIButton) {
        let currTimestamp = NSDate.timeIntervalSinceReferenceDate()
        let timeDiff = min(currTimestamp - self.buttonHoldDownStartTimestamp, ControlViewController.MAX_BUTTON_HOLD_TIME_S)
        
        var randomBurstTime = MathHelper.lerp(timeDiff, x0: 0.0, x1: ControlViewController.MAX_BUTTON_HOLD_TIME_S, y0: 0.4, y1: 0.2)
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        var anims = FireAnimatorManager.buildRandomFireAnimators(0.0, minNumRandomFlames: 8, maxNumRandomFlames: 16, minBurstTimeInSecs: randomBurstTime, maxBurstTimeInSecs: randomBurstTime)
        
        if let fireMgr = appDelegate.fireAnimatorManager {
            fireMgr.clearAnimators()
            fireMgr.addAnimators(anims)
        }
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
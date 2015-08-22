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
    
    @IBOutlet var pinwheelButton: UIButton!
    @IBOutlet var eruptionButton: UIButton!
    @IBOutlet var randomButton: UIButton!
    
    var pinwheelButtonDefaultBGColour = UIColor.redColor()
    var eruptionButtonDefaultBGColour = UIColor.orangeColor()
    var randomButtonDefaultBGColour = UIColor.yellowColor()
    
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
        
        self.pinwheelButtonDefaultBGColour = self.pinwheelButton.backgroundColor!
        self.eruptionButtonDefaultBGColour = self.eruptionButton.backgroundColor!
        self.randomButtonDefaultBGColour = self.randomButton.backgroundColor!
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
    
    static let DELTA_FLASH_TIME_S: NSTimeInterval = 0.05
    
    static let MAX_BUTTON_HOLD_TIME_S: NSTimeInterval = 2.0
    private var buttonHoldDownStartTimestamp: NSTimeInterval = 0.0
    
    
    @IBAction func onPinwheelButtonDown(sender: UIButton) {
        self.buttonHoldDownStartTimestamp = NSDate.timeIntervalSinceReferenceDate()
        
        self.stopFlashing(self.pinwheelButton, originalColour: self.pinwheelButtonDefaultBGColour)
        self.flashOn(self.pinwheelButton, flashTimeInS: 0.3, delay: 0.0, originalColour: self.pinwheelButtonDefaultBGColour)
    }
    @IBAction func onPinwheelButtonUp(sender: UIButton) {
        self.stopFlashing(self.pinwheelButton, originalColour: self.pinwheelButtonDefaultBGColour)
        
        let currTimestamp = NSDate.timeIntervalSinceReferenceDate()
        let timeDiff = min(currTimestamp - self.buttonHoldDownStartTimestamp, ControlViewController.MAX_BUTTON_HOLD_TIME_S)
        
        let numPinwheels = Int(MathHelper.lerp(timeDiff, x0: 0.0, x1: ControlViewController.MAX_BUTTON_HOLD_TIME_S, y0: 1.0, y1: 4.0))
        let pinwheelSpd = MathHelper.lerp(timeDiff, x0: 0.0, x1: ControlViewController.MAX_BUTTON_HOLD_TIME_S, y0: 0.15, y1: 0.075)
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        var anims = FireAnimatorManager.buildPinwheelFireAnimators(0.0, burstTimeInSecs: pinwheelSpd, clockwise: MathHelper.randomBool(), numPinwheels: numPinwheels)
        
        if let fireMgr = appDelegate.fireAnimatorManager {
            fireMgr.clearAnimators()
            fireMgr.addAnimators(anims)
        }
    }
    @IBAction func onPinwheelButtonCancel(sender: UIButton) {
        self.stopFlashing(self.pinwheelButton, originalColour: self.pinwheelButtonDefaultBGColour)
    }
    
    @IBAction func onEruptionButtonDown(sender: UIButton) {
        self.buttonHoldDownStartTimestamp = NSDate.timeIntervalSinceReferenceDate()
        
        self.stopFlashing(self.eruptionButton, originalColour: self.eruptionButtonDefaultBGColour)
        self.flashOn(self.eruptionButton, flashTimeInS: 0.3, delay: 0.0, originalColour: self.eruptionButtonDefaultBGColour)
    }
    @IBAction func onEruptionButtonUp(sender: UIButton) {
        self.stopFlashing(self.eruptionButton, originalColour: self.eruptionButtonDefaultBGColour)
        
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
    @IBAction func onEruptionButtonCancel(sender: UIButton) {
        self.stopFlashing(self.eruptionButton, originalColour: self.eruptionButtonDefaultBGColour)
    }
    
    @IBAction func onRandomButtonDown(sender: UIButton) {
        self.buttonHoldDownStartTimestamp = NSDate.timeIntervalSinceReferenceDate()
        
        self.stopFlashing(self.randomButton, originalColour: self.randomButtonDefaultBGColour)
        self.flashOn(self.randomButton, flashTimeInS: 0.3, delay: 0.0, originalColour: self.randomButtonDefaultBGColour)
    }
    @IBAction func onRandomButtonUp(sender: UIButton) {
        self.stopFlashing(self.randomButton, originalColour: self.randomButtonDefaultBGColour)
        
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
    @IBAction func onRandomButtonCancel(sender: UIButton) {
        self.stopFlashing(self.randomButton, originalColour: self.randomButtonDefaultBGColour)
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
    
    
    private func flashOff(v: UIView, flashTimeInS: NSTimeInterval, originalColour: UIColor) {
        UIView.animateWithDuration(flashTimeInS, delay: 0.0, options: UIViewAnimationOptions.AllowUserInteraction, animations: { v.backgroundColor = originalColour }, completion: { (isComplete: Bool) in if isComplete { self.flashOn(v, flashTimeInS: flashTimeInS - ControlViewController.DELTA_FLASH_TIME_S, delay: NSTimeInterval(0.0), originalColour: originalColour) } })
    }
    
    private func flashOn(v: UIView, flashTimeInS: NSTimeInterval, delay: NSTimeInterval, originalColour: UIColor) {
        var flashTime = max(flashTimeInS, ControlViewController.DELTA_FLASH_TIME_S)
        UIView.animateWithDuration(flashTime, delay: delay, options: UIViewAnimationOptions.AllowUserInteraction, animations: { v.backgroundColor = UIColor.whiteColor() }, completion: { (isComplete: Bool) in if isComplete { self.flashOff(v, flashTimeInS: flashTime, originalColour: originalColour) } })
    }
    
    private func stopFlashing(v: UIView, originalColour: UIColor) {
        v.layer.removeAllAnimations()
        v.backgroundColor = originalColour
    }
}
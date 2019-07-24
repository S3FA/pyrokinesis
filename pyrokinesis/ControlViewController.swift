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
    
    var pinwheelButtonDefaultBGColour = UIColor.red
    var eruptionButtonDefaultBGColour = UIColor.orange
    var randomButtonDefaultBGColour = UIColor.yellow
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let navCtrl = self.navigationController {
            navCtrl.delegate = self
        }
        
        // Make this view a delegate of the fire simulator
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.fireSimulator.delegate = self
        
        self.pinwheelButtonDefaultBGColour = self.pinwheelButton.backgroundColor!
        self.eruptionButtonDefaultBGColour = self.eruptionButton.backgroundColor!
        self.randomButtonDefaultBGColour = self.randomButton.backgroundColor!
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.checkFlameEffectTouches(touches, touchOn: true)
        super.touchesBegan(touches, with:event)
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.checkFlameEffectTouches(touches, touchOn: true)
        super.touchesMoved(touches, with: event)
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.checkFlameEffectTouches(touches, touchOn: false)
        super.touchesEnded(touches, with: event)
    }
    override func touchesCancelled(_ touches: Set<UITouch>!, with event: UIEvent?) {
        self.checkFlameEffectTouches(touches, touchOn: false)
        super.touchesCancelled(touches, with: event)
    }
    
    // FireSimulatorDelegate Protocol
    func flameEffectChanged(_ flameIdx: Int, isOn: Bool) {
        for view in self.view.subviews {
            if let flameEffect = view as? UIFlameEffect {
                if flameEffect.index == flameIdx {
                    flameEffect.simulateTouchWithoutSendingData(isOn)
                    return
                }
            }
        }
    }
    
    static let DELTA_FLASH_TIME_S: TimeInterval = 0.05
    
    static let MAX_BUTTON_HOLD_TIME_S: TimeInterval = 2.0
    fileprivate var buttonHoldDownStartTimestamp: TimeInterval = 0.0
    
    
    @IBAction func onPinwheelButtonDown(_ sender: UIButton) {
        self.buttonHoldDownStartTimestamp = Date.timeIntervalSinceReferenceDate
        
        self.stopFlashing(self.pinwheelButton, originalColour: self.pinwheelButtonDefaultBGColour)
        self.flashOn(self.pinwheelButton, flashTimeInS: 0.3, delay: 0.0, originalColour: self.pinwheelButtonDefaultBGColour)
    }
    @IBAction func onPinwheelButtonUp(_ sender: UIButton) {
        self.stopFlashing(self.pinwheelButton, originalColour: self.pinwheelButtonDefaultBGColour)
        
        let currTimestamp = Date.timeIntervalSinceReferenceDate
        let timeDiff = min(currTimestamp - self.buttonHoldDownStartTimestamp, ControlViewController.MAX_BUTTON_HOLD_TIME_S)
        
        let numPinwheels = Int(MathHelper.lerp(timeDiff, x0: 0.0, x1: ControlViewController.MAX_BUTTON_HOLD_TIME_S, y0: 1.0, y1: 4.0))
        let pinwheelSpd = MathHelper.lerp(timeDiff, x0: 0.0, x1: ControlViewController.MAX_BUTTON_HOLD_TIME_S, y0: 0.15, y1: 0.075)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        var anims = FireAnimatorManager.buildPinwheelFireAnimators(0.0, burstTimeInSecs: pinwheelSpd, clockwise: MathHelper.randomBool(), numPinwheels: numPinwheels)
        
        if let fireMgr = appDelegate.fireAnimatorManager {
            fireMgr.clearAnimators()
            fireMgr.addAnimators(anims)
        }
    }
    @IBAction func onPinwheelButtonCancel(_ sender: UIButton) {
        self.stopFlashing(self.pinwheelButton, originalColour: self.pinwheelButtonDefaultBGColour)
    }
    
    @IBAction func onEruptionButtonDown(_ sender: UIButton) {
        self.buttonHoldDownStartTimestamp = Date.timeIntervalSinceReferenceDate
        
        self.stopFlashing(self.eruptionButton, originalColour: self.eruptionButtonDefaultBGColour)
        self.flashOn(self.eruptionButton, flashTimeInS: 0.3, delay: 0.0, originalColour: self.eruptionButtonDefaultBGColour)
    }
    @IBAction func onEruptionButtonUp(_ sender: UIButton) {
        self.stopFlashing(self.eruptionButton, originalColour: self.eruptionButtonDefaultBGColour)
        
        let currTimestamp = Date.timeIntervalSinceReferenceDate
        let timeDiff = min(currTimestamp - self.buttonHoldDownStartTimestamp, ControlViewController.MAX_BUTTON_HOLD_TIME_S)
        
        var eruptionLengthInS = MathHelper.lerp(timeDiff, x0: 0.0, x1: ControlViewController.MAX_BUTTON_HOLD_TIME_S, y0: 0.5, y1: 1.9)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        var anims = FireAnimatorManager.buildEruptionFireAnimators(0.0, burstTimeInSecs: eruptionLengthInS)
        
        if let fireMgr = appDelegate.fireAnimatorManager {
            fireMgr.clearAnimators()
            fireMgr.addAnimators(anims)
        }
    }
    @IBAction func onEruptionButtonCancel(_ sender: UIButton) {
        self.stopFlashing(self.eruptionButton, originalColour: self.eruptionButtonDefaultBGColour)
    }
    
    @IBAction func onRandomButtonDown(_ sender: UIButton) {
        self.buttonHoldDownStartTimestamp = Date.timeIntervalSinceReferenceDate
        
        self.stopFlashing(self.randomButton, originalColour: self.randomButtonDefaultBGColour)
        self.flashOn(self.randomButton, flashTimeInS: 0.3, delay: 0.0, originalColour: self.randomButtonDefaultBGColour)
    }
    @IBAction func onRandomButtonUp(_ sender: UIButton) {
        self.stopFlashing(self.randomButton, originalColour: self.randomButtonDefaultBGColour)
        
        let currTimestamp = Date.timeIntervalSinceReferenceDate
        let timeDiff = min(currTimestamp - self.buttonHoldDownStartTimestamp, ControlViewController.MAX_BUTTON_HOLD_TIME_S)
        
        var randomBurstTime = MathHelper.lerp(timeDiff, x0: 0.0, x1: ControlViewController.MAX_BUTTON_HOLD_TIME_S, y0: 0.4, y1: 0.2)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        var anims = FireAnimatorManager.buildRandomFireAnimators(0.0, minNumRandomFlames: 8, maxNumRandomFlames: 16, minBurstTimeInSecs: randomBurstTime, maxBurstTimeInSecs: randomBurstTime)
        
        if let fireMgr = appDelegate.fireAnimatorManager {
            fireMgr.clearAnimators()
            fireMgr.addAnimators(anims)
        }
    }
    @IBAction func onRandomButtonCancel(_ sender: UIButton) {
        self.stopFlashing(self.randomButton, originalColour: self.randomButtonDefaultBGColour)
    }
    
    fileprivate func checkFlameEffectTouches(_ touches: Set<NSObject>, touchOn: Bool) {
        if let touch = touches.first as? UITouch {
            
            let touchLocation = touch.location(in: self.view)
            
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
    
    
    fileprivate func flashOff(_ v: UIView, flashTimeInS: TimeInterval, originalColour: UIColor) {
        UIView.animate(withDuration: flashTimeInS, delay: 0.0, options: UIView.AnimationOptions.allowUserInteraction, animations: { v.backgroundColor = originalColour }, completion: { (isComplete: Bool) in if isComplete { self.flashOn(v, flashTimeInS: flashTimeInS - ControlViewController.DELTA_FLASH_TIME_S, delay: TimeInterval(0.0), originalColour: originalColour) } })
    }
    
    fileprivate func flashOn(_ v: UIView, flashTimeInS: TimeInterval, delay: TimeInterval, originalColour: UIColor) {
        let flashTime = max(flashTimeInS, ControlViewController.DELTA_FLASH_TIME_S)
        UIView.animate(withDuration: flashTime, delay: delay, options: UIView.AnimationOptions.allowUserInteraction, animations: { v.backgroundColor = UIColor.white }, completion: { (isComplete: Bool) in if isComplete { self.flashOff(v, flashTimeInS: flashTime, originalColour: originalColour) } })
    }
    
    fileprivate func stopFlashing(_ v: UIView, originalColour: UIColor) {
        v.layer.removeAllAnimations()
        v.backgroundColor = originalColour
    }
}

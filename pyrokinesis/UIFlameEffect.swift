//
//  UIFlameEffect.swift
//  pyrokinesis
//
//  Created by Callum Hay on 2015-07-19.
//  Copyright (c) 2015 s3fa. All rights reserved.
//

import Foundation
import UIKit

class UIFlameEffect : UIView {
    
    @IBInspectable var index: Int = -1
    
    static let IDLE_FILL_COLOUR: UIColor  = UIColor(red:1.0, green:0.0, blue:0.0, alpha:0.5)
    @IBInspectable var touchFillColour: UIColor = UIColor.red
    @IBInspectable var strokeColour: UIColor = UIColor.black
    
    fileprivate var currFillColour : UIColor
    fileprivate var shapePath: UIBezierPath
    
    fileprivate var touchRepeatTimer: Timer?
    
    var lockUntouch = false // If true this will not allow the flame effect to be untoggled by touch
    
    
    required init?(coder aDecoder: NSCoder) {
        self.currFillColour = UIFlameEffect.IDLE_FILL_COLOUR
        self.shapePath = UIBezierPath()
        self.touchRepeatTimer = nil
        
        super.init(coder: aDecoder)
        self.isUserInteractionEnabled = true
        self.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
    }
    
    override func draw(_ rect: CGRect) {
        let LINE_WIDTH: CGFloat = 3.0
        
        var circleRect = CGRect(x: rect.origin.x+LINE_WIDTH, y: rect.origin.y+2*LINE_WIDTH, width: rect.size.width - 2*LINE_WIDTH, height: rect.size.height - 2*LINE_WIDTH);
        
        self.shapePath = UIBezierPath(ovalIn: rect)
        self.shapePath.lineWidth = LINE_WIDTH
        
        self.currFillColour.setFill()
        self.strokeColour.setStroke()
        self.shapePath.fill()
        self.shapePath.stroke()
    }
    
    func containsPoint(_ point: CGPoint) -> Bool {
        return self.shapePath.contains(self.convert(point, from: self.superview))
    }
    
    func simulateTouchWithoutSendingData(_ isBeingTouched: Bool) {
        self.lockUntouch = isBeingTouched
        if isBeingTouched {
            self.currFillColour = self.touchFillColour
        }
        else {
            self.currFillColour = UIFlameEffect.IDLE_FILL_COLOUR
        }
        
        self.setNeedsDisplay()
    }
    
    func setTouched(_ isBeingTouched: Bool) {
        // Setup or tear down a timer for checking on resending fire data...
        if isBeingTouched {
            
            // If the effect is already being touched then ignore
            if self.isTouched() {
                return
            }
            
            self.sendFireControlData()
            
            if self.touchRepeatTimer == nil {
                self.touchRepeatTimer = Timer.scheduledTimer(timeInterval: PyrokinesisSettings.FLAME_EFFECT_RESEND_TIME_S, target: self, selector: #selector(UIFlameEffect.sendFireControlData), userInfo: nil, repeats: true)
            }
            
            self.currFillColour = self.touchFillColour
        }
        else {
            if let timer = self.touchRepeatTimer {
                if timer.isValid {
                    timer.invalidate()
                }
            }
            self.touchRepeatTimer = nil
            if !self.lockUntouch {
                self.currFillColour = UIFlameEffect.IDLE_FILL_COLOUR
            }
        }

        self.setNeedsDisplay()
    }
    
    // Resend fire data if the flame effect is being held down...
    @objc
    func sendFireControlData() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.sendFireControlData(self.index)
    }
    
    fileprivate func isTouched() -> Bool {
        return self.currFillColour == self.touchFillColour
    }
    
}

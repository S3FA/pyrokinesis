//
//  UIFlameEffect.swift
//  pyrokinesis
//
//  Created by beowulf on 2015-07-19.
//  Copyright (c) 2015 s3fa. All rights reserved.
//

import Foundation
import UIKit

class UIFlameEffect : UIView {
    
    @IBInspectable var index: Int = -1
    
    @IBInspectable var idleFillColour: UIColor  = UIColor.whiteColor()
    @IBInspectable var touchFillColour: UIColor = UIColor.redColor()
    @IBInspectable var strokeColour: UIColor = UIColor.blackColor()
    
    
    
    private var currFillColour : UIColor
    private var shapePath: UIBezierPath
    
    private var touchRepeatTimer: NSTimer?
    
    required init(coder aDecoder: NSCoder) {
        self.currFillColour = idleFillColour
        self.shapePath = UIBezierPath()
        self.touchRepeatTimer = nil
        
        super.init(coder: aDecoder)
        self.userInteractionEnabled = true
        self.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
    }
    
    override func drawRect(rect: CGRect) {
        let LINE_WIDTH: CGFloat = 3.0
        
        var circleRect = CGRectMake(rect.origin.x+LINE_WIDTH, rect.origin.y+LINE_WIDTH, rect.size.width - 2*LINE_WIDTH, rect.size.height - 2*LINE_WIDTH);
        
        self.shapePath = UIBezierPath(ovalInRect: circleRect)
        self.shapePath.lineWidth = LINE_WIDTH
        
        self.currFillColour.setFill()
        self.strokeColour.setStroke()
        self.shapePath.fill()
        self.shapePath.stroke()
    }
    
    func containsPoint(point: CGPoint) -> Bool {
        return self.shapePath.containsPoint(self.convertPoint(point, fromView: self.superview))
    }
    
    func setTouched(isBeingTouched: Bool) {
        // Setup or tear down a timer for checking on resending fire data...
        if isBeingTouched {
            
            // If the effect is already being touched then ignore
            if self.isTouched() {
                return
            }
            
            self.sendFireControlData()
            
            if self.touchRepeatTimer == nil {
                self.touchRepeatTimer = NSTimer.scheduledTimerWithTimeInterval(PyrokinesisSettings.FLAME_EFFECT_RESEND_TIME_S, target: self, selector: Selector("sendFireControlData"), userInfo: nil, repeats: true)
            }
            
            self.currFillColour = self.touchFillColour
        }
        else {
            if let timer = self.touchRepeatTimer {
                if timer.valid {
                    timer.invalidate()
                }
            }
            self.touchRepeatTimer = nil
            self.currFillColour = self.idleFillColour
        }

        self.setNeedsDisplay()
    }
    
    // Resend fire data if the flame effect is being held down...
    func sendFireControlData() {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.sendFireControlData(self.index)
    }
    
    private func isTouched() -> Bool {
        return self.currFillColour == self.touchFillColour
    }
    
}
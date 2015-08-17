//
//  FireAnimator.swift
//  pyrokinesis
//
//  Created by Callum Hay on 2015-08-12.
//  Copyright (c) 2015 s3fa. All rights reserved.
//

import Foundation

class FireAnimator {
    
    static let REPEAT_ANIM_FOREVER: Int = -1
    
    var fireIndices = [Int]()
    var animationTime: Double = 0.0
    var holdFlameTime: Double = 0.0
    
    private var timeCounter: Double = 0
    private var keepFiringTimeCounter: Double = 0
    
    init() {
        
    }
    init(fireIndices: [Int]) {
        assert(fireIndices.count >= 0 && fireIndices.count <= PyrokinesisSettings.NUM_FLAME_EFFECTS)
        self.fireIndices = fireIndices
    }
    convenience init(fireIndices: [Int], animationTime: Double) {
        self.init(fireIndices: fireIndices)
        self.startAnimation(animationTime)
    }
    convenience init(fireIndices: [Int], animationTime: Double, holdFlameTime: Double) {
        self.init(fireIndices: fireIndices, animationTime: animationTime)
        self.holdFlameTime = holdFlameTime
    }
    
    func startAnimation(animationTime: Double) {
        assert(animationTime >= 0.0)
        self.timeCounter = 0
        self.animationTime = animationTime
    }
    
    func stopAnimation() {
        self.animationTime = 0.0
        self.timeCounter = 0
    }
    
    func timeUntilFinished() -> Double {
        if self.isFinished() {
            return 0.0
        }
        
        if self.holdFlameTime > 0.0 {
            return (self.animationTime + self.holdFlameTime) - self.timeCounter
        }
        return self.animationTime - self.timeCounter
    }
    
    func isFinished() -> Bool {
        // Special case if the hold flame time is non-zero, positive
        if self.holdFlameTime > 0.0 {
            return self.timeCounter > (self.animationTime + self.holdFlameTime)
        }
        
        return self.timeCounter > self.animationTime
    }
    
    func tick(dt: Double) {
        if self.isFinished() {
            return
        }
        
        if self.holdFlameTime > 0.0 && self.timeCounter > self.animationTime {
            self.keepFiringTimeCounter += dt
            self.timeCounter += dt
            
            // Make sure we keep "strobing" the fire (keeping it turned on) if the
            // keep firing flag is on
            if self.keepFiringTimeCounter >= PyrokinesisSettings.FLAME_EFFECT_RESEND_TIME_S {
                self.fire()
                self.keepFiringTimeCounter = 0
            }
            
            return
        }
        
        // Figure out where we are in the animation time and shoot fire if we're far enough into it
        self.timeCounter += dt
        if self.timeCounter >= self.animationTime {
            // Shoot the fire!
            self.fire()
            self.timeCounter = self.animationTime
        }
    }
    
    private func fire() {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.sendMultiFireControlData(self.fireIndices)
    }
    
}
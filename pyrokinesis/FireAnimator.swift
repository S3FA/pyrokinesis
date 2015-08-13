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
    
    private var fireIndices = [Int]()
    
    private var animationTime: Double = 0.0
    private var timeCounter: Double = 0
    
    init(fireIndices: [Int]) {
        assert(fireIndices.count >= 0 && fireIndices.count <= PyrokinesisSettings.NUM_FLAME_EFFECTS)
        self.fireIndices = fireIndices
    }
    convenience init(fireIndices: [Int], animationTime: Double) {
        self.init(fireIndices: fireIndices)
        self.startAnimation(animationTime)
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
    
    func isFinished() -> Bool {
        return self.timeCounter > self.animationTime
    }
    
    func tick(dt: Double) {
        if self.isFinished() {
            return
        }
        
        // Figure out where we are in the animation time and shoot fire if we're far enough into it
        self.timeCounter += dt
        if self.timeCounter >= self.animationTime {
            // Shoot the fire!
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            appDelegate.sendMultiFireControlData(self.fireIndices)
            
            self.timeCounter = self.animationTime + 0.1
        }
    }
}
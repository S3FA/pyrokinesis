//
//  FireAnimatorManager.swift
//  pyrokinesis
//
//  Created by Callum Hay on 2015-08-12.
//  Copyright (c) 2015 s3fa. All rights reserved.
//

import Foundation

class FireAnimatorManager {
    
    private static let TICK_DELTA_TIME_SECS = 0.1
    
    private var tickTimer: NSTimer? = nil
    
    var animators = [FireAnimator]()
    
    init() {
        self.animators.reserveCapacity(3*PyrokinesisSettings.NUM_FLAME_EFFECTS)
        self.tickTimer = NSTimer.scheduledTimerWithTimeInterval(FireAnimatorManager.TICK_DELTA_TIME_SECS, target: self, selector: Selector("tick"), userInfo: nil, repeats: true)
    }
    
    func animatorsActive() -> Bool {
        return !self.animators.isEmpty
    }
    
    func addAnimator(animator: FireAnimator) {
        self.animators.append(animator)
    }
    
    func clearAnimators() {
        for animator in self.animators {
            animator.stopAnimation()
        }
        self.animators.removeAll(keepCapacity: true)
    }
    
    func tick() {
        // Tick each of the current animators...
        var allDone = true
        for animator in self.animators {
            animator.tick(FireAnimatorManager.TICK_DELTA_TIME_SECS)
            allDone = allDone && animator.isFinished()
        }
        
        if allDone {
            self.clearAnimators()
        }
    }
    
    func getLatestAnimator() -> FireAnimator {
        var latestTime: Double = -1
        var result: FireAnimator? = nil
        for animator in self.animators {
            if animator.animationTime > latestTime {
                result = animator
                latestTime = animator.animationTime
            }
        }
        
        assert (result != nil)
        return result!
    }
    
    // Fire routine builder methods
    static let TIME_BETWEEN_CALM_FIRE_BURSTS: Double = 1.0
    class func buildCalmFireAnimators(startTimeInSecs: Double) -> [FireAnimator] {
        var result = [FireAnimator]()
        result.reserveCapacity(PyrokinesisSettings.NUM_FLAME_EFFECTS)
        
        // Inner-most flame heads....
        
        
        // 2nd inner-most...
        
        
        // Outer-most...
        
        
        return result
    }
    
    
    
}
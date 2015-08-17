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
    func addAnimators(animatorList: [FireAnimator]!) {
        self.animators += animatorList
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
    
    func getLatestAnimator() -> FireAnimator? {
        var latestTime: Double = -1
        var result: FireAnimator? = nil
        for animator in self.animators {
            if animator.animationTime > latestTime {
                result = animator
                latestTime = animator.animationTime
            }
        }
        
        return result
    }
    
    // Fire routine builder methods
    class func buildInnerOuterFireAnimators(startTimeInSecs: Double, burstTimeInSecs: Double) -> [FireAnimator] {
        var result = [FireAnimator]()
        result.reserveCapacity(2)
        
        // Inner-most flame heads....
        result.append(FireAnimator(fireIndices: PyrokinesisSettings.INNER_MOST_FLAME_INDICES, animationTime: startTimeInSecs, holdFlameTime: burstTimeInSecs))
        // Outer-most...
        result.append(FireAnimator(fireIndices: PyrokinesisSettings.OUTER_MOST_FLAME_INDICES, animationTime: startTimeInSecs + burstTimeInSecs, holdFlameTime: burstTimeInSecs))
        
        return result
    }
    
    class func buildPinwheelFireAnimators(startTimeInSecs: Double, burstTimeInSecs: Double, clockwise: Bool) -> [FireAnimator] {
        var result = [FireAnimator]()
        result.reserveCapacity(PyrokinesisSettings.NUM_FLAME_EFFECTS)
        
        var timeCountInS: Double = startTimeInSecs
        if clockwise {
            for (var i = 0; i < PyrokinesisSettings.NUM_FLAME_EFFECTS; i++) {
                result.append(FireAnimator(fireIndices: [i], animationTime: timeCountInS, holdFlameTime: burstTimeInSecs))
                timeCountInS += burstTimeInSecs
            }
        }
        else {
            for (var i = PyrokinesisSettings.NUM_FLAME_EFFECTS-1; i >= 0 ; i--) {
                result.append(FireAnimator(fireIndices: [i], animationTime: timeCountInS, holdFlameTime: burstTimeInSecs))
                timeCountInS += burstTimeInSecs
            }
        }
        
        return result
    }
}
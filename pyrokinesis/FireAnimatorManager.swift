//
//  FireAnimatorManager.swift
//  pyrokinesis
//
//  Created by Callum Hay on 2015-08-12.
//  Copyright (c) 2015 s3fa. All rights reserved.
//

import Foundation

class FireAnimatorManager : NSObject {
    
    private static let TICK_DELTA_TIME_SECS: NSTimeInterval = PyrokinesisSettings.FLAME_EFFECT_RESEND_TIME_S / 2.0
    
    private var tickTimer: NSTimer? = nil
    
    var animators = [FireAnimator]()
    
    override init() {
        super.init()
        
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
            let timeUntilFinished = animator.timeUntilFinished()
            if timeUntilFinished > latestTime {
                result = animator
                latestTime = timeUntilFinished
            }
        }
        
        return result
    }
    
    // Fire routine builder methods
    class func buildInnerOuterFireAnimators(startTimeInSecs: Double, burstTimeInSecs: Double) -> [FireAnimator] {
        var result = [FireAnimator]()
        result.reserveCapacity(2)
        
        // Inner-most flame heads....
        result.append(FireAnimator(fireIndices: PyrokinesisSettings.INNER_MOST_FLAME_INDICES, timeUntilFire: startTimeInSecs, holdFlameTime: burstTimeInSecs))
        // Outer-most...
        result.append(FireAnimator(fireIndices: PyrokinesisSettings.OUTER_MOST_FLAME_INDICES, timeUntilFire: startTimeInSecs + burstTimeInSecs, holdFlameTime: burstTimeInSecs))
        
        return result
    }
    
    class func buildPinwheelFireAnimators(startTimeInSecs: Double, burstTimeInSecs: Double, clockwise: Bool, numPinwheels: Int) -> [FireAnimator] {
        var result = [FireAnimator]()
        result.reserveCapacity(PyrokinesisSettings.NUM_FLAME_EFFECTS)
        
        var timeCountInS = startTimeInSecs
        if clockwise {
            for (var x = 0; x < numPinwheels; x++) {
                for (var i = 0; i < PyrokinesisSettings.NUM_FLAME_EFFECTS; i++) {
                    result.append(FireAnimator(fireIndices: [i], timeUntilFire: timeCountInS, holdFlameTime: burstTimeInSecs))
                    timeCountInS += burstTimeInSecs
                }
            }
        }
        else {
            for (var x = 0; x < numPinwheels; x++) {
                for (var i = PyrokinesisSettings.NUM_FLAME_EFFECTS-1; i >= 0 ; i--) {
                    result.append(FireAnimator(fireIndices: [i], timeUntilFire: timeCountInS, holdFlameTime: burstTimeInSecs))
                    timeCountInS += burstTimeInSecs
                }
            }
        }
        
        return result
    }
    
    class func buildEruptionFireAnimators(startTimeInSecs: Double, burstTimeInSecs: Double) -> [FireAnimator] {
        return [ FireAnimator(fireIndices: PyrokinesisSettings.ALL_FLAME_INDICES, timeUntilFire: startTimeInSecs, holdFlameTime: burstTimeInSecs) ]
    }
    
    class func buildRandomFireAnimators(startTimeInSecs: Double, minNumRandomFlames: UInt, maxNumRandomFlames: UInt, minBurstTimeInSecs: Double, maxBurstTimeInSecs: Double) -> [FireAnimator] {
        
        assert(minNumRandomFlames <= maxNumRandomFlames)
        assert(minBurstTimeInSecs <= maxBurstTimeInSecs)
        
        let numRandomFlames = Int(MathHelper.randomUInt(minNumRandomFlames, maxVal: maxNumRandomFlames))
        
        var result = [FireAnimator]()
        result.reserveCapacity(numRandomFlames)
        
        var randomFireIdx = Int(MathHelper.randomUInt(0, maxVal: UInt(PyrokinesisSettings.NUM_FLAME_EFFECTS-1)))

        var timeCountInS = startTimeInSecs
        for (var i = 0; i < numRandomFlames; i++) {
            
            let randomBurstTimeInS = MathHelper.randomDouble(minBurstTimeInSecs, maxVal: maxBurstTimeInSecs)
            
            result.append(FireAnimator(fireIndices: [randomFireIdx], timeUntilFire: timeCountInS, holdFlameTime: randomBurstTimeInS))
            
            timeCountInS += randomBurstTimeInS
            
            randomFireIdx = (randomFireIdx + 1 + Int(MathHelper.randomUInt(0, maxVal: UInt(PyrokinesisSettings.NUM_FLAME_EFFECTS-2)))) % PyrokinesisSettings.NUM_FLAME_EFFECTS
        }
        
        return result
    }
    
}
//
//  FireAnimatorManager.swift
//  pyrokinesis
//
//  Created by Callum Hay on 2015-08-12.
//  Copyright (c) 2015 s3fa. All rights reserved.
//

import Foundation

class FireAnimatorManager : NSObject {
    
    fileprivate static let TICK_DELTA_TIME_SECS: TimeInterval = PyrokinesisSettings.FLAME_EFFECT_RESEND_TIME_S / 2.0
    
    fileprivate var tickTimer: Timer? = nil
    
    var animators = [FireAnimator]()
    
    override init() {
        super.init()
        
        self.animators.reserveCapacity(3*PyrokinesisSettings.NUM_FLAME_EFFECTS)
        self.tickTimer = Timer.scheduledTimer(timeInterval: FireAnimatorManager.TICK_DELTA_TIME_SECS, target: self, selector: #selector(FireAnimatorManager.tick), userInfo: nil, repeats: true)
    }
    
    func animatorsActive() -> Bool {
        return !self.animators.isEmpty
    }
    
    func addAnimator(_ animator: FireAnimator) {
        self.animators.append(animator)
    }
    func addAnimators(_ animatorList: [FireAnimator]!) {
        self.animators += animatorList
    }
    
    func clearAnimators() {
        for animator in self.animators {
            animator.stopAnimation()
        }
        self.animators.removeAll(keepingCapacity: true)
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
    class func buildInnerOuterFireAnimators(_ startTimeInSecs: Double, burstTimeInSecs: Double) -> [FireAnimator] {
        var result = [FireAnimator]()
        result.reserveCapacity(2)
        
        // Inner-most flame heads....
        result.append(FireAnimator(fireIndices: PyrokinesisSettings.INNER_MOST_FLAME_INDICES, timeUntilFire: startTimeInSecs, holdFlameTime: burstTimeInSecs))
        // Outer-most...
        result.append(FireAnimator(fireIndices: PyrokinesisSettings.OUTER_MOST_FLAME_INDICES, timeUntilFire: startTimeInSecs + burstTimeInSecs, holdFlameTime: burstTimeInSecs))
        
        return result
    }
    
    class func buildPinwheelFireAnimators(_ startTimeInSecs: Double, burstTimeInSecs: Double, clockwise: Bool, numPinwheels: Int) -> [FireAnimator] {
        var result = [FireAnimator]()
        result.reserveCapacity(PyrokinesisSettings.NUM_FLAME_EFFECTS)
        
        var timeCountInS = startTimeInSecs
        if clockwise {
            for _ in 0...numPinwheels {
                for i in 0...PyrokinesisSettings.NUM_FLAME_EFFECTS {
                    result.append(FireAnimator(fireIndices: [i], timeUntilFire: timeCountInS, holdFlameTime: burstTimeInSecs))
                    timeCountInS += burstTimeInSecs
                }
            }
        }
        else {
            for _ in 0...numPinwheels {
                for i in (PyrokinesisSettings.NUM_FLAME_EFFECTS-1)...0 {
                    result.append(FireAnimator(fireIndices: [i], timeUntilFire: timeCountInS, holdFlameTime: burstTimeInSecs))
                    timeCountInS += burstTimeInSecs
                }
            }
        }
        
        return result
    }
    
    class func buildEruptionFireAnimators(_ startTimeInSecs: Double, burstTimeInSecs: Double) -> [FireAnimator] {
        return [ FireAnimator(fireIndices: PyrokinesisSettings.ALL_FLAME_INDICES, timeUntilFire: startTimeInSecs, holdFlameTime: burstTimeInSecs) ]
    }
    
    class func buildRandomFireAnimators(_ startTimeInSecs: Double, minNumRandomFlames: UInt, maxNumRandomFlames: UInt, minBurstTimeInSecs: Double, maxBurstTimeInSecs: Double) -> [FireAnimator] {
        
        assert(minNumRandomFlames <= maxNumRandomFlames)
        assert(minBurstTimeInSecs <= maxBurstTimeInSecs)
        
        let numRandomFlames = Int(MathHelper.randomUInt(minNumRandomFlames, maxVal: maxNumRandomFlames))
        
        var result = [FireAnimator]()
        result.reserveCapacity(numRandomFlames)
        
        var randomFireIdx = Int(MathHelper.randomUInt(0, maxVal: UInt(PyrokinesisSettings.NUM_FLAME_EFFECTS-1)))

        var timeCountInS = startTimeInSecs
        for _ in 0...(numRandomFlames-1) {
            
            let randomBurstTimeInS = MathHelper.randomDouble(minBurstTimeInSecs, maxVal: maxBurstTimeInSecs)
            
            result.append(FireAnimator(fireIndices: [randomFireIdx], timeUntilFire: timeCountInS, holdFlameTime: randomBurstTimeInS))
            
            timeCountInS += randomBurstTimeInS
            
            randomFireIdx = (randomFireIdx + 1 + Int(MathHelper.randomUInt(0, maxVal: UInt(PyrokinesisSettings.NUM_FLAME_EFFECTS-2)))) % PyrokinesisSettings.NUM_FLAME_EFFECTS
        }
        
        return result
    }
    
}

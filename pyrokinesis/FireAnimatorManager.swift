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
    private var animators = [FireAnimator]()
    
    init() {
        self.animators.reserveCapacity(3*PyrokinesisSettings.NUM_FLAME_EFFECTS)
        self.tickTimer = NSTimer.scheduledTimerWithTimeInterval(FireAnimatorManager.TICK_DELTA_TIME_SECS, target: self, selector: Selector("tick"), userInfo: nil, repeats: true)
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
        for animator in self.animators {
            animator.tick(FireAnimatorManager.TICK_DELTA_TIME_SECS)
        }
        
    }
    
}
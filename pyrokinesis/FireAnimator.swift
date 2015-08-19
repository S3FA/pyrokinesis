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
    var waitToFireTime: Double = 0.0
    var holdFlameTime: Double = 0.0
    
    private var timeCounter: Double = 0
    private var strobeFiringTimeCounter: Double = 0
    
    private enum State {
        case WaitingToFire
        case Firing
        case Done
    }
    private var currState = State.WaitingToFire
    
    init() {
        
    }
    init(fireIndices: [Int]) {
        assert(fireIndices.count >= 0 && fireIndices.count <= PyrokinesisSettings.NUM_FLAME_EFFECTS)
        self.fireIndices = fireIndices
    }
    convenience init(fireIndices: [Int], timeUntilFire: Double) {
        self.init(fireIndices: fireIndices)
        self.startAnimation(timeUntilFire)
    }
    convenience init(fireIndices: [Int], timeUntilFire: Double, holdFlameTime: Double) {
        self.init(fireIndices: fireIndices, timeUntilFire: timeUntilFire)
        self.holdFlameTime = holdFlameTime
    }
    
    func startAnimation(waitToFireTime: Double) {
        assert(waitToFireTime >= 0.0)

        self.waitToFireTime = waitToFireTime
        if waitToFireTime > 0 {
            self.setState(State.WaitingToFire)
        }
        else {
            self.setState(State.Firing)
        }
    }
    
    func stopAnimation() {
        self.setState(State.Done)
    }
    
    func timeUntilFinished() -> Double {
        switch (self.currState) {
            case .WaitingToFire:
                return (self.waitToFireTime - self.timeCounter) + self.holdFlameTime
            case .Firing:
                return (self.holdFlameTime - self.timeCounter)
            case .Done:
                return 0.0
        }
    }
    
    func isFinished() -> Bool {
        return self.currState == .Done
    }
    
    func tick(dt: Double) {
        switch (self.currState) {
            case .WaitingToFire:
                
                // Figure out where we are in the animation time and shoot fire if we're far enough into it
                self.timeCounter += dt
                if self.timeCounter >= self.waitToFireTime {
                    
                    let diff = self.timeCounter - self.waitToFireTime
                    
                    // Shoot the fire!
                    self.fire()
                    self.setState(State.Firing)
                    self.timeCounter = diff
                }
                break
                
            case .Firing:
                // Make sure we keep "strobing" the fire (keeping it turned on) if the
                // keep firing flag is on
                self.strobeFiringTimeCounter += dt
                if self.strobeFiringTimeCounter >= PyrokinesisSettings.FLAME_EFFECT_RESEND_TIME_S {
                    let diff = PyrokinesisSettings.FLAME_EFFECT_RESEND_TIME_S - self.strobeFiringTimeCounter
                    
                    self.fire()
                    self.strobeFiringTimeCounter = diff
                }
                
                self.timeCounter += dt
                if self.timeCounter >= self.holdFlameTime {
                    self.setState(State.Done)
                    return
                }
            
                break
                
            case .Done:
                break
        }
    }
    
    private func fire() {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.sendMultiFireControlData(self.fireIndices)
    }
    
    private func setState(newState: State) {
        switch (newState) {
        case .WaitingToFire:
            self.timeCounter = 0
            break
        case .Firing:
            self.timeCounter = 0
            self.strobeFiringTimeCounter = PyrokinesisSettings.FLAME_EFFECT_RESEND_TIME_S
            break
        case .Done:
            break
        }
        
        self.currState = newState
    }
    
}
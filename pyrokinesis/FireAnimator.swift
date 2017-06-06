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
    
    fileprivate var timeCounter: Double = 0
    fileprivate var strobeFiringTimeCounter: Double = 0
    
    fileprivate enum State {
        case waitingToFire
        case firing
        case done
    }
    fileprivate var currState = State.waitingToFire
    
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
    
    func startAnimation(_ waitToFireTime: Double) {
        assert(waitToFireTime >= 0.0)

        self.waitToFireTime = waitToFireTime
        if waitToFireTime > 0 {
            self.setState(State.waitingToFire)
        }
        else {
            self.setState(State.firing)
        }
    }
    
    func stopAnimation() {
        self.setState(State.done)
    }
    
    func timeUntilFinished() -> Double {
        switch (self.currState) {
            case .waitingToFire:
                return (self.waitToFireTime - self.timeCounter) + self.holdFlameTime
            case .firing:
                return (self.holdFlameTime - self.timeCounter)
            case .done:
                return 0.0
        }
    }
    
    func isFinished() -> Bool {
        return self.currState == .done
    }
    
    func tick(_ dt: Double) {
        switch (self.currState) {
            case .waitingToFire:
                
                // Figure out where we are in the animation time and shoot fire if we're far enough into it
                self.timeCounter += dt
                if self.timeCounter >= self.waitToFireTime {
                    
                    let diff = self.timeCounter - self.waitToFireTime
                    
                    // Shoot the fire!
                    self.fire()
                    self.setState(State.firing)
                    self.timeCounter = diff
                }
                break
                
            case .firing:
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
                    self.setState(State.done)
                    return
                }
            
                break
                
            case .done:
                break
        }
    }
    
    fileprivate func fire() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.sendMultiFireControlData(self.fireIndices)
    }
    
    fileprivate func setState(_ newState: State) {
        switch (newState) {
        case .waitingToFire:
            self.timeCounter = 0
            break
        case .firing:
            self.timeCounter = 0
            self.strobeFiringTimeCounter = PyrokinesisSettings.FLAME_EFFECT_RESEND_TIME_S
            break
        case .done:
            break
        }
        
        self.currState = newState
    }
    
}

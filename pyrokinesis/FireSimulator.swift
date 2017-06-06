//
//  FireSimulator.swift
//  pyrokinesis
//
//  Created by Callum Hay on 2015-08-18.
//  Copyright (c) 2015 s3fa. All rights reserved.
//

import Foundation

protocol FireSimulatorDelegate {
    func flameEffectChanged(_ flameIdx: Int, isOn: Bool)
}

class FlameEffectSimulator : NSObject {
    
    fileprivate var timer: Timer?
    
    fileprivate(set) var index: Int
    fileprivate(set) var isOn: Bool
    
    var delegate: FireSimulatorDelegate?
    
    init(index: Int) {
        self.index = index
        self.isOn = false
        self.timer = nil
        
        super.init()
    }
    
    func turnOn() {
        self.timer?.invalidate()
        
        self.isOn = true
        delegate?.flameEffectChanged(self.index, isOn: self.isOn)
        
        self.timer = Timer.scheduledTimer(timeInterval: PyrokinesisSettings.FLAME_EFFECT_ON_TIME_S, target: self, selector: Selector("turnOff"), userInfo: nil, repeats: false)
    }
    
    func turnOff() {
        self.isOn = false
        delegate?.flameEffectChanged(self.index, isOn: self.isOn)
        
        self.timer?.invalidate()
        self.timer = nil
    }
}

class FireSimulator {
    
    var flameEffects: [FlameEffectSimulator]
    var delegate: FireSimulatorDelegate? {
        set {
            for flameEffect in self.flameEffects {
                flameEffect.delegate = newValue
            }
        }
        get {
            return self.delegate
        }
    }
    
    init() {
        self.flameEffects = [FlameEffectSimulator]()
        self.flameEffects.reserveCapacity(PyrokinesisSettings.NUM_FLAME_EFFECTS)

        for i in 0...PyrokinesisSettings.NUM_FLAME_EFFECTS {
            self.flameEffects.append(FlameEffectSimulator(index: i))
        }
    }
}

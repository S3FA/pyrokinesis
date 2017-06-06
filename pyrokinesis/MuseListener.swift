//
//  MuseListener.swift
//  pyrokinesis
//
//  Created by Callum Hay on 2015-06-14.
//  Copyright (c) 2015 s3fa. All rights reserved.
//

import Foundation
import UIKit

class MuseListener : IXNMuseDataListener, IXNMuseConnectionListener {

    static let MAX_CACHED_VALUES : Int = 80
    static let MAX_HORSESHOE_CACHED_VALUES: Int = 20
    static let MAX_HORSESHOE_SCORE_TO_FIRE : Double = 6
    static let WORST_HORSESHOE_SCORE : Double = 16

    static let MAX_TIME_BETWEEN_QUEUED_ANIMS: Double = 2.0
    
    static let MIN_TIME_BETWEEN_JAW_CLENCH_FLAMES: Double = 1.0
    
    var cachedScoreValues = [IXNMuseDataPacketType: [Double]]()
    var horseshoeScoreValues = [Double]() // 4 - best, 16 - worst

    var museConnStatus:IXNConnectionState = IXNConnectionState.disconnected
    var dataUpdated: Bool = false
    
    fileprivate var sawOneBlink: Bool = false
    fileprivate var lastBlink: Bool = false
    fileprivate var sawOneJawClench: Bool = false
    fileprivate var lastJawClench: Bool = false
    fileprivate var lastJawClenchFireTime: Date = Date()
    
    @objc func receive(_ packet: IXNMuseDataPacket) {
        var cacheScore = false
        
        switch (packet.packetType) {
        
            // "Score" values - used to determine how intense and what types of fire are happening
            case IXNMuseDataPacketType.alphaScore:
                cacheScore = true
                break
            case IXNMuseDataPacketType.betaScore:
                cacheScore = true
                break
            case IXNMuseDataPacketType.deltaScore:
                //cacheScore = true
                break
            case IXNMuseDataPacketType.thetaScore:
                //cacheScore = true
                break
            case IXNMuseDataPacketType.gammaScore:
                //cacheScore = true
                break
            case IXNMuseDataPacketType.mellow:
                cacheScore = true
                break
            case IXNMuseDataPacketType.concentration:
                cacheScore = true
                break

            // "Other" values - for general information and misc. stuffs
            case IXNMuseDataPacketType.accelerometer:
                break
            case IXNMuseDataPacketType.battery:
                break
            case IXNMuseDataPacketType.horseshoe:
                var count: Double = 0
                for val in packet.values {
                    if let dblVal = val as? Double {
                        count += dblVal
                    }
                }
                
                if self.horseshoeScoreValues.count >= MuseListener.MAX_HORSESHOE_CACHED_VALUES {
                    self.horseshoeScoreValues.remove(at: 0)
                }
                self.horseshoeScoreValues.append(count)
                
                break
            
            default:
                break
        }
        
        if cacheScore {
            
            // Get the last known horseshoe value, if it's not acceptible then we don't record the value...
            if let lastHorseshoeScore = self.horseshoeScoreValues.last {
                if lastHorseshoeScore > MuseListener.MAX_HORSESHOE_SCORE_TO_FIRE {
                    return
                }
            }
            else {
                return
            }
            
            let values = packet.values
            
            var avgValue: Double = 0.0
            var count: Int = 0
            for val in values! {
                if let dblVal = val as? Double {
                    avgValue += dblVal
                    count += 1
                }
            }
            avgValue /= Double(count)
            
            // This shouldn't happen, we only accept numbers in [0,1]
            if avgValue < 0 || avgValue > 1 {
                return
            }
            
            if count > 0 {
                self.dataUpdated = true
                
                if self.cachedScoreValues[packet.packetType] != nil {
                    if self.cachedScoreValues[packet.packetType]!.count >= MuseListener.MAX_CACHED_VALUES {
                        self.cachedScoreValues[packet.packetType]!.remove(at: 0)
                    }
                    self.cachedScoreValues[packet.packetType]!.append(avgValue)
                    self.museBrainToFireCalc()
                }
                else {
                    self.cachedScoreValues[packet.packetType] = [avgValue]
                    self.cachedScoreValues[packet.packetType]!.reserveCapacity(MuseListener.MAX_CACHED_VALUES)
                }
            }
        }
        
    }
    
    @objc func receive(_ packet: IXNMuseArtifactPacket) {
        if !packet.headbandOn {
            return;
        }
        
        if !self.sawOneBlink {
            self.sawOneBlink = true;
            self.lastBlink = !packet.blink;
        }
        if self.lastBlink != packet.blink {
            if packet.blink {
                self.museBlinkToFireCalc()
                NSLog("Blink!");
            }
            self.lastBlink = packet.blink;
        }
        
        if !self.sawOneJawClench {
            self.sawOneJawClench = true;
            self.lastJawClench = !packet.jawClench;
        }
        if self.lastJawClench != packet.jawClench {
            if packet.jawClench {
                NSLog("Jaw Clench!");
            }
            self.lastJawClench = packet.jawClench;
        }
        
        if packet.jawClench {
            self.museJawClenchToFireCalc()
        }

    }
    
    @objc func receive(_ packet: IXNMuseConnectionPacket) {
        self.museConnStatus = packet.currentConnectionState
        
        switch (packet.currentConnectionState) {
            
            case IXNConnectionState.disconnected:
                // Try to reconnect by posting to the main thread...
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                 Timer.scheduledTimer(timeInterval: 0.0, target: appDelegate, selector: Selector("reconnectMuse"), userInfo: nil, repeats: false)
                break
            
            case IXNConnectionState.connected:
                break
            case IXNConnectionState.connecting:
                break
            
            case IXNConnectionState.needsUpdate:
                break
            case IXNConnectionState.unknown:
                break
            
            default:
                break
        }
        
        NSLog("Muse is now \(MuseListener.getConnectionStatusString(self.museConnStatus))")
    }
    
    class func getConnectionStatusString(_ state: IXNConnectionState) -> String {
        var statusStr: String = ""

        switch (state) {
            case IXNConnectionState.disconnected:
                statusStr = "DISCONNECTED"
                break
            case IXNConnectionState.connected:
                statusStr = "CONNECTED"
                break
            case IXNConnectionState.connecting:
                statusStr = "CONNECTING"
                break
            case IXNConnectionState.needsUpdate:
                statusStr = "NEEDS UPDATING"
                break
            case IXNConnectionState.unknown:
                statusStr = "UNKNOWN"
                break
            default:
                statusStr = "INVALID"
                break
        }
        
        return statusStr
    }
    
    func isMuseAvailable() -> Bool {
        switch (self.museConnStatus) {
            case .connected:
                return true
            case .connecting:
                return true
            case .needsUpdate:
                return true
            
            default:
                return false
        }
    }
    
    func avgHorseshoeValue() -> Double {
        if self.horseshoeScoreValues.count == 0 {
            return MuseListener.WORST_HORSESHOE_SCORE
        }
        return self.horseshoeScoreValues.reduce(0, +) / Double(self.horseshoeScoreValues.count)
    }
    
    class func getConnectionStatusColour(_ state: IXNConnectionState) -> UIColor {
        switch (state) {
            case IXNConnectionState.disconnected:
                return UIColor.red
            case IXNConnectionState.connected:
                return UIColor.green
            case IXNConnectionState.connecting:
                return UIColor.yellow
            case IXNConnectionState.needsUpdate:
                return UIColor.lightGray
            case IXNConnectionState.unknown:
                return UIColor.magenta
            default:
                return UIColor.magenta
        }
    }
    
    class func getSignalStrengthString(_ horseshoeValue: Double) -> String {
        if horseshoeValue <=  4 {
            return "EXCELLENT"
        }
        else if horseshoeValue <= 6 {
            return "GOOD"
        }
        else if horseshoeValue <= 8 {
            return "OK"
        }
        else {
            return "POOR"
        }
    }
    class func getSignalDetailString(_ horseshoeValue: Double) -> String {
        if horseshoeValue <= MuseListener.MAX_HORSESHOE_SCORE_TO_FIRE {
            return "SENDING FIRE DATA"
        }
        else {
            return "NOT SENDING FIRE DATA"
        }
    }
    
    class func getSignalStrengthColour(_ horseshoeValue: Double) -> UIColor {
        
        if horseshoeValue <= MuseListener.MAX_HORSESHOE_SCORE_TO_FIRE {
            return UIColor.green
        }
        return UIColor.red
    }
    
    fileprivate func museBrainToFireCalc() {
        if !self.okToFire() {
            return
        }
        
        // Calculate all the current averages...
        var avgScoreValues = [IXNMuseDataPacketType: Double]()
        for (packetType, valueArray) in self.cachedScoreValues {
            avgScoreValues.updateValue(valueArray.reduce(0, +) / Double(valueArray.count), forKey: packetType)
        }
        
        if let settings = PyrokinesisSettings.getSettings() {
            
            if let gameMode = PyrokinesisSettings.GameMode(rawValue: settings.gameMode) {
            
                switch (gameMode) {
                    case .Calm:
                        self.calmModeCalc(avgScoreValues)
                        break
                    
                    case .Concentration:
                        self.concentrationModeCalc(avgScoreValues)
                        break
                    
                    default:
                        return
                }
            }
        }
    }
    
    fileprivate func calmModeCalc(_ avgScoreValues: [IXNMuseDataPacketType: Double]) {
        if avgScoreValues[IXNMuseDataPacketType.alphaScore] == nil || avgScoreValues[IXNMuseDataPacketType.mellow] == nil {
            return
        }
        
        // Alpha and Mellow are the key values being examined here, make sure they have a high enough
        // value over time in order to shoot fire...
        let avgAlpha = avgScoreValues[IXNMuseDataPacketType.alphaScore]!
        let avgMellow = avgScoreValues[IXNMuseDataPacketType.mellow]!
        
        let MIN_ACCEPTED_ALPHA: Double = 0.5
        let MIN_ACCEPTED_MELLOW: Double = 0.6
        
        if avgAlpha >= MIN_ACCEPTED_ALPHA && avgMellow >= MIN_ACCEPTED_MELLOW {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let animMgr = appDelegate.fireAnimatorManager!
            
            // Check the latest animation time in the animation manager, if there's a
            // animation running that won't be finished for some time then we shouldn't
            // append more animations
            var animTimeLeft = 0.0
            if let latestAnim = animMgr.getLatestAnimator() {
                animTimeLeft = latestAnim.timeUntilFinished()
            }
            if animTimeLeft <= MuseListener.MAX_TIME_BETWEEN_QUEUED_ANIMS {
                
                // Speed up the animation based on how good the brainwave values are...
                let MIN_BURST_TIME_S: Double = 0.5
                let MAX_BURST_TIME_S: Double = 1.2
                
                let MAX_SUM_CLAMP = 1.8
                
                var total = min(0.3*avgAlpha + 0.7*avgMellow, MAX_SUM_CLAMP)
                var burstTimeInSecs: Double = MathHelper.lerp(total, x0: MIN_ACCEPTED_ALPHA + MIN_ACCEPTED_MELLOW, x1: MAX_SUM_CLAMP, y0: MIN_BURST_TIME_S, y1: MAX_BURST_TIME_S)
                
                // Create the "calm" fire routine
                let animators = FireAnimatorManager.buildInnerOuterFireAnimators(animTimeLeft + burstTimeInSecs, burstTimeInSecs: burstTimeInSecs)
                animMgr.addAnimators(animators)
            }
        }
    }
    fileprivate func concentrationModeCalc(_ avgScoreValues: [IXNMuseDataPacketType: Double]) {
        if avgScoreValues[IXNMuseDataPacketType.betaScore] == nil || avgScoreValues[IXNMuseDataPacketType.concentration] == nil {
            return
        }
        
        // Beta and Concentration are the key values being examined here, make sure they have a high enough
        // value over time in order to shoot fire...
        let avgBeta = avgScoreValues[IXNMuseDataPacketType.betaScore]!
        let avgConcentration = avgScoreValues[IXNMuseDataPacketType.concentration]!
        
        let MIN_ACCEPTED_BETA: Double = 0.4
        let MIN_ACCEPTED_CONCENTATION: Double = 0.6
        
        if avgBeta >= MIN_ACCEPTED_BETA && avgConcentration >= MIN_ACCEPTED_CONCENTATION {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let animMgr = appDelegate.fireAnimatorManager!
            
            // Check the latest animation time in the animation manager, if there's a
            // animation running that won't be finished for some time then we shouldn't
            // append more animations
            var animTimeLeft = 0.0
            if let latestAnim = animMgr.getLatestAnimator() {
                animTimeLeft = latestAnim.timeUntilFinished()
            }
            if animTimeLeft <= MuseListener.MAX_TIME_BETWEEN_QUEUED_ANIMS {
                
                // Speed up the animation based on how good the brainwave values are...
                let MIN_BURST_TIME_S = 0.2
                let MAX_BURST_TIME_S = 1.0
                
                let MAX_SUM_CLAMP = 1.75
                
                var total = min(0.3*avgBeta + 0.7*avgConcentration, MAX_SUM_CLAMP)
                var burstTimeInSecs: Double = MathHelper.lerp(total, x0: MIN_ACCEPTED_BETA + MIN_ACCEPTED_CONCENTATION, x1: MAX_SUM_CLAMP, y0: MIN_BURST_TIME_S, y1: MAX_BURST_TIME_S)
                
                let animators = FireAnimatorManager.buildPinwheelFireAnimators(animTimeLeft + burstTimeInSecs, burstTimeInSecs: burstTimeInSecs, clockwise: true, numPinwheels: 1)
                animMgr.addAnimators(animators)
            }
        }
    }
    
    fileprivate func museBlinkToFireCalc() {
        if !self.okToFire() {
            return
        }
        
        // ... blinks are just too common...
    }
    fileprivate func museJawClenchToFireCalc() {
        if !self.okToFire() {
            return
        }
        
        // Make sure jaw clenching is enabled...
        if let settings = PyrokinesisSettings.getSettings() {
            if !settings.jawClenchingEnabled {
                return
            }
        }
        
        // Make sure we don't spam this...
        let currTime = Date()
        
        if (currTime.timeIntervalSinceReferenceDate - self.lastJawClenchFireTime.timeIntervalSinceReferenceDate) < MuseListener.MIN_TIME_BETWEEN_JAW_CLENCH_FLAMES {
            self.lastJawClenchFireTime = currTime
            return
        }
        
        // ALL OF THE FIRE!
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let animations = FireAnimatorManager.buildEruptionFireAnimators(0.0, burstTimeInSecs: MuseListener.MIN_TIME_BETWEEN_JAW_CLENCH_FLAMES-0.1)
        appDelegate.fireAnimatorManager?.addAnimators(animations)
        
        self.lastJawClenchFireTime = currTime
    }
    
    fileprivate func okToFire() -> Bool {
        if let lastHorseshoeScore = self.horseshoeScoreValues.last {
            let avgHorseshoeScore = self.avgHorseshoeValue()
            return self.museConnStatus == IXNConnectionState.connected && avgHorseshoeScore <= MuseListener.MAX_HORSESHOE_SCORE_TO_FIRE
        }
        else {
            return false
        }
    }
}

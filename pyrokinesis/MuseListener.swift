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

    static let MAX_CACHED_VALUES : Int = 100
    static let MAX_HORSESHOE_CACHED_VALUES: Int = 20
    static let MAX_HORSESHOE_SCORE_TO_FIRE : Double = 6
    static let WORST_HORSESHOE_SCORE : Double = 16
    
    var cachedScoreValues = [IXNMuseDataPacketType: [Double]]()
    var horseshoeScoreValues = [Double]() // 4 - best, 16 - worst

    var museConnStatus:IXNConnectionState = IXNConnectionState.Disconnected
    var dataUpdated: Bool = false
    
    private var sawOneBlink: Bool = false
    private var lastBlink: Bool = false
    private var sawOneJawClench: Bool = false
    private var lastJawClench: Bool = false
    private var lastJawClenchFireTime: NSDate = NSDate()
    
    @objc func receiveMuseDataPacket(packet: IXNMuseDataPacket) {
        var cacheScore = false
        
        switch (packet.packetType) {
        
            // "Score" values - used to determine how intense and what types of fire are happening
            case IXNMuseDataPacketType.AlphaScore:
                cacheScore = true
                break
            case IXNMuseDataPacketType.BetaScore:
                cacheScore = true
                break
            case IXNMuseDataPacketType.DeltaScore:
                cacheScore = true
                break
            case IXNMuseDataPacketType.ThetaScore:
                cacheScore = true
                break
            case IXNMuseDataPacketType.GammaScore:
                cacheScore = true
                break
            case IXNMuseDataPacketType.Mellow:
                cacheScore = true
                break
            case IXNMuseDataPacketType.Concentration:
                cacheScore = true
                break

            // "Other" values - for general information and misc. stuffs
            case IXNMuseDataPacketType.Accelerometer:
                break
            case IXNMuseDataPacketType.Battery:
                break
            case IXNMuseDataPacketType.Horseshoe:
                var count: Double = 0
                for val in packet.values {
                    if let dblVal = val as? Double {
                        count += dblVal
                    }
                }
                
                if self.horseshoeScoreValues.count >= MuseListener.MAX_HORSESHOE_CACHED_VALUES {
                    self.horseshoeScoreValues.removeAtIndex(0)
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
            for val in values {
                if let dblVal = val as? Double {
                    avgValue += dblVal
                    count++
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
                        self.cachedScoreValues[packet.packetType]!.removeAtIndex(0)
                    }
                    self.cachedScoreValues[packet.packetType]!.append(avgValue)
                }
                else {
                    self.cachedScoreValues[packet.packetType] = [avgValue]
                    self.cachedScoreValues[packet.packetType]!.reserveCapacity(MuseListener.MAX_CACHED_VALUES)
                }
            }
        }
        
    }
    
    @objc func receiveMuseArtifactPacket(packet: IXNMuseArtifactPacket) {
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
    
    @objc func receiveMuseConnectionPacket(packet: IXNMuseConnectionPacket) {
        self.museConnStatus = packet.currentConnectionState
        
        switch (packet.currentConnectionState) {
            
            case IXNConnectionState.Disconnected:
                // Try to reconnect by posting to the main thread...
                var appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                 NSTimer.scheduledTimerWithTimeInterval(0.0, target: appDelegate, selector: Selector("reconnectMuse"), userInfo: nil, repeats: false)
                break
            
            case IXNConnectionState.Connected:
                break
            case IXNConnectionState.Connecting:
                break
            
            case IXNConnectionState.NeedsUpdate:
                break
            case IXNConnectionState.Unknown:
                break
            
            default:
                break
        }
        
        NSLog("Muse is now \(MuseListener.getConnectionStatusString(self.museConnStatus))")
    }
    
    class func getConnectionStatusString(state: IXNConnectionState) -> String {
        var statusStr: String = ""

        switch (state) {
            case IXNConnectionState.Disconnected:
                statusStr = "Disconnected"
                break
            case IXNConnectionState.Connected:
                statusStr = "Connected"
                break
            case IXNConnectionState.Connecting:
                statusStr = "Connecting"
                break
            case IXNConnectionState.NeedsUpdate:
                statusStr = "Needs Updating"
                break
            case IXNConnectionState.Unknown:
                statusStr = "Unknown"
                break
            default:
                statusStr = "Invalid"
                break
        }
        
        return statusStr
    }
    
    func avgHorseshoeValue() -> Double {
        if self.horseshoeScoreValues.count == 0 {
            return MuseListener.WORST_HORSESHOE_SCORE
        }
        return self.horseshoeScoreValues.reduce(0, combine: +) / Double(self.horseshoeScoreValues.count)
    }
    
    class func getConnectionStatusColour(state: IXNConnectionState) -> UIColor {
        switch (state) {
            case IXNConnectionState.Disconnected:
                return UIColor.redColor()
            case IXNConnectionState.Connected:
                return UIColor.greenColor()
            case IXNConnectionState.Connecting:
                return UIColor.yellowColor()
            case IXNConnectionState.NeedsUpdate:
                return UIColor.lightGrayColor()
            case IXNConnectionState.Unknown:
                return UIColor.magentaColor()
            default:
                return UIColor.magentaColor()
        }
    }
    
    class func getSignalStrengthString(horseshoeValue: Double) -> String {
        if horseshoeValue <=  4 {
            return "Excellent (Sending Fire Data)"
        }
        else if horseshoeValue <= 6 {
            return "Good (Sending Fire Data)"
        }
        else if horseshoeValue <= 8 {
            return "OK (Not Sending Fire Data)"
        }
        else {
            return "Poor (Not Sending Fire Data)"
        }
    }
    
    class func getSignalStrengthColour(horseshoeValue: Double) -> UIColor {
        
        if horseshoeValue <= MuseListener.MAX_HORSESHOE_SCORE_TO_FIRE {
            return UIColor.greenColor()
        }
        return UIColor.redColor()
    }
    
    private func museBrainToFireCalc() {
        if !self.okToFire() {
            return
        }
        
        
        
        // Calculate all the current averages...
        var avgScoreValues = [IXNMuseDataPacketType: Double]()
        for (packetType, valueArray) in self.cachedScoreValues {
            avgScoreValues.updateValue(valueArray.reduce(0, combine: +) / Double(valueArray.count), forKey: packetType)
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
        
        
        // Certain combinations of scores will create different kinds of effects...
        // TODO
        
        
        //
    }
    
    private func calmModeCalc(avgScoreValues: [IXNMuseDataPacketType: Double]) {
        // Alpha and Mellow are the key values being examined here, make sure they have a high enough
        // value over time in order to shoot fire...
        
        let avgAlpha = avgScoreValues[IXNMuseDataPacketType.AlphaScore]
        let avgMellow = avgScoreValues[IXNMuseDataPacketType.Mellow]
        
        if avgAlpha > 0.7 && avgMellow > 0.9 {
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            let animMgr = appDelegate.fireAnimatorManager
            
            // Check the latest animation time in the animation manager, if there's a
            // animation running that won't be finished for some time then we shouldn't
            // append more animations
            let latestAnim = animMgr.getLatestAnimator()
            if latestAnim.animationTime <= 3.0 {
                
                // Create the "calm" fire routine
                FireAnimatorManager.buildCalmFireAnimators(latestAnim.animationTime + 0.5)
                
                
            }
            
        }
    }
    private func concentrationModeCalc(avgScoreValues: [IXNMuseDataPacketType: Double]) {
        
    }
    
    private func museBlinkToFireCalc() {
        if !self.okToFire() {
            return
        }
        
    }
    private func museJawClenchToFireCalc() {
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
        let currTime = NSDate()
        
        if self.lastJawClenchFireTime.timeIntervalSinceDate(currTime) < PyrokinesisSettings.FLAME_EFFECT_RESEND_TIME_S {
            self.lastJawClenchFireTime = currTime
            return
        }
        
        // ALL OF THE FIRE!
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        var fireIndices = [Int]()
        for (var i = 0; i < PyrokinesisSettings.NUM_FLAME_EFFECTS; i++) {
            fireIndices.append(i)
        }
        appDelegate.sendMultiFireControlData(fireIndices)
        
        self.lastJawClenchFireTime = currTime
    }
    
    private func okToFire() -> Bool {
        if let lastHorseshoeScore = self.horseshoeScoreValues.last {
            let avgHorseshoeScore = self.avgHorseshoeValue()
            return self.museConnStatus == IXNConnectionState.Connected && avgHorseshoeScore <= MuseListener.MAX_HORSESHOE_SCORE_TO_FIRE
        }
        else {
            return false
        }
    }
}

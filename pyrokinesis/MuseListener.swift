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

    let MAX_CACHED_VALUES : Int = 100
    var cachedScoreValues : [IXNMuseDataPacketType: [Double]] = [IXNMuseDataPacketType: [Double]]()
    
    init() {
    }
    
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
                break
                
            default:
                break
        }
        
        if cacheScore {
            let values = packet.values
            //NSLog(values.debugDescription)
            
            if let value = packet.values.first as? Double {
                if var valueArray = self.cachedScoreValues[packet.packetType] {
                    if valueArray.count >= MAX_CACHED_VALUES {
                        valueArray.removeAtIndex(0)
                    }
                    valueArray.append(value)
                }
                else {
                    self.cachedScoreValues[packet.packetType] = [value]
                    self.cachedScoreValues[packet.packetType]?.reserveCapacity(MAX_CACHED_VALUES)
                }
            }
        }
        
    }
    
    @objc func receiveMuseArtifactPacket(packet: IXNMuseArtifactPacket) {
        if !packet.headbandOn {
            return;
        }
        
        if packet.blink {
            
        }
        if packet.jawClench {
            
        }
    }
    
    @objc func receiveMuseConnectionPacket(packet: IXNMuseConnectionPacket) {
        
        switch (packet.currentConnectionState) {
            
            case IXNConnectionState.Disconnected:
                // Try to reconnect by posting to the main thread...
                AppDelegate.performSelector(Selector("reconnectToMuse"), withObject:nil, afterDelay:0)
                break
            
            case IXNConnectionState.Connected:
                break
            case IXNConnectionState.Connecting:
                break
            case IXNConnectionState.Connected:
                break
            case IXNConnectionState.NeedsUpdate:
                break
            case IXNConnectionState.Unknown:
                break
            default:
                break
        }
    }
}

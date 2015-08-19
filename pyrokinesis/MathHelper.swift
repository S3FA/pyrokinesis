//
//  MathHelper.swift
//  pyrokinesis
//
//  Created by Callum Hay on 2015-08-16.
//  Copyright (c) 2015 s3fa. All rights reserved.
//

import Foundation

class MathHelper {
    
    class func clamp(x: Double, xMin: Double, xMax: Double) -> Double {
        return max(xMin, min(xMax, x) as Double) as Double
    }
    
    // Calculate the linear interpolation
    class func lerp(x: Double, x0: Double, x1: Double, y0: Double, y1: Double) -> Double {
        return y0 + (y1-y0) * (MathHelper.clamp(x, xMin: x0, xMax: x1) - x0) / (x1 - x0)
    }
    
    class func randomDouble(minVal: Double, maxVal: Double) -> Double {
        return minVal + MathHelper.randomZeroToOneIncl() * (maxVal - minVal)
    }
    class func randomZeroToOneIncl() -> Double {
        return Double(arc4random() % UINT32_MAX) / Double(UINT32_MAX-1)
    }
    
    class func randomUInt(minVal: UInt, maxVal: UInt) -> UInt {
        return UInt(randomUInt32(UInt32(minVal), maxVal: UInt32(maxVal)))
    }
    class func randomUInt32(minVal: UInt32, maxVal: UInt32) -> UInt32 {
        return minVal + arc4random() % (maxVal - minVal + 1)
    }
    class func randomBool() -> Bool {
        return arc4random() % 2 == 0
    }
}
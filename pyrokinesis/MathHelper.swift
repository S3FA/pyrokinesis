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
    
}
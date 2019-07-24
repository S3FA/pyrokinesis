//
//  UISettings.swift
//  pyrokinesis
//
//  Created by Callum Hay on 2015-08-16.
//  Copyright (c) 2015 s3fa. All rights reserved.
//

import Foundation
import UIKit

class UISettings {
    
    static let DARK_RED_COLOR = UIColor(red: 158.0/255.0, green: 27.0/255.0, blue: 30.0/255.0, alpha: 1.0)
    
    class func buildTabBarInsets() -> UIEdgeInsets {
        return UIEdgeInsets.init(top:6, left:0, bottom:-6, right:0);
    }
}

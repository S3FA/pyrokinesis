//
//  PyrokinesisTabBarController.swift
//  pyrokinesis
//
//  Created by Callum Hay on 2015-08-16.
//  Copyright (c) 2015 s3fa. All rights reserved.
//

import Foundation
import UIKit

class PyrokinesisTabBarController: UITabBarController {
    
    static let TAB_BAR_HEIGHT: CGFloat = 152
    static let HALF_TAB_BAR_HEIGHT: CGFloat = TAB_BAR_HEIGHT / 2
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let selectedItemColour = UISettings.DARK_RED_COLOR
        let bgColour = UIColor(white: 24.0/255.0, alpha: 1.0)
        
        self.tabBar.tintColor = selectedItemColour
        
        if let items = self.tabBar.items {
            
            for item in items {
                if let tabBarItem = item as? UITabBarItem {
                    tabBarItem.title = nil
                    tabBarItem.imageInsets = UISettings.buildTabBarInsets()
                }
            }
            
            assert(items.count == 3)
            
            var item0 = items[0] as! UITabBarItem
            item0.image = UIImage(named: "graphInactive")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
            item0.selectedImage = UIImage(named: "graphActive")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
            
            var item1 = items[1] as! UITabBarItem
            item1.image = UIImage(named: "controlInactive")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
            item1.selectedImage = UIImage(named: "controlActive")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
            
            var item2 = items[2] as! UITabBarItem
            item2.image = UIImage(named: "settingsInactive")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
            item2.selectedImage = UIImage(named: "settingsActive")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
        }
    }
    
    
    
    override func viewWillLayoutSubviews() {
        var tabFrame = self.tabBar.frame;
        tabFrame.size.height = PyrokinesisTabBarController.HALF_TAB_BAR_HEIGHT;
        tabFrame.origin.y = self.view.frame.size.height - PyrokinesisTabBarController.HALF_TAB_BAR_HEIGHT;
        self.tabBar.frame = tabFrame;
    }
    
}
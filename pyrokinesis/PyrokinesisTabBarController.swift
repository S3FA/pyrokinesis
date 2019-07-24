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
            
            assert(items.count == 2)
            
            let item1 = items[0]
            item1.image = UIImage(named: "controlInactive")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
            item1.selectedImage = UIImage(named: "controlActive")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
            
            let item2 = items[1] 
            item2.image = UIImage(named: "settingsInactive")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
            item2.selectedImage = UIImage(named: "settingsActive")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        }
    }
    
    
    
    override func viewWillLayoutSubviews() {
        var tabFrame = self.tabBar.frame;
        tabFrame.size.height = PyrokinesisTabBarController.HALF_TAB_BAR_HEIGHT;
        tabFrame.origin.y = self.view.frame.size.height - PyrokinesisTabBarController.HALF_TAB_BAR_HEIGHT;
        self.tabBar.frame = tabFrame;
    }
    
}

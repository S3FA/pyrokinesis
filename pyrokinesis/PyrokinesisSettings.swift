//
//  PyrokinesisSettings.swift
//  pyrokinesis
//
//  Created by beowulf on 2015-07-19.
//  Copyright (c) 2015 s3fa. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class PyrokinesisSettings : NSManagedObject {
    
    @NSManaged var connectionEnabled: Bool
    @NSManaged var fireIPAddress: String
    @NSManaged var firePort: Int32
    
    static let FLAME_EFFECT_RESEND_TIME_S : NSTimeInterval = 1.0
    static let NUM_FLAME_EFFECTS: Int = 8
    
    static let DEFAULT_IP_ADDRESS: String = "192.168.43.212"
    static let DEFAULT_PORT_NUMBER: Int32 = 2000
    
    class func getSettings() -> PyrokinesisSettings? {
        
        let fetchRequest = NSFetchRequest(entityName: "PyrokinesisSettings")
        fetchRequest.fetchLimit = 1
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        if let managedObjectContext = appDelegate.managedObjectContext {
            
            var error: NSError?
            var fetchedEntities = managedObjectContext.executeFetchRequest(fetchRequest, error: &error) as! [PyrokinesisSettings]
            if error != nil || fetchedEntities.isEmpty {
                
                // Create a new GameData entity
                let newSettings = NSEntityDescription.insertNewObjectForEntityForName("PyrokinesisSettings", inManagedObjectContext: managedObjectContext) as! PyrokinesisSettings
                newSettings.resetToDefaults()
                
                fetchedEntities = [newSettings]
            }
            
            return fetchedEntities[0]
        }
        
        return nil
    }
    
    func save() {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.saveContext()
    }
    
    func resetToDefaults() {
        self.connectionEnabled = true
        self.fireIPAddress = PyrokinesisSettings.DEFAULT_IP_ADDRESS
        self.firePort = PyrokinesisSettings.DEFAULT_PORT_NUMBER
    }
    
}
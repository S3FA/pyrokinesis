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
        self.fireIPAddress = "192.168.43.212"
        self.firePort = 2000
    }
    
}
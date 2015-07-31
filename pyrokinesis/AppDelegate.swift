//
//  AppDelegate.swift
//  pyrokinesis
//
//  Created by Callum Hay on 2015-06-14.
//  Copyright (c) 2015 s3fa. All rights reserved.
//

import UIKit
import Foundation
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GCDAsyncUdpSocketDelegate {

    var window: UIWindow?
    
    var muse: IXNMuse? = nil
    var musePickerTimer: NSTimer? = nil
    var museListener: MuseListener? = nil
    var museManager: IXNMuseManager? = nil
    
    var udpSocket: GCDAsyncUdpSocket? = nil
    
    private var packetCount: Int = 0
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        objc_sync_enter(self.museManager)
        if self.museManager != nil {
            objc_sync_exit(self.museManager)
            return
        }
        self.museManager = IXNMuseManager.sharedManager()
        objc_sync_exit(self.museManager)

        if self.museListener == nil {
            self.museListener = MuseListener()
        }
        
        if self.muse == nil {
            // Intent: show a bluetooth picker, but only if there isn't already a
            // Muse connected to the device. Do this by delaying the picker by 1
            // second. If startWithMuse happens before the timer expires, cancel
            // the timer.
            self.musePickerTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("showMusePicker"), userInfo: nil, repeats: false)
        }
        
        self.museManager!.addObserver(self, forKeyPath: self.museManager!.connectedMusesKeyPath(), options:(NSKeyValueObservingOptions.New | NSKeyValueObservingOptions.Initial), context:nil)
        
        self.initUdp()
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        
        self.muse = nil;
    }
    
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        
        if keyPath == self.museManager?.connectedMusesKeyPath() {
            var connectedMuses = (change[NSKeyValueChangeNewKey] as! NSSet) as Set
            
            if connectedMuses.count > 0 {
                if let muse = connectedMuses.first as? IXNMuse {
                    self.startWithMuse(muse)
                }
            }
        }
    }
    
    func showMusePicker() {
        self.museManager?.showMusePickerWithCompletion({(error: NSError?) in
            if let e = error {
                NSLog("Error showing Muse picker: \(e)");
            }
        })
    }
    
    func startWithMuse(muse: IXNMuse) {
        objc_sync_enter(self.muse)
        if self.muse != nil {
            objc_sync_exit(self.muse)
            return
        }
        self.muse = muse;
        objc_sync_exit(self.muse)
        
        self.musePickerTimer?.invalidate()
        self.musePickerTimer = nil
        
        if let m = self.muse {
            m.registerDataListener(self.museListener, type: IXNMuseDataPacketType.Horseshoe)
            m.registerDataListener(self.museListener, type: IXNMuseDataPacketType.Battery)
            m.registerDataListener(self.museListener, type: IXNMuseDataPacketType.Artifacts)
            m.registerDataListener(self.museListener, type: IXNMuseDataPacketType.AlphaScore)
            m.registerDataListener(self.museListener, type: IXNMuseDataPacketType.BetaScore)
            m.registerDataListener(self.museListener, type: IXNMuseDataPacketType.DeltaScore)
            m.registerDataListener(self.museListener, type: IXNMuseDataPacketType.ThetaScore)
            m.registerDataListener(self.museListener, type: IXNMuseDataPacketType.GammaScore)
            m.registerDataListener(self.museListener, type: IXNMuseDataPacketType.Mellow)
            m.registerDataListener(self.museListener, type: IXNMuseDataPacketType.Concentration)
            //m.registerDataListener(self.museListener, type: IXNMuseDataPacketType.Accelerometer)
            m.registerConnectionListener(self.museListener)
            
            m.runAsynchronously()
        }
    }
    
    func reconnectMuse() {
        if let m = self.muse {
            m.runAsynchronously()
        }
    }
    
    func initUdp() {
        if let udp = self.udpSocket {
            return
        }
        
        self.udpSocket = GCDAsyncUdpSocket(delegate: self, delegateQueue: dispatch_get_main_queue())
    }
    
    func sendFireControlData(fireIdx: Int) {
        assert(fireIdx >= 0 && fireIdx <= 7, "Invalid fire emitter index.")
        
        if let udp = self.udpSocket {
            if let settings = PyrokinesisSettings.getSettings() {
                var data = ("F\(fireIdx)" as NSString).dataUsingEncoding(NSUTF8StringEncoding)
                udp.sendData(data, toHost: settings.fireIPAddress, port: UInt16(settings.firePort), withTimeout: -1, tag: self.packetCount)
                self.packetCount++
            }
        }
    }
    
    // GCDAsyncUdpSocket delegate methods
    func udpSocket(sock: GCDAsyncUdpSocket!, didConnectToAddress address: NSData!) {
        NSLog("Connected!")
    }
    func udpSocket(sock: GCDAsyncUdpSocket!, didNotConnect error: NSError!) {
        NSLog("Failed to connect!")
    }
    func udpSocket(sock: GCDAsyncUdpSocket!, didSendDataWithTag tag: CLong) {
        NSLog("Sent data!")
    }
    func udpSocket(sock: GCDAsyncUdpSocket!, didNotSendDataWithTag tag: CLong, dueToError error: NSError!) {
        NSLog("Failed to send data!")
    }
    func udpSocket(sock: GCDAsyncUdpSocket!, didReceiveData data: NSData!, fromAddress address: NSData!, withFilterContext filterContext: AnyObject!) {
        
        NSLog("Received data!")
        /*
        NSString *msg = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        if (msg)
        {
            [self logMessage:FORMAT(@"RECV: %@", msg)];
        }
        else
        {
            NSString *host = nil;
            uint16_t port = 0;
            [GCDAsyncUdpSocket getHost:&host port:&port fromAddress:address];
            
            [self logInfo:FORMAT(@"RECV: Unknown message from: %@:%hu", host, port)];
        }
        */
    }
    
    
    // Core Data stack
    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file.
        // This code uses a directory named "com.xxxx.ProjectName" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1] as! NSURL
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional.
        // It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("pyrokinesis", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("pyrokinesis.sqlite")
        var error: NSError? = nil
        var failureReason = "There was an error creating or loading the application's saved data."
        var options : [NSObject : AnyObject] = [ NSMigratePersistentStoresAutomaticallyOption : true, NSInferMappingModelAutomaticallyOption : true ]
        if coordinator!.addPersistentStoreWithType (NSSQLiteStoreType, configuration: nil, URL: url, options: options, error: &error) == nil {
            
            coordinator = nil
            // Report any error we got
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            dict[NSUnderlyingErrorKey] = error
            error = NSError(domain: "PYROKINESIS_ERROR", code: 9999, userInfo: dict)
            NSLog("Unresolved error \(error), \(error!.userInfo)")
        }
        
        return coordinator
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext? = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        if coordinator == nil {
            return nil
        }
        var managedObjectContext = NSManagedObjectContext()
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    
    // Core Data Saving support
    func saveContext () {
        if let moc = self.managedObjectContext {
            var error: NSError? = nil
            if moc.hasChanges && !moc.save(&error) {
                NSLog("Unresolved error \(error), \(error!.userInfo)")
            }
        }
    }
    
}


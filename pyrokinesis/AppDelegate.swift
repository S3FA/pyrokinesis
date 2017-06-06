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
    var overviewViewController: OverviewViewController? = nil
    
    
    var muse: IXNMuse? = nil
    var musePickerTimer: Timer? = nil
    var museListener: MuseListener? = nil
    var museManager: IXNMuseManager? = nil
    
    var udpSocket: GCDAsyncUdpSocket? = nil
    
    var fireAnimatorManager: FireAnimatorManager? = nil
    var fireSimulator: FireSimulator = FireSimulator()
    
    fileprivate var packetCount: Int = 0
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        //UINavigationBar.appearance().translucent = false
        //UINavigationBar.appearance().barTintColor = UIColor(red: 24.0/255.0, green: 24.0/255.0, blue: 24.0/255.0, alpha: 1.0)
        //UINavigationBar.appearance().titleTextAttributes?.updateValue(UIFont(name: "Gotham-Bold", size: 22)!, forKey: NSFontAttributeName)

        UITableViewHeaderFooterView.appearance().tintColor = UIColor.white
        UIApplication.shared.setStatusBarStyle(UIStatusBarStyle.lightContent, animated: true)
        
        self.fireAnimatorManager = FireAnimatorManager()
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; 
        // here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. 
        // If the application was previously in the background, optionally refresh the user interface.
        
        objc_sync_enter(self.museManager)
        if self.museManager != nil {
            objc_sync_exit(self.museManager)
            return
        }
        self.museManager = IXNMuseManager.shared()
        objc_sync_exit(self.museManager)

        if self.museListener == nil {
            self.museListener = MuseListener()
        }
        
        if self.muse == nil {
            // Intent: show a bluetooth picker, but only if there isn't already a
            // Muse connected to the device. Do this by delaying the picker by 1
            // second. If startWithMuse happens before the timer expires, cancel the timer.
            self.musePickerTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(AppDelegate.showMusePicker), userInfo: nil, repeats: false)
        }
        
        self.museManager!.addObserver(self, forKeyPath: self.museManager!.connectedMusesKeyPath(), options:[.new, .initial], context:nil)
        
        self.initUdp()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        
        self.muse = nil;
    }
    
    func observeValue(forKeyPath keyPath: String, of object: AnyObject, change: [AnyHashable: Any], context: UnsafeMutableRawPointer) {
        
        if keyPath == self.museManager?.connectedMusesKeyPath() {
            let connectedMuses = (change[NSKeyValueChangeKey.newKey] as! NSSet) as Set
            
            if connectedMuses.count > 0 {
                if let muse = connectedMuses.first as? IXNMuse {
                    self.startWithMuse(muse)
                }
            }
        }
    }
    
    func showMusePicker() {
        if self.muse != nil {
            return
        }
        
        self.museManager?.showMusePicker(completion: {(error: NSError?) in
            if let e = error {
                NSLog("Error showing Muse picker: \(e)");
            }
        } as! EABluetoothAccessoryPickerCompletion)
    }
    
    func startWithMuse(_ muse: IXNMuse) {
        self.musePickerTimer?.invalidate()
        self.musePickerTimer = nil
        
        objc_sync_enter(self.muse)
        if self.muse != nil {
            objc_sync_exit(self.muse)
            return
        }
        self.muse = muse;
        objc_sync_exit(self.muse)
        
        if let m = self.muse {
            m.register(self.museListener, type: IXNMuseDataPacketType.horseshoe)
            m.register(self.museListener, type: IXNMuseDataPacketType.battery)
            m.register(self.museListener, type: IXNMuseDataPacketType.artifacts)
            
            m.register(self.museListener, type: IXNMuseDataPacketType.alphaScore)
            m.register(self.museListener, type: IXNMuseDataPacketType.betaScore)
            m.register(self.museListener, type: IXNMuseDataPacketType.deltaScore)
            m.register(self.museListener, type: IXNMuseDataPacketType.thetaScore)
            m.register(self.museListener, type: IXNMuseDataPacketType.gammaScore)
            m.register(self.museListener, type: IXNMuseDataPacketType.mellow)
            m.register(self.museListener, type: IXNMuseDataPacketType.concentration)
            
            //m.registerDataListener(self.museListener, type: IXNMuseDataPacketType.Accelerometer)
            m.register(self.museListener)
            
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
        
        self.udpSocket = GCDAsyncUdpSocket(delegate: self, delegateQueue: DispatchQueue.main)
    }
    
    func sendFireControlData(_ fireIdx: Int) {
        self.sendMultiFireControlData([fireIdx])
    }
    func sendMultiFireControlData(_ fireIndices: [Int]) {
        if let udp = self.udpSocket {
            if let settings = PyrokinesisSettings.getSettings() {

                var data = [UInt8]()
                
                for fireIdx in fireIndices {
                    assert(fireIdx >= 0 && fireIdx <= 7, "Invalid fire emitter index.")
                    data.append(0x01)
                    data.append(UInt8(48 + fireIdx))
                    
                    // Simulate the fire on this client...
                    self.fireSimulator.flameEffects[fireIdx].turnOn()
                }

                //NSLog("Sending data: \(data), to IP: \(settings.fireIPAddress), on port: \(settings.firePort)")
                
                udp.send(Data(bytes: UnsafePointer<UInt8>(data), count: data.count), toHost: settings.fireIPAddress, port: UInt16(settings.firePort), withTimeout: -1, tag: self.packetCount)
                self.packetCount += 1
            }
        }
    }
    
    // GCDAsyncUdpSocket delegate methods
    func udpSocket(_ sock: GCDAsyncUdpSocket!, didConnectToAddress address: Data!) {
        NSLog("Connected!")
    }
    func udpSocket(_ sock: GCDAsyncUdpSocket!, didNotConnect error: NSError!) {
        NSLog("Failed to connect!")
    }
    func udpSocket(_ sock: GCDAsyncUdpSocket!, didSendDataWithTag tag: CLong) {
        //NSLog("Sent data!")
    }
    func udpSocket(_ sock: GCDAsyncUdpSocket!, didNotSendDataWithTag tag: CLong, dueToError error: NSError!) {
        NSLog("Failed to send data!")
    }
    func udpSocket(_ sock: GCDAsyncUdpSocket!, didReceive data: Data!, fromAddress address: Data!, withFilterContext filterContext: AnyObject!) {
        
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
    lazy var applicationDocumentsDirectory: URL = {
        // The directory the application uses to store the Core Data store file.
        // This code uses a directory named "com.xxxx.ProjectName" in the application's documents Application Support directory.
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1] 
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional.
        // It is a fatal error for the application not to be able to find and load its model.
        let modelURL = Bundle.main.url(forResource: "pyrokinesis", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent("pyrokinesis.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        var options : [AnyHashable: Any] = [ NSMigratePersistentStoresAutomaticallyOption : true, NSInferMappingModelAutomaticallyOption : true ]
        do { try coordinator!.addPersistentStore (ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: options)}
        catch {
            coordinator = nil
            // Report any error we got
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject
            dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject
            dict[NSUnderlyingErrorKey] = error as AnyObject
            let error = NSError(domain: "PYROKINESIS_ERROR", code: 9999, userInfo: dict)
            NSLog("Unresolved error \(error)")
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
            if !moc.hasChanges { return; }
            do { try moc.save() }
            catch let error {
                NSLog("Unresolved error \(error), \(error._userInfo)")
            }
        }
    }
    
}


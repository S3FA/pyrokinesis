//
//  SettingsViewController.swift
//  pyrokinesis
//
//  Created by Callum Hay on 2015-06-19.
//  Copyright (c) 2015 s3fa. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController, UINavigationControllerDelegate {

    // Table View
    @IBOutlet var settingsTableView: UITableView!
    
    // Connection Settings
    @IBOutlet var connectionEnabledSwitch: UISwitch!
    @IBOutlet var ipAddressLabel: UILabel!
    @IBOutlet var portLabel: UILabel!
    
    // EEG Settings
    @IBOutlet var modeLabel: UILabel!
    @IBOutlet var jawClenchEnabledSwitch: UISwitch!
    
    required init(coder aDecoder: NSCoder!) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.delegate = self
        
        // Update with any previous settings data
        self.updateSettingsValues()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    
    @IBAction func onConnEnableSwitchChanged(sender: UISwitch) {
        if let settings = PyrokinesisSettings.getSettings() {
            settings.connectionEnabled = sender.on
            settings.save()
        }
    }
    
    @IBAction func onJawClenchEnableSwitchChanged(sender: UISwitch) {
        if let settings = PyrokinesisSettings.getSettings() {
            settings.jawClenchingEnabled = sender.on
            settings.save()
        }
    }
    
    // UITableViewController/Delegate Protocol
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return tableView.rowHeight
    }
    
    // UINavigationControllerDelegate Protocol
    func navigationController(navigationController: UINavigationController, didShowViewController viewController: UIViewController, animated: Bool) {
        
        if viewController == self {
            // Update the settings values...
            self.updateSettingsValues()
        }
    }
    
    
    // Private helper methods
    private func updateSettingsValues() {
        // Update with any previous settings data
        if let settings = PyrokinesisSettings.getSettings() {
            self.ipAddressLabel.text = settings.fireIPAddress
            self.portLabel.text = "\(settings.firePort)"
            self.connectionEnabledSwitch.setOn(settings.connectionEnabled, animated: false)
            
            self.modeLabel.text = "\(settings.gameMode)"
            self.jawClenchEnabledSwitch.setOn(settings.jawClenchingEnabled, animated: false)
        }
        else {
            var connSwitchOn = false
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            if let udpSocket = appDelegate.udpSocket {
                connSwitchOn = true
            }
            self.connectionEnabledSwitch.setOn(connSwitchOn, animated: false)
        }
    }
    
}

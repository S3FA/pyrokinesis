//
//  SettingsViewController.swift
//  pyrokinesis
//
//  Created by Callum Hay on 2015-06-19.
//  Copyright (c) 2015 s3fa. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController, SwitchCellDelegate {

    @IBOutlet var connectionEnabledSwitch: UISwitch!
    @IBOutlet var connectionEnabledCell: TableViewSwitchCell!
    
    @IBOutlet var ipAddressLabel: UILabel!
    @IBOutlet var portLabel: UILabel!
    
    
    required init(coder aDecoder: NSCoder!) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.connectionEnabledCell.delegate = self
        
        // Update with any previous settings data
        if let settings = PyrokinesisSettings.getSettings() {
            self.ipAddressLabel.text = settings.fireIPAddress
            self.portLabel.text = "\(settings.firePort)"
            self.connectionEnabledSwitch.setOn(settings.connectionEnabled, animated: false)
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // SwitchCellDelegate Protocol
    func onSwitchStateChange(sender: TableViewSwitchCell, isOn: Bool) {
        
        // Updating the settings will take care of the rest
        if let settings = PyrokinesisSettings.getSettings() {
            settings.connectionEnabled = isOn
            settings.save()
        }
    }
    

    
}

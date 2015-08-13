//
//  SettingsViewController.swift
//  pyrokinesis
//
//  Created by Callum Hay on 2015-06-19.
//  Copyright (c) 2015 s3fa. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController, UINavigationControllerDelegate, SwitchCellDelegate {


    // Table View
    @IBOutlet var settingsTableView: UITableView!
    
    // Connection Settings
    @IBOutlet var connectionEnabledSwitch: UISwitch!
    @IBOutlet var connectionEnabledCell: TableViewSwitchCell!
    @IBOutlet var ipAddressLabel: UILabel!
    @IBOutlet var portLabel: UILabel!
    
    // EEG Settings
    @IBOutlet var modeLabel: UILabel!
    
    
    required init(coder aDecoder: NSCoder!) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.connectionEnabledCell.delegate = self
        self.navigationController?.delegate = self
        
        // Update with any previous settings data
        self.updateSettingsValues()
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
    
    // UITableViewController/Delegate Protocol
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return tableView.rowHeight
    }
    
    /*
    // UIPickerViewDelegate Protocol
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        assert(pickerView == self.modePicker)
        assert(component == 0)
        
        // Update the settings
        if let settings = PyrokinesisSettings.getSettings() {
            
            var gameModeStr = PyrokinesisSettings.GameMode.allValues[row].rawValue
            if let gameModeEnum = PyrokinesisSettings.GameMode(rawValue: gameModeStr) {
                settings.gameMode = gameModeEnum.rawValue
                settings.save()
            }
            else {
                assert(false, "Invalid game mode found in picker.")
            }
        }
    }
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        assert(pickerView == self.modePicker)
        assert(component == 0)
        
        return PyrokinesisSettings.GameMode.allValues[row].rawValue
    }
    */
    
    
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

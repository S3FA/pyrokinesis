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
    
    // Cells
    @IBOutlet var ipAddressCell: UITableViewCell!
    @IBOutlet var portCell: UITableViewCell!
    @IBOutlet var gameModeCell: UITableViewCell!
    
    
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
        
        if let navCtrl = self.navigationController {
            navCtrl.delegate = self
        }
        
        // Custom images for the disclosure indicators
        self.ipAddressCell.accessoryView = UIImageView(image: UIImage(named: "disclosureIndicator"))
        self.portCell.accessoryView = UIImageView(image: UIImage(named: "disclosureIndicator"))
        self.gameModeCell.accessoryView = UIImageView(image: UIImage(named: "disclosureIndicator"))
        
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
    override func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let header = view as? UITableViewHeaderFooterView {
            header.textLabel.textColor = UIColor.whiteColor()
            //header.textLabel.font
        }
    }
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        cell.backgroundColor = UIColor(red: 23/255.0, green: 23/255.0, blue: 23/255.0, alpha: 1.0)
    }
    
    // UINavigationControllerDelegate Protocol
    func navigationController(navigationController: UINavigationController, didShowViewController viewController: UIViewController, animated: Bool) {
        
        if viewController == self {
            // Update the settings values...
            self.updateSettingsValues()
        }
    }
    
    
    class func setupNavButtons(target: AnyObject?, navigationItem: UINavigationItem) {
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "checkmark"), style: UIBarButtonItemStyle.Done, target: target, action: Selector("doneButtonPressed"))
        navigationItem.rightBarButtonItem?.tintColor = UISettings.DARK_RED_COLOR
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "cancelBack"), style: UIBarButtonItemStyle.Plain, target: target, action: Selector("cancelButtonPressed"))
        navigationItem.leftBarButtonItem?.tintColor = UISettings.DARK_RED_COLOR
    }
    
    // Private helper methods
    private func updateSettingsValues() {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
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
            if let udpSocket = appDelegate.udpSocket {
                connSwitchOn = true
            }
            self.connectionEnabledSwitch.setOn(connSwitchOn, animated: false)
        }
        
        // Update the overview controller as well...
        if let graphView = appDelegate.overviewViewController {
            graphView.updateSettings()
        }
        
    }
    
}

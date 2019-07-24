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
    
    required init?(coder aDecoder: NSCoder!) {
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
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    
    @IBAction func onConnEnableSwitchChanged(_ sender: UISwitch) {
        if let settings = PyrokinesisSettings.getSettings() {
            settings.connectionEnabled = sender.isOn
            settings.save()
        }
    }
    
    @IBAction func onJawClenchEnableSwitchChanged(_ sender: UISwitch) {
        if let settings = PyrokinesisSettings.getSettings() {
            settings.jawClenchingEnabled = sender.isOn
            settings.save()
        }
    }
    
    // UITableViewController/Delegate Protocol
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.rowHeight
    }
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let header = view as? UITableViewHeaderFooterView {
            header.textLabel?.textColor = UIColor.white
            //header.textLabel.font
        }
    }
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        cell.backgroundColor = UIColor(red: 23/255.0, green: 23/255.0, blue: 23/255.0, alpha: 1.0)
    }
    
    // UINavigationControllerDelegate Protocol
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        
        if viewController == self {
            // Update the settings values...
            self.updateSettingsValues()
        }
    }
    
    
    class func setupNavButtons(_ target: AnyObject?, navigationItem: UINavigationItem) {
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "checkmark"), style: UIBarButtonItem.Style.done, target: target, action: Selector("doneButtonPressed"))
        navigationItem.rightBarButtonItem?.tintColor = UISettings.DARK_RED_COLOR
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "cancelBack"), style: UIBarButtonItem.Style.plain, target: target, action: Selector("cancelButtonPressed"))
        navigationItem.leftBarButtonItem?.tintColor = UISettings.DARK_RED_COLOR
    }
    
    // Private helper methods
    fileprivate func updateSettingsValues() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
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
        
    }
    
}

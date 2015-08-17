//
//  PortNumberViewController.swift
//  pyrokinesis
//
//  Created by Callum Hay on 2015-06-19.
//  Copyright (c) 2015 s3fa. All rights reserved.
//

import Foundation
import UIKit

class PortNumberViewController : UIViewController {

    @IBOutlet var portNumberTextField: UITextField!

    required init(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        
        self.navigationItem.title = "PORT"
        SettingsViewController.setupNavButtons(self, navigationItem: self.navigationItem)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let settings = PyrokinesisSettings.getSettings() {
            self.portNumberTextField.text = "\(settings.firePort)"
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    func getPortNumber() -> Int32 {
        if let port = self.portNumberTextField.text.toInt() {
            return Int32(port)
        }
        
        return PyrokinesisSettings.DEFAULT_PORT_NUMBER
    }
    
    func doneButtonPressed() {
        // Update the settings
        if let settings = PyrokinesisSettings.getSettings() {
            settings.firePort = self.getPortNumber()
            settings.save()
        }
        
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func cancelButtonPressed() {
        self.navigationController?.popViewControllerAnimated(true)
    }
}

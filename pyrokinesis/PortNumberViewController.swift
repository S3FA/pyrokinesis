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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Port Number"
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Done, target: self, action: Selector("doneButtonPressed"))
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Cancel, target: self, action: Selector("cancelButtonPressed"))
        
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

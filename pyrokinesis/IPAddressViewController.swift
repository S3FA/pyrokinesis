//
//  IPAddressViewController.swift
//  pyrokinesis
//
//  Created by Callum Hay on 2015-06-19.
//  Copyright (c) 2015 s3fa. All rights reserved.
//

import Foundation
import UIKit

class IPAddressViewController : UIViewController, UITextFieldDelegate {
    
    @IBOutlet var ipField0: UITextField!
    @IBOutlet var ipField1: UITextField!
    @IBOutlet var ipField2: UITextField!
    @IBOutlet var ipField3: UITextField!
    
    required init(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        
        self.navigationItem.title = "IP ADDRESS"
        SettingsViewController.setupNavButtons(self, navigationItem: self.navigationItem)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.ipField0.delegate = self
        self.ipField1.delegate = self
        self.ipField2.delegate = self
        self.ipField3.delegate = self
        
        if let settings = PyrokinesisSettings.getSettings() {
            // Parse apart the ip address...
            let ipAddressArray = settings.fireIPAddress.componentsSeparatedByString(".")
            if ipAddressArray.count >= 4 {
                self.ipField0.text = ipAddressArray[0]
                self.ipField1.text = ipAddressArray[1]
                self.ipField2.text = ipAddressArray[2]
                self.ipField3.text = ipAddressArray[3]
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    // UITextFieldDelegate
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        if (range.length + range.location > count(textField.text)) {
            return false;
        }
        
        let newLength = count(textField.text) + count(string) - range.length
        return newLength <= 3
    }
    
    func getIPAddress() -> String {
        return self.ipField0.text + "." + self.ipField1.text + "." + self.ipField2.text + "." + self.ipField3.text
    }
    
    func doneButtonPressed() {
        // Update the settings
        if let settings = PyrokinesisSettings.getSettings() {
            settings.fireIPAddress = self.getIPAddress()
            settings.save()
        }
        
        self.navigationController?.popViewControllerAnimated(true)
    }
    func cancelButtonPressed() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
}
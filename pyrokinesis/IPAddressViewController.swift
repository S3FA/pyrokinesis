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
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        
        self.navigationItem.title = "IP ADDRESS"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        SettingsViewController.setupNavButtons(self, navigationItem: self.navigationItem)
        
        self.ipField0.delegate = self
        self.ipField1.delegate = self
        self.ipField2.delegate = self
        self.ipField3.delegate = self
        
        if let settings = PyrokinesisSettings.getSettings() {
            // Parse apart the ip address...
            let ipAddressArray = settings.fireIPAddress.components(separatedBy: ".")
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
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    // UITextFieldDelegate
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if (range.length + range.location > (textField.text?.count)!) {
            return false;
        }
        
        let newLength = (textField.text?.count)! + string.count - range.length
        return newLength <= 3
    }
    
    func getIPAddress() -> String {
        return String(format: "%@.%@.%@.%@", ipField0.text!, ipField1.text!, ipField2.text!, ipField3.text!)
    }
    
    func doneButtonPressed() {
        // Update the settings
        if let settings = PyrokinesisSettings.getSettings() {
            settings.fireIPAddress = self.getIPAddress()
            settings.save()
        }
        
        self.navigationController?.popViewController(animated: true)
    }
    func cancelButtonPressed() {
        self.navigationController?.popViewController(animated: true)
    }
    
}

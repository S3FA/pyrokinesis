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

    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        
        self.navigationItem.title = "PORT"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        SettingsViewController.setupNavButtons(self, navigationItem: self.navigationItem)
        
        if let settings = PyrokinesisSettings.getSettings() {
            self.portNumberTextField.text = "\(settings.firePort)"
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    func getPortNumber() -> Int32 {
        if let portString = self.portNumberTextField.text, let port = Int(portString) {
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
        
        self.navigationController?.popViewController(animated: true)
    }
    
    func cancelButtonPressed() {
        self.navigationController?.popViewController(animated: true)
    }
}

//
//  IPAddressViewController.swift
//  pyrokinesis
//
//  Created by beowulf on 2015-06-19.
//  Copyright (c) 2015 s3fa. All rights reserved.
//

import Foundation
import UIKit

class IPAddressViewController : UIViewController, UITextFieldDelegate {
    
    @IBOutlet var ipField0: UITextField!
    @IBOutlet var ipField1: UITextField!
    @IBOutlet var ipField2: UITextField!
    @IBOutlet var ipField3: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ipField0.delegate = self
        ipField1.delegate = self
        ipField2.delegate = self
        ipField3.delegate = self 
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // UITextFieldDelegate
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        if (range.length + range.location > count(textField.text)) {
            return false;
        }
        
        let newLength = count(textField.text) + count(string) - range.length
        return newLength <= 3
    }
    
    
    
}
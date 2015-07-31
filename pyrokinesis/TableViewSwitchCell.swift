//
//  TableViewCellSwitch.swift
//  pyrokinesis
//
//  Created by Callum Hay on 2015-06-19.
//  Copyright (c) 2015 s3fa. All rights reserved.
//

import UIKit

protocol SwitchCellDelegate : class {
    func onSwitchStateChange(sender: TableViewSwitchCell, isOn: Bool)
}

class TableViewSwitchCell: UITableViewCell {
    
    // MARK: Properties
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var enableSwitch: UISwitch!
    
    var delegate: SwitchCellDelegate?
    
    @IBAction func onSwitchChange(sender: UISwitch) {
        self.delegate?.onSwitchStateChange(self, isOn: self.enableSwitch.on)
    }
}

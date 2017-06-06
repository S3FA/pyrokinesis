//
//  GameModeViewController.swift
//  pyrokinesis
//
//  Created by Callum Hay on 2015-08-13.
//  Copyright (c) 2015 s3fa. All rights reserved.
//

import Foundation

class GameModeViewController : UITableViewController {
    
    @IBOutlet var gameModeTableView: UITableView!
    
    static let CELL_BG_COLOUR = UIColor(red: 23/255.0, green: 23/255.0, blue: 23/255.0, alpha: 1.0)
    fileprivate var lastSelectedIndexPath: IndexPath? = nil
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.navigationItem.title = "GAME MODE"
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        SettingsViewController.setupNavButtons(self, navigationItem: self.navigationItem)
        
        var selectedIndex = IndexPath(row: 0, section: 0)
        if let settings = PyrokinesisSettings.getSettings() {

            // Find the index of the given game mode...
            var gameModeIdx = 0
            for mode in PyrokinesisSettings.GameMode.allValues {
                
                let modeStr = mode.rawValue as String
                
                if modeStr == settings.gameMode {
                    break
                }
                gameModeIdx += 1
            }
            
            if gameModeIdx < PyrokinesisSettings.GameMode.allValues.count {
                selectedIndex = IndexPath(row: gameModeIdx, section: 0)
            }
        }
       
        // Make sure SOMETHING is selected...
        self.tableView(self.gameModeTableView, didSelectRowAt: selectedIndex)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return PyrokinesisSettings.GameMode.allValues.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let gameMode = PyrokinesisSettings.GameMode.allValues[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ModeOptionCell", for: indexPath) 
        cell.textLabel?.text = PyrokinesisSettings.GameMode.allValues[indexPath.row].rawValue
        cell.accessoryType = (self.lastSelectedIndexPath?.row == indexPath.row) ? .checkmark : .none
        if (cell.accessoryType == .checkmark) {
            cell.accessoryView = UIImageView(image: UIImage(named: "checkmark"))
            cell.accessoryView?.backgroundColor = GameModeViewController.CELL_BG_COLOUR
        }
        else {
            cell.accessoryView = nil
        }
        
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.row != self.lastSelectedIndexPath?.row {
            if let lastIdxPath = lastSelectedIndexPath {
                let oldCell = tableView.cellForRow(at: lastIdxPath)
                oldCell?.accessoryType = .none
                oldCell?.accessoryView = nil
            }
            
            let newCell = tableView.cellForRow(at: indexPath)
            newCell?.accessoryType = .checkmark
            newCell?.accessoryView = UIImageView(image: UIImage(named: "checkmark"))
            newCell?.accessoryView?.backgroundColor = GameModeViewController.CELL_BG_COLOUR
            
            self.lastSelectedIndexPath = indexPath
        }
    }
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let header = view as? UITableViewHeaderFooterView {
            header.textLabel?.textColor = UIColor.white
        }
    }
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        cell.backgroundColor = GameModeViewController.CELL_BG_COLOUR
    }
    
    func getGameModeString() -> String {
        if let selectedIdxPath = self.lastSelectedIndexPath {
            if let cell = self.gameModeTableView.cellForRow(at: selectedIdxPath) {
                if let label = cell.textLabel {
                    if let text = label.text {
                        return text
                    }
                }
            }
        }
        
        if let settings = PyrokinesisSettings.getSettings() {
            return settings.gameMode
        }
        
        return PyrokinesisSettings.GameMode.Calm.rawValue
    }
    
    func doneButtonPressed() {
        // Update the settings
        if let settings = PyrokinesisSettings.getSettings() {
            settings.gameMode = self.getGameModeString()
            settings.save()
        }
        
        self.navigationController?.popViewController(animated: true)
    }
    
    func cancelButtonPressed() {
        self.navigationController?.popViewController(animated: true)
    }
}

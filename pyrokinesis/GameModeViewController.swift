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
    
    private var lastSelectedIndexPath: NSIndexPath? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Game Mode"
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Done, target: self, action: Selector("doneButtonPressed"))
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Cancel, target: self, action: Selector("cancelButtonPressed"))
        
        var selectedIndex = NSIndexPath(forRow: 0, inSection: 0)
        if let settings = PyrokinesisSettings.getSettings() {

            // Find the index of the given game mode...
            var gameModeIdx = 0
            for mode in PyrokinesisSettings.GameMode.allValues {
                
                let modeStr = mode.rawValue as String
                
                if modeStr == settings.gameMode {
                    break
                }
                gameModeIdx++
            }
            
            if gameModeIdx < PyrokinesisSettings.GameMode.allValues.count {
                selectedIndex = NSIndexPath(forRow: gameModeIdx, inSection: 0)
            }
        }
       
        // Make sure SOMETHING is selected...
        self.tableView(self.gameModeTableView, didSelectRowAtIndexPath: selectedIndex)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return PyrokinesisSettings.GameMode.allValues.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let gameMode = PyrokinesisSettings.GameMode.allValues[indexPath.row]
        
        let cell = tableView.dequeueReusableCellWithIdentifier("ModeOptionCell", forIndexPath: indexPath) as! UITableViewCell
        cell.textLabel?.text = PyrokinesisSettings.GameMode.allValues[indexPath.row].rawValue
        cell.accessoryType = (self.lastSelectedIndexPath?.row == indexPath.row) ? .Checkmark : .None
        
        return cell
    }
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if indexPath.row != self.lastSelectedIndexPath?.row {
            if let lastIdxPath = lastSelectedIndexPath {
                let oldCell = tableView.cellForRowAtIndexPath(lastIdxPath)
                oldCell?.accessoryType = .None
            }
            
            let newCell = tableView.cellForRowAtIndexPath(indexPath)
            newCell?.accessoryType = .Checkmark
            
            self.lastSelectedIndexPath = indexPath
        }
    }
    
    func getGameModeString() -> String {
        if let selectedIdxPath = self.lastSelectedIndexPath {
            if let cell = self.gameModeTableView.cellForRowAtIndexPath(selectedIdxPath) {
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
        
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func cancelButtonPressed() {
        self.navigationController?.popViewControllerAnimated(true)
    }
}
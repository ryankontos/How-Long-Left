//
//  CalendarPreferenceViewController.swift
//  How Long Left (macOS)
//
//  Created by Ryan Kontos on 4/12/18.
//  Copyright © 2019 Ryan Kontos. All rights reserved.
//

import Foundation
import Cocoa
import Preferences
import LaunchAtLogin
import EventKit


final class CalendarPreferenceViewController: NSViewController, Preferenceable, NSTableViewDelegate, NSTableViewDataSource, CalendarCellDelegate {
    
    let toolbarItemTitle = "Calendars"
    let toolbarItemIcon = NSImage(named: "CalIcon")!
    var calSelect : NSWindowController?
    var calSelectStoryboard = NSStoryboard()
    
   
    var timer: Timer!
    var cals = [EKCalendar]()
    var selectedCals = [EKCalendar]()
    
    @IBOutlet weak var table: NSTableView!
    @IBOutlet weak var selectAllButton: NSButton!
    var saState = false
    
    override var nibName: NSNib.Name? {
        return "CalendarPreferencesView"
    }
    
    @IBAction func selectAllClicked(_ sender: NSButton) {
        
        if saState == true {
            
            selectedCals = cals
            
        } else {
            
            selectedCals = [EKCalendar]()
            
        }
        
        table.reloadData()
        updateSelectAllButton()
        outputSelectedArrayToDefaults()
        
    }
    
    @IBAction func changeClicked(_ sender: NSButton) {
        

        if calSelect?.window?.isVisible == true {
        
        
        
        } else {
            
            self.calSelectStoryboard = NSStoryboard(name: "CalSelectStoryboard", bundle: nil)
            
            self.calSelect = self.calSelectStoryboard.instantiateController(withIdentifier: "Cal2") as? NSWindowController
            self.calSelect!.showWindow(self)
            
            
        }
            
    }
    
    override func viewWillAppear() {
        
            self.setupCals()
            self.updateSelectAllButton()
        table.delegate = self
        table.dataSource = self
            self.table.reloadData()
        
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        table.delegate = self
        table.dataSource = self
        
        
    }
    
    func setupCals() {
        
        cals = HLLEventSource.shared.getCalendars()
        
        
        for item in HLLDefaults.calendar.enabledCalendars {
            
            for cal in cals {
                
                if cal.calendarIdentifier == item {
                    
                    selectedCals.append(cal)
                    
                }
                
                
            }
            
            
        }
        
        self.updateSelectAllButton()
        
    }
    
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return cals.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "CalCell"), owner: nil) as? calendarItemRow {
            
            var isSelected = false
            
            if selectedCals.contains(cals[row]) {
                
                isSelected = true
                
                
            }
            
            
            cell.setup(delegate: self, calendar: cals[row], enabled: isSelected)
            
            return cell
            
        }
        
        return nil
        
    }
    
    override func viewWillDisappear() {
        
        NotificationCenter.default.removeObserver(self, name: Notification.Name("updateCalendar"), object: nil)
        
        NotificationCenter.default.post(name: Notification.Name("closingCalPrefsWindow"), object: nil)
        
        
    }
    
    func cellClicked(calendar: EKCalendar, state: Bool) {
        
        if state == true {
            
            selectedCals.append(calendar)
            
        } else {
            
            if let index = selectedCals.firstIndex(where: {cal in
                
                return cal.calendarIdentifier == calendar.calendarIdentifier
                
            }) {
                
                selectedCals.remove(at: index)
                
            }
            
            
            
        }
        
        for item in selectedCals {
            
            print("Selected Cal: \(item.title)")
            
        }
        
        outputSelectedArrayToDefaults()
        updateSelectAllButton()
        
    }
    
    @IBOutlet weak var useNewButton: NSButton!
    
    
    @IBAction func useNewClicked(_ sender: NSButton) {
        
        if sender.state == .on {
            
            HLLDefaults.calendar.useNewCalendars = true
            
        } else {
            
            HLLDefaults.calendar.useNewCalendars = false
            
        }
        
        
    }
    
    
    
    func updateSelectAllButton() {
        
        if HLLDefaults.calendar.useNewCalendars {
            
            useNewButton.state = .on
            
        } else {
            
            useNewButton.state = .off
            
        }
        
        
        if selectedCals.count == cals.count {
            
            selectAllButton.title = "Deselect All"
            saState = false
            
        } else {
            
            selectAllButton.title = "Select All"
            saState = true
        }
        
        
        
    }
    
    func outputSelectedArrayToDefaults() {
        
        var idArray = [String]()
        
        for cal in selectedCals {
            
            idArray.append(cal.calendarIdentifier)
            
            
        }
        
        var disabledArray = [String]()
        
        for calendar in cals {
            
            if selectedCals.contains(calendar) == false {
                
                disabledArray.append(calendar.calendarIdentifier)
                
            }
            
            
            
            
        }
        
        HLLDefaults.calendar.disabledCalendars = disabledArray
        
        
        HLLDefaults.calendar.enabledCalendars = idArray
        
        NotificationCenter.default.post(name: Notification.Name("updateCalendar"), object: nil)
        //HLLEventSource.shared.updateEnabledCalendars()

        
    }
    

    
}

//
//  MagdaleneUpdateAlert.swift
//  How Long Left (macOS)
//
//  Created by Ryan Kontos on 19/12/18.
//  Copyright © 2019 Ryan Kontos. All rights reserved.
//

import Foundation
import AppKit

class MagdalenePrompts {
   
    let version = Version()
    let showChangesPrompt = true
    
    func presentMagdaleneChangesPrompt() {
        
        if let launched = HLLDefaults.appData.launchedVersion, SchoolAnalyser.schoolMode == .Magdalene, showChangesPrompt == true {
            
            if Version.currentVersion > launched {
                
                DispatchQueue.main.async {
                    
                    
                    NSApp.activate(ignoringOtherApps: true)
                    let alert: NSAlert = NSAlert()
                    alert.window.title = "How Long Left \(Version.currentVersion)"
                    alert.messageText = "New in Magdalene Mode:"
                    alert.informativeText = """
                    - Adds the option to show the end time of the current event in the menu item. You can enable this in Preferences.
                    = Fixed an issue where Magdalene Mode would not be avaliable if you only had your Term 2 timetable installed.
                    - Also, when there's one minute left of an event, the notification will now say "We're in the endgame now", because why not.
                    
                    """
                    
                    alert.alertStyle = NSAlert.Style.informational
                    alert.addButton(withTitle: "Epic!")
                    alert.runModal()
                    
                }
                
                
            }
            
        }
        
        
        
    }
    
    func presentSchoolHolidaysPrompt() {
        
        DispatchQueue.main.async {
            
            NSApp.activate(ignoringOtherApps: true)
            let alert: NSAlert = NSAlert()
            alert.window.title = "How Long Left \(Version.currentVersion)"
            alert.messageText = "School is done for the term!"
            alert.informativeText = """
            How Long Left will count down to the start of next term. You can disable this in Magdalene preferences.
            
            Have a great holidays! Thanks for using How Long Left. 😁
            
            """
            
            alert.alertStyle = NSAlert.Style.informational
            alert.addButton(withTitle: "OK")
            alert.runModal()
            
        }
    }
    
    func presentSentralPrompt(reinstall: Bool) {
        
        
        DispatchQueue.main.async {
            
            let installInstructions = "You can do this by logging in, navigating to the \"My Timetable\" section, and clicking \"Export as iCal\""
            
            var titleText = "Magdalene Timetable not installed"
            var infoText = """
            To use How Long Left with your Magdalene classes, please download your timetable from Sentral. \(installInstructions).
            
            """
            
            if reinstall == true {
                
                var termText = "this term"
                
                if let term = MagdaleneSchoolHolidays().getNextHolidays()?.holidaysTerm {
                    
                    termText = "Term \(term)"
                }
                
            titleText = "Reinstall your timetable for \(termText)"
                
            infoText = """
            Your timetable must be reinstalled from Sentral  each term. \(installInstructions).
            
            """
        
            }
            
            NSApp.activate(ignoringOtherApps: true)
            let alert: NSAlert = NSAlert()
            alert.window.title = "How Long Left"
            alert.messageText = titleText
            alert.informativeText = infoText
            
            alert.alertStyle = NSAlert.Style.informational
            
            
            alert.addButton(withTitle: "Open Sentral")
            alert.addButton(withTitle: "Ignore")
            
            let button = alert.runModal()
            
            if button == NSApplication.ModalResponse.alertFirstButtonReturn {
                
                
                if let url = URL(string: "https://sent.mchsdow.catholic.edu.au/portal/timetable/mytimetable") {
                    NSWorkspace.shared.open(url)
                    
                }
                
                print("Opening Sentral")
                
            }
            
            
        }
    }
    
   
    
}
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


final class aboutViewController: NSViewController, Preferenceable {
    let toolbarItemTitle = "About"
    let toolbarItemIcon = NSImage(named: "logo")!
    @IBOutlet weak var appIconButton: NSButton!
    
    @IBOutlet weak var nameLabel: NSTextField!
    @IBOutlet weak var versionLabel: NSTextField!
    @IBOutlet weak var devLabel: NSTextField!
    @IBOutlet weak var buildDateLabel: NSTextField!
    
    
    
    override var nibName: NSNib.Name? {
        return "AboutView"
    }
    
    var currentLinks = [URL]()
    var sourceLinks = [URL]()
    
    var compileDate:Date
    {
        let bundleName = Bundle.main.infoDictionary!["CFBundleName"] as? String ?? "Info.plist"
        if let infoPath = Bundle.main.path(forResource: bundleName, ofType: nil),
            let infoAttr = try? FileManager.default.attributesOfItem(atPath: infoPath),
            let infoDate = infoAttr[FileAttributeKey.creationDate] as? Date
        { return infoDate }
        return Date()
    }
    
    override func viewWillAppear() {
        
        buildDateLabel.stringValue = "Written in Swift!"
        
        
        DispatchQueue.main.async {
            
            HLLMain.shared?.getLinks()
            
        }
        
        
        var titleString = "How Long Left"
            
            let group = UserGrouping.shared.getCurrentGroup()
                
                if group == .Boiz {
                    
                    titleString += ": The Boiz Edition"
                    
                }
                
                if group == .BoizGirls {
                    
                    titleString += ": The Boiz Girls Edition"
                    
                }
                
                
            
        
        nameLabel.stringValue = titleString
        
        let version = Version.currentVersion
        versionLabel.stringValue = "Version \(version) (\(Version.buildVersion))"
        
        if SchoolAnalyser.privSchoolMode == .Magdalene || MagdaleneWifiCheck().isOnMagdaleneWifi() {
            
            let inYear = Date().year()-2008
            
            if inYear > 12 {
                
                devLabel.stringValue = "Developed by Ryan Kontos, a former student at Magdalene."
                
            } else if inYear < 11 {
                
                devLabel.stringValue = "Developed by Ryan Kontos, a student at Magdalene."
                
            } else {
                
                devLabel.stringValue = "Developed by Ryan Kontos, a Year \(inYear) student at Magdalene."
                
            }
            
            
            
        } else {
            
            devLabel.stringValue = "Developed by Ryan Kontos in Sydney, Australia."
            
        }
        
        
        
        
    }
    
    @IBAction func githubButtonClicked(_ sender: NSButton) {
        
        if let url = URL(string: "https://github.com/ryankontos") {
            NSWorkspace.shared.open(url)
            
        }
        
    }
    
    @IBAction func emailMeClicked(_ sender: NSButton) {
        
        if let url = URL(string: "mailto:ryanjkontos@gmail.com") {
            NSWorkspace.shared.open(url)
            
        }
        
        
    }
    
    
    
    @IBAction func twitterButtonClicked(_ sender: NSButton) {
        
        if let url = URL(string: "https://twitter.com/ryanjkontos") {
            NSWorkspace.shared.open(url)
            
        }
        
    }
    
    @IBAction func writeReviewClicked(_ sender: NSButton) {
        
        if #available(OSX 10.14, *) {
           
            if let url = URL(string: "macappstore://itunes.apple.com/app/id1388832966?action=write-review") {
                NSWorkspace.shared.open(url)
                
            }
            
        } else {
            
            if let url = URL(string: "macappstore://itunes.apple.com/app/id1388832966?mt=12") {
                NSWorkspace.shared.open(url)
                
            }
            
        }
        
        
        
    }
    

    var linksWorking = [String]()
    
    @IBAction func appIconClicked(_ sender: NSButton) {
     
        if SchoolAnalyser.schoolMode == .Magdalene {
            
            DispatchQueue.main.async {
                
                HLLMain.shared?.getLinks()
                
            }
    
            if currentLinks.isEmpty {
                
                currentLinks = HLLMain.boizLinks
                sourceLinks = HLLMain.boizLinks
                
            }
            
            if HLLMain.boizLinks != self.sourceLinks {
                
                currentLinks = HLLMain.boizLinks
                sourceLinks = HLLMain.boizLinks
                
            }
            
            if let element = currentLinks.randomElement(), let index = currentLinks.firstIndex(of: element) {
                
                currentLinks.remove(at: index)
                    
                    NSWorkspace.shared.open(element)
                    
                
            }
            
            
            
            
        }
        
        
    }
    
    
    
}

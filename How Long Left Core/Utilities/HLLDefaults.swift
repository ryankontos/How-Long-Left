//
//  HLLDefaults.swift
//  How Long Left (macOS)
//
//  Created by Ryan Kontos on 27/11/18.
//  Copyright © 2019 Ryan Kontos. All rights reserved.
//

import Foundation

class HLLDefaults {

    static var shared = HLLDefaults()
    
    #if os(OSX)
    static var defaults = UserDefaults.init(suiteName: "5AMFX8X5ZN.howlongleft")!
    #elseif os(watchOS)
    static var defaults = UserDefaults.standard
    #else
    static var defaults = UserDefaults(suiteName: "group.com.ryankontos.How-Long-Left")!
    #endif
    
    struct appData {
        
        
        static var launchedVersion: String? {
            
            get {
                
                
                return defaults.string(forKey: "launchedVersion")
                
            }
            
            set (to) {
                
                defaults.set(to, forKey: "launchedVersion")
                
            }
            
            
        }
        
        static var proUser: Bool {
            
            
            get {
                
                return defaults.bool(forKey: "pro")
                
            }
            
            set (to) {
                
                defaults.set(to, forKey: "pro")
                
            }
            
            
            
            
        }
        
    }
    
    
    
    struct rename {
        
        static var promptToRename: Bool {
            
            
            get {
                
                return !defaults.bool(forKey: "RNDontPrompt")
                
            }
            
            set (to) {
                
                defaults.set(!to, forKey: "RNDontPrompt")
                
            }
            
            
            
            
        }
        
        
    }
    
    struct complication {
        
        
        static var largeCountdown: Bool {
            
                
                get {
                    
                    return defaults.bool(forKey: "largeCountdown")
                    
                }
                
                set (to) {
                    
                    defaults.set(to, forKey: "largeCountdown")
                    
                }
                
            
            
            
        }
        
        
        
    }
    
    struct general {
        
        static var selectedEventID: String? {
            
            get {
                
                return HLLDefaults.defaults.string(forKey: "SelectedEvent")
                
                
            }
            
            set (to) {
                
                HLLDefaults.defaults.set(to, forKey: "SelectedEvent")
                
            }
            
            
        }
        
        static var eventInfoOrdering: [[HLLEventInfoItemType]] {
                   
                   get {
                       
                       var returnDict = [[HLLEventInfoItemType]]()
                       
                       if let test = HLLDefaults.defaults.object(forKey: "InfoItemOrdering") as? [[String]] {
                           
                           for item in test {
                               
                               var array = [HLLEventInfoItemType]()
                               
                               for subItem in item {
                                   
                                   if let type = HLLEventInfoItemType(rawValue: subItem) {
                                       
                                       array.append(type)
                                       
                                   }
                                   
                               }
                               
                               returnDict.append(array)
                               
                           }
                           
                       }
                    
                    return returnDict
                       
                   }
                   
                   set (to) {
                       
                    var final = [[String]]()
                    
                    for item in to {
                        
                        var array = [String]()
                        
                        for subItem in item {
                            
                            array.append(subItem.rawValue)
                            
                        }
                        
                        final.append(array)
                    
                    }
                    
                       defaults.set(final, forKey: "InfoItemOrdering")
                       
                   }
                   
               }
        
        static var use24HourTime: Bool {
            
            get {
                
                return defaults.bool(forKey: "use24HrTime")
                
            }
            
            set (to) {
                
                defaults.set(to, forKey: "use24HrTime")
                
            }
            
        }
        
        static var showAllDay: Bool {
            
            get {
                
                return defaults.bool(forKey: "showAllDay")
                
            }
            
            set (to) {
                
                defaults.set(to, forKey: "showAllDay")
                
            }
            
        }
        
        static var showAllDayInStatusItem: Bool {
            
            get {
                
                return defaults.bool(forKey: "showAllDayInCurrent")
                
            }
            
            set (to) {
                
                defaults.set(to, forKey: "showAllDayInCurrent")
                
            }
            
        }
        
        static var showUpcomingWeekMenu: Bool {
            
            get {
                
                return !defaults.bool(forKey: "hideUpcomingSubmenu")
                
            }
            
            set (to) {
                
                defaults.set(!to, forKey: "hideUpcomingSubmenu")
                
            }
            
        }
        
        static var syncPreferences: Bool {
            
            get {
                
                return !defaults.bool(forKey: "syncPreferences")
                
            }
            
            set (to) {
                
                defaults.set(!to, forKey: "syncPreferences")
                
            }
            
        }
        
        static var showNextOccurItems: Bool {
            
            get {
                
                return !defaults.bool(forKey: "hideNextOccur")
                
            }
            
            set (to) {
                
                defaults.set(!to, forKey: "hideNextOccur")
                
            }
            
        }
        
        static var showPercentage: Bool {
            
            get {
                
                return !defaults.bool(forKey: "hidePercentage")
                
            }
            
            set (to) {
                
                defaults.set(!to, forKey: "hidePercentage")
                
            }
            
        }
        
        static var showLocation: Bool {
            
            get {
                
                return !defaults.bool(forKey: "hideLocation")
                
            }
            
            set (to) {
                
                defaults.set(!to, forKey: "hideLocation")
                
            }
            
        }
        
        static var showUpdates: Bool {
            
            get {
                
                return !defaults.bool(forKey: "hideUpdates")
                
            }
            
            set (to) {
                
                defaults.set(!to, forKey: "hideUpdates")
                
            }
            
        }
        
        
    }
    
    struct menu {
        
        static var topLevelUpcoming: Bool {
            
            get {
                
                return !defaults.bool(forKey: "topLevelUpcoming")
                
            }
            
            set (to) {
                
                defaults.set(!to, forKey: "topLevelUpcoming")
                
            }
            
        }
        
        static var listUpcoming: Bool {
            
            get {
                
                return !defaults.bool(forKey: "hideUpcoming")
                
            }
            
            set (to) {
                
                defaults.set(!to, forKey: "hideUpcoming")
                
            }
            
        }
        
       
        
    }
    
    struct statusItem {
        
        static var mode: StatusItemMode {
            
            get {
                
                if let mode = StatusItemMode(rawValue: defaults.integer(forKey: "statusItemTimerMode")) {
                    
        
                    
                  //  print("MakeMode: \(int) \(mode)")
                    
                    return mode
                    
                } else {
                    
                    return StatusItemMode.Timer
                    
                }
                
            }
            
            set (to) {
                
                defaults.set(to.rawValue, forKey: "statusItemTimerMode")
                
            }
            
        }
        
        static var appIconStatusItem: Bool {
            
            get {
                
                return defaults.bool(forKey: "appIconStatusItem")
                
            }
            
            set (to) {
                
                defaults.set(to, forKey: "appIconStatusItem")
                
            }
            
            
            
        }
        
        static var showCurrent: Bool {
            
            get {
                
                return !defaults.bool(forKey: "hideCurrentSI")
                
            }
            
            set (to) {
                
                defaults.set(!to, forKey: "hideCurrentSI")
                
            }
            
        }
        
        static var showUpcoming: Bool {
            
            get {
                
                return !defaults.bool(forKey: "hideUpcomingSI")
                
            }
            
            set (to) {
                
                defaults.set(!to, forKey: "hideUpcomingSI")
                
            }
            
        }
        
        static var showEndTime: Bool {
            
            get {
                
                return defaults.bool(forKey: "showStatusItemEndTime")
                
            }
            
            set (to) {
                
                defaults.set(to, forKey: "showStatusItemEndTime")
                
            }
            
        }
        
        static var showPercentage: Bool {
            
            get {
                
                return defaults.bool(forKey: "showStatusItemPercentage")
                
            }
            
            set (to) {
                
                defaults.set(to, forKey: "showStatusItemPercentage")
                
            }
            
        }
        
        static var showTitle: Bool {
            
            get {
                
                return !defaults.bool(forKey: "hideStatusItemTitle")
                
            }
            
            set (to) {
                
                defaults.set(!to, forKey: "hideStatusItemTitle")
                
            }
            
        }
        
        static var showLeftText: Bool {
            
            get {
                
                return defaults.bool(forKey: "showLeftText")
                
            }
            
            set (to) {
                
                defaults.set(to, forKey: "showLeftText")
                
            }
            
        }
        
        static var doneAlerts: Bool {
            
            get {
                
                return !defaults.bool(forKey: "noDoneAlerts")
                
            }
            
            set (to) {
                
                defaults.set(!to, forKey: "noDoneAlerts")
                
            }
            
        }

        static var useFullUnits: Bool {
            
            get {
                
                return defaults.bool(forKey: "useFullUnits")
                
            }
            
            set (to) {
                
                defaults.set(to, forKey: "useFullUnits")
                
            }
            
        }

        
        static var hideTimerSeconds: Bool {
            
            get {
                
                return defaults.bool(forKey: "hideTimerSecs")
                
            }
            
            set (to) {
                
                defaults.set(to, forKey: "hideTimerSecs")
                
            }
            
        }

        
        
    }
    
    struct calendar {
        
        
        static var selectedCalendar: String? {
            
            get {
                
                return defaults.string(forKey: "selectedCalendar")
                
            }
            
            set (to) {
                
                defaults.set(to, forKey: "selectedCalendar")
                
            }
            
        }
        
        static var enabledCalendars: [String] {
            
            get {
                
                return defaults.stringArray(forKey: "setCalendars") ?? [String]()
                
            }
            
            set (to) {
                
                defaults.set(to, forKey: "setCalendars")
                
            }
            
        }
        
        static var disabledCalendars: [String] {
            
            get {
                
                return defaults.stringArray(forKey: "disabledCalendars") ?? [String]()
                
            }
            
            set (to) {
                
                defaults.set(to, forKey: "disabledCalendars")
                
            }
            
        }
        
        
        static var useAllCalendars: Bool {
            
            get {
                
                return !defaults.bool(forKey: "doNotUseAllCalendars")
                
            }
            
            set (to) {
                
                defaults.set(!to, forKey: "doNotUseAllCalendars")
                
            }
            
        }
        
        static var useNewCalendars: Bool {
            
            get {
                
                return !defaults.bool(forKey: "doNotUseNewCalendars")
                
            }
            
            set (to) {
                
                defaults.set(!to, forKey: "doNotUseNewCalendars")
                
            }
            
        }
        
    }
    
    struct notifications {
        
        static var startNotifications: Bool {
            
            get {
                
                return !defaults.bool(forKey: "doNotDoStartNotos")
                
            }
            
            set (to) {
                
                defaults.set(!to, forKey: "doNotDoStartNotos")
                
            }
            
            
        }
        
        static var sounds: Bool {
            
            get {
                
                return defaults.bool(forKey: "useSounds")
                
            }
            
            set (to) {
                
                defaults.set(to, forKey: "useSounds")
                
            }
            
            
        }
        
        static var soundName: String? {
            
            get {
                
                if HLLDefaults.notifications.sounds == true {
                    
                    return "Hero"
                    
                } else {
                    
                    return nil
                    
                }
                
                
                
            }
            
            
        }
        
        static var hotkey: HLLHotKeyOption {
            
            get {
                
                if let hotKey = HLLHotKeyOption(rawValue: defaults.integer(forKey: "hotKey")) {
                    
                    return hotKey
                    
                } else {
                    
                    return HLLHotKeyOption.OptionW
                    
                }
                
            }
            
            set (to) {
                
                defaults.set(to.rawValue, forKey: "hotKey")
                
            }
            
        }
        
        static var milestones: [Int] {
            
            get {
                
                var returnArray = [Int]()
                
                if let hkArray = defaults.stringArray(forKey: "Milestones") {
                    
                    for item in hkArray {
                        
                        if let intItem = Int(item) {
                            
                            returnArray.append(intItem)
                            
                        }
                        
                    }
                    
                    return returnArray
                    
                    
                } else {
                    defaults.set(["600", "300", "60", "0"], forKey: "Milestones")
                    return [600, 300, 60, 0]
                    
                }
                
                
            }
            
            set (to) {
                
                var setArray = [String]()
                
                for item in to {
                    
                    setArray.append(String(item))
                    
                }
                
                defaults.set(setArray, forKey: "Milestones")
                
            }
            
            
        }
        
        static var Percentagemilestones: [Int] {
            
            get {
                
                var returnArray = [Int]()
                
                if let hkArray = defaults.stringArray(forKey: "PercentageMilestones") {
                    
                    for item in hkArray {
                        
                        if let intItem = Int(item) {
                            
                            returnArray.append(intItem)
                            
                        }
                        
                    }
                    
                    return returnArray
                    
                    
                } else {
                    defaults.set(["25", "50", "75"], forKey: "PercentageMilestones")
                    return [25, 50, 75]
                    
                }
                
                
            }
            
            set (to) {
                
                var setArray = [String]()
                
                for item in to {
                    
                    setArray.append(String(item))
                    
                }
                
                defaults.set(setArray, forKey: "PercentageMilestones")
                
            }
            
            
        }

        
    }
    
    struct magdalene {
        
        static var manuallyDisabled: Bool {
            
            get {
                
                return defaults.bool(forKey: "magdaleneFeaturesManuallyDisabled")
                
            }
            
            set (to) {
                
                defaults.set(to, forKey: "magdaleneFeaturesManuallyDisabled")
                
            }
            
        }
        
        static var hideExtras: Bool {
            
            get {
                
                return defaults.bool(forKey: "hideMExtras")
                
            }
            
            set (to) {
                
                defaults.set(to, forKey: "hideMExtras")
                
            }
            
        }
        
        static var showSportAsStudy: Bool {
            
            get {
                
                return defaults.bool(forKey: "showSportAsStudy")
                
            }
            
            set (to) {
                
                defaults.set(to, forKey: "showSportAsStudy")
                
            }
            
        }
        
        static var magdaleneModeWasEnabled: Bool {
            
            get {
                
                return defaults.bool(forKey: "magdaleneModeWasEnabled")
                
            }
            
            set (to) {
                
                defaults.set(to, forKey: "magdaleneModeWasEnabled")
                
            }
            
        }
    
        static var showBreaks: Bool {
            
            get {
                
                return !defaults.bool(forKey: "doNotShowBreaks")
                
            }
            
            set (to) {
                
                defaults.set(!to, forKey: "doNotShowBreaks")
                
            }
            
        }
        
        static var doHolidays: Bool {
            
            get {
                
                return !defaults.bool(forKey: "doNotDoHolidays")
                
            }
            
            set (to) {
                
                defaults.set(!to, forKey: "doNotDoHolidays")
                
            }
            
        }
        
        static var doTerm: Bool {
            
            get {
                
                return !defaults.bool(forKey: "doNotShowTerm")
                
            }
            
            set (to) {
                
                defaults.set(!to, forKey: "doNotShowTerm")
                
            }
            
        }
        
        static var showPrelims: Bool {
            
            get {
                
                return !defaults.bool(forKey: "doNotShowPrelims")
                
            }
            
            set (to) {
                
                defaults.set(!to, forKey: "doNotShowPrelims")
                
            }
            
        }
    

        static var showEdvalButton: Bool {
            
            get {
                
                return !defaults.bool(forKey: "hideEdvalButton")
                
            }
            
            set (to) {
                
                defaults.set(!to, forKey: "hideEdvalButton")
                
            }
            
        }
        
        
        
    }
    
}

protocol DefaultsTransferHandler {
    
    func transferDefaultsDictionary(_ defaultsToTransfer: [String:Any])
    
}

protocol DefaultsTransferObserver {
    
    func defaultsUpdatedRemotely()
    
}

enum HLLDefaultsKeys: CaseIterable {
    
    enum General: String, CaseIterable {
        
        case test = "test"
        case example = "lol"
        
    }
    
    enum Calendars: String, CaseIterable {
        
        case enabledCalendars = "set"
        case disabledCalendars = "disabled"
        
    }
    
}

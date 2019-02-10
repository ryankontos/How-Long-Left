//
//  Main.swift
//  How Long Left (macOS)
//
//  Created by Ryan Kontos on 30/10/18.
//  Copyright © 2019 Ryan Kontos. All rights reserved.
//

import Foundation
import HotKey
import AppKit

class Main: HLLCountdownController {
    
    let updateInterval = 5
    let fastUpdateInterval = 0.05
    let minUpdateInterval = 0.1
    
    var statusItemLoops = 1
    lazy var defaults = HLLDefaults()
    lazy var countdownStringGenerator = CountdownStringGenerator()
    lazy var upcomingEventStringGenerator = UpcomingEventStringGenerator()
    lazy var schoolAnalyser = SchoolAnalyser()
    lazy var milestoneNotifications = MilestoneNotifications()
    lazy var calendarData = EventDataSource.shared
    lazy var statusItemTimerStringGenerator = StatusItemTimerStringGenerator(isForPreview: false)
    lazy var nextOccurStringGenerator = NextOccurenceStringGenerator()
    lazy var holidaysStringGenerator = SchoolHolidaysStringGenerator()
    lazy var eventNextOccurFinder = EventNextOccurenceFinder()
    lazy var memoryRelaunch = MemoryRelaunch()
    lazy var schoolManager = SchoolFunctionsManager()
    var delegate: HLLMacUIController? {
        
        didSet {
            
            self.mainRunLoop()
            
        }
        
        
    }
    let schoolHoliday = MagdaleneSchoolHolidays()
    var nextEventToStart: HLLEvent?
    let calendar = NSCalendar.current
    var betaExpiryDate: Date?
    var welcomeWindowController : NSWindowController?
    var welcomeStoryboard = NSStoryboard()
    var mainTimer: Timer?
    var calUpdateCooldownTimer: Timer?
    var dataUpdateTimer: Timer!
    var frequentLowUsageTimer: Timer!
    var checkForUpdateTimer: Timer!
    var lastCalendarUpdate: Date?
    var statusItemTimerStrings: [Double: String] = [:]
    var eventEndUpdateInProgress = false
    var calendarUpdateInProgress = false
    var beenTooLongWithoutUpdate = false
    var updatingStatusItemTimer = false
    var fastTimerMode = false
    var statusItemTimerRunning = false
    var inCalendarUpdateCooldown = false
    var updateRequestedDuringCooldown = false
    var shownUpdateNotification = false
    var shownNoCalAccessNotification = false
    var shownBetaExpiredNoto = false
    var updateCalID: String?
    
    let version = Version()
    var currentStatusItemLoop = 0
    
    
    
    lazy var preciseUpdateForMinuteChangeTimer = RepeatingTimer(time: minUpdateInterval)
    lazy var preciseUpdateForPreferencesOpenTimer = RepeatingTimer(time: minUpdateInterval)
    lazy var statusItemLoopTimer = RepeatingTimer(time: 5.0)
    lazy var statusItemTimer = RepeatingTimer(time: fastUpdateInterval)
    lazy var eventMilestoneTracker = EventTimeRemainingMonitor(delegate: self)
    
   // let milestoneNotosch = MilestoneNotificationScheduler()
    
    init(aDelegate: HLLMacUIController) {

        delegate = aDelegate
        
        UIController.awokeAt = Date()
        
        schoolAnalyser.analyseCalendar()
        
      //  betaExpiryDate = Date(timeIntervalSince1970: 1544792400)
        
        var showOnboarding = false
        
      //  if let launched = HLLDefaults.appData.launchedVersion  {
        
        if HLLDefaults.appData.launchedVersion == nil {
            
            showOnboarding = true
            
          /*  if version.currentVersion > launched {
                
                showOnboarding = true
                
            } */
            
        } else {
            
            showOnboarding = false
            
        }
        
        
        
        if showOnboarding == true {
            
        DispatchQueue.main.async {
            
            let defaultsMigrator = DefaultsMigrator()
            defaultsMigrator.migrate1XXDefaults()
            
            self.welcomeStoryboard = NSStoryboard(name: "Onboarding", bundle: nil)
        
            self.welcomeWindowController = self.welcomeStoryboard.instantiateController(withIdentifier: "Onboard1") as? NSWindowController
            self.welcomeWindowController!.showWindow(self)
        
        }
            
            
        }
        
        mainRunLoop()
        
        let magdaleneUpdateAlert = MagdaleneUpdateAlert()
        magdaleneUpdateAlert.CheckToShowMagdaleneChangesPrompt()
        
        
        HLLDefaults.appData.launchedVersion = version.currentVersion
        
        delegate?.setHotkey(to: HLLDefaults.notifications.hotkey)
        
        
        statusItemLoopTimer.eventHandler = {
            
            
            if self.currentStatusItemLoop < self.statusItemLoops {
                
                self.currentStatusItemLoop += 1
                
            } else {
                
                self.currentStatusItemLoop = 0
                
            }
            
         //   print("Loop: \(self.currentStatusItemLoop)")
            
            
            
        }
        
        statusItemLoopTimer.resume()
        
        statusItemTimer.eventHandler = {
            
            DispatchQueue.global(qos: .userInteractive).async {
                
                var countdown: HLLEvent?
                
                if let top = EventCache.primaryEvent {
                    
                    countdown = top
                    
                } else {
                    
                    countdown = EventCache.currentEvents.first
                    
                }
                
                
                
                if let currentEvent = countdown, currentEvent.isHolidays == false, let timerString = self.statusItemTimerStringGenerator.generateStringFor(event: currentEvent) {
                    self.runStatusItemUIUpdate(event: currentEvent)
                    self.delegate?.updateStatusItem(with: timerString)
                    
                } else {
                    
                    self.delegate?.updateStatusItem(with: nil)
                    
                }
            }
            
        }
        
        preciseUpdateForMinuteChangeTimer.eventHandler = { self.preciseMainRunLoopTrigger() }
        preciseUpdateForPreferencesOpenTimer.eventHandler = { self.preciseMainRunLoopTrigger() }
        
        updateCalendarData(doGlobal: false)
        
        mainRunLoop()
        
        mainTimer = Timer.scheduledTimer(timeInterval: TimeInterval(updateInterval), target: self, selector: #selector(mainRunLoop), userInfo: nil, repeats: true)
        frequentLowUsageTimer = Timer.scheduledTimer(timeInterval: TimeInterval(1), target: self, selector: #selector(checkEvents), userInfo: nil, repeats: true)
        dataUpdateTimer = Timer.scheduledTimer(timeInterval: TimeInterval(300), target: self, selector: #selector(updateCalendarData), userInfo: nil, repeats: true)
        checkForUpdateTimer = Timer.scheduledTimer(timeInterval: TimeInterval(300), target: self, selector: #selector(doUpdateCheck), userInfo: nil, repeats: true)

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.doUpdateCheck()
        }
        
        RunLoop.main.add(mainTimer!, forMode: .common)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.calendarDidChange),
            name: .EKEventStoreChanged,
            object: nil)
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateGlobalTrigger), name: Notification.Name("updateCalendar"), object: nil)
            
       print("Init took \(Date().timeIntervalSince(UIController.awokeAt!))s")
        
    }
    
    
    @objc func updateGlobalTrigger() {
        
        updateCalendarData(doGlobal: true)
        
    }
    
    @objc func doUpdateCheck() {
        
        let update = version.updateAvaliable()
        
       delegate?.setUpdateAvaliableState(version: update)
        
        if let uUpdate = update, shownUpdateNotification == false {
            
            sendUpdateAvaliableNotification(version: uUpdate)
            shownUpdateNotification = true
            
        }
        
        
        
    }
    
    @objc func preciseMainRunLoopTrigger() {
        self.mainRunLoop()
       // print("Precise trigger")
    }
    
    @objc func checkEvents() {
        
        eventMilestoneTracker.checkCurrentEvents()
        
        DispatchQueue.main.async {
            
            let second = self.calendar.component(.second, from: Date())
            
            if second == 58 || second == 59 || second == 0 || second == 1 {
                
                    
                    self.preciseUpdateForMinuteChangeTimer.resume()
                
                
            } else if UIController.preferencesWindowController.window!.isVisible == false {
                self.preciseUpdateForMinuteChangeTimer.suspend()
                
            }
            
        }
        
    }
    
    @objc func mainRunLoop() {
        
        DispatchQueue.global(qos: .default).async {
        
            self.calendarData.getCalendarAccess()
            
            if EventDataSource.accessToCalendar == .Denied {
                
                self.statusItemTimer.suspend()
                self.delegate?.noCalendarAccessUIState(enabled: true)
                
                if self.shownNoCalAccessNotification == false {
                    
                    self.sendNoCalAccessNotification()
                    
                }
                
                return
                
            } else {
                
                self.delegate?.noCalendarAccessUIState(enabled: false)
                
            }
            
          EventCache.currentEvents = self.schoolManager.handle(events: EventCache.currentEvents)
            
            EventCache.allUpcomingEvents = self.schoolManager.handle(events: EventCache.allUpcomingEvents)
            
            EventCache.nextUpcomingEvents = self.schoolManager.handle(events: EventCache.nextUpcomingEvents)
            
            EventCache.upcomingEventsToday = self.schoolManager.handle(events: EventCache.upcomingEventsToday)
            
            if let topE = EventCache.primaryEvent {
                
            EventCache.primaryEvent = self.schoolManager.handle(events: [topE]).first!
                
            }
            
            self.organiseCurrentEvents()
            
        let currentEvents = EventCache.currentEvents
        let allUpcoming = EventCache.nextUpcomingEvents
        var topEvent = EventCache.primaryEvent
           
            self.checkIfPrimaryIsStillRunning()
            
        
        if currentEvents.isEmpty == false {
            
            if topEvent == nil {
                
                topEvent = currentEvents.first
                
            }
            
            self.eventMilestoneTracker.setCurrentEvents(events: currentEvents)
            
        } else {
            
            self.eventMilestoneTracker.removeAllCurrentEvents()
            
        }
        
        
            self.runStatusItemUIUpdate(event: topEvent)
        
        
        if allUpcoming.isEmpty == false {
            
            self.nextEventToStart = allUpcoming[0]
            
        } else {
            
            self.nextEventToStart = nil
            
        }
        
            if let unwrappedUpcoming = self.nextEventToStart {
                
                // If the next to start event has started, update calendar data.
                
                if unwrappedUpcoming.startDate.timeIntervalSinceNow < 1 {
                    
                    self.nextEventToStart = nil
                    self.updateCalendarData(doGlobal: false)
                    
                }
            
            }
        
            if let unwrappedLastCalendarUpdate = self.lastCalendarUpdate {
                
                if unwrappedLastCalendarUpdate.timeIntervalSinceNow < -302 || unwrappedLastCalendarUpdate.timeIntervalSinceNow > 1 {
                  
                    if self.beenTooLongWithoutUpdate == false {
                        
                        self.beenTooLongWithoutUpdate = true
                        self.updateCalendarData(doGlobal: false)
                        print("Updating calendar at \(Date()) due to too long")
                        
                    }
                    
                }
                
            }
        
            DispatchQueue.main.async {
                
            
        if UIController.preferencesWindowController.window!.isVisible, HLLDefaults.statusItem.mode != .Off {
                self.preciseUpdateForPreferencesOpenTimer.resume()
            
            
        } else {
            
                self.preciseUpdateForPreferencesOpenTimer.suspend()
            
            
        }
                
            }
            
            if let top = EventCache.primaryEvent {
                var match = false
                for event in EventCache.currentEvents {
                    
                    if event == top {
                        
                        EventCache.primaryEvent = event
                        match = true
                        
                    }
                    
                    
                }
                
                if match == false {
                    
                    EventCache.primaryEvent = EventCache.currentEvents.first
                    
                }
                
            }
            
            self.memoryRelaunch.relaunchIfNeeded()
            self.checkBetaExpiry()
            self.delegate?.setHotkey(to: HLLDefaults.notifications.hotkey)
            
            
            
            if self.calendarData.latestFetchSchoolMode != SchoolAnalyser.schoolMode {
                
                self.updateCalendarData(doGlobal: false)
            }
                
                if self.updateCalID != HLLDefaults.calendar.selectedCalendar {
                    
                    self.updateCalID = HLLDefaults.calendar.selectedCalendar
                    self.schoolAnalyser.analyseCalendar()
                    self.updateCalendarData(doGlobal: false)
                    
                    print("Update for new cal")
                    
                }
                
            for event in EventCache.upcomingEventsToday {
                
                if event.completionStatus == EventCompletionStatus.InProgress {
                    
                    if EventCache.currentEvents.contains(event) == false {
                        
                        self.updateCalendarData(doGlobal: false)
                        
                        
                    }
                    
                }
                
            }
            
        }
        
    
            
    }
    
    @objc func calendarDidChange() {
        
       // print("Updating calendar at \(Date()) due to calendar change")
        updateCalendarData(doGlobal: false)
        print("Updating calendar at \(Date()) due to cal change")
        DispatchQueue.global(qos: .default).asyncAfter(deadline: .now() + 1) {
            self.schoolAnalyser.analyseCalendar()
        }
        mainRunLoop()
        
        
    }
    
    func organiseCurrentEvents() {
        
        var currentEvents = EventCache.currentEvents
        currentEvents.sort(by: { $0.endDate.compare($1.endDate) == .orderedAscending })
        
        
        
        EventCache.currentEvents = currentEvents
        
    }
    
    func checkIfPrimaryIsStillRunning() {
        
        if let primary = EventCache.primaryEvent {
            
            var match = false
            
            for event in EventCache.currentEvents {
                
                if event == primary {
                    
                    match = true
                    
                }
                
            }
            
            if match == false {
                
                EventCache.primaryEvent = nil
                
            }
            
            
        }
        
    }
    
    func runMainMenuUIUpdate() {
        
        let currentEvents = EventCache.currentEvents
        let upcomingEventsToday = EventCache.upcomingEventsToday
        let nextUpcomingDay = EventCache.nextUpcomingEventsDay
        let allUpcoming = EventCache.allUpcomingEvents
        let upcomingWeek = EventCache.upcomingWeekEvents
        
        delegate?.addCurrentEventRows(with: countdownStringGenerator.generateCurrentEventStrings(currentEvents: currentEvents, nextEvents: upcomingEventsToday))
        
        let upcomingEventsMenuInfo = upcomingEventStringGenerator.generateUpcomingEventsMenuStrings(upcoming: nextUpcomingDay)
        
       // let upcomingFuture = upcomingEventStringGenerator.generateUpcomingEventsMenuStrings(upcoming: nextUpcoming2)
        
            delegate?.updateNextEventItem(text: upcomingEventStringGenerator.generateNextEventString(upcomingEvents: upcomingEventsToday, currentEvents: currentEvents, isForDoneNotification: false))
        
        let upcomingWeekItems = upcomingEventStringGenerator.generateUpcomingDayItems(days: upcomingWeek)
        
        let nextOccurEvents = eventNextOccurFinder.findNextOccurrences(currentEvents: currentEvents, upcomingEvents: allUpcoming)
        
        let nextOccurItems = nextOccurStringGenerator.generateNextOccurenceItems(events: nextOccurEvents)
        
        delegate?.addNextOccurRows(items: nextOccurItems)
            
        delegate?.updateUpcomingWeekMenu(data: upcomingWeekItems)
        
        delegate?.updateUpcomingEventsMenu(title: upcomingEventsMenuInfo.0, info: upcomingEventsMenuInfo.1, events: upcomingEventsMenuInfo.2)
        
        
        
        
            
        
    }
    
    func runStatusItemUIUpdate(event: HLLEvent?) {
        
        if let uEvent = event {
            
            if uEvent.isHolidays == true, HLLDefaults.magdalene.doHolidaysInStatusItem == false {
                
                self.statusItemTimer.suspend()
                self.delegate?.updateStatusItem(with: nil)
                return
                
            }
            
            
        }
        
        if HLLDefaults.statusItem.mode == .Timer, event?.isHolidays != true {
            
                if event != nil {
              //   statusItemTimerStrings = statusItemTimerStringGenerator.generateStringsFor(event: countdownEvent)
                        
                        self.statusItemTimer.resume()
                    
                } else {
                    
                    statusItemTimerStrings.removeAll()
                    
                        self.statusItemTimer.suspend()
                        delegate?.updateStatusItem(with: countdownStringGenerator.generateStatusItemString(event: nil))
                    
                }
                
            } else if HLLDefaults.statusItem.mode == .Minute || event?.isHolidays == true {
                
                self.statusItemTimer.suspend()
                
                delegate?.updateStatusItem(with: countdownStringGenerator.generateStatusItemString(event: event))
                
                
            } else {
                
                delegate?.updateStatusItem(with: nil)
                
            }
        
    }
    
    @objc func updateCalendarData(doGlobal: Bool) {
        
        
        if inCalendarUpdateCooldown == false || doGlobal == true {
        
            inCalendarUpdateCooldown = true
            
            
        DispatchQueue.global(qos: .userInteractive).async {
            
            self.calendarData.updateEventStore()
            
            if self.calendarUpdateInProgress == false {
                
                
                self.calendarUpdateInProgress = true
            print("Cal update")
                
                
                if doGlobal == true {
                    
                    let _ = self.calendarData.getCurrentEvents()
                    let _ = self.calendarData.getUpcomingEventsToday()
                    let _ = self.calendarData.getUpcomingEventsFromNextDayWithEvents()
                    let _ = self.calendarData.getArraysOfUpcomingEventsForNextSevenDays()
                    EventCache.allUpcomingEvents = self.calendarData.fetchEventsFromPresetPeriod(period: .Next2Weeks)
                    EventCache.allEventsToday = self.calendarData.fetchEventsFromPresetPeriod(period: .AllToday)
                    
                } else {
                
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.0) {
                let _ = self.calendarData.getCurrentEvents()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                let _ = self.calendarData.getUpcomingEventsToday()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                let _ = self.calendarData.getUpcomingEventsFromNextDayWithEvents()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                EventCache.allUpcomingEvents = self.calendarData.fetchEventsFromPresetPeriod(period: .Next2Weeks)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.0) {
                let _ = self.calendarData.getArraysOfUpcomingEventsForNextSevenDays()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                EventCache.allEventsToday = self.calendarData.fetchEventsFromPresetPeriod(period: .AllToday)
            }
                    
                    
                }
            
            self.lastCalendarUpdate = Date()
            self.mainRunLoop()
                self.calendarUpdateInProgress = false
                self.beenTooLongWithoutUpdate = false
            
            }
           
            
        }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                
             //   print("Cooldown ending")
                self.inCalendarUpdateCooldown = false
                
                if self.updateRequestedDuringCooldown == true {
                //    print("Doing update requested during cooldown")
                    self.updateRequestedDuringCooldown = false
                    self.updateCalendarData(doGlobal: false)
                    
                }
                
            }
            
        } else {
            
          //  print("update requested during cooldown")
            updateRequestedDuringCooldown = true
            
        }
            
    }
    
    
    func sendNoCalAccessNotification() {
        
        let notification = NSUserNotification()
        notification.title = "How Long Left"
        notification.subtitle = "No calendar access ⚠️"
        notification.informativeText = "Click to fix..."
        notification.identifier = "Cal"
        NSUserNotificationCenter.default.deliver(notification)
        
    }
    
    func sendUpdateAvaliableNotification(version: String) {
        
        let notification = NSUserNotification()
        notification.title = "An update for How Long Left is avaliable"
        notification.subtitle = "(v\(version))"
        notification.informativeText = "Click to view in the Mac App Store..."
        notification.identifier = "Update"
        NSUserNotificationCenter.default.deliver(notification)
        
    }
    
    func hotKeyPressed() {
        
        if EventDataSource.accessToCalendar == .Denied {
            
            sendNoCalAccessNotification()
            
        }
        
        let currentEvents = EventCache.currentEvents
        let upcomingEvents = EventCache.upcomingEventsToday
        
        let currentInfo = countdownStringGenerator.generateCurrentEventStrings(currentEvents: currentEvents, nextEvents: upcomingEvents)
        
        var countdownItem = currentInfo[0]
        
        if let preferedCountdownEvent = EventCache.primaryEvent {
            
            for eventItem in currentInfo {
                
                if let eventItemEvent = eventItem.2 {
                    
                    if eventItemEvent == preferedCountdownEvent {
                        
                        countdownItem = eventItem
                        
                    }
                    
                }
                
                
            }
            
        }
        
        let notification = NSUserNotification()
        notification.title = countdownItem.0
        
        if let percentText = countdownItem.1 {
            notification.subtitle = percentText
        }
        
        notification.informativeText = upcomingEventStringGenerator.generateNextEventString(upcomingEvents: upcomingEvents, currentEvents: currentEvents, isForDoneNotification: false)
        
        NSUserNotificationCenter.default.deliver(notification)
        
    }
    
    func milestoneReached(milestone seconds: Int, event: HLLEvent) {
        milestoneNotifications.sendNotificationFor(milestone: seconds, event: event)
    }
    
    func percentageMilestoneReached(milestone percentage: Int, event: HLLEvent) {
        
        milestoneNotifications.sendNotificationFor(percentage: percentage, event: event)
        
    }
    
    func eventStarted(event: HLLEvent) {
        
        milestoneNotifications.sendStartingNotification(for: event)
        
    }
    
    func updateDueToEventEnd(event: HLLEvent, endingNow: Bool) {
        
        DispatchQueue.global(qos: .default).async {
            
        
            self.updateCalendarData(doGlobal: false)
            self.checkIfPrimaryIsStillRunning()
        
        var idArray = [HLLEvent]()
        
        EventCache.currentEvents.forEach({ event in
            
            idArray.append(event)
            
        })
        
        if let indexOfEnding = idArray.firstIndex(of: event) {
            
            EventCache.currentEvents.remove(at: indexOfEnding)
            
        }
        
        }
            
        if endingNow == true {
            
            preciseUpdateForMinuteChangeTimer.resume()
            
            if let topEvent = EventCache.primaryEvent {
                
                
                if event == topEvent {
                delegate?.doStatusItemAlert(with: ["\(event.shortTitle) is done"])
                }
                
            } else {
                delegate?.doStatusItemAlert(with: ["\(event.shortTitle) is done"])
                
            }
            
            preciseUpdateForMinuteChangeTimer.suspend()
        }
        
        eventEndUpdateInProgress = true
      //  print("Updating calendar at \(Date()) due to event end")
        
        eventEndUpdateInProgress = false
        
    }
    
    func checkBetaExpiry() {
        
        if let expiry = self.betaExpiryDate, expiry.timeIntervalSinceNow < 0 {
            
            self.mainTimer?.invalidate()
            self.statusItemTimer.suspend()
            self.preciseUpdateForMinuteChangeTimer.suspend()
            self.preciseUpdateForPreferencesOpenTimer.suspend()
            
            DispatchQueue.main.async {
                
                NSApp.activate(ignoringOtherApps: true)
                let alert: NSAlert = NSAlert()
                alert.window.title = "How Long Left \(self.version.currentVersion)"
                alert.messageText = "This beta build of How Long Left has expired."
                alert.informativeText = """
                Please use a release build or obtain a newer beta.
                """
                
                alert.alertStyle = NSAlert.Style.informational
                alert.addButton(withTitle: "Quit")
                alert.runModal()
                NSApplication.shared.terminate(self)
                
            }
            
        }
        
    }
        
    }


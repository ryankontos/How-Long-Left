//
//  UpcomingEventsTableViewController.swift
//  How Long Left (iOS)
//
//  Created by Ryan Kontos on 31/3/19.
//  Copyright © 2019 Ryan Kontos. All rights reserved.
//

import Foundation
import UIKit
import MarqueeLabel
    
class UpcomingEventsTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, DataSourceChangedDelegate, ScrollUpDelegate {
        
        let eventDatasource = EventDataSource()
        var events = [HLLEvent]()
        var daysOfEvents = [DayOfEvents]()
        var lastReadReturnedNoCalendarAccess = false
        var endCheckTimer: Timer!
        var updateDate: Date?
        let dayOfEventsGenerator = DayOfEventsGenerator()
        let schoolAnalyser = SchoolAnalyser()
        @IBOutlet weak var tableView: UITableView!
    
        override func viewDidLoad() {
            //extendedLayoutIncludesOpaqueBars = true
            print("load")
            
            
            let insets = UIEdgeInsets(top: 0, left: 0, bottom: 25, right: 0)
            self.tableView.contentInset = insets
            
            updateTheme()
            
            //schoolAnalyser.analyseCalendar()
            self.navigationItem.title = "Upcoming Events"
            self.daysOfEvents = self.dayOfEventsGenerator.generateDaysOfEventsFromUpcomingEvents()
            
            tableView.delegate = self
            tableView.dataSource = self
            tableView.reloadData()
            
            
            NotificationCenter.default.addObserver(self, selector: #selector(self.calendarDidChange), name: UIApplication.willEnterForegroundNotification, object: nil)
            
            extendedLayoutIncludesOpaqueBars = true
             NotificationCenter.default.addObserver(self, selector: #selector(self.updateTheme), name: Notification.Name("ThemeChanged"), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(self.gotCalAccess), name: Notification.Name("CalendarAllowed"), object: nil)
            
            //  self.tabBarController?.tabBar.tintColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            self.endCheckTimer = Timer.scheduledTimer(timeInterval: TimeInterval(1), target: self, selector: #selector(self.checkForEnd), userInfo: nil, repeats: true)
            
            DispatchQueue.main.async {
            
            
            self.updateCountdownData()
                
            }
            
            WatchSessionManager.sharedManager.addDataSourceChangedDelegate(delegate: self)
            
            
            
            
           NotificationCenter.default.addObserver(
                self,
                selector: #selector(self.calendarDidChange),
                name: .EKEventStoreChanged,
                object: nil)
            
            
        }
    
    
    @objc func updateTheme() {
        navigationController?.navigationBar.barTintColor = AppTheme.current.plainColor
        //navigationController?.navigationBar.barStyle = AppTheme.current.barStyle
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: AppTheme.current.textColor]
        navigationController?.navigationBar.isTranslucent = AppTheme.current.translucentBars
        tableView.backgroundColor = AppTheme.current.groupedTableViewBackgroundColor
        tabBarController?.tabBar.isTranslucent = AppTheme.current.translucentBars
        tabBarController?.tabBar.barStyle = AppTheme.current.barStyle
        tableView.separatorColor = AppTheme.current.tableCellSeperatorColor
        tabBarController?.tabBar.barTintColor = AppTheme.current.plainColor
        self.navigationController?.setNeedsStatusBarAppearanceUpdate()
        tableView.reloadData()
    }
    
        
        @objc func calendarDidChange() {
            
            schoolAnalyser.analyseCalendar()
            updateCountdownData()
            
            
        }
        
    @objc func checkForEnd() {
        
        
        for event in self.events {
            
            if event.endDate.timeIntervalSinceNow > 0 {
                
                
                self.updateCountdownData()
                
            }
            
        }
        
        
        if self.lastReadReturnedNoCalendarAccess == true {
            
            self.updateCountdownData()
            
        }
        
        if EventDataSource.accessToCalendar != .Granted {
            
            self.lastReadReturnedNoCalendarAccess = true
            self.updateCountdownData()
            
        } else {
            
            self.lastReadReturnedNoCalendarAccess = false
            
        }
        
        
        
        
    }

    var gotAccess = false
    
    @objc func gotCalAccess() {
    
        if gotAccess == false {
            
            gotAccess = true
            updateCountdownData()
            
        }
    
    }
    
       @objc func updateCountdownData() {
        
        DispatchQueue.global(qos: .default).async {
            self.daysOfEvents = self.dayOfEventsGenerator.generateDaysOfEventsFromUpcomingEvents()

         DispatchQueue.main.async {
            
            
            self.tableView.reloadData()
            self.updateDate = Date()
            
        
            
        }
            
        }
            
            
        }
        
        override func viewWillAppear(_ animated: Bool) {
            
            tableView.reloadData()
            let insets = UIEdgeInsets(top: 0, left: 0, bottom: 25, right: 0)
            self.tableView.contentInset = insets
            
            
            updateTheme()
            
            DispatchQueue.main.async {
            
            RootViewController.selectedController = self
            
          //  schoolAnalyser.analyseCalendar()
            
            
            
                self.updateCountdownData()
                
            }
            
        }
        
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            
            
            //self.tabBarController?.tabBar.items?.first?.badgeValue = "\(events.count)"
            return daysOfEvents[section].events.count
            
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            
            let event = daysOfEvents[indexPath.section].events[indexPath.row]
            
            let iden = "UpcomingEventCellLocation"
            
            if event.location != nil {
                
               // iden = "UpcomingEventCellLocation"
                
            }
            
            
            let cell = tableView.dequeueReusableCell(withIdentifier: iden, for: indexPath) as! upcomingCell
            
            cell.generate(from: event)
            
            return cell
            
        }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return daysOfEvents[section].headerString
    }
        
        func numberOfSections(in tableView: UITableView) -> Int {
            
            var areEvents = false
            
            if let day = daysOfEvents.first {
                
                if day.events.isEmpty == false {
                    
                    areEvents = true
                    
                }
                
            }
            
            if areEvents == true {
                tableView.separatorStyle = .singleLine
                tableView.backgroundView = nil
                if #available(iOS 11.0, *) {
                    navigationItem.largeTitleDisplayMode = .always
                }
                
            } else {
                
                var text = "No Upcoming Events"
                
                if EventDataSource.accessToCalendar == .Denied {
                    
                    text = "No Calendar Access"
                    
                }
                
                let noDataLabel: UILabel  = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
                noDataLabel.text          = text
                noDataLabel.textColor     = UIColor.lightGray
                noDataLabel.font = UIFont.systemFont(ofSize: 18)
                noDataLabel.textAlignment = .center
                tableView.backgroundView  = noDataLabel
                tableView.separatorStyle  = .none
                if #available(iOS 11.0, *) {
                    navigationItem.largeTitleDisplayMode = .never
                }
            }
            
            return daysOfEvents.count
        }
        
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
           // tableView.deselectRow(at: indexPath, animated: true)
        }
        
        func userInfoChanged(date: Date) {
        }
    
    
    func scrollUp() {
        
        if self.tableView.numberOfSections > 0, self.tableView.numberOfRows(inSection: 0) > 0 {
            
            self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
            
        }
        
    }
    
}
    

class upcomingCell: UITableViewCell {
    
    var timer: Timer!
    
    @IBOutlet weak var endLabel: UILabel!
    @IBOutlet weak var startLabel: UILabel!
    @IBOutlet weak var titleLabel: MarqueeLabel!
    @IBOutlet weak var locationLabel: MarqueeLabel!
    @IBOutlet weak var startsInTimer: UILabel!
    let timerStringGenerator = EventCountdownTimerStringGenerator()
    var rowEvent: HLLEvent!
    let gradient = CAGradientLayer()
    
    @IBOutlet weak var calColBAr: UIView!
    
    func generate(from event: HLLEvent) {
        
        self.backgroundColor = AppTheme.current.tableCellBackgroundColor
        titleLabel.textColor = AppTheme.current.textColor
        locationLabel.textColor = AppTheme.current.secondaryTextColor
        rowEvent = event
        titleLabel.text = event.title
        startLabel.text = event.startDate.formattedTime()
        endLabel.text = event.endDate.formattedTime()
    
        startLabel.textColor = AppTheme.current.textColor
        
        endLabel.textColor = AppTheme.current.secondaryTextColor
        
        if event.startDate.formattedDate() != event.endDate.formattedDate() {
            
            endLabel.text = " "
            
        }
    
        var infoText: String?
        
        if let period = rowEvent.magdalenePeriod {
            
            infoText = "Period \(period)"
            locationLabel.isHidden = false
            
            if let location = rowEvent.location {
                
                infoText = "\(infoText!) - \(location)"
                locationLabel.isHidden = false
                
            }
            
        } else if let location = rowEvent.location {
                
                infoText = location
                locationLabel.isHidden = false
                
            } else {
                
                locationLabel.isHidden = true
                
            }
        
            
            locationLabel.text = infoText
            
        
        
        
        
        if let col = event.calendar?.cgColor {
            
            let uiCOL = UIColor(cgColor: col)
            
          //  let lighter = uiCOL.lighter(by: 13)!.cgColor
           // let darker = uiCOL.darker(by: 8)!.cgColor
            
            
            
            
           // gradient.frame = calColBAr.bounds
           // gradient.colors = [lighter, col, darker]
            
          //  calColBAr.layer.insertSublayer(gradient, at: 0)
            
            calColBAr.backgroundColor = uiCOL
            
        }
        
        titleLabel.fadeLength = 10
        locationLabel.fadeLength = 10
        
       
        
        
        DispatchQueue.main.async {
            
            self.titleLabel.marqueeType = .MLContinuous
            self.titleLabel.animationDelay = 6
            self.titleLabel.scrollDuration = 15
            
            self.titleLabel.trailingBuffer = 20
            
            
            self.locationLabel.marqueeType = .MLContinuous
            self.locationLabel.animationDelay = 6
            self.locationLabel.scrollDuration = 15
            
            self.locationLabel.trailingBuffer = 20
            
            self.titleLabel.triggerScrollStart()
            self.locationLabel.triggerScrollStart()
            
        }
        
        
    }
    
    func updateTimer() {
        
        if let countdownString = self.timerStringGenerator.generateStringFor(event: rowEvent, start: true) {
            startsInTimer.text = "\(countdownString)"
        }
        
        
    }
    
    
}

//
//  UpcomingEventStringGenerator.swift
//  How Long Left (macOS)
//
//  Created by Ryan Kontos on 1/11/18.
//  Copyright © 2019 Ryan Kontos. All rights reserved.
//

import Foundation

class UpcomingEventStringGenerator {
    
    var schoolAnalyser = SchoolAnalyser()
    
    func generateNextEventString(upcomingEvents: [HLLEvent], currentEvents: [HLLEvent], isForDoneNotification: Bool) -> String? {
        
        var returnString: String?
    
        if HLLDefaults.general.showNextEvent == true {
        
        if upcomingEvents.isEmpty == false {
            
            let nextEvent = upcomingEvents[0]
            
            var nextNonBreakEvent = nextEvent
            
            if currentEvents.isEmpty == false {
            
                if nextEvent.startDate.timeIntervalSinceNow > 1 {
                    
                    returnString = "\(nextEvent.title) starts next"
                    
                } else {
                    
                    returnString = "\(nextEvent.title) is starting now"
                    
                }
            
            if nextEvent.title.containsAnyOfThese(Strings: ["Recess","Lunch"]), SchoolAnalyser.schoolMode == .Magdalene {
                
                if let afterNextEvent = upcomingEvents[safe: 1] {
                    
                    nextNonBreakEvent = afterNextEvent
                    
                    returnString = "\(returnString!), then \(afterNextEvent.title)"
                
                }
                
            } else {
            
                if currentEvents.isEmpty == false {
                
                let currentEvent = currentEvents[0]
                
                    if currentEvent.endDate != nextEvent.startDate {
                        returnString = "\(returnString!), at \(nextEvent.startDate.formattedTime())"
                    }
               
                }
                
            }
                
            returnString = "\(returnString!)."
            
            if let nextEventLocation = nextNonBreakEvent.location, HLLDefaults.general.showLocation == true {
                
                returnString = "\(returnString!) (\(nextEventLocation))"
                
            }
            
            } else {
                
                let formatter = DateComponentsFormatter()
                var secondsLeft = nextEvent.startDate.timeIntervalSinceNow+60
                
                if secondsLeft+1 > 86400 {
                    secondsLeft += 86400
                    formatter.allowedUnits = [.day, .weekOfMonth]
                    
                } else if secondsLeft+1 > 3600 {
                    
                    formatter.allowedUnits = [.hour, .minute]
                    
                } else {
                    
                    formatter.allowedUnits = [.minute]
                    
                }
                
                formatter.unitsStyle = .full
                let countdownText = formatter.string(from: secondsLeft)!
                
                returnString = "\(nextEvent.title) starts in \(countdownText)."
                
            }
            
        } else {
            
            returnString = "No upcoming events."
            
        }
            
        }
        
        return returnString
    }
    
    func generateUpcomingEventsMenuStrings(upcoming events: [HLLEvent]) -> upcomingDayOfEvents? {
        
        var menuTitle = "No events found within the next 7 days."
        var infoItems = [String]()
        var eventItems = [String]()
        
        if events.isEmpty == false {
        
            
        var comp: DateComponents = NSCalendar.current.dateComponents([.year, .month, .day], from: Date())
        comp.timeZone = TimeZone.current
        let midnightToday = NSCalendar.current.date(from: comp)!
        
        let daysUntilUpcomingStart = Int(events[0].startDate.timeIntervalSince(midnightToday))/60/60/24
            
            let dateFormatter  = DateFormatter()
            dateFormatter.dateFormat = "EEEE"
            let formattedEnd = dateFormatter.string(from: events[0].startDate)
            
            var dayText = formattedEnd
            
            var eventsPluralised = "event"
            if events.count != 1 {
                eventsPluralised += "s"
            }
            
            switch daysUntilUpcomingStart {
            case 0:
                dayText = "Today"
                menuTitle = "On Today (\(events.count)):"
                infoItems.append("\(events.count) on \(eventsPluralised) today.")
                
                let interval = Int(events.last!.endDate.timeIntervalSinceNow)+60
                let formatter = DateComponentsFormatter()
                formatter.allowedUnits = [.hour, .minute]
                formatter.unitsStyle = .full
                
                let formattedString = formatter.string(from: TimeInterval(interval))!
                
                infoItems.append("All done in \(formattedString).")
                
            case 1:
                dayText = "Tomorrow"
                menuTitle = "Events on Tomorrow (\(events.count)):"
              //  infoItems.append("\(events.count) \(eventsPluralised) on tomorrow...")
            default:
                dayText = formattedEnd
                menuTitle = "Events on \(dayText) (\(events.count)):"
              //  infoItems.append("\(events.count) \(eventsPluralised) on \(dayText)...")
            }
            
            eventItems = generateMenuEventStrings(events: events)
         
        } else {
            
            return nil
            
        }
        
        var dayItem = upcomingDayOfEvents(rowTitle: menuTitle, eventStringItems: eventItems, eventsDate: events.first!.startDate.midnight(), events: events)
        
        dayItem.headerStrings = [menuTitle]
        
       // var arrayOfTimesWhereEventsAreOnToday = Set<Date>()
        
       /* var numberOfMinutesWithEventsOnToday = 0
        var numberOfElapsedMinutesWithEventsOnToday = 0
        
        for event in EventCache.allToday {
            
            var date = event.startDate
            
            
            print("While = \(date.timeIntervalSince(event.endDate))")
            
            while date.timeIntervalSince(event.endDate) < 0 {
                
                numberOfMinutesWithEventsOnToday += 1
                
                if date.timeIntervalSinceNow > 0 {
                    
                    numberOfElapsedMinutesWithEventsOnToday += 1
                    
                }
                
                date = date.addingTimeInterval(60)
                
                
            }
            
            
           
            
            
            
        } */
        
      //  print("Elapsed Event Minutes = \(numberOfElapsedMinutesWithEventsOnToday)")
        
       // print("Total Event Minutes = \(numberOfMinutesWithEventsOnToday)")
        
        
        EventCache.fetchQueue.async(flags: .barrier) {
        
        if let first = EventCache.allToday.first, let last = EventCache.allToday.last, first.completionStatus != .NotStarted  {
            
            let secondsElapsed = Date().timeIntervalSince(first.startDate)
            let totalSeconds = last.endDate.timeIntervalSince(first.startDate)
            let percentOfEventComplete = Int(100*secondsElapsed/totalSeconds)
            
            
           
            
            if percentOfEventComplete < 101 {
                
                dayItem.footerStrings = ["You are \(percentOfEventComplete)% through your events today."]
                
                
                
            }
            
            
            
            
        }
        
    }
        
        
        
        return dayItem
        
        
    }
    
    func generateUpcomingDayItems(days: [Date:[HLLEvent]]) -> [upcomingDayOfEvents] {
        
        var returnArray = [upcomingDayOfEvents]()
        
        for dayObject in days {
            
            
            var menuTitle = ""
            var eventItems = [String]()
            var eventsArray = [HLLEvent]()
            
            var comp: DateComponents = NSCalendar.current.dateComponents([.year, .month, .day], from: Date())
            comp.timeZone = TimeZone.current
            let midnightToday = NSCalendar.current.date(from: comp)!
            
            let daysUntilUpcomingStart = Int(dayObject.key.timeIntervalSince(midnightToday))/60/60/24
            
            let dateFormatter  = DateFormatter()
            dateFormatter.dateFormat = "EEEE"
            let formattedEnd = dateFormatter.string(from: dayObject.key)
            
            var dayText = formattedEnd
            
            var eventsPluralised = "event"
            if dayObject.value.count != 1 {
                eventsPluralised += "s"
            }
            
            switch daysUntilUpcomingStart {
            case 0:
                dayText = "Today"
                menuTitle = "Today (\(dayObject.value.count) \(eventsPluralised))"
                
                
            default:
                dayText = formattedEnd
                menuTitle = "\(dayText) (\(dayObject.value.count) \(eventsPluralised))"
            }
            
            if dayObject.value.isEmpty == false {
                
                var finalArray = [HLLEvent]()
                
                eventsArray = dayObject.value
                
                for event in eventsArray {
                    
                    if event.startDate.midnight() == dayObject.key.midnight() {
                        
                        finalArray.append(event)
                        
                    }
                    
                }
                
                eventsPluralised = "event"
                if finalArray.count != 1 {
                    eventsPluralised += "s"
                }
                
                switch daysUntilUpcomingStart {
                case 0:
                    dayText = "Today"
                    menuTitle = "Today (\(finalArray.count) \(eventsPluralised))"
                    
                    
                default:
                    dayText = formattedEnd
                    menuTitle = "\(dayText) (\(finalArray.count) \(eventsPluralised))"
                }
                
                
                
                eventItems = generateMenuEventStrings(events: finalArray)
                
                
            }
            
            returnArray.append(upcomingDayOfEvents(rowTitle: menuTitle, eventStringItems: eventItems, eventsDate: dayObject.key, events: eventsArray))
            
            
        }

        returnArray.sort(by: {
            
            $0.date.compare($1.date) == .orderedAscending
            
        })
        
       return returnArray
    }
    
    func generateMenuEventStrings(events: [HLLEvent]) -> [String] {
        
        var returnArray = [String]()
        
        let sortedEvents = events.sorted(by: { $0.startDate.compare($1.startDate) == .orderedAscending })
        
        for event in sortedEvents {
            
            var titleAndMaybeLocation = event.title
            
            if let location = event.location, HLLDefaults.general.showLocation == true {
                titleAndMaybeLocation += " (\(location))"
            }
            
            
            var eventTimeInfo = "\(event.startDate.formattedTime())-\(event.endDate.formattedTime())"
            
            if event.startDate.formattedDate() != event.endDate.formattedDate() {
                
                eventTimeInfo = "\(event.startDate.formattedTime())"
                
            }
            
            if let period = event.magdalenePeriod {
                
                eventTimeInfo = "Period \(period)"
                
            }
            
            returnArray.append("\(eventTimeInfo): \(titleAndMaybeLocation)")
            
        }
        
        return returnArray
        
    }
    
}

struct upcomingDayOfEvents {
    
    var headerStrings = [String]()
    var footerStrings = [String]()
    var menuTitle: String
    var eventStrings: [String]
    var HLLEvents: [HLLEvent]
    var nextOccurs = [HLLEvent?]()
    var date: Date
    

    
    init(rowTitle: String, eventStringItems: [String], eventsDate: Date, events: [HLLEvent]) {
        
        menuTitle = rowTitle
        eventStrings = eventStringItems
        HLLEvents = events
        date = eventsDate
        let eventNextOccurFinder = EventNextOccurenceFinder()
        
        
            for event in self.HLLEvents {
            
                let nextEvent = eventNextOccurFinder.findNextOccurrences(currentEvents: [event], upcomingEvents: EventCache.allUpcoming).first
                
                self.nextOccurs.append(nextEvent)
    
        }
            
        
        
    }
    
}


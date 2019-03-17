//
//  EventNextOccurenceFinder.swift
//  How Long Left
//
//  Created by Ryan Kontos on 30/11/18.
//  Copyright © 2019 Ryan Kontos. All rights reserved.
//

import Foundation


class EventNextOccurenceFinder {
    
    /**
     Returns the first match in upcomingEvents for each event in currentEvents
     
     */
    
    func findNextOccurrences(currentEvents: [HLLEvent], upcomingEvents: [HLLEvent]) -> [HLLEvent] {
        
        var returnEvents = [HLLEvent]()
        
        if HLLDefaults.general.showNextOccurItems == false {
            return returnEvents
        }
        
        for currentEvent in currentEvents {
            
            var comp: DateComponents = NSCalendar.current.dateComponents([.year, .month, .day], from: Date())
            comp.timeZone = TimeZone.current
            let istartDate = NSCalendar.current.date(from: comp)!
            var loopStart = Date()
            var loopEnd = Date()
            loopStart = istartDate
            loopEnd = loopStart.addingTimeInterval(86400)
            
            outer: for _ in 0...8 {
                
                for event in upcomingEvents {
                    
                    let dif = Date().timeIntervalSince(event.startDate)
                    
                    if event.title.contains(text: currentEvent.title), dif < 0, event.startDate != currentEvent.startDate {
                        returnEvents.append(event)
                        break outer
                    } else if currentEvent.title.contains(text: event.title), dif < 0, event.startDate != currentEvent.startDate {
                        returnEvents.append(event)
                        break outer
                    }
                    
                }
                
                loopStart = loopStart.addingTimeInterval(86400)
                loopEnd = loopEnd.addingTimeInterval(86400)
                
            }
            
        }
        
        return returnEvents
    }
    
    
}


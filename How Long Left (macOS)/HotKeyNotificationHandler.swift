//
//  HotKeyNotificationHandler.swift
//  How Long Left (macOS)
//
//  Created by Ryan Kontos on 7/11/19.
//  Copyright © 2020 Ryan Kontos. All rights reserved.
//

import Foundation
import UserNotifications

class HotKeyNotificationHandler {
    
    let countdownStringGenerator = CountdownStringGenerator()
    let upcomingEventStringGenerator = UpcomingEventStringGenerator()
    
    func hotKeyPressed() {
        
        var title: String?
        var subtitle: String?
        var body: String?
        
        var identifier: String?
        
        if HLLEventSource.shared.access == .Granted {
        
        title = "No events are on right now"
        
        let notification = NSUserNotification()
        notification.identifier = ""
        
        body = upcomingEventStringGenerator.generateNextEventString(upcomingEvents: HLLEventSource.shared.getUpcomingEventsFromNextDayWithEvents())
        
        if let event = HLLEventSource.shared.getPrimaryEvent() {
            
            if event.completionStatus == .Upcoming {
                body = nil
            }
            
            let currentInfo = countdownStringGenerator.generateCountdownTextFor(event: event, showEndTime: false)
            
            title = currentInfo.mainText
        
            if let percent = currentInfo.percentageText {
                subtitle = "(\(percent) Done)"
                
            }
            
            }

        } else {
            
            title = "How Long Left"
            subtitle = "No Calendar Access ⚠️"
            body = "Click to fix..."
            
            identifier = "Cal"
            
            
        }
        
        if #available(OSX 10.14, *) {
            
            let content = UNMutableNotificationContent()
            
            if let sound = HLLDefaults.notifications.soundName {
            
                content.sound = UNNotificationSound(named: UNNotificationSoundName(sound))
            }
            
            if let safeTitle = title {
                content.title = safeTitle
            }
            
            if let safeSubtitle = subtitle {
                content.subtitle = safeSubtitle
            }
                
            if let safeBody = body {
                content.body = safeBody
            }
            
            if HLLEventSource.shared.access == CalendarAccessState.Denied {
            
            content.userInfo = ["Type":"Cal"]
                
            }
            
            let calendar = Calendar.current
            let time = calendar.dateComponents([.hour, .minute, .second, .day, .month, .year], from: Date())
            let trigger = UNCalendarNotificationTrigger(dateMatching: time, repeats: false)
            let uuidString = "Scheduled \(UUID().uuidString)"
            let request = UNNotificationRequest(identifier: uuidString, content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request, withCompletionHandler: { error in })
            
        } else {
            
            let notification = NSUserNotification()
            notification.title = title
            notification.subtitle = subtitle
            notification.informativeText = body
            notification.identifier = identifier
            notification.soundName = HLLDefaults.notifications.soundName
            NSUserNotificationCenter.default.deliver(notification)
            
        }
        
    }
    
}

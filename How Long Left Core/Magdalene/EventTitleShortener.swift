//
//  EventTitleShortener.swift
//  How Long Left
//
//  Created by Ryan Kontos on 16/10/18.
//  Copyright © 2019 Ryan Kontos. All rights reserved.
//

import Foundation

class EventTitleShortener {
    
    static let shared = EventTitleShortener()
    
    func shortenTitle(events: [HLLEvent]) -> [HLLEvent] {
        
        if HLLDefaults.magdalene.shortenTitles == false {
            return events
        }
        
        var returnArray = [HLLEvent]()
        
        for eventItem in events {
        
            let event = eventItem
            
        var newTitle = event.title
        var ultraCompact: String?
        
            if event.originalTitle.contains(text:"Food Technology") {
                newTitle = "Food Tech"
                ultraCompact = "FT"
            }
            
            if event.originalTitle.contains(text:"Science") {
                newTitle = "Science"
                ultraCompact = "SCI"
            }
            
            if event.originalTitle.contains(text:"Mathematics") {
                newTitle = "Math"
            }
            
            if event.originalTitle.contains(text:"English") {
                newTitle = "English"
                ultraCompact = "ENG"
            }
            
        if SchoolAnalyser.schoolMode == .Jasmine {
            
            if event.originalTitle.contains(text:"Roll Call") {
                newTitle = "Roll Call"
            }
            
            if event.originalTitle.contains(text:"Work Education") {
                newTitle = "Work Education"
            }
            
            if event.originalTitle.contains(text:"Dance") {
                newTitle = "Dance"
            }
            
                
                
        } else {
            
        if event.originalTitle.contains(text:"Pastoral Care") {
            newTitle = "Homeroom"
            ultraCompact = "PC"
        }
        
        if event.originalTitle.contains(text:"Information Software Technology") {
            newTitle = "IST"
        }
            
        if event.originalTitle.contains(text:"Information Process Technology") {
            newTitle = "IPT"
        }
           
        if event.originalTitle.contains(text:"Design"), event.originalTitle.contains(text:"Technology")  {
            newTitle = "D&T"
        }
            
        if event.originalTitle.contains(text:"Software Design") {
            newTitle = "SDD"
        }
            
        if event.originalTitle.contains(text:"Commerce") {
            newTitle = "Commerce"
            ultraCompact = "Cmrce"
        }
            
        if event.originalTitle.contains(text:"Arts") {
            newTitle = "Art"
        }
            
        if event.originalTitle.contains(text:"Drama") {
            newTitle = "Drama"
        }
            
        if event.originalTitle.contains(text:"PASS") {
            newTitle = "PASS"
        }
        
        if event.originalTitle.contains(text:"SPORT:") {
            newTitle = "Sport"
        }
        
        if event.originalTitle.contains(text:"HSIE") {
            newTitle = "History"
            ultraCompact = "HIST"
        }
        
        if event.originalTitle.contains(text:"History") {
            newTitle = "History"
            ultraCompact = "HIST"
        }
        
        if event.originalTitle.contains(text:"History Elective") {
            newTitle = "HEL"
        }
        
        if event.originalTitle.contains(text:"Music") {
            newTitle = "Music"
        }
        
        if event.originalTitle.contains(text:"Maths") {
            newTitle = "Math"
        }
        
        if event.originalTitle.contains(text:"PDHPE") {
            newTitle = "PDHPE"
            ultraCompact = "PDH"
        }
        
        if event.originalTitle.contains(text:"Geography") {
            newTitle = "Geography"
        }
            
        if event.originalTitle.contains(text:"Geography Elective") {
            newTitle = "GEL"
        }
        
        if event.originalTitle.contains(text:"GEL") {
            newTitle = "GEL"
        }
        
        if event.originalTitle.contains(text:"Early Childhood") {
            newTitle = "EEC"
        }
            
        if event.originalTitle.contains(text:"Bussiness Studies") {
            newTitle = "Bussiness"
            ultraCompact = "BS"
        }
            
        if event.originalTitle.contains(text:"Bussiness Servies") {
            newTitle = "Bussiness"
            ultraCompact = "BS"
        }
            
        if event.originalTitle.contains(text:"IST") {
            newTitle = "IST"
        }
        
        if event.originalTitle.contains(text:"Religion") {
            newTitle = "Religion"
            ultraCompact = "RE"
        }
            
        if event.originalTitle.contains(text:"Chemistry") {
            newTitle = "Chemistry"
            ultraCompact = "Chem"
        }
            
        if event.originalTitle.contains(text:"Biology") {
            newTitle = "Biology"
            ultraCompact = "Bio"
        }
        
        if event.originalTitle.contains(text:"Physics") {
            newTitle = "Physics"
            ultraCompact = "PHYS"
        }
            
        if event.originalTitle.contains(text:"Photography") {
            newTitle = "Photography"
            ultraCompact = "PHO"
        }
          
        if event.originalTitle.contains(text:"Study") {
            newTitle = "Study"
        }
        
        if event.originalTitle.contains(text:"Drama") {
            newTitle = "Drama"
        }
            
        if event.originalTitle.contains(text:"Legal") {
            newTitle = "Legal"
        }
            
        }
            
            if newTitle != event.originalTitle {
                
                event.isSchoolEvent = true
            }
            
            
        event.title = newTitle
        event.shortTitle = newTitle
            
        if let UC = ultraCompact {
                
         event.ultraCompactTitle = UC
                
        } else {
            
        event.ultraCompactTitle = newTitle
            
        }
            
        returnArray.append(event)
            
        }
        
        return returnArray
        
    }
    
}

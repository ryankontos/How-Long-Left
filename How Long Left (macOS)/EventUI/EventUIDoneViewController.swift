//
//  EventUIDoneViewController.swift
//  How Long Left (macOS)
//
//  Created by Ryan Kontos on 12/7/19.
//  Copyright © 2019 Ryan Kontos. All rights reserved.
//

import Foundation
import Cocoa
import Lottie
import EventKit

class EventUIDoneViewController: NSViewController {
    
    @IBOutlet weak var eventLabel: NSTextField!
    @IBOutlet weak var doneAnimation: AnimationView!
    
    var parentController: EventUITabViewController!
    
    override func viewDidLoad() {
        
        parentController = (self.parent as! EventUITabViewController)
        
        if parentController.event!.completionStatus == .Done {
            
            
            print("evui done")
            doneAnimation.isHidden = false
           playDoneAnimation()
            eventLabel.stringValue = "\(parentController.event!.title) is done"
            
        } else {
            
            print("evui not running")
            doneAnimation.isHidden = true
            eventLabel.stringValue = "\(parentController.event!.title) is no longer running"
            
        }
        
       
        
    }
    
    func playDoneAnimation() {
        DispatchQueue.main.async {
            
            self.doneAnimation.animation = Animation.named("DoneAnimation")!
            self.doneAnimation.loopMode = .playOnce
            self.doneAnimation.play()
            
        }
        
    }
    
    @IBAction func closeClicked(_ sender: NSButton) {
        
        self.view.window?.performClose(nil)
        
    }
    
}

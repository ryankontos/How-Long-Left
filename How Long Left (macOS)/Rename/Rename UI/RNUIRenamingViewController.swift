//
//  RenamingViewController.swift
//  How Long Left (macOS)
//
//  Created by Ryan Kontos on 22/6/19.
//  Copyright © 2019 Ryan Kontos. All rights reserved.
//

import Foundation
import Cocoa

class RNUIRenamingViewController: NSViewController, ControllerTab, RNProcessUI {
    
    
    func processStateChanged(to: RNProcessState) {
        
        switch to {
            
        case .InProgress:
            break
        case .Failed:
            break
        case .Done:
            self.delegate?.goToIndex(3)
        }
        
    }
    

    @IBOutlet var verboseTextView: NSTextView!
    var delegate: ControllableTabView?
    
    @IBOutlet weak var label: NSTextField!
    
    @IBOutlet weak var percentLabel: NSTextField!
    @IBOutlet weak var progressBar: NSProgressIndicator!
    
    var renamer: RNProcess?
    
    override func viewDidLoad() {
        
        
        
    }
    
    override func viewWillAppear() {
        
        self.progressBar.isIndeterminate = true
        self.label.stringValue = "Finding events to rename..."
        self.percentLabel.stringValue = "0%"
        self.progressBar.doubleValue = 0.0
        self.verboseTextView.string = ""
        
        self.progressBar.startAnimation(nil)
        
        DispatchQueue.main.async {
            
            [unowned self] in
            
            self.renamer = RNProcess()
            
            self.renamer!.UIDelegate = self
            
            self.renamer!.run()
            // label.stringValue = dummy.varText
            
        }
        
    }
    
    override func viewWillDisappear() {
        renamer?.cancelled = true
        renamer = nil
    }
    
    @IBAction func canClicked(_ sender: Any) {
        renamer?.cancelled = true
        delegate?.previousPage()
        
        
    }
    
    func addLineToTextView(_ string: String) {
        
        DispatchQueue.main.async {
        
            [unowned self] in
            
            if self.verboseTextView.string.isEmpty == false {
        
                self.verboseTextView.string = "\(self.verboseTextView.string) \n\(string)"
            
        } else {
            
                self.verboseTextView.string = string
            
        }
        
            self.verboseTextView.scrollToEndOfDocument(self)
            
        }
        
    }
    
    func setStatusString(_ to: String) {
        
        DispatchQueue.main.async {
            
            [weak self] in
            
            self?.label.stringValue = to
            
        }
        
    }
    
    func setProgress(_ to: Double) {
        DispatchQueue.main.async {
            
            [weak self] in
            
            self?.progressBar.isIndeterminate = false
            print("Setting prgress to \(to)")
            
            self?.progressBar.doubleValue = to
            
            self?.percentLabel.stringValue = "\(Int(to))%"
            
        }
    }
    
    func log(_ string: String) {
        
        addLineToTextView(string)
        
    }
    
    
    func setSharedItem(to: Any) {
    }
    
    
    
}
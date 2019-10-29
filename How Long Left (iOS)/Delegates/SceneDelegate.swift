//
//  SceneDelegate.swift
//  How Long Left (iOS)
//
//  Created by Ryan Kontos on 3/10/19.
//  Copyright © 2019 Ryan Kontos. All rights reserved.
//

import Foundation
import UIKit

@available(iOS 13.0, *)
class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
      
       
        #if !targetEnvironment(macCatalyst)
        
        if let shortcutItem = connectionOptions.shortcutItem {
            
            self.handleShortcut(shortcutItem)
            
        }
        #endif
        
        #if targetEnvironment(macCatalyst)
        if let windowScene = scene as? UIWindowScene {
            if let titlebar = windowScene.titlebar {
                let toolbar = NSToolbar(identifier: "testToolbar")
                
                let rootViewController = window?.rootViewController as? UITabBarController
                rootViewController?.tabBar.isHidden = true
                
                toolbar.delegate = self
                toolbar.allowsUserCustomization = true
                toolbar.centeredItemIdentifier = NSToolbarItem.Identifier(rawValue: "testGroup")
                titlebar.titleVisibility = .hidden
                
                titlebar.toolbar = toolbar
            }
        }
        #endif
        
        
        guard let _ = (scene as? UIWindowScene) else { return }
        self.window?.makeKeyAndVisible()
    }
    

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
    
    func windowScene(_ windowScene: UIWindowScene, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        
        self.handleShortcut(shortcutItem)
        
    }
    
    private func handleShortcut(_ item: UIApplicationShortcutItem) {
        
       if let shortcutItem = ApplicationShortcut(rawValue: item.type) {
            
            switch shortcutItem {
            
            case .LaunchCurrentEvents:
                RootViewController.launchPage = .Current
            case .LaunchUpcomingEvents:
                RootViewController.launchPage = .Upcoming
            case .LaunchSettngs:
               RootViewController.launchPage = .Settings
            
        }
            
        }
            
        
    }
    
}

#if targetEnvironment(macCatalyst)
extension SceneDelegate: NSToolbarDelegate {
    func toolbar(_ toolbar: NSToolbar, itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier, willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem? {
        if (itemIdentifier == NSToolbarItem.Identifier(rawValue: "testGroup")) {
            let group = NSToolbarItemGroup.init(itemIdentifier: NSToolbarItem.Identifier(rawValue: "testGroup"), titles: ["Current", "Upcoming", "Settings"], selectionMode: .selectOne, labels: ["section1", "section2", "section3"], target: self, action: #selector(toolbarGroupSelectionChanged))
            
            group.setSelected(true, at: 0)
            
            return group
        }
        
        return nil
    }
    
    @objc func toolbarGroupSelectionChanged(sender: NSToolbarItemGroup) {
        print("testGroup selection changed to index: \(sender.selectedIndex)")
        
        let rootViewController = window?.rootViewController as? UITabBarController
        rootViewController?.selectedIndex = sender.selectedIndex
    }
    
    func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return [NSToolbarItem.Identifier(rawValue: "testGroup")]
    }
    
    func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return self.toolbarDefaultItemIdentifiers(toolbar)
    }
}
#endif
//
//  ExtensionDelegate.swift
//  Comedores UGR Watch Extension
//
//  Created by Daniel Barros López on 3/30/16.
/*
MIT License

Copyright (c) 2016 Daniel Barros

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/
//

import WatchKit

private let DefaultsLastUIUpdateKey = "DefaultsLastUIUpdateKey"


class ExtensionDelegate: NSObject, WKExtensionDelegate {
    
    let menuManager = MenuManager()
    
    var hasUpdatedUIToday: Bool {
        if let date = NSUserDefaults.standardUserDefaults().objectForKey(DefaultsLastUIUpdateKey) as? NSDate where NSCalendar.currentCalendar().isDateInToday(date) {
            return true
        }
        return false
    }
    

    func applicationDidFinishLaunching() {
        updateAppPages(with: menuManager.relevantSavedMenu)
        
        if #available(watchOSApplicationExtension 3.0, *) {
            scheduleAppUIRefreshTomorrow()
        }
    }

    
    func applicationDidBecomeActive() {
        print(#function)
        
        if #available(watchOSApplicationExtension 3.0, *) {
            
        } else {
            if hasUpdatedUIToday == false {
                updateAppPages(with: menuManager.relevantSavedMenu)
            }
        }
        if menuManager.needsToUpdateMenu || menuManager.hasUpdatedDataToday == false {
            updateMenuAndUI()
        }
    }
    

    func applicationWillResignActive() {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, etc.
    }

    
    @available(watchOSApplicationExtension 3.0, *)
    func handleBackgroundTasks(backgroundTasks: Set<WKRefreshBackgroundTask>) {
        
        var tasks = backgroundTasks
        // Menu update. If no new menu available tries update again in 4 hours
        if let task = tasks.filter({ $0 is WKApplicationRefreshBackgroundTask }).first {
            print("Updating menu")
            tasks.remove(task)
            updateMenuAndUI(completion: { updated in
                if updated == false {
                    self.scheduleAppDataRefreshNow(addingHours: 4)
                }
                task.setTaskCompleted()
            })
        }
        // UI update
        else if let task = tasks.filter({ $0 is WKSnapshotRefreshBackgroundTask }).first {
            print("Updating UI")
            tasks.remove(task)
            scheduleAppUIRefreshTomorrow()
            if self.menuManager.needsToUpdateMenu {
                scheduleAppDataRefreshNow()
            } else {
                updateAppPages(with: self.menuManager.relevantSavedMenu)
            }
            task.setTaskCompleted()
        }
        
        tasks.forEach { $0.setTaskCompleted() }
    }
}


// MARK: - Helpers

private extension ExtensionDelegate {
    
    /// Updates app UI.
    func updateAppPages(with weekMenu: [DayMenu]) {
        print(#function)
        NSUserDefaults.standardUserDefaults().setObject(NSDate(), forKey: DefaultsLastUIUpdateKey)

        if weekMenu.isEmpty {
            WKInterfaceController.reloadRootControllersWithNames([String(InterfaceController)], contexts: nil)
        } else {
            WKInterfaceController.reloadRootControllersWithNames(Array(count: weekMenu.count, repeatedValue: String(InterfaceController)), contexts: weekMenu.map(DayMenuWrapper.init(menu:)))
        }
    }
    
    
    /// Updates the menu and if there's a new one the UI is refreshed.
    func updateMenuAndUI(completion handler: ((updated: Bool) -> ())? = nil) {
        print(#function)
        let previousMenu = menuManager.savedMenu
        menuManager.updateMenu { menu in
            if let menu = menu where previousMenu == nil || previousMenu! != menu {
                mainQueue {
                    self.updateAppPages(with: self.menuManager.relevantSavedMenu)
                    handler?(updated: true)
                }
            } else {
                handler?(updated: false)
            }
        }
    }
    
    
    @available(watchOSApplicationExtension 3.0, *)
    func scheduleAppUIRefreshTomorrow() {
        print(#function)
        let tomorrow = NSCalendar.currentCalendar().startOfDayForDate(NSDate().dateByAddingTimeInterval(60*60*24+60))
        WKExtension.sharedExtension().scheduleSnapshotRefreshWithPreferredDate(tomorrow, userInfo: nil, scheduledCompletion: {_ in })
    }
    
    
    @available(watchOSApplicationExtension 3.0, *)
    func scheduleAppDataRefreshNow(addingHours hours: Double = 0) {
        print(#function)
        WKExtension.sharedExtension().scheduleBackgroundRefreshWithPreferredDate(NSDate().dateByAddingTimeInterval(60*60*hours), userInfo: nil, scheduledCompletion: { _ in })
    }
}

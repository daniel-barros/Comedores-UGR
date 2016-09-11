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
    }

    func applicationDidBecomeActive() {
        print(#function)
        
        if #available(watchOS 3.0, *) {
            // TODO: Update for watchOS 3: Update UI everyday at 00:00, update menu when necessary every x hours
            if hasUpdatedUIToday == false {
                updateAppPages(with: menuManager.relevantSavedMenu)
            }
        } else {
            if hasUpdatedUIToday == false {
                updateAppPages(with: menuManager.relevantSavedMenu)
            }
        }
        
        if menuManager.needsToUpdateMenu || menuManager.hasUpdatedDataToday == false {
            let previousMenu = menuManager.savedMenu
            menuManager.updateMenu { menu in
                if previousMenu == nil || previousMenu! != menu {
                    mainQueue {
                        self.updateAppPages(with: self.menuManager.relevantSavedMenu)
                    }
                }
            }
        }
    }

    func applicationWillResignActive() {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, etc.
    }

}


// MARK: - Helpers

private extension ExtensionDelegate {
    
    /// Updates app UI
    func updateAppPages(with weekMenu: [DayMenu]) {
        
        NSUserDefaults.standardUserDefaults().setObject(NSDate(), forKey: DefaultsLastUIUpdateKey)

        if weekMenu.isEmpty {
            WKInterfaceController.reloadRootControllersWithNames([String(InterfaceController)], contexts: nil)
        } else {
            WKInterfaceController.reloadRootControllersWithNames(Array(count: weekMenu.count, repeatedValue: String(InterfaceController)), contexts: weekMenu.map(DayMenuWrapper.init(menu:)))
        }
    }
    
}

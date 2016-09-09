//
//  InterfaceController.swift
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
import WatchConnectivity
import Foundation


class InterfaceController: WKInterfaceController {
    
    // TODO: In Swift 3.0 remove this since awakeWithContext takes Any? instead of AnyObject?
    /// Class wrapper for DayMenu struct.
    private class DayMenuWrapper {
        let menu: DayMenu
        
        init(menu: DayMenu) {
            self.menu = menu
        }
    }
    
    
    @IBOutlet weak var label: WKInterfaceLabel!
    
    let menuManager = MenuManager() // TODO: Figure this out for multiple controllers
    var menu: DayMenu?
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)

        if let menu = context as? DayMenuWrapper {
            self.menu = menu.menu
            updateUI(with: menu.menu)
        } else if let weekMenu = menuManager.savedMenu {
            updateAppPages(with: weekMenu)
//            if let menu = weekMenu.first {
//                self.menu = menu
//                updateUI(with: menu)
//            } else {
//                // TODO: Handle this case
//            }
        } else {
            // TODO: Handle this case
        }
    }
    
    
    override func willActivate() {
        super.willActivate()
        
        // TODO: Update pages every day instead of each willActivate
        if let menu = menu, date = menu.processedDate
            where date.isTodayOrFuture == false {
            if let weekMenu = menuManager.savedMenu {
                updateAppPages(with: weekMenu)
            }
        }
        
        // TODO: When to update? when context is nil in awake or menu is nil in willActivate
        if menuManager.needsToUpdateMenu || menuManager.hasUpdatedDataToday == false {
            let previousMenu = menuManager.savedMenu
            menuManager.updateMenu { [weak self] menu in
                if previousMenu == nil || previousMenu! != menu {
                    mainQueue {
                        self?.updateAppPages(with: menu)
                    }
                }
            }
        }
    }
    
    
    override func didDeactivate() {
        super.didDeactivate()
    }
}


// MARK: - Helpers

private extension InterfaceController {
    
    func updateAppPages(with weekMenu: [DayMenu]) {
        let filteredMenu = relevantWeekMenu(from: weekMenu)
        if filteredMenu.isEmpty {
            WKInterfaceController.reloadRootControllersWithNames([String(InterfaceController)], contexts: nil)
        } else {
            WKInterfaceController.reloadRootControllersWithNames(Array(count: filteredMenu.count, repeatedValue: String(InterfaceController)), contexts: filteredMenu.map(DayMenuWrapper.init(menu:)))
        }
    }
    
    
    func updateUI(with menu: DayMenu) {
        setTitle(shortDate(from: menu.date))
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.paragraphSpacing = 6
        label.setAttributedText(NSAttributedString(string: menu.allDishes, attributes: [NSParagraphStyleAttributeName: paragraphStyle]))
    }
    
    
    /// Returns a string like "Lunes 5" from one like "Lunes 5 Septiembre".
    func shortDate(from date: String) -> String {
        var dateComponents = date.componentsSeparatedByString(" ")
        dateComponents.removeLast()
        if let name = dateComponents.first, number = dateComponents.second {
            return name + " " + number
        }
        return date
    }
    
    
    /// Returns a filtered array containing only menus corresponding to today and beyond.
    func relevantWeekMenu(from weekMenu: [DayMenu]) -> [DayMenu] {
        return weekMenu.flatMap { menu -> DayMenu? in
            if let date = menu.processedDate where date.isTodayOrFuture {
                return menu
            }
            return nil
        }
    }
}

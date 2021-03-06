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


/// Shows a day menu passed as context.
class InterfaceController: WKInterfaceController {
    
    fileprivate static let showTodaysMenuNotification = Notification.Name("showTodaysMenuNotification")
    
    @IBOutlet weak var label: WKInterfaceLabel!
    @IBOutlet var errorLabel: WKInterfaceLabel!
    
    var menu: DayMenu?
    fileprivate var observer: AnyObject?
    
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)

        if let menu = context as? DayMenu {
            self.menu = menu
            updateUI(with: menu)
        } else {
            updateUI(withError: NSLocalizedString("No Menu"))
        }
        
        listenToNotifications()
    }
    
    
    deinit {
        stopListeningToNotifications()
    }
    
    
    // Called from context menu item.
    func showTodaysMenuPage() {
        NotificationCenter.default.post(name: InterfaceController.showTodaysMenuNotification, object: nil)
    }
}


// MARK: - Helpers

private extension InterfaceController {
    
    func updateUI(with menu: DayMenu) {
        setTitle(shortDate(from: menu.date))
        if menu.isClosedMenu {
            label.setHidden(true)
            errorLabel.setHidden(false)
            errorLabel.setText(menu.allDishes)
        } else {
            label.setHidden(false)
            errorLabel.setHidden(true)
            label.setAttributedText(menu.allDishes.with(paragraphSpacing: 6))
        }
        addMenuItem(withImageNamed: "LeftArrow",
                                  title: NSLocalizedString("Today"),
                                  action: #selector(showTodaysMenuPage))
    }
    
    
    func updateUI(withError message: String) {
        setTitle(NSLocalizedString("UGR Menu"))
        label.setHidden(true)
        errorLabel.setHidden(false)
        errorLabel.setText(message)
    }
    
    
    /// Observers notification which, when received, updates the current page.
    func listenToNotifications() {
        observer = NotificationCenter.default.addObserver(forName: InterfaceController.showTodaysMenuNotification, object: nil, queue: OperationQueue.main) { notification in
            if let menu = self.menu, menu.isTodayMenu {
                self.becomeCurrentPage()
            }
        }
    }
    
    
    func stopListeningToNotifications() {
        if let observer = observer {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    
    /// Returns a string like "Lunes 5" from one like "Lunes 5 Septiembre".
    func shortDate(from date: String) -> String {
        var dateComponents = date.components(separatedBy: " ")
        dateComponents.removeLast()
        if let name = dateComponents.first, let number = dateComponents.second {
            return name + " " + number
        }
        return date
    }
}


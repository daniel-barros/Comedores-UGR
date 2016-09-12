//
//  MenuManager.swift
//  Comedores UGR
//
//  Created by Daniel Barros López on 4/3/16.
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

import Foundation
import WatchConnectivity


private let DefaultsWeekMenuKey = "DefaultsWeekMenuKey"
private let DefaultsLastDataUpdateKey = "DefaultsLastDataUpdateKey"


class MenuManager: NSObject, WCSessionDelegate {
    
    private var session = WCSession.defaultSession()
    
    private var handler: ([DayMenu] -> ())?
    
    var savedMenu: [DayMenu]? {
        return NSUserDefaults.standardUserDefaults().menuForKey(DefaultsWeekMenuKey)
    }
    
    
    /// - warning: There is no guarantee that handler will be called.
    func updateMenu(responseHandler handler: [DayMenu] -> ()) {
        session.delegate = self
        session.activateSession()
        self.handler = handler
    }
    
    
    /// `true` if savedMenu is nil or corrupt, or if it's next Sunday or later.
    var needsToUpdateMenu: Bool {
        guard let menu = savedMenu, firstDate = menu.first?.processedDate else {
            return true
        }
        return NSCalendar.currentCalendar().differenceInDays(from: firstDate, to: NSDate()) > 5
    }
    
    
    var hasUpdatedDataToday: Bool {
        if let date = NSUserDefaults.standardUserDefaults().objectForKey(DefaultsLastDataUpdateKey) as? NSDate where NSCalendar.currentCalendar().isDateInToday(date) {
            return true
        }
        return false
    }
    
    
    // MARK: WCSessionDelegate

    func session(session: WCSession, didReceiveMessageData messageData: NSData) {
        if let menu = NSKeyedUnarchiver.unarchiveMenuWithData(messageData) {
            let defaults = NSUserDefaults.standardUserDefaults()
            defaults.setMenu(menu, forKey: DefaultsWeekMenuKey)
            defaults.setObject(NSDate(), forKey: DefaultsLastDataUpdateKey)
            handler?(menu)
        } else {
            print("Error: Bad data.")
        }
    }
    
    
    func session(session: WCSession, activationDidCompleteWithState activationState: WCSessionActivationState, error: NSError?) {
        if activationState == .Activated {
            session.sendMessage([:], replyHandler: nil, errorHandler: nil)
        }
    }
}

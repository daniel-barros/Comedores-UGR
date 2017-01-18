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
    
    fileprivate var session = WCSession.default()
    
    fileprivate var handler: (([DayMenu]?) -> ())?
    
    var savedMenu: [DayMenu]? {
        return UserDefaults.standard.menu(forKey: DefaultsWeekMenuKey)
    }
    
    
    func updateMenu(responseHandler handler: @escaping ([DayMenu]?) -> ()) {
        session.delegate = self
        session.activate()
        self.handler = handler
    }
    
    
    /// `true` if savedMenu is nil or corrupt, or if it's next Sunday or later.
    var needsToUpdateMenu: Bool {
        guard let menu = savedMenu, let firstDate = menu.first?.processedDate else {
            return true
        }
        return Calendar.current.differenceInDays(from: firstDate, to: Date()) > 5
    }
    
    
    var hasUpdatedDataToday: Bool {
        if let date = UserDefaults.standard.object(forKey: DefaultsLastDataUpdateKey) as? Date, Calendar.current.isDateInToday(date) {
            return true
        }
        return false
    }
    
    
    // MARK: WCSessionDelegate

    func session(_ session: WCSession, didReceiveMessageData messageData: Data) {
        if let menu = NSKeyedUnarchiver.unarchiveMenu(with: messageData) {
            let defaults = UserDefaults.standard
            defaults.setMenu(menu, forKey: DefaultsWeekMenuKey)
            defaults.set(Date(), forKey: DefaultsLastDataUpdateKey)
            handler?(menu)
        } else {
            handler?(nil)
            print("Error: Bad data.")
        }
        handler = nil
    }
    
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if activationState == .activated {
            session.sendMessage([:], replyHandler: nil, errorHandler: nil)
        } else {
            handler?(nil)
            handler = nil
        }
    }
}

extension MenuManager {
    /// Returns a filtered array containing only menus corresponding to today and beyond.
    var relevantSavedMenu: [DayMenu] {
        guard let weekMenu = savedMenu else {
            return []
        }
        return weekMenu.flatMap { menu -> DayMenu? in
            if let date = menu.processedDate, date.isTodayOrFuture {
                return menu
            }
            return nil
        }
    }
}

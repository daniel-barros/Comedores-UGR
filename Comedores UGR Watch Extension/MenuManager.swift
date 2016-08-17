//
//  MenuManager.swift
//  Comedores UGR
//
//  Created by Daniel Barros López on 4/3/16.
//  Copyright © 2016 Daniel Barros. All rights reserved.
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
        session.sendMessage([:], replyHandler: nil, errorHandler: nil)
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
}

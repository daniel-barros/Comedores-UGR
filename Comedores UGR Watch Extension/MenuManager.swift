//
//  MenuManager.swift
//  Comedores UGR
//
//  Created by Daniel Barros López on 4/3/16.
//  Copyright © 2016 Daniel Barros. All rights reserved.
//

import Foundation
import WatchConnectivity


private let DefaultsLastDataUpdateKey = "DefaultsLastDataUpdateKey"

class MenuManager: NSObject, WCSessionDelegate {
    static let defaultManager = MenuManager()
    
    var savedMenu: [DayMenu]? {
        return NSUserDefaults.standardUserDefaults().menuForKey(DefaultsWeekMenuKey)
    }
    
    private var session = WCSession.defaultSession()
    
    private override init() {
        super.init()
        NSKeyedUnarchiver.setClass(DayMenu.self, forClassName: "Comedores_UGR.DayMenu")
        NSKeyedArchiver.setClassName("Comedores_UGR.DayMenu", forClass: DayMenu.self)
    }

    
    var handler: ([DayMenu] -> ())?
    
    /// Calling this method will prevent handler closures from previous ongoing requests from being executed.
    func requestMenu(responseHandler handler: [DayMenu] -> ()) {
        session.delegate = self
        session.activateSession()
        self.handler = handler
        session.sendMessage([:], replyHandler: nil, errorHandler: nil)
    }
    
    
    var hasUpdatedDataToday: Bool {
        if let date = NSUserDefaults.standardUserDefaults().objectForKey(DefaultsLastDataUpdateKey) as? NSDate where NSCalendar.currentCalendar().isDateInToday(date) {
            return true
        }
        return false
    }
    
    
    // MARK: WCSessionDelegate

    func session(session: WCSession, didReceiveMessageData messageData: NSData) {
        if let menu = NSKeyedUnarchiver.unarchiveObjectWithData(messageData) as? [DayMenu] {
            let defaults = NSUserDefaults.standardUserDefaults()
            defaults.setObject(NSDate(), forKey: DefaultsLastDataUpdateKey)
            defaults.setMenu(menu, forKey: DefaultsWeekMenuKey)
            handler?(menu)
        } else {
            print("Error: Bad data.")
        }
    }
}

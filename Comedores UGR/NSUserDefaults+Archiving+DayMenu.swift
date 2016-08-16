//
//  NSUserDefaults+Menu.swift
//  Comedores UGR
//
//  Created by Daniel Barros López on 3/27/16.
//  Copyright © 2016 Daniel Barros. All rights reserved.
//

import Foundation


extension NSUserDefaults {
    
    func menuForKey(key: String) -> [DayMenu]? {
        if let menuData = self.dataForKey(key) {
            return NSKeyedUnarchiver.unarchiveMenuWithData(menuData)
        } else {
            return nil
        }
    }
    
    
    func setMenu(menu: [DayMenu]?, forKey key: String) {
        if let menu = menu {
            let menuData = NSKeyedArchiver.archivedMenu(menu)
            self.setObject(menuData, forKey: key)
        } else {
            self.setObject(nil, forKey: key)
        }
    }
}


extension NSKeyedUnarchiver {
    
    static func unarchiveMenuWithData(data: NSData) -> [DayMenu]? {
        guard let archivedMenu = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? [[String: AnyObject]] else {
            return nil
        }
        var ok = true
        let menu = archivedMenu.map { (dict: [String: AnyObject]) -> DayMenu in
            if let menu = DayMenu(archivedMenu: dict) {
                return menu
            } else {
                ok = false
                return DayMenu(date: "", dishes: [])
            }
        }
        if ok == false { return nil }
        return menu
    }
}


extension NSKeyedArchiver {
    
    static func archivedMenu(menu: [DayMenu]) -> NSData {
        let archivedMenu = menu.map { $0.archivableVersion }
        return archivedDataWithRootObject(archivedMenu)
    }
}


private extension DayMenu {
    
    init?(archivedMenu: [String: AnyObject]) {
        guard let date = archivedMenu["date"] as? String,
            dishes = archivedMenu["dishes"] as? [String] else {
                return nil
        }
        self.date = date
        self.dishes = dishes
        self.processedDate = DayMenu.dateFromRawString(date)
    }
    
    
    /// A representation of the menu instance that can be archived using NSKeyedArchiver.
    var archivableVersion: [String: AnyObject] {
        return ["date": date, "dishes": dishes]
    }
}

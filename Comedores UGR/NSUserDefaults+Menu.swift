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
        if let archivedMenu = self.dataForKey(key),
            menu = NSKeyedUnarchiver.unarchiveObjectWithData(archivedMenu) as? [DayMenu] {
            return menu
        } else {
            return nil
        }
    }
    
    func setMenu(menu: [DayMenu]?, forKey key: String) {
        if let menu = menu {
            let archivedMenu = NSKeyedArchiver.archivedDataWithRootObject(menu)
            self.setObject(archivedMenu, forKey: key)
        } else {
            self.setObject(nil, forKey: key)
        }
    }
}
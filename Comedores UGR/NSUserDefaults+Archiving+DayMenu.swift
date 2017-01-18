//
//  NSUserDefaults+Menu.swift
//  Comedores UGR
//
//  Created by Daniel Barros López on 3/27/16.
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


extension UserDefaults {
    
    func menu(forKey key: String) -> [DayMenu]? {
        if let menuData = self.data(forKey: key) {
            return NSKeyedUnarchiver.unarchiveMenu(with: menuData)
        } else {
            return nil
        }
    }
    
    
    func setMenu(_ menu: [DayMenu]?, forKey key: String) {
        if let menu = menu {
            let menuData = NSKeyedArchiver.archivedMenu(menu)
            self.set(menuData, forKey: key)
        } else {
            self.set(nil, forKey: key)
        }
    }
}


extension NSKeyedUnarchiver {
    
    static func unarchiveMenu(with data: Data) -> [DayMenu]? {
        guard let archivedMenu = NSKeyedUnarchiver.unarchiveObject(with: data) as? [[String: Any]] else {
            return nil
        }
        var ok = true
        let menu = archivedMenu.map { (dict: [String: Any]) -> DayMenu in
            if let menu = DayMenu(archivedMenu: dict) {
                return menu
            } else {
                ok = false
                return DayMenu(date: "", dishes: [], allergens: nil)
            }
        }
        if ok == false { return nil }
        return menu
    }
}


extension NSKeyedArchiver {
    
    static func archivedMenu(_ menu: [DayMenu]) -> Data {
        let archivedMenu = menu.map { $0.archivableVersion }
        return archivedData(withRootObject: archivedMenu)
    }
}


private extension DayMenu {
    
    init?(archivedMenu: [String: Any]) {
        guard let date = archivedMenu["date"] as? String,
            let dishes = archivedMenu["dishes"] as? [String] else {
                return nil
        }
        self.date = date
        self.dishes = dishes
        self.processedDate = DayMenu.date(fromRawString: date)
        self.allergens = archivedMenu["allergens"] as? String
    }
    
    
    /// A representation of the menu instance that can be archived using NSKeyedArchiver.
    var archivableVersion: [String: Any] {
        if let al = allergens {
            return ["date": date, "dishes": dishes, "allergens": al]
        } else {
            return ["date": date, "dishes": dishes]
        }
    }
}

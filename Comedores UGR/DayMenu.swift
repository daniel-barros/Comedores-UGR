//
//  DayMenu.swift
//  Comedores UGR
//
//  Created by Daniel Barros López on 3/25/16.
//  Copyright © 2016 Daniel Barros. All rights reserved.
//

import Foundation


class DayMenu: NSObject, NSCoding {
    let date: String    // TODO: Use NSDate instead?
    let dishes: [String]
    
    init(date: String, dishes: [String]) {
        self.date = date
        self.dishes = dishes
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let date = aDecoder.decodeObjectForKey("date") as! String
        let dishes = aDecoder.decodeObjectForKey("dishes") as! [String]
        self.init(date: date, dishes: dishes)
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(date, forKey: "date")
        aCoder.encodeObject(dishes, forKey: "dishes")
    }
}


extension CollectionType where Self: Indexable, Index == Int, Generator.Element == DayMenu {
    
    var todayMenu: DayMenu? {
        
        // Try to match NSDate to today
        let formatter = NSDateFormatter()
//        formatter.locale = NSLocale(localeIdentifier: )
        formatter.dateFormat = "MM dd DD"   // TODO: Proper format
        
        for menu in self {
            if let date = formatter.dateFromString(menu.date)
                where NSCalendar.currentCalendar().isDateInToday(date) {
                return menu
            }
        }

        // In case this fails, use current day of the week and menu index
        let weekDay = NSCalendar.currentCalendar().component(.Weekday, fromDate: NSDate())
        var index = weekDay - 2
        if index < 0 {
            index = 0
        } else if index >= self.count {
            index = self.count - 1
        }
        
        return self[index]
    }
}
//
//  DayMenu.swift
//  Comedores UGR
//
//  Created by Daniel Barros López on 3/25/16.
//  Copyright © 2016 Daniel Barros. All rights reserved.
//

import Foundation


class DayMenu: NSObject, NSCoding {
    let date: String
    let dishes: [String]
    
    init(date: String, dishes: [String]) {
        self.date = date
        self.dishes = dishes
    }
    
    
    var processedDate: NSDate? {
        let components = date.componentsSeparatedByString(" ")
        guard components.count == 3 else {
            return nil
        }
        
        if let month = monthsDict[components[0]],
            day = Int(components[1]) {
            let calendar = NSCalendar.currentCalendar()
            let year = calendar.component(.Year, fromDate: NSDate())
            
            return calendar.dateWithEra(1, year: year, month: month, day: day, hour: 0, minute: 0, second: 0, nanosecond: 0)
        }
        
        return nil
    }
    
    
    var month: String? {
        let components = date.componentsSeparatedByString(" ")
        return components.first
    }
    
    
    var dayNumber: String? {
        let components = date.componentsSeparatedByString(" ")
        guard components.count >= 2 else {
            return nil
        }

        return components[1]
    }
    
    
    var dayName: String? {
        let components = date.componentsSeparatedByString(" ")
        guard components.count >= 3 else {
            return nil
        }
        
        return components[2]
    }
    
    
    var allDishes: String {
        let string = dishes.reduce("", combine: { (total: String, dish: String) -> String in
            total + dish + "\n\n"
        })
        if string.characters.count > 2 {
            return string.substringToIndex(string.endIndex.advancedBy(-2))
        }
        return string
    }
    
    
    var isTodayMenu: Bool {
        if let date = processedDate where NSCalendar.currentCalendar().isDateInToday(date) {
            return true
        } else {
            return false
        }
    }
    
    // MARK: NSCoding
    
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


extension CollectionType where Generator.Element == DayMenu {
    
    var todayMenu: DayMenu? {
        for menu in self {
            if menu.isTodayMenu {
                return menu
            }
        }
        return nil
    }
    
    
    func containsSameWeekMenuAs(menuCollection: Self) -> Bool {
        return self.first?.processedDate != menuCollection.first?.processedDate && self.first?.processedDate != nil
    }
}

private let monthsDict = ["Enero": 1, "Febrero": 2, "Marzo": 3, "Abril": 4, "Mayo": 5, "Junio": 6,
    "Julio": 7, "Agosto": 8, "Septiembre": 9, "Octubre": 10, "Noviembre": 11, "Diciembre": 12]


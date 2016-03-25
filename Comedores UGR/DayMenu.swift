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


extension CollectionType where Self: Indexable, Index == Int, Generator.Element == DayMenu {
    
    var todayMenu: DayMenu? {
        
        let calendar = NSCalendar.currentCalendar()
        
        // Try to match NSDate to today
        for menu in self {
            if let date = menu.processedDate where calendar.isDateInToday(date) {
                return menu
            }
        }

        // In case this fails, use current day of the week and collection index
        let weekDay = calendar.component(.Weekday, fromDate: NSDate())
        let index = weekDay - 2     // Mon is weekday 2, supposed to have index 0 in collection
        if index < 0 || index >= self.count {
            return nil
        }
        return self[index]
    }
}

private let monthsDict = ["Enero": 1, "Febrero": 2, "Marzo": 3, "Abril": 4, "Mayo": 5, "Junio": 6,
    "Julio": 7, "Agosto": 8, "Septiembre": 9, "Octubre": 10, "Noviembre": 11, "Diciembre": 12]


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
    
    
    lazy var processedDate: NSDate? = {
        let components = self.date.componentsSeparatedByString(" ")
        guard components.count == 3 else {
            return nil
        }
        
        if let month = monthsDict[components[2]],
            day = Int(components[1]) {
            let calendar = NSCalendar.currentCalendar()
            let year = calendar.component(.Year, fromDate: NSDate())
            
            return calendar.dateWithEra(1, year: year, month: month, day: day, hour: 0, minute: 0, second: 0, nanosecond: 0)
        }
        
        return nil
    }()
    
    
    var month: String? {
        return date.componentsSeparatedByString(" ").third
    }
    
    
    var dayNumber: String? {
        return date.componentsSeparatedByString(" ").second
    }
    
    
    var dayName: String? {
        return date.componentsSeparatedByString(" ").first
    }
    
    
    var allDishes: String {
        return dishesStringFrom(dishes)
    }
    
    
    var isTodayMenu: Bool {
        if let date = processedDate where NSCalendar.currentCalendar().isDateInToday(date) {
            return true
        } else {
            return false
        }
    }
    
    
    /// `true` if dishes text contains a message like "CERRADO".
    var isClosedMenu: Bool {
        return dishes.count == 1 && dishes.first == "CERRADO"
    }
    
    
    override func isEqual(object: AnyObject?) -> Bool {
        if let rhs = object as? DayMenu {
            return self == rhs
        }
        return false
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


// MARK: Helpers

private extension DayMenu {
    
    func dishesStringFrom(dishesArray: [String]) -> String {
        let string = dishesArray.reduce("", combine: { (total: String, dish: String) -> String in
            total + dish + "\n"
        })
        if string.characters.count > 1 {
            return string.substringToIndex(string.endIndex.advancedBy(-1))
        }
        return string
    }
}


func ==(lhs: DayMenu, rhs: DayMenu) -> Bool {
    return lhs.date == rhs.date && lhs.dishes == rhs.dishes
}


// MARK: DayMenu collections

extension CollectionType where Generator.Element == DayMenu {
    
    var todayMenu: DayMenu? {
        for menu in self {
            if menu.isTodayMenu {
                return menu
            }
        }
        return nil
    }
}


private let monthsDict = ["Enero": 1, "Febrero": 2, "Marzo": 3, "Abril": 4, "Mayo": 5, "Junio": 6,
    "Julio": 7, "Agosto": 8, "Septiembre": 9, "Octubre": 10, "Noviembre": 11, "Diciembre": 12]


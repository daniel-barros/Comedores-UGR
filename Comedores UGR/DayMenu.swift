//
//  DayMenu.swift
//  Comedores UGR
//
//  Created by Daniel Barros López on 3/25/16.
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


struct DayMenu: Equatable {
    
    let date: String
    let dishes: [String]
    let processedDate: Date?
    let allergens: String?  // TODO: Do allergens for individual dishes
    
    
    init(date: String, dishes: [String], allergens: String?) {
        let fixedDate = date.lowercased().capitalized
        self.date = fixedDate
        self.dishes = dishes
        self.processedDate = DayMenu.date(fromRawString: fixedDate)
        self.allergens = allergens
    }
    
    
    var month: String? {
        return date.components(separatedBy: " ").fourth
    }
    
    
    var dayNumber: String? {
        return date.components(separatedBy: " ").second
    }
    
    
    var dayName: String? {
        if let day = date.components(separatedBy: " ").first {
            return day.substring(to: day.characters.index(before: day.endIndex))
        }
        return nil
    }
    
    
    var allDishes: String {
        return DayMenu.dishesString(from: dishes)
    }
    
    
    var isTodayMenu: Bool {
        if let date = processedDate, Calendar.current.isDateInToday(date) {
            return true
        } else {
            return false
        }
    }
    
    
    /// `true` if dishes text contains a message like "CERRADO".
    var isClosedMenu: Bool {
        return dishes.count == 1 && dishes.first == "CERRADO"
    }
}


// MARK: Helpers

extension DayMenu {
    
    static func dishesString(from dishesArray: [String]) -> String {
        let string = dishesArray.reduce("", { (total: String, dish: String) -> String in
            total + dish + "\n"
        })
        if string.characters.count > 1 {
            return string.substring(to: string.characters.index(string.endIndex, offsetBy: -1))
        }
        return string
    }
    
    
    /// Date from a string like "LUNES, 9 DE ENERO DE 2017".
    static func date(fromRawString dateString: String) -> Date? {
        let capitalizedDate = dateString.lowercased().capitalized
        let components = capitalizedDate.components(separatedBy: " ")
        guard components.count == 6 else {
            return nil
        }
        
        if let month = monthsDict[components[3]],
            let day = Int(components[1]) {
            let calendar = Calendar.current
            let year = calendar.component(.year, from: Date())
            return calendar.date(from: DateComponents(year: year, month: month, day: day))
        }
        
        return nil
    }
}


func ==(lhs: DayMenu, rhs: DayMenu) -> Bool {
    return lhs.date == rhs.date && lhs.dishes == rhs.dishes
}


// MARK: DayMenu collections

extension Collection where Iterator.Element == DayMenu {
    
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


//
//  WeekMenuFetcher.swift
//  Comedores UGR
//
//  Created by Daniel Barros López on 3/9/16.
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
import HTMLReader


private let DefaultsWeekMenuKey = "DefaultsWeekMenuKey"
private let DefaultsPriceKey = "DefaultsPriceKey"
private let DefaultsOpeningTimeKey = "DefaultsOpeningTimeKey"
private let DefaultsClosingTimeKey = "DefaultsClosingTimeKey"
private let DefaultsLastUpdateKey = "DefaultsLastUpdatedKey"
private let DefaultsAppVersionWhenLastUpdate = "DefaultsAppVersionWhenLastUpdate"
private let SharedDefaultsName = "group.danielbarros.comedoresUGR"


enum FetcherError: Error {
    case noInternetConnection
    case other
}


/// Fetching the menu persists it locally, and it can be accessed via the `savedMenu` property.
class WeekMenuFetcher {
    
    fileprivate struct Defaults {
        static let url = URL(string: "http://scu.ugr.es")!
        static let encoding = String.Encoding.utf8
        static let spanishLocale = Locale(identifier: "es_ES")
        static let defaultMenuPrice = 3.5
        static let defaultOpeningTime = Date(timeIntervalSinceReferenceDate: 12*60*60)
        static let defaultClosingTime = Date(timeIntervalSinceReferenceDate: 14*60*60 + 30*60)
    }
    
    var isFetching = false
    
    
    var savedMenu: [DayMenu]? {
        return sharedDefaults.menu(forKey: DefaultsWeekMenuKey)
    }
    
    
    /// `true` if savedMenu is nil or corrupt, if it's next Sunday or later, or if a new app version was just installed.
    var needsToUpdateMenu: Bool {
        guard let menu = savedMenu, let firstDate = menu.first?.processedDate else {
            return true
        }
        if let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String, appVersionWhenLastUpdate != appVersion {
            return true
        }
        return Calendar.current.differenceInDays(from: firstDate, to: Date()) > 5
    }
    
    
    /// Last time savedMenu was updated.
    var lastUpdate: Date? {
        return sharedDefaults.object(forKey: DefaultsLastUpdateKey) as? Date
    }
    
    
    var menuPrice: Double {
        return sharedDefaults.object(forKey: DefaultsPriceKey) as? Double ?? Defaults.defaultMenuPrice
    }
    
    
    var diningOpeningTime: Date {
        return sharedDefaults.object(forKey: DefaultsOpeningTimeKey) as? Date ?? Defaults.defaultOpeningTime
    }
    
    
    var diningClosingTime: Date {
        return sharedDefaults.object(forKey: DefaultsClosingTimeKey) as? Date ?? Defaults.defaultClosingTime
    }
    
    
    /// Fetches week menu **asynchronously**.
    func fetchMenu(completionHandler: @escaping ([DayMenu]) -> (), errorHandler: @escaping (FetcherError) -> ()) {
        
        isFetching = true
        URLSession.shared.dataTask(with: Defaults.url, completionHandler: {
            data, response, error in
            
            defer { self.isFetching = false }
            
            if let data = data, let htmlString = String(data: data, encoding: Defaults.encoding) {
                
                let (newMenu, price, openingTime, closingTime) = self.parseHTML(htmlString)
                
                if let price = price {
                    self.savePrice(price)
                }
                
                if let opening = openingTime, let closing = closingTime {
                    self.saveTime(opening: opening, closing: closing)
                }
                
                if let menu = newMenu {
                    self.saveMenu(menu)
                    completionHandler(menu)
                } else {
                    errorHandler(.other)
                }
                
            } else if let error = error {
                if (error as NSError).code == NSURLErrorNotConnectedToInternet {
                    errorHandler(.noInternetConnection)
                } else {
                    errorHandler(.other)
                }
            }
        }).resume()
    }    
}


// MARK: - Helpers

private extension WeekMenuFetcher {
    
    // MARK: Parsing
    
    func parseHTML(_ html: String) -> (menu: [DayMenu]?, price: Double?, opening: Date?, closing: Date?) {
        var weekMenu = [DayMenu]()
        var price: Double?
        var opening, closing: Date?
        let doc = HTMLDocument(string: html)
        
        // Menu table
        for table in doc.nodes(matchingSelector: "table[class=inline]") as! [HTMLElement] {
            var date: String?
            var dishes: [String] = []
            var drinksAndDesserts: String?
//            var allergens: String?
            
            for tr in table.nodes(matchingSelector: "tr") as! [HTMLElement] {
                var isDrinksOrDessertsRow = false
                
                for (i, td) in (tr.nodes(matchingSelector: "td") as! [HTMLElement]).enumerated() {
                    let text = td.textContent.stringByTrimmingExtraWhitespaces
                    // first column (date and labels)
                    if i == 0 {
                        if stringStartsWithSpanishWeekDay(text) {   // date row
                            // Save previous day menu
                            if let date = date {
                                if let dd = drinksAndDesserts {
                                    dishes.append(dd)
                                }
                                weekMenu.append(DayMenu(date: date, dishes: dishes, allergens: nil))
                                dishes.removeAll()
                                drinksAndDesserts = nil
//                                allergens = nil
                            }
                            date = text
                            break
                        } else if text == "Pan" {   // bread row (ignored)
                            break
                        } else if text == "Postre" || text == "Bebida" {    // drinks or desserts row
                            isDrinksOrDessertsRow = true
                        } else {    // other dishes row (primero, segundo, acompañamiento)
                            isDrinksOrDessertsRow = false
                        }
                    // second column (dishes)
                    } else if i == 1 {
                        if isDrinksOrDessertsRow {
                            if drinksAndDesserts != nil {
                                drinksAndDesserts!.append(", " + text)
                            } else {
                                drinksAndDesserts = text
                            }
                        } else {
                            dishes.append(text)
                        }
                    // third column (allergens)
                    } else if i == 2 {
//                        allergens = text
                    } else {
                        assertionFailure()
                    }
                }
            }
            if let date = date {
                if let dd = drinksAndDesserts {
                    dishes.append(dd)
                }
                weekMenu.append(DayMenu(date: date, dishes: dishes, allergens: nil))
            }
            if !weekMenu.isEmpty { break }  // found the correct table
        }
        
        // Dining hours and menu price
        if let info = doc.firstNode(matchingSelector: "ul[class=departamento]") {
            for div in info.nodes(matchingSelector: "div[class=li]") as! [HTMLElement] {
                
                let text = div.textContent.stringByTrimmingExtraWhitespaces
                if text.hasPrefix("Horario del comedor") {
                    let timeStrings = text.replacingOccurrences(of: "Horario del comedor ", with: "").components(separatedBy: " a ")
                    let formatter = spanishDateFormatter()
                    opening = formatter.date(from: timeStrings.first ?? "")
                    closing = formatter.date(from: timeStrings.second ?? "")
                }
                
                if text.hasPrefix("Precio por menú") {
                    let priceString = text.replacingOccurrences(of: "Precio por menú ", with: "").replacingOccurrences(of: "€", with: "")
                    let formatter = spanishNumberFormatter()
                    price = formatter.number(from: priceString)?.doubleValue
                }
            }
        }
        
        return (weekMenu.isEmpty ? nil : weekMenu, price, opening, closing)
    }
    
    
    func spanishDateFormatter() -> DateFormatter {
        let f = DateFormatter()
        f.locale = Defaults.spanishLocale
        f.dateStyle = .none
        f.timeStyle = .short
        return f
    }
    
    
    func spanishNumberFormatter() -> NumberFormatter {
        let f = NumberFormatter()
        f.locale = Defaults.spanishLocale
        f.numberStyle = .decimal
        return f
    }
    
    
    func spanishCalendar() -> Calendar {
        var c = Calendar(identifier: .gregorian)
        c.locale = Locale(identifier: "es_ES")
        return c
    }
    
    
    /// It is case-insensitive.
    func stringStartsWithSpanishWeekDay(_ text: String) -> Bool {
        return spanishCalendar().weekdaySymbols.contains(where: {
            if text.characters.count < $0.characters.count { return false }
            return $0.caseInsensitiveCompare(text.substring(to: $0.endIndex)) == .orderedSame })
    }
    
    
    // MARK: Persistence
    
    /// NSUserDefaults instance shared between members of the app group.
    /// - warning: Proper named app group should be activated in the target's capabilities.
    var sharedDefaults: UserDefaults {
        return UserDefaults(suiteName: SharedDefaultsName)!
    }
    
    
    var appVersionWhenLastUpdate: String? {
        return sharedDefaults.object(forKey: DefaultsAppVersionWhenLastUpdate) as? String
    }
    
    
    func saveMenu(_ menu: [DayMenu]) {
        sharedDefaults.setMenu(menu, forKey: DefaultsWeekMenuKey)
        sharedDefaults.set(Date(), forKey: DefaultsLastUpdateKey)
        if let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            sharedDefaults.set(appVersion, forKey: DefaultsAppVersionWhenLastUpdate)
        }
    }
    
    
    func savePrice(_ price: Double) {
        sharedDefaults.set(price, forKey: DefaultsPriceKey)
    }
    
    
    func saveTime(opening: Date, closing: Date) {
        sharedDefaults.set(opening, forKey: DefaultsOpeningTimeKey)
        sharedDefaults.set(closing, forKey: DefaultsClosingTimeKey)
    }
}

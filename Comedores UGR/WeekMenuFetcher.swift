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


enum FetcherError: ErrorType {
    case NoInternetConnection
    case Other
}


/// Fetching the menu persists it locally, and it can be accessed via the `savedMenu` property.
class WeekMenuFetcher {
    
    private struct Defaults {
        static let url = NSURL(string: "http://scu.ugr.es")!
        static let encoding = NSUTF8StringEncoding
        static let spanishLocale = NSLocale(localeIdentifier: "es_ES")
        static let defaultMenuPrice = 3.5
        static let defaultOpeningTime = NSDate(timeIntervalSinceReferenceDate: 12*60*60)
        static let defaultClosingTime = NSDate(timeIntervalSinceReferenceDate: 14*60*60 + 30*60)
    }
    
    var isFetching = false
    
    
    var savedMenu: [DayMenu]? {
        return sharedDefaults.menuForKey(DefaultsWeekMenuKey)
    }
    
    
    /// `true` if savedMenu is nil or corrupt, if it's next Sunday or later, or if a new app version was just installed.
    var needsToUpdateMenu: Bool {
        guard let menu = savedMenu, firstDate = menu.first?.processedDate else {
            return true
        }
        if let appVersion = NSBundle.mainBundle().infoDictionary?["CFBundleShortVersionString"] as? String
            where appVersionWhenLastUpdate != appVersion {
            return true
        }
        return NSCalendar.currentCalendar().differenceInDays(from: firstDate, to: NSDate()) > 5
    }
    
    
    /// Last time savedMenu was updated.
    var lastUpdate: NSDate? {
        return sharedDefaults.objectForKey(DefaultsLastUpdateKey) as? NSDate
    }
    
    
    var menuPrice: Double {
        return sharedDefaults.objectForKey(DefaultsPriceKey) as? Double ?? Defaults.defaultMenuPrice
    }
    
    
    var diningOpeningTime: NSDate {
        return sharedDefaults.objectForKey(DefaultsOpeningTimeKey) as? NSDate ?? Defaults.defaultOpeningTime
    }
    
    
    var diningClosingTime: NSDate {
        return sharedDefaults.objectForKey(DefaultsClosingTimeKey) as? NSDate ?? Defaults.defaultClosingTime
    }
    
    
    /// Fetches week menu **asynchronously**.
    func fetchMenu(completionHandler completionHandler: [DayMenu] -> (), errorHandler: FetcherError -> ()) {
        
        isFetching = true
        NSURLSession.sharedSession().dataTaskWithURL(Defaults.url, completionHandler: {
            data, response, error in
            
            defer { self.isFetching = false }
            
            if let data = data, htmlString = String(data: data, encoding: Defaults.encoding) {
                
                let (newMenu, price, openingTime, closingTime) = self.parseHTML(htmlString)
                
                if let price = price {
                    self.savePrice(price)
                }
                
                if let opening = openingTime, closing = closingTime {
                    self.saveTime(opening: opening, closing: closing)
                }
                
                if let menu = newMenu {
                    self.saveMenu(menu)
                    completionHandler(menu)
                } else {
                    errorHandler(.Other)
                }
                
            } else if let error = error {
                if error.code == NSURLErrorNotConnectedToInternet {
                    errorHandler(.NoInternetConnection)
                } else {
                    errorHandler(.Other)
                }
            }
        }).resume()
    }    
}


// MARK: - Helpers

private extension WeekMenuFetcher {
    
    // MARK: Parsing
    
    func parseHTML(html: String) -> (menu: [DayMenu]?, price: Double?, opening: NSDate?, closing: NSDate?) {
        var weekMenu = [DayMenu]()
        var price: Double?
        var opening, closing: NSDate?
        let doc = HTMLDocument(string: html)
        
        // Menu
        if let table = doc.firstNodeMatchingSelector("table[class=inline]") {
            var date: String?
            var dishes: [String] = []
            var allergensUrl: String?
            for td in table.nodesMatchingSelector("td") as! [HTMLElement] {
                if td.hasClass("centeralign") && td.objectForKeyedSubscript("rowspan") != nil { // date row
                    // Save previous day menu
                    if let date = date {
                        weekMenu.append(DayMenu(date: date, dishes: dishes, allergensUrl: allergensUrl))
                        dishes.removeAll(keepCapacity: true)
                    }
                    // Set date for next dishes
                    date = td.textContent
                        .stringByReplacingOccurrencesOfString("\n", withString: " ")
                        .stringByTrimmingExtraWhitespaces
                        .capitalizedString
                } else if td.hasClass("rightalign") {   // Allergens info row
                    if let url = td.firstNodeMatchingSelector("a")?.attributes["href"] as? String {
                        allergensUrl = Defaults.url.relativeString + url
                    }
                } else {    // dish row
                    dishes.append(td.textContent
                        .stringByTrimmingExtraWhitespaces)
                }
            }
            if let date = date {
                weekMenu.append(DayMenu(date: date, dishes: dishes, allergensUrl: allergensUrl))
            }
        }
        
        // Dining hours and menu price
        if let info = doc.firstNodeMatchingSelector("ul[class=departamento]") {
            for div in info.nodesMatchingSelector("div[class=li]") {
                
                let text = div.textContent.stringByTrimmingExtraWhitespaces
                if text.hasPrefix("Horario de Comedor") {
                    let timeStrings = text.stringByReplacingOccurrencesOfString("Horario de Comedor ", withString: "").componentsSeparatedByString(" a ")
                    let formatter = spanishDateFormatter()
                    opening = formatter.dateFromString(timeStrings.first ?? "")
                    closing = formatter.dateFromString(timeStrings.second ?? "")
                }
                
                if text.hasPrefix("Precio por menú") {
                    let priceString = text.stringByReplacingOccurrencesOfString("Precio por menú ", withString: "").stringByReplacingOccurrencesOfString("€", withString: "")
                    let formatter = spanishNumberFormatter()
                    price = formatter.numberFromString(priceString)?.doubleValue
                }
            }
        }
        
        return (weekMenu.isEmpty ? nil : weekMenu, price, opening, closing)
    }
    
    
    func spanishDateFormatter() -> NSDateFormatter {
        let f = NSDateFormatter()
        f.locale = Defaults.spanishLocale
        f.dateStyle = .NoStyle
        f.timeStyle = .ShortStyle
        return f
    }
    
    
    func spanishNumberFormatter() -> NSNumberFormatter {
        let f = NSNumberFormatter()
        f.locale = Defaults.spanishLocale
        f.numberStyle = .DecimalStyle
        return f
    }
    
    
    // MARK: Persistence
    
    /// NSUserDefaults instance shared between members of the app group.
    /// - warning: Proper named app group should be activated in the target's capabilities.
    var sharedDefaults: NSUserDefaults {
        return NSUserDefaults(suiteName: SharedDefaultsName)!
    }
    
    
    var appVersionWhenLastUpdate: String? {
        return sharedDefaults.objectForKey(DefaultsAppVersionWhenLastUpdate) as? String
    }
    
    
    func saveMenu(menu: [DayMenu]) {
        sharedDefaults.setMenu(menu, forKey: DefaultsWeekMenuKey)
        sharedDefaults.setObject(NSDate(), forKey: DefaultsLastUpdateKey)
        if let appVersion = NSBundle.mainBundle().infoDictionary?["CFBundleShortVersionString"] as? String {
            sharedDefaults.setObject(appVersion, forKey: DefaultsAppVersionWhenLastUpdate)
        }
    }
    
    
    func savePrice(price: Double) {
        sharedDefaults.setObject(price, forKey: DefaultsPriceKey)
    }
    
    
    func saveTime(opening opening: NSDate, closing: NSDate) {
        sharedDefaults.setObject(opening, forKey: DefaultsOpeningTimeKey)
        sharedDefaults.setObject(closing, forKey: DefaultsClosingTimeKey)
    }
}

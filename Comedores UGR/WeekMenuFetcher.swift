//
//  WeekMenuFetcher.swift
//  Comedores UGR
//
//  Created by Daniel Barros López on 3/9/16.
//  Copyright © 2016 Daniel Barros. All rights reserved.
//

import Foundation
import HTMLReader


private let DefaultsWeekMenuKey = "DefaultsWeekMenuKey"
private let DefaultsLastUpdateKey = "DefaultsLastUpdatedKey"
private let SharedDefaultsName = "group.danielbarros.comedoresUGR"


enum FetcherError: ErrorType {
    case NoInternetConnection
    case Other
}


/// Fetching the menu persists it locally, and can be accessed via the `savedMenu` property.
class WeekMenuFetcher {
    
    private struct Defaults {
        static let url = NSURL(string: "http://bahia.ugr.es/~x45909484/menu/index3.html")!  // TODO: Change to http://scu.ugr.es
        static let encoding = NSUTF8StringEncoding
    }
    
    var isFetching = false
    
    
    var savedMenu: [DayMenu]? {
        return sharedDefaults.menuForKey(DefaultsWeekMenuKey)
    }
    
    
    /// `true` if savedMenu is nil or corrupt, or if it's next Sunday or later.
    var needsToUpdateMenu: Bool {
        guard let menu = savedMenu, firstDate = menu.first?.processedDate else {
            return true
        }
        return NSCalendar.currentCalendar().differenceInDays(from: firstDate, to: NSDate()) > 5
    }
    
    
    /// Last time savedMenu was updated.
    var lastUpdate: NSDate? {
        return sharedDefaults.objectForKey(DefaultsLastUpdateKey) as? NSDate
    }
    
    
    /// Fetches week menu **asynchronously**.
    func fetchMenu(completionHandler completionHandler: [DayMenu] -> (), errorHandler: FetcherError -> ()) {
        
        isFetching = true
        NSURLSession.sharedSession().dataTaskWithURL(Defaults.url, completionHandler: {
            data, response, error in
            
            defer { self.isFetching = false }
            
            if let data = data, htmlString = String(data: data, encoding: Defaults.encoding) {
                let newMenu = self.parseHTML(htmlString)
                if newMenu.isEmpty {
                    errorHandler(.Other)
                } else {
                    self.saveMenu(newMenu)
                    completionHandler(newMenu)
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


/// MARK: Helpers

private extension WeekMenuFetcher {
    
    /// NSUserDefaults instance shared between members of the app group.
    /// - warning: Proper named app group should be activated in the target's capabilities.
    var sharedDefaults: NSUserDefaults {
        return NSUserDefaults(suiteName: SharedDefaultsName)!
    }
    

    func parseHTML(html: String) -> [DayMenu] {
        var weekMenu = [DayMenu]()
        let doc = HTMLDocument(string: html)
        
        if let table = doc.firstNodeMatchingSelector("table[class=inline]") {
            var date: String?
            var dishes: [String] = []
            for td in table.nodesMatchingSelector("td") as! [HTMLElement] {
                if td.hasClass("centeralign") && td.objectForKeyedSubscript("rowspan") != nil {
                    if let date = date {
                        weekMenu.append(DayMenu(date: date, dishes: dishes))
                        dishes.removeAll(keepCapacity: true)
                    }
                    date = td.textContent
                        .stringByReplacingOccurrencesOfString("\n", withString: " ")
                        .stringByTrimmingExtraWhitespaces
                        .capitalizedString
                } else {
                    dishes.append(td.textContent
                        .stringByTrimmingExtraWhitespaces)
                }
            }
            if let date = date {
                weekMenu.append(DayMenu(date: date, dishes: dishes))
            }
        }
        
        return weekMenu
    }
    
    
    func saveMenu(menu: [DayMenu]) {
        sharedDefaults.setMenu(menu, forKey: DefaultsWeekMenuKey)
        sharedDefaults.setObject(NSDate(), forKey: DefaultsLastUpdateKey)
    }
}

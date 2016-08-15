//
//  WeekMenuFetcher.swift
//  Comedores UGR
//
//  Created by Daniel Barros López on 3/9/16.
//  Copyright © 2016 Daniel Barros. All rights reserved.
//

import Foundation
import HTMLReader


private let DefaultsLastUpdateKey = "DefaultsLastUpdatedKey"

enum FetcherError: ErrorType {
    case NoInternetConnection
    case Other
}


/// Fetching the menu persists it locally, and can be accessed via the `savedMenu` property.
class WeekMenuFetcher {
    
    private struct Defaults {
        static let url = NSURL(string: "http://scu.ugr.es")!
        static let encoding = NSUTF8StringEncoding
    }
    
    var isFetching = false
    
    var savedMenu: [DayMenu]? {
        return NSUserDefaults.standardUserDefaults().menuForKey(DefaultsWeekMenuKey)
    }
    
    
    static var hasAlreadyFetchedToday: Bool {
        if let date = WeekMenuFetcher.lastUpdate where NSCalendar.currentCalendar().isDateInToday(date) {
            return true
        }
        return false
    }
    
    
    static var lastUpdate: NSDate? {
        return NSUserDefaults.standardUserDefaults().objectForKey(DefaultsLastUpdateKey) as? NSDate
    }
    
    
    /// Fetches week menu **asynchronously**.
    func fetchMenu(completionHandler completionHandler: [DayMenu] -> (), errorHandler: FetcherError -> ()) {
        isFetching = true
        NSURLSession.sharedSession().dataTaskWithURL(Defaults.url, completionHandler: {
            data, response, error in
            
            if let data = data, htmlString = String(data: data, encoding: Defaults.encoding) {
                let weekMenu = self.parseHTML(htmlString)
                self.persistMenu(weekMenu)
                completionHandler(weekMenu)
            } else if let error = error {
                if error.code == NSURLErrorNotConnectedToInternet {
                    errorHandler(.NoInternetConnection)
                } else {
                    errorHandler(.Other)
                }
            }
            self.isFetching = false
        }).resume()
    }
    
    
    /// Fetches week menu **synchronously**.
    /// If it fails it throws an error of type `FetcherError`.
    func fetchMenu() throws -> [DayMenu] {
        do {
            let htmlString = try String(contentsOfURL: Defaults.url, encoding: Defaults.encoding)
            let menu = parseHTML(htmlString)
            persistMenu(menu)
            return menu
        } catch {
            if (error as NSError).code == NSURLErrorNotConnectedToInternet {
                throw FetcherError.NoInternetConnection
            } else {
                throw FetcherError.Other
            }
        }
    }
    
    
    private func parseHTML(html: String) -> [DayMenu] {
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
    
    
    private func persistMenu(menu: [DayMenu]) {
        NSUserDefaults.standardUserDefaults().setMenu(menu, forKey: DefaultsWeekMenuKey)
        NSUserDefaults.standardUserDefaults().setObject(NSDate(), forKey: DefaultsLastUpdateKey)
    }
}

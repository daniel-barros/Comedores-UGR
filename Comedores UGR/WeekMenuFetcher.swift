//
//  WeekMenuFetcher.swift
//  Comedores UGR
//
//  Created by Daniel Barros López on 3/9/16.
//  Copyright © 2016 Daniel Barros. All rights reserved.
//

import Foundation
import HTMLReader


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


struct WeekMenuFetcher {
    
    private static let url = NSURL(string: "http://comedoresugr.tcomunica.org")!
    
    
    func fetchMenuAsync(completionHandler completionHandler: [DayMenu] -> (), errorHandler: ErrorType -> ()) {
        
        NSURLSession.sharedSession().dataTaskWithURL(WeekMenuFetcher.url, completionHandler: {
            data, response, error in
            
            if let data = data, htmlString = String(data: data, encoding: NSISOLatin1StringEncoding) {
                let menu = self.parseHTML(htmlString)
                completionHandler(menu)
            } else if let error = error {
                errorHandler(error)
            }
        }).resume()
    }
    
    
    func fetchMenuSync(completionHandler completionHandler: [DayMenu] -> (), errorHandler: ErrorType -> ()) {
        do {
            let htmlString = try String(contentsOfURL: WeekMenuFetcher.url, encoding: NSISOLatin1StringEncoding)
            let menu = parseHTML(htmlString)
            completionHandler(menu)
        } catch {
            errorHandler(error)
        }
    }
    
    
    private func parseHTML(html: String) -> [DayMenu] {
        var weekMenu = [DayMenu]()
        
        let doc = HTMLDocument(string: html)
        
        for node in doc.nodesMatchingSelector("#plato") as! [HTMLElement] {
            if let dateNode = node.firstNodeMatchingSelector("#diaplato"),
                dishesNode = node.firstNodeMatchingSelector("#platos") {
                // Parse date
                let date = dateNode.textContent
                    .stringByEscapingStrangeCharacters
                    .stringByReplacingOccurrencesOfString("\n", withString: " ")
                    .stringByTrimmingExtraWhitespaces
                
                // Parse dishes
                var dishesNodes = dishesNode.nodesMatchingSelector("div") as! [HTMLElement]
                dishesNodes.removeFirst()    // first one is the parent itself
                let dishes = dishesNodes.map {
                    $0.textContent
                        .stringByEscapingStrangeCharacters
                        .stringByTrimmingExtraWhitespaces
                }
                
                weekMenu.append(DayMenu(date: date, dishes: dishes))
            }
        }
        
        return weekMenu
    }
}


extension String {
    /// Returns a string without consecutive whitespaces.
    /// It also removes the first character if it is a new line.
    var stringByTrimmingExtraWhitespaces: String {
        var string = self
        if self[startIndex] == "\n" {
            string = self.substringFromIndex(startIndex.advancedBy(1))
        }
        
        let components = string.componentsSeparatedByCharactersInSet(NSCharacterSet.whitespaceCharacterSet()).filter { !$0.isEmpty }
        return components.joinWithSeparator(" ")
    }
    
    
    // TODO: Get encoding to work properly instead of doing this!
    var stringByEscapingStrangeCharacters: String {
        return stringByReplacingOccurrencesOfString("Ã¡", withString: "á")
            .stringByReplacingOccurrencesOfString("Ã³", withString: "ó")
            .stringByReplacingOccurrencesOfString("Ãº", withString: "ú")
            .stringByReplacingOccurrencesOfString("Ã±", withString: "ñ")
            .stringByReplacingOccurrencesOfString("Ã©", withString: "é")
            .stringByReplacingOccurrencesOfString("Ã", withString: "í")
    }
}

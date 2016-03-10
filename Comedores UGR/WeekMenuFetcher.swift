//
//  WeekMenuFetcher.swift
//  Comedores UGR
//
//  Created by Daniel Barros López on 3/9/16.
//  Copyright © 2016 Daniel Barros. All rights reserved.
//

import Foundation
import HTMLReader


struct DayMenu {
    let date: String    // TODO: Use NSDate instead
    let dishes: [String]
}


class WeekMenuFetcher {
    
    class func fetchMenu(completionHandler completionHandler: [DayMenu] -> (), errorHandler: ErrorType -> ()) {
        var weekMenu = [DayMenu]()
        let url = NSURL(string: "http://comedoresugr.tcomunica.org")!
        let html: String
        do {
            // TODO: Use asynchronous NSURLConnection instead
            html = try String(contentsOfURL: url, encoding: NSISOLatin1StringEncoding)
            
            let doc = HTMLDocument(string: html)
            
            // Parsing
            for node in doc.nodesMatchingSelector("#plato") as! [HTMLElement] {
                if let dateNode = node.firstNodeMatchingSelector("#diaplato"),
                dishesNode = node.firstNodeMatchingSelector("#platos") {
                    // Parse date
                    let date = dateNode.textContent
                        .stringByReplacingOccurrencesOfString("\n", withString: " ")
                        .stringByTrimmingExtraWhitespaces
                    
                    // Parse dishes
                    var dishesNodes = dishesNode.nodesMatchingSelector("div") as! [HTMLElement]
                    dishesNodes.removeFirst()    // first one is the parent itself
                    let dishes = dishesNodes.map {
                        $0.textContent.stringByTrimmingExtraWhitespaces
                    }
                    
                    weekMenu.append(DayMenu(date: date, dishes: dishes))
                }
            }
        } catch {
            errorHandler(error)
        }
        completionHandler(weekMenu)
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
}

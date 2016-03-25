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
    let date: String    // TODO: Use NSDate instead?
    let dishes: [String]
}


struct WeekMenuFetcher {
    
    private static let url = NSURL(string: "http://comedoresugr.tcomunica.org")!
    
    
    func fetchMenu(completionHandler completionHandler: [DayMenu] -> (), errorHandler: ErrorType -> ()) {

        NSURLSession.sharedSession().dataTaskWithURL(WeekMenuFetcher.url, completionHandler: {
            data, response, error in
            
            var weekMenu = [DayMenu]()

            if let data = data, htmlString = String(data: data, encoding: NSISOLatin1StringEncoding) {
                let doc = HTMLDocument(string: htmlString)
                // Parsing
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
                
                completionHandler(weekMenu)
                
            } else if let error = error {
                errorHandler(error)
            }
        }).resume()
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

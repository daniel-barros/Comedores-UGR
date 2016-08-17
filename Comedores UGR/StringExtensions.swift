//
//  StringExtensions.swift
//  Comedores UGR
//
//  Created by Daniel Barros López on 8/15/16.
//  Copyright © 2016 Daniel Barros. All rights reserved.
//

import Foundation

extension String {
    /// Returns a string without consecutive whitespaces.
    /// It also removes the first character if it is a new line or whitespace.
    var stringByTrimmingExtraWhitespaces: String {
        var string = self
        if self[startIndex] == "\n" || self[startIndex] == " " {
            string = self.substringFromIndex(startIndex.advancedBy(1))
        }
        
        let components = string.componentsSeparatedByCharactersInSet(NSCharacterSet.whitespaceCharacterSet()).filter { !$0.isEmpty }
        return components.joinWithSeparator(" ")
    }
}
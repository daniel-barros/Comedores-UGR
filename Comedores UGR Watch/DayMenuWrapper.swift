//
//  DayMenuWrapper.swift
//  Comedores UGR
//
//  Created by Daniel Barros López on 9/12/16.
//  Copyright © 2016 Daniel Barros. All rights reserved.
//

import Foundation

// TODO: In Swift 3.0 remove this since awakeWithContext takes Any? instead of AnyObject?
/// Class wrapper for DayMenu struct.
class DayMenuWrapper {
    let menu: DayMenu
    
    init(menu: DayMenu) {
        self.menu = menu
    }
}

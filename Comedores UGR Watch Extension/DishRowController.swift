//
//  MenuRowController.swift
//  Comedores UGR
//
//  Created by Daniel Barros López on 4/3/16.
//  Copyright © 2016 Daniel Barros. All rights reserved.
//

import WatchKit

class DishRowController: NSObject {

    @IBOutlet var group: WKInterfaceGroup!
    @IBOutlet var dishLabel: WKInterfaceLabel!
    
    func configure(dish dish: String, isTodayMenu: Bool) {
        dishLabel.setText(dish)
        group.setBackgroundColor(isTodayMenu ? UIColor.customDarkRedColor() : nil)
    }
}

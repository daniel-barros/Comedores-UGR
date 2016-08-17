//
//  DateRowController.swift
//  Comedores UGR
//
//  Created by Daniel Barros López on 4/3/16.
//  Copyright © 2016 Daniel Barros. All rights reserved.
//

import WatchKit

class DateRowController: NSObject {
    
    @IBOutlet var group: WKInterfaceGroup!
    @IBOutlet var dateLabel: WKInterfaceLabel!
    
    func configure(menu menu: DayMenu) {
        dateLabel.setText(menu.date)
        dateLabel.setTextColor(menu.isTodayMenu ? .customRedColor() : .customRedColor())
    }
}

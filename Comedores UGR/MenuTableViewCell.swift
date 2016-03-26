//
//  MenuTableViewCell.swift
//  Comedores UGR
//
//  Created by Daniel Barros López on 3/26/16.
//  Copyright © 2016 Daniel Barros. All rights reserved.
//

import UIKit

class MenuTableViewCell: UITableViewCell {

    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var dayNumberLabel: UILabel!
    @IBOutlet weak var dayNameLabel: UILabel!
    @IBOutlet weak var dishesLabel: UILabel!
    
    func configure(menu menu: DayMenu) {
        monthLabel.text = menu.month
        dayNumberLabel.text = menu.dayNumber
        dayNameLabel.text = menu.dayName
        dishesLabel.text = menu.allDishes
        
        if menu.isTodayMenu {
            monthLabel.textColor = UIColor.redColor()
            dayNumberLabel.textColor = UIColor.redColor()
            dayNameLabel.textColor = UIColor.redColor()
        } else {
            monthLabel.textColor = UIColor.blackColor()
            dayNumberLabel.textColor = UIColor.blackColor()
            dayNameLabel.textColor = UIColor.blackColor()
        }
    }
}

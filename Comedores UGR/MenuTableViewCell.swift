//
//  MenuTableViewCell.swift
//  Comedores UGR
//
//  Created by Daniel Barros López on 3/27/16.
//  Copyright © 2016 Daniel Barros. All rights reserved.
//

import UIKit

class MenuTableViewCell: UITableViewCell {
    
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var dayNumberLabel: UILabel!
    @IBOutlet weak var dayNameLabel: UILabel!
    @IBOutlet weak var dishLabel1: UILabel!
    @IBOutlet weak var dishLabel2: UILabel!
    @IBOutlet weak var dishLabel3: UILabel!
    
    func configure(menu menu: DayMenu) {
        monthLabel.text = menu.month
        dayNumberLabel.text = menu.dayNumber
        dayNameLabel.text = menu.dayName
        dishLabel1.text = menu.dishes.first
        dishLabel2.text = menu.dishes.second
        dishLabel3.text = menu.dishes.third
        
        // TODO: Use proper colors and font weights
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

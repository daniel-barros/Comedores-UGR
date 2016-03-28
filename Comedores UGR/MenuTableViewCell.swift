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
    
    private var dateLabels: [UILabel!] {
        return [monthLabel, dayNumberLabel, dayNameLabel]
    }
    
    func configure(menu menu: DayMenu) {
        monthLabel.text = menu.month
        dayNumberLabel.text = menu.dayNumber
        dayNameLabel.text = menu.dayName
        dishLabel1.text = menu.dishes.first
        dishLabel2.text = menu.dishes.second
        dishLabel3.text = menu.dishes.third
        
        if menu.isTodayMenu {
            dateLabels.forEach {
                $0.textColor = UIColor.customRedColor()
                let fontWeight = $0 == dayNumberLabel ? UIFontWeightLight : UIFontWeightMedium
                $0.font = UIFont.systemFontOfSize($0.font.pointSize, weight: fontWeight)
            }
        } else {
            dateLabels.forEach {
                $0.textColor = UIColor.blackColor()
                let fontWeight = $0 == dayNumberLabel ? UIFontWeightLight : UIFontWeightRegular
                $0.font = UIFont.systemFontOfSize($0.font.pointSize, weight: fontWeight)
            }
        }
    }
}


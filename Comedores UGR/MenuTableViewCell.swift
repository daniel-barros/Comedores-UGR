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
    @IBOutlet weak var dishesLabel: UILabel!
        
    private var dateLabels: [UILabel!] {
        return [monthLabel, dayNumberLabel, dayNameLabel]
    }
    
    
    func configure(menu menu: DayMenu) {
        // Text
        monthLabel.text = menu.month
        dayNumberLabel.text = menu.dayNumber
        dayNameLabel.text = menu.dayName
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.paragraphSpacing = 13.25
        let attrString = NSAttributedString(string: menu.allDishes, attributes: [NSParagraphStyleAttributeName: paragraphStyle, NSForegroundColorAttributeName: menu.isClosedMenu ? UIColor.grayColor() : UIColor.mainTextColor()])
        dishesLabel.attributedText = attrString
        
        // Today's date highlight
        if menu.isTodayMenu {
            dateLabels.forEach {
                $0.textColor = .customRedColor()
                let weight = $0 == dayNumberLabel ? UIFontWeightLight : UIFontWeightMedium
                $0.font = .systemFontOfSize($0.font.pointSize, weight: weight)
            }
        } else if menu.isClosedMenu {
            dateLabels.forEach {
                $0.textColor = .grayColor()
                let weight = $0 == dayNumberLabel ? UIFontWeightLight : UIFontWeightRegular
                $0.font = .systemFontOfSize($0.font.pointSize, weight: weight)
            }
        } else {
            dateLabels.forEach {
                $0.textColor = .blackColor()
                let weight = $0 == dayNumberLabel ? UIFontWeightLight : UIFontWeightRegular
                $0.font = .systemFontOfSize($0.font.pointSize, weight: weight)
            }
        }
    }
}


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
    
    @IBOutlet weak var dayNumberTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var dayNumberCenterConstraint: NSLayoutConstraint!
    @IBOutlet weak var dayNumberBottomConstraint: NSLayoutConstraint!
    
    private var dateLabels: [UILabel!] {
        return [monthLabel, dayNumberLabel, dayNameLabel]
    }
    
    
    func configure(menu menu: DayMenu) {
        // Text
        monthLabel.text = menu.month
        dayNumberLabel.text = menu.dayNumber
        dayNameLabel.text = menu.dayName
        dishLabel1.text = menu.dishes.first
        dishLabel2.text = menu.dishes.second
        dishLabel3.text = menu.dishes.third
        
        // Today's date highlight
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
    
    
    override func layoutSubviews() {
        // Text alignment
        switch (fixedWidthlabelHasOnlyOneLine(dishLabel1), fixedWidthlabelHasOnlyOneLine(dishLabel2), fixedWidthlabelHasOnlyOneLine(dishLabel3)) {
        case (false, true, true):
            dayNumberTopConstraint.active = false
            dayNumberCenterConstraint.active = false
            dayNumberBottomConstraint.active = true
        case (true, true, false):
            dayNumberTopConstraint.constant = -(dayNumberLabel.font.lineHeight - dayNumberLabel.font.pointSize) / 2 - (dishLabel2.font.lineHeight - dishLabel2.font.pointSize) / 2
            dayNumberTopConstraint.active = true
            dayNumberCenterConstraint.active = false
            dayNumberBottomConstraint.active = false
        default:
            dayNumberTopConstraint.active = false
            dayNumberCenterConstraint.active = true
            dayNumberBottomConstraint.active = false
        }
        
        super.layoutSubviews()
    }

    
    private func fixedWidthlabelHasOnlyOneLine(label: UILabel) -> Bool {
        if let text = label.text {
            let oneLineSize = (text as NSString).boundingRectWithSize(CGSize.max, options: [], attributes: [NSFontAttributeName: label.font], context: nil)
            if oneLineSize.width > label.frame.width {
                return false
            }
        }
        return true
    }
}


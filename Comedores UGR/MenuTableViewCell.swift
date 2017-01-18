//
//  MenuTableViewCell.swift
//  Comedores UGR
//
//  Created by Daniel Barros López on 3/27/16.
/*
MIT License

Copyright (c) 2016 Daniel Barros

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/
//

import UIKit

class MenuTableViewCell: UITableViewCell {
    
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var dayNumberLabel: UILabel!
    @IBOutlet weak var dayNameLabel: UILabel!
    @IBOutlet weak var dishesLabel: UILabel!
        
    fileprivate var dateLabels: [UILabel] {
        return [monthLabel, dayNumberLabel, dayNameLabel]
    }
    
    
    func configure(with menu: DayMenu) {
        // Text
        monthLabel.text = menu.month
        dayNumberLabel.text = menu.dayNumber
        dayNameLabel.text = menu.dayName
        
        let color = menu.isClosedMenu ? UIColor.gray : UIColor.mainTextColor
        dishesLabel.attributedText = menu.allDishes.with(color: color, paragraphSpacing: 13.25)
        
        // Today's date highlight
        if menu.isTodayMenu {
            dateLabels.forEach {
                $0.textColor = .customRedColor
                let weight = $0 == dayNumberLabel ? UIFontWeightLight : UIFontWeightMedium
                $0.font = .systemFont(ofSize: $0.font.pointSize, weight: weight)
            }
        } else if menu.isClosedMenu {
            dateLabels.forEach {
                $0.textColor = .gray
                let weight = $0 == dayNumberLabel ? UIFontWeightLight : UIFontWeightRegular
                $0.font = .systemFont(ofSize: $0.font.pointSize, weight: weight)
            }
        } else {
            dateLabels.forEach {
                $0.textColor = .black
                let weight = $0 == dayNumberLabel ? UIFontWeightLight : UIFontWeightRegular
                $0.font = .systemFont(ofSize: $0.font.pointSize, weight: weight)
            }
        }
    }
}


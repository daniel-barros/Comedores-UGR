//
//  GlanceController.swift
//  Comedores UGR Watch Extension
//
//  Created by Daniel Barros López on 3/30/16.
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

import WatchKit
import Foundation


class GlanceController: WKInterfaceController {
    
    let menuManager = MenuManager()
    
    @IBOutlet weak var image: WKInterfaceImage!
    @IBOutlet weak var dishesLabel: WKInterfaceLabel!
    @IBOutlet weak var dayNameLabel: WKInterfaceLabel!
    @IBOutlet weak var dayNumberLabel: WKInterfaceLabel!

    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        let icon = StyleKit.imageOfIconUtensils(size: CGSize(width: 40, height: 40))
        image.setImage(icon)
//        if let menu = menuManager.savedMenu {
//            updateUI(withMenu: menu.todayMenu)
//        }
    }

    
    override func willActivate() {
        super.willActivate()
        
        if let menu = menuManager.savedMenu {
            updateUI(with: menu.todayMenu)
        }
        
        if menuManager.needsToUpdateMenu || menuManager.hasUpdatedDataToday == false {
            menuManager.updateMenu { [weak self] menu in
                guard let menu = menu else {
                    return
                }
                mainQueue {
                    self?.updateUI(with: menu.todayMenu)
                }
            }
        }
    }

    
    override func didDeactivate() {
        super.didDeactivate()
    }
    
    
    func updateUI(with menu: DayMenu?) {
        // Date
        let todayComponents = Calendar.current.dateComponents([.day, .weekday], from: Date())
        dayNumberLabel.setText(String(describing: todayComponents.day))
        let formatter = DateFormatter()
        dayNameLabel.setText(formatter.shortWeekdaySymbols[todayComponents.weekday! - 1])
        
        // Dishes
        let text: String
        let paragraphStyle = NSMutableParagraphStyle()
        if let menu = menu {
            text = menu.allDishes
            dishesLabel.setVerticalAlignment(.top)
            dishesLabel.setHorizontalAlignment(.left)
            paragraphStyle.alignment = .left
        } else {
            text = NSLocalizedString("No Menu")
            dishesLabel.setVerticalAlignment(.center)
            dishesLabel.setHorizontalAlignment(.center)
            paragraphStyle.alignment = .center
        }
        
        paragraphStyle.paragraphSpacing = 6
        let attributedText = NSAttributedString(string: text, attributes: [NSParagraphStyleAttributeName: paragraphStyle])
        dishesLabel.setAttributedText(attributedText)
    }
}

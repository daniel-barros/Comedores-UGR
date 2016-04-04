//
//  GlanceController.swift
//  Comedores UGR Watch Extension
//
//  Created by Daniel Barros López on 3/30/16.
//  Copyright © 2016 Daniel Barros. All rights reserved.
//

import WatchKit
import Foundation


class GlanceController: WKInterfaceController {
    
    let menuManager = MenuManager.defaultManager
    
    @IBOutlet weak var image: WKInterfaceImage!
    @IBOutlet weak var dishesLabel: WKInterfaceLabel!
    @IBOutlet weak var dayNameLabel: WKInterfaceLabel!
    @IBOutlet weak var dayNumberLabel: WKInterfaceLabel!

    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        let icon = StyleKit.imageOfIconUtensils(size: CGSize(width: 40, height: 40))
        image.setImage(icon)
    }

    override func willActivate() {
        super.willActivate()
        
        if let menu = menuManager.savedMenu {
            updateUI(withMenu: menu.todayMenu)
            if menu.todayMenu != nil {
                return
            }
        }
        
        menuManager.requestMenu { [weak self] menu in
            mainQueue {
                self?.updateUI(withMenu: menu.todayMenu)
            }
        }
    }

    override func didDeactivate() {
        super.didDeactivate()
    }
    
    
    func updateUI(withMenu menu: DayMenu?) {
        // Date
        let todayComponents = NSCalendar.currentCalendar().components([.Day, .Weekday], fromDate: NSDate())
        dayNumberLabel.setText(String(todayComponents.day))
        let formatter = NSDateFormatter()
        dayNameLabel.setText(formatter.shortWeekdaySymbols[todayComponents.weekday - 1])
        
        // Dishes
        let text: String
        let paragraphStyle = NSMutableParagraphStyle()
        if let menu = menu {
            text = menu.allDishes.stringByReplacingOccurrencesOfString("\n\n", withString: "\n")
            paragraphStyle.alignment = .Left
        } else {
            text = NSLocalizedString("No Menu")
            paragraphStyle.alignment = .Center
        }

        paragraphStyle.paragraphSpacing = 4
//        let oneLineSize = (text as NSString).boundingRectWithSize(CGSize.max, options: [], attributes: [NSFontAttributeName: label.font], context: nil)
        let attributedText = NSAttributedString(string: text, attributes: [NSParagraphStyleAttributeName: paragraphStyle, NSFontAttributeName: UIFont.systemFontOfSize(13)])
        
        
        dishesLabel.setAttributedText(attributedText)
        dishesLabel.sizeToFitWidth()
        dishesLabel.sizeToFitHeight()
    }
}

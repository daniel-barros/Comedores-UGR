//
//  InterfaceController.swift
//  Comedores UGR Watch Extension
//
//  Created by Daniel Barros López on 3/30/16.
//  Copyright © 2016 Daniel Barros. All rights reserved.
//

import WatchKit
import WatchConnectivity
import Foundation


class InterfaceController: WKInterfaceController {

    @IBOutlet var table: WKInterfaceTable!
    
    let menuManager = MenuManager.defaultManager
    
//    private var justAwoke = false
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
//        justAwoke = true
    }

    override func willActivate() {
        super.willActivate()
                
        if let menu = menuManager.savedMenu {
            updateTable(withMenu: menu)
//            if justAwoke {
//                scrollToTodaysMenu(inWeekMenu: menu)
//                justAwoke = false
//            }
        }
        
        if menuManager.hasUpdatedDataToday == false {
            menuManager.requestMenu { [weak self] menu in
                mainQueue {
                    self?.updateTable(withMenu: menu)
//                    self?.scrollToTodaysMenu(inWeekMenu: menu)
                }
            }
        }
    }

    override func didDeactivate() {
        super.didDeactivate()
    }
    
    
    private func updateTable(withMenu weekMenu: [DayMenu]) {
        var rowTypes = [String]()
        for menu in weekMenu {
            rowTypes.append(String(DateRowController))
            for _ in menu.dishes {
                rowTypes.append(String(DishRowController))
            }
        }
        
        table.setRowTypes(rowTypes)
        
        var index = 0
        for menu in weekMenu {
            let dateRowController = table.rowControllerAtIndex(index) as! DateRowController
            dateRowController.dateLabel.setText(menu.date)
            dateRowController.group.setBackgroundColor(menu.isTodayMenu ? UIColor.customRedColor() : UIColor.customDarkRedColor())
            index += 1
            for dish in menu.dishes {
                let dishRowController = table.rowControllerAtIndex(index) as! DishRowController
                dishRowController.dishLabel.setText(dish)
                index += 1
            }
        }
    }
    
    
//    private func scrollToTodaysMenu(inWeekMenu weekMenu: [DayMenu]) {
//        var index = 0
//        for menu in weekMenu {
//            if menu.isTodayMenu {
//                break
//            }
//            index += 1 + menu.dishes.count
//        }
//        table.scrollToRowAtIndex(index + 2)
//    }
}

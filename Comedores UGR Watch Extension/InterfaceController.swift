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


//  TODO: Pull to refresh
class InterfaceController: WKInterfaceController {

    @IBOutlet var table: WKInterfaceTable!
    
    let menuManager = MenuManager.defaultManager
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        if menuManager.savedMenu == nil {
            // TODO: No data / Empty screen
        }
    }

    override func willActivate() {
        super.willActivate()
                
        if let menu = menuManager.savedMenu {
            updateTable(withMenu: menu)
        }
        
        if menuManager.hasUpdatedDataToday == false {
            // TODO: Updating wheel
            menuManager.requestMenu { [weak self] menu in
                self?.updateTable(withMenu: menu)
            }
        }
        
        // TODO: Scroll to today's menu
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
            index += 1
            for dish in menu.dishes {
                let dishRowController = table.rowControllerAtIndex(index) as! DishRowController
                dishRowController.dishLabel.setText(dish)
                dishRowController.group.setBackgroundColor(menu.isTodayMenu ? UIColor.customDarkRedColor() : nil)
                index += 1
            }
        }
    }

}

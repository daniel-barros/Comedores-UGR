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
    
    let menuManager = MenuManager()
    
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
//        if let menu = menuManager.savedMenu {
//            updateTable(withMenu: menu)
//        }
    }
    

    override func willActivate() {
        super.willActivate()
        
        if let menu = menuManager.savedMenu {
            updateTable(withMenu: menu)
        }
        
        if menuManager.needsToUpdateMenu || menuManager.hasUpdatedDataToday == false {
            menuManager.updateMenu { [weak self] menu in
                mainQueue {
                    self?.updateTable(withMenu: menu)
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
            dateRowController.configure(menu: menu)
            index += 1
            for dish in menu.dishes {
                let dishRowController = table.rowControllerAtIndex(index) as! DishRowController
                dishRowController.configure(dish: dish, isTodayMenu: menu.isTodayMenu)
                index += 1
            }
        }
    }
}

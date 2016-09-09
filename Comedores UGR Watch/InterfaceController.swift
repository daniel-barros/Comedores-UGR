//
//  InterfaceController.swift
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
import WatchConnectivity
import Foundation


class InterfaceController: WKInterfaceController {

    @IBOutlet var table: WKInterfaceTable!
    var todayRowIndex: Int?
    
    let menuManager = MenuManager()
    
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        if let menu = menuManager.savedMenu {
            updateUI(with: menu)
        }
    }
    

    override func willActivate() {
        super.willActivate()
        
        //if dayChanged { updateUI(with: menu) } 
        
        if menuManager.needsToUpdateMenu || menuManager.hasUpdatedDataToday == false {
            menuManager.updateMenu { [weak self] menu in
                mainQueue {
                    self?.updateUI(with: menu)
                }
            }
        }
    }
    

    override func didDeactivate() {
        super.didDeactivate()
    }
}


// MARK: - Helpers
private extension InterfaceController {
    
    func updateUI(with weekMenu: [DayMenu]) {
        updateTable(with: weekMenu)
//        updateTableScrollPosition()
    }
    
    
    func updateTableScrollPosition() {
        if let index = todayRowIndex {
            print(#function, index)
            table.scrollToRowAtIndex(index)
        }
    }
    
    
    func updateTable(with weekMenu: [DayMenu]) {
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
            if menu.isTodayMenu {
                todayRowIndex = index
            }
            let dateRowController = table.rowControllerAtIndex(index) as! DateRowController
            dateRowController.configure(with: menu.date, isToday: menu.isTodayMenu)
            index += 1
            for dish in menu.dishes {
                let dishRowController = table.rowControllerAtIndex(index) as! DishRowController
                dishRowController.configure(with: dish, isToday: menu.isTodayMenu)
                index += 1
            }
        }
    }
}

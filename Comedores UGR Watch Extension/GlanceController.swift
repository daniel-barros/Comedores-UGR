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
    
    @IBOutlet weak var label: WKInterfaceLabel!

    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
    }

    override func willActivate() {
        super.willActivate()
        
//        if let menu = menuManager.savedMenu, todayMenu = menu.todayMenu {
//            updateUIWithMenu(todayMenu)
//            return
//        }
//
//        menuManager.requestMenu { [weak self] menu in
//            mainQueue {
//                self?.updateUIWithMenu(menu)
//            }
//        }
    }

    override func didDeactivate() {
        super.didDeactivate()
    }
    
    
    func updateUIWithMenu(menu: DayMenu) {
        label.setText(menu.allDishes)
    }
}

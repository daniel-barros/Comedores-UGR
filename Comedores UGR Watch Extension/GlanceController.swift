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
    @IBOutlet weak var label: WKInterfaceLabel!

    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        let icon = StyleKit.imageOfIconUtensils(size: CGSize(width: 46, height: 46))
        image.setImage(icon)
    }

    override func willActivate() {
        super.willActivate()
        
        if let menu = menuManager.savedMenu {
            if let todayMenu = menu.todayMenu {
                updateUIWithMenu(todayMenu)
                return
            } else {
                updateUIWithMenu(nil)
            }
        }
        
        menuManager.requestMenu { [weak self] menu in
            mainQueue {
                self?.updateUIWithMenu(menu.todayMenu)
            }
        }
    }

    override func didDeactivate() {
        super.didDeactivate()
    }
    
    
    func updateUIWithMenu(menu: DayMenu?) {
        
        let text: String
        let paragraphStyle = NSMutableParagraphStyle()
        if let menu = menu {
            text = menu.allDishes
            paragraphStyle.alignment = .Left
        } else {
            text = NSLocalizedString("No Menu")
            paragraphStyle.alignment = .Center
        }

        let attributedText = NSAttributedString(string: text, attributes: [NSParagraphStyleAttributeName: paragraphStyle])
        label.setAttributedText(attributedText)
    }
}

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
    
    @IBOutlet weak var label: WKInterfaceLabel!
    @IBOutlet var errorLabel: WKInterfaceLabel!
    
    let menuManager = MenuManager() // TODO: Figure this out for multiple controllers
    var menu: DayMenu?
    
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)

        if let menu = context as? DayMenuWrapper {
            self.menu = menu.menu
            updateUI(with: menu.menu)
        } else {
            updateUI(withError: NSLocalizedString("No Menu"))
        }
    }
    
    
    override func willActivate() {
        super.willActivate()
    }
    
    
    override func didDeactivate() {
        super.didDeactivate()
    }
}


// MARK: - Helpers

private extension InterfaceController {
    
    func updateUI(with menu: DayMenu) {
        setTitle(shortDate(from: menu.date))
        label.setHidden(false)
        errorLabel.setHidden(true)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.paragraphSpacing = 6
        label.setAttributedText(NSAttributedString(string: menu.allDishes, attributes: [NSParagraphStyleAttributeName: paragraphStyle]))
    }
    
    
    func updateUI(withError message: String) {
        setTitle(NSLocalizedString("UGR Menu"))
        label.setHidden(true)
        errorLabel.setHidden(false)
        errorLabel.setText(message)
    }
    
    
    /// Returns a string like "Lunes 5" from one like "Lunes 5 Septiembre".
    func shortDate(from date: String) -> String {
        var dateComponents = date.componentsSeparatedByString(" ")
        dateComponents.removeLast()
        if let name = dateComponents.first, number = dateComponents.second {
            return name + " " + number
        }
        return date
    }
}


//
//  TodayViewController.swift
//  Comedores UGR Widget
//
//  Created by Daniel Barros López on 3/25/16.
//  Copyright © 2016 Daniel Barros. All rights reserved.
//

import UIKit
import NotificationCenter

// TODO: Create a Tomorrow Menu widget too
// TODO: Hide from NC in some cases (Sundays, holidays?): use setHasContent(_:forWidgetWithBundleIdentifier:) and a local notification that triggers the call in the parent app
// TODO: Fix Autolayout constraints error
class TodayViewController: UIViewController, NCWidgetProviding {
    
    @IBOutlet weak var label: UILabel!
    
    private let fetcher = WeekMenuFetcher()
    
    var weekMenu: [DayMenu] = {
        if let archivedMenu = NSUserDefaults.standardUserDefaults().dataForKey(DefaultsWeekMenuKey),
            menu = NSKeyedUnarchiver.unarchiveObjectWithData(archivedMenu) as? [DayMenu] {
            return menu
        } else {
            return [DayMenu]()
        }
    }() {
        didSet {
            guard weekMenu.isEmpty == false else {
                return
            }
            let archivedMenu = NSKeyedArchiver.archivedDataWithRootObject(weekMenu)
            NSUserDefaults.standardUserDefaults().setObject(archivedMenu, forKey: DefaultsWeekMenuKey)
            NSUserDefaults.standardUserDefaults().setObject(NSDate(), forKey: DefaultsLastUpdatedKey)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
    }
    
    
    var alreadyFetchedToday: Bool {
        if let lastUpdated = NSUserDefaults.standardUserDefaults().objectForKey(DefaultsLastUpdatedKey) as? NSDate where NSCalendar.currentCalendar().isDateInToday(lastUpdated) {
            return true
        }
        return false
    }
    
    
    private func updateUI(error error: ErrorType? = nil) {
        if let dishes = weekMenu.todayMenu?.allDishes {
            label.text = dishes
        } else if alreadyFetchedToday == false {
            label.text = "Cargando..."
        } else if let error = error {
            // TODO: Handle error
            label.text = "Error: \(error)"
        } else {
            label.text = "No hay menú"
//            label.text = weekMenu.first?.allDishes
        }
    }
    
    
    @IBAction func openApp(sender: AnyObject) {
        extensionContext?.openURL(NSURL(string: "comedoresugr://")!, completionHandler: nil)
    }
    
    
    func widgetPerformUpdateWithCompletionHandler(completionHandler: ((NCUpdateResult) -> Void)) {
        
        if alreadyFetchedToday {
            updateUI()
            completionHandler(.NoData)
        } else {
            // TODO: Sure you should to it synchronously here?
            fetcher.fetchMenuSync(completionHandler: { menu in
                self.weekMenu = menu
                self.updateUI()
                completionHandler(.NewData)
            }, errorHandler: { error in
                self.updateUI(error: error)
                completionHandler(.Failed)
            })
        }
    }
    
    
    func widgetMarginInsetsForProposedMarginInsets(defaultMarginInsets: UIEdgeInsets) -> UIEdgeInsets {
        var insets = defaultMarginInsets
        insets.top = 14
        return insets
    }
}

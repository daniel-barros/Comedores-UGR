//
//  TodayViewController.swift
//  Comedores UGR Widget
//
//  Created by Daniel Barros López on 3/25/16.
//  Copyright © 2016 Daniel Barros. All rights reserved.
//

import UIKit
import NotificationCenter

// TODO: Improve UI
// TODO: Differentiate between a connection error and no menu today
// TODO: Create a Tomorrow Menu widget too
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
    
    
    private func updateUI() {
        label.text = weekMenu.todayMenu?.allDishes ?? "No Hay Menú"
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
                print(error)
                if self.weekMenu.isEmpty {
                    // TODO: Handle error
                    print(error)
                } else {
                    self.updateUI()
                }
                completionHandler(.Failed)
            })
        }
    }
    
    
    //    func widgetMarginInsetsForProposedMarginInsets(defaultMarginInsets: UIEdgeInsets) -> UIEdgeInsets {
    //
    //    }
}

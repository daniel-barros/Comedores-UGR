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
// TODO: Tap on widget should open the app
class TodayViewController: UIViewController, NCWidgetProviding {
    
    @IBOutlet weak var label: UILabel!
    
    private let fetcher = WeekMenuFetcher()
    
    var weekMenu: [DayMenu] = {
        if let archivedMenu = NSUserDefaults.standardUserDefaults().dataForKey("weekMenu"),
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
            NSUserDefaults.standardUserDefaults().setObject(archivedMenu, forKey: "weekMenu")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
    }
    
    
    private func updateUI() {
        label.text = weekMenu.todayMenu?.allDishes ?? "No Menu"
    }
    
    
    @IBAction func openApp(sender: AnyObject) {
        extensionContext?.openURL(NSURL(string: "comedoresugr://")!, completionHandler: nil)
    }
    
    
    func widgetPerformUpdateWithCompletionHandler(completionHandler: ((NCUpdateResult) -> Void)) {
        
        // TODO: Sure you should to it synchronously here?
        fetcher.fetchMenuSync(completionHandler: { menu in
            self.weekMenu = menu
            self.updateUI()
            completionHandler(.NewData)
            }, errorHandler: { error in
                // TODO: Handle error
                print(error)
                completionHandler(.Failed)
        })
        
        // TODO: If there's no update required, use NCUpdateResult.NoData
    }
    
    
    //    func widgetMarginInsetsForProposedMarginInsets(defaultMarginInsets: UIEdgeInsets) -> UIEdgeInsets {
    //
    //    }
}

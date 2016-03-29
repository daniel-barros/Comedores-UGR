//
//  TodayViewController.swift
//  Comedores UGR Widget
//
//  Created by Daniel Barros López on 3/25/16.
//  Copyright © 2016 Daniel Barros. All rights reserved.
//

import UIKit
import NotificationCenter

// TODO: Fix Autolayout constraints error
class TodayViewController: UIViewController, NCWidgetProviding {
    
    @IBOutlet weak var label: UILabel!
    
    private let fetcher = WeekMenuFetcher()
    
    var weekMenu: [DayMenu] = {
        return NSUserDefaults.standardUserDefaults().menuForKey(DefaultsWeekMenuKey) ?? [DayMenu]()
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
    }
    
    
    /// Updates `weekMenu` from current user defaults value.
    /// Returns `true` if the menu changed, `false otherwise.
    private func updateMenu() -> Bool {
        if let newMenu = NSUserDefaults.standardUserDefaults().menuForKey(DefaultsWeekMenuKey)
            where weekMenu.containsSameWeekMenuAs(newMenu) == false {
            weekMenu = newMenu
            return true
        }
        return false
    }
    
    
    private func updateUI(error error: FetcherError? = nil) {
        if let dishes = weekMenu.todayMenu?.allDishes {
            label.text = dishes
        } else if fetcher.hasAlreadyFetchedToday == false {
            label.text = NSLocalizedString("Loading...")
        } else if let error = error {
            switch error {
            case .NoInternetConnection:
                label.text = NSLocalizedString("No Connection")
            case .Other:
                label.text = NSLocalizedString("Error")
            }
        } else {
            label.text = NSLocalizedString("No Menu")
//            label.text = weekMenu.first?.allDishes
        }
    }
    
    
    /// Opens parent app.
    @IBAction func openApp(sender: AnyObject) {
        extensionContext?.openURL(NSURL(string: "comedoresugr://")!, completionHandler: nil)
    }
    
    
    // MARK: NCWidgetProviding
    
    func widgetPerformUpdateWithCompletionHandler(completionHandler: ((NCUpdateResult) -> Void)) {
        
        if fetcher.hasAlreadyFetchedToday {
            if updateMenu() {
                updateUI()
                completionHandler(.NewData)
            } else {
                completionHandler(.NoData)
            }
        } else {
            // TODO: Sure you should to it synchronously here?
            do {
                weekMenu = try fetcher.fetchMenu()
                updateUI()
                completionHandler(.NewData)
            } catch {
                updateUI(error: (error as! FetcherError))
                completionHandler(.Failed)
            }
        }
    }
    
    
//    func widgetMarginInsetsForProposedMarginInsets(defaultMarginInsets: UIEdgeInsets) -> UIEdgeInsets {
//        var insets = defaultMarginInsets
////        insets.top = 14
//        return insets
//    }
}

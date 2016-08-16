//
//  TodayViewController.swift
//  Comedores UGR Widget
//
//  Created by Daniel Barros López on 3/25/16.
//  Copyright © 2016 Daniel Barros. All rights reserved.
//

import UIKit
import NotificationCenter


class TodayViewController: UIViewController, NCWidgetProviding {
    
    @IBOutlet weak var label: UILabel!
    
    private let fetcher = WeekMenuFetcher()
    
    var weekMenu = [DayMenu]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        weekMenu = fetcher.savedMenu ?? []
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        updateUI()
    }
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        view.layoutIfNeeded()   // Fixes top margin glitch
    }
    
    
    /// Opens main app.
    @IBAction func openApp(sender: AnyObject) {
        extensionContext?.openURL(NSURL(string: "comedoresugr://")!, completionHandler: nil)
    }
    
    
    // MARK: NCWidgetProviding
    
    func widgetPerformUpdateWithCompletionHandler(completionHandler: ((NCUpdateResult) -> Void)) {
        if let savedMenu = fetcher.savedMenu where savedMenu != weekMenu {
            weekMenu = savedMenu
            updateUI()
            completionHandler(.NewData)
        } else if fetcher.needsToUpdateMenu {
            completionHandler(.NoData)
            fetcher.fetchMenu(completionHandler: { newMenu in
                self.weekMenu = newMenu
                self.updateUI()
                completionHandler(.NewData) // TODO: Remove?
            }, errorHandler: { error in
                self.updateUI(error: error)
                completionHandler(.Failed)  // TODO: Remove?
            })
        } else {
            updateUI()  // Updates today's menu even if week menu didn't change
            completionHandler(.NoData)
        }
    }
    
    
    func widgetMarginInsetsForProposedMarginInsets(defaultMarginInsets: UIEdgeInsets) -> UIEdgeInsets {
        var insets = defaultMarginInsets
        insets.top = 10
        insets.right = 8
        insets.bottom = 20
        return insets
    }
}


// MARK: Helpers

private extension TodayViewController {
    
    private func updateUI(error error: FetcherError? = nil) {
        if let dishes = weekMenu.todayMenu?.allDishes {
            label.text = dishes.stringByReplacingOccurrencesOfString("\n", withString: "\n\n")
        } else if let error = error {
            switch error {
            case .NoInternetConnection:
                label.text = NSLocalizedString("No Connection")
            case .Other:
                label.text = NSLocalizedString("Error")
            }
        } else {
            label.text = NSLocalizedString("No Menu")
        }
    }
}


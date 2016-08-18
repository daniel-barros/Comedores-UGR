//
//  TodayViewController.swift
//  Comedores UGR Widget
//
//  Created by Daniel Barros López on 3/25/16.
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
        if let savedMenu = fetcher.savedMenu {
            weekMenu = savedMenu
        }
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
        // Menu was updated externally and changes need to be reflected in UI
        if let savedMenu = fetcher.savedMenu where savedMenu != weekMenu {
            weekMenu = savedMenu
            updateUI()
            completionHandler(.NewData)
        // Menu needs to be updated
        } else if fetcher.needsToUpdateMenu {
            completionHandler(.NoData)
            fetcher.fetchMenu(completionHandler: { newMenu in
                self.weekMenu = newMenu
                mainQueue {
                    self.updateUI()
                    completionHandler(.NewData) // TODO: Remove?
                }
            }, errorHandler: { error in
                mainQueue {
                    self.updateUI(error: error)
                    completionHandler(.Failed)  // TODO: Remove?
                }
            })
        // Menu is up to date
        } else {
            updateUI()  // Updates today's menu even if week menu didn't change
            completionHandler(.NoData)
        }
    }
    
    
    func widgetMarginInsetsForProposedMarginInsets(defaultMarginInsets: UIEdgeInsets) -> UIEdgeInsets {
        var insets = defaultMarginInsets
        insets.top = 10
        insets.right = 8
        insets.bottom = 28
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


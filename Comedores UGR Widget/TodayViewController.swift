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
    
    @IBOutlet weak var label: UILabel!  // Used for displaying menu, and error messages in iOS 9.
    @IBOutlet weak var errorLabel: UILabel! // Used for displaying error messages only from iOS 10 and on.
    
    @IBOutlet weak var labelLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var labelTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var labelTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var labelBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var labelAlternateBottomConstraint: NSLayoutConstraint!  // A >= constraint used in iOS 10.
    
    fileprivate let fetcher = WeekMenuFetcher()
    
    var weekMenu = [DayMenu]()
    var displayedMenu: DayMenu?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        weekMenu = fetcher.savedMenu ?? []
        
        setUpLabels()
        updateUI()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let savedMenu = fetcher.savedMenu {
            weekMenu = savedMenu
        }
        if displayedMenu == nil || displayedMenu != weekMenu.todayMenu {
            updateUI()
            if #available(iOSApplicationExtension 10.0, *) {
                if let context = extensionContext {
                    updatePreferredContentSize(withMaximumSize: context.widgetMaximumSize(for: context.widgetActiveDisplayMode))
                }
            }
        }
        
        if #available(iOSApplicationExtension 10.0, *) {    // This is not inside previous if because it needs to be called right after viewDidLoad()
            updateAvailableDisplayModes()
        }
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if #available(iOS 10, *) {} else {
            view.layoutIfNeeded()   // Fixes top margin glitch in iOS 9 (sort of).
        }
    }
    
    
    /// Opens main app.
    @IBAction func openApp(_ sender: AnyObject) {
        extensionContext?.open(URL(string: "comedoresugr://")!, completionHandler: nil)
    }
    
    
    // MARK: NCWidgetProviding
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        
        func updateUIAndDisplayModes(with error: FetcherError? = nil) {
            updateUI(with: error)
            if #available(iOSApplicationExtension 10.0, *) {
                updateAvailableDisplayModes()
                if let context = extensionContext {
                    updatePreferredContentSize(withMaximumSize: context.widgetMaximumSize(for: context.widgetActiveDisplayMode))
                }
            }
        }
        
        // Menu was updated externally and changes need to be reflected in UI
        if let savedMenu = fetcher.savedMenu, savedMenu != weekMenu {
            weekMenu = savedMenu
            updateUIAndDisplayModes()
            completionHandler(.newData)
        // Menu needs to be updated
        } else if fetcher.needsToUpdateMenu {
            completionHandler(.noData)
            fetcher.fetchMenu(completionHandler: { newMenu in
                self.weekMenu = newMenu
                mainQueue {
                    updateUIAndDisplayModes()
                    completionHandler(.newData) // TODO: Remove?
                }
            }, errorHandler: { error in
                mainQueue {
                    updateUIAndDisplayModes(with: error)
                    completionHandler(.failed)  // TODO: Remove?
                }
            })
        // Menu is up to date
        } else {
            completionHandler(.noData)
        }
    }
    
    
    func widgetMarginInsets(forProposedMarginInsets defaultMarginInsets: UIEdgeInsets) -> UIEdgeInsets {
        var insets = defaultMarginInsets
        insets.top = 10
        insets.right = 8
        insets.bottom = 28
        return insets
    }
    
    
    @available(iOSApplicationExtension 10.0, *)
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        updatePreferredContentSize(withMaximumSize: maxSize)
    }
}


// MARK: Helpers

private extension TodayViewController {
    
    func setUpLabels() {
        if #available(iOS 10, *) {
            // Menu label color and position
            label.textColor = .black
            labelLeadingConstraint.constant = 16
            labelTrailingConstraint.constant = 16
            labelTopConstraint.constant = 8
            labelBottomConstraint.isActive = false
            labelAlternateBottomConstraint.constant = 16
        }
    }
    
    
    func updateUI(with error: FetcherError? = nil) {
        // Show menu
        if let todayMenu = weekMenu.todayMenu {
            displayedMenu = todayMenu
            let dishes = todayMenu.allDishes
            if #available(iOS 10, *) {
                if todayMenu.isClosedMenu { // Today it's closed
                    label.isHidden = true
                    errorLabel.isHidden = false
                    errorLabel.text = NSLocalizedString("Closed")
                } else {    // Menu available
                    label.isHidden = false
                    errorLabel.isHidden = true
                    label.attributedText = dishes.with(paragraphSpacing: 8, lineBreakMode: .byTruncatingTail)
                }
            } else {
                label.text = dishes.replacingOccurrences(of: "\n", with: "\n\n")
            }
        // Show error
        } else {
            displayedMenu = nil
            let alternateLabel: UILabel
            if #available(iOS 10, *) {
                alternateLabel = errorLabel
                label.isHidden = true
                errorLabel.isHidden = false
            } else {
                alternateLabel = label
            }
            if let error = error {
                switch error {
                case .noInternetConnection:
                    alternateLabel.text = NSLocalizedString("No Connection")
                case .other:
                    alternateLabel.text = NSLocalizedString("Error")
                }
            } else {
                alternateLabel.text = NSLocalizedString("No Menu")
            }
        }
    }
    
    
    /// - warning: Lay out UI before using this.
    @available(iOSApplicationExtension 10.0, *)
    func updateAvailableDisplayModes() {
        if displayedMenu == nil || contentRequiresExpandedMode() == false {
            extensionContext?.widgetLargestAvailableDisplayMode = .compact
        } else {
            extensionContext?.widgetLargestAvailableDisplayMode = .expanded
        }
    }
    
    
    @available(iOS 10, *)
    func contentRequiresExpandedMode() -> Bool {
        // Asumes expanded widget will not take more space than strictly necessary for displaying the label
        return label.textRect(forBounds: CGRect(x: 0, y: 0, width: label.frame.width, height: CGFloat.greatestFiniteMagnitude), limitedToNumberOfLines: 0).height + labelTopConstraint.constant + labelAlternateBottomConstraint.constant >= view.frame.height
    }
    
    
    @available(iOSApplicationExtension 10.0, *)
    func updatePreferredContentSize(withMaximumSize maxSize: CGSize) {
        let verticalPadding = labelTopConstraint.constant + labelAlternateBottomConstraint.constant
        let horizontalPadding = labelLeadingConstraint.constant + labelTrailingConstraint.constant
        let textBounds = CGRect(x: 0, y: 0,
                                width: maxSize.width - horizontalPadding,
                                height: maxSize.height - verticalPadding)
        var newHeight = label.textRect(forBounds: textBounds, limitedToNumberOfLines: 0).size.height
        newHeight += verticalPadding
        preferredContentSize.height = min(newHeight, maxSize.height)
    }
}


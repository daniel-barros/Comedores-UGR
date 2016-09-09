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
    @IBOutlet weak var labelAlternateBottomConstraint: NSLayoutConstraint!  // A >= constraint used from iOS 10.
    
    private let fetcher = WeekMenuFetcher()
    
    var weekMenu = [DayMenu]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        weekMenu = fetcher.savedMenu ?? []
        
        setUpLabels()
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
    
    
    @available(iOSApplicationExtension 10.0, *)
    func widgetActiveDisplayModeDidChange(activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        var newSize = label.textRectForBounds(CGRect(x: 0, y: 0, width: label.frame.width, height: maxSize.height), limitedToNumberOfLines: 0).size
        newSize.height += labelTopConstraint.constant + labelAlternateBottomConstraint.constant
        preferredContentSize = newSize
        
    }
}


// MARK: Helpers

private extension TodayViewController {
    
    func setUpLabels() {
        
        let effect: UIVibrancyEffect
        if #available(iOS 10, *) {
            // Menu label color and position
            label.textColor = .blackColor()
            labelLeadingConstraint.constant = 16
            labelTrailingConstraint.constant = 16
            labelTopConstraint.constant = 8
            labelBottomConstraint.active = false
            labelAlternateBottomConstraint.constant = 16
            
            effect = UIVibrancyEffect.widgetSecondaryVibrancyEffect()
        } else {
            effect = UIVibrancyEffect.notificationCenterVibrancyEffect()
        }
        
        // Error label visual effect
        let visualEffectView = UIVisualEffectView(effect: effect)
        visualEffectView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(visualEffectView)
        NSLayoutConstraint.activateConstraints([
            visualEffectView.leadingAnchor.constraintEqualToAnchor(view.leadingAnchor),
            visualEffectView.trailingAnchor.constraintEqualToAnchor(view.trailingAnchor),
            visualEffectView.topAnchor.constraintEqualToAnchor(view.topAnchor),
            visualEffectView.bottomAnchor.constraintEqualToAnchor(view.bottomAnchor)
            ])
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        visualEffectView.contentView.addSubview(errorLabel)
        NSLayoutConstraint.activateConstraints([
            errorLabel.centerXAnchor.constraintEqualToAnchor(visualEffectView.centerXAnchor),
            errorLabel.centerYAnchor.constraintEqualToAnchor(visualEffectView.centerYAnchor)
            ])
    }
    
    
    func updateUI(error error: FetcherError? = nil) {
        
        if let dishes = weekMenu.todayMenu?.allDishes {
            if #available(iOS 10, *) {
                label.hidden = false
                errorLabel.hidden = true
                
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.paragraphSpacing = 8
                paragraphStyle.lineBreakMode = .ByTruncatingTail
                label.attributedText = NSAttributedString(string: dishes, attributes: [NSParagraphStyleAttributeName: paragraphStyle])
                
                if dishesLabelNeedsMoreSpace() {
                    extensionContext?.widgetLargestAvailableDisplayMode = .Expanded
                } else {
                    extensionContext?.widgetLargestAvailableDisplayMode = .Compact
                }
            } else {
                label.text = dishes.stringByReplacingOccurrencesOfString("\n", withString: "\n\n")
            }
        } else {
            let alternateLabel: UILabel
            if #available(iOS 10, *) {
                extensionContext?.widgetLargestAvailableDisplayMode = .Compact
                alternateLabel = errorLabel
                label.hidden = true
                errorLabel.hidden = false
            } else {
                alternateLabel = label
            }
            if let error = error {
                switch error {
                case .NoInternetConnection:
                    alternateLabel.text = NSLocalizedString("No Connection")
                case .Other:
                    alternateLabel.text = NSLocalizedString("Error")
                }
            } else {
                alternateLabel.text = NSLocalizedString("No Menu")
            }
        }
    }
    
    
    func dishesLabelNeedsMoreSpace() -> Bool {
        return label.textRectForBounds(CGRect(x: 0, y: 0, width: label.frame.width, height: CGFloat.max), limitedToNumberOfLines: 0).height > label.frame.height
    }
}


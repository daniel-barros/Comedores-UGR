//
//  MenuTableViewController.swift
//  Comedores UGR
//
//  Created by Daniel Barros López on 3/9/16.
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
import EventKitUI


class MenuTableViewController: UITableViewController {
    
    let fetcher = WeekMenuFetcher()
    
    var weekMenu = [DayMenu]()

    var error: FetcherError?
    
    var lastTimeTableViewReloaded: NSDate?
    
    /// `false` when there's a saved menu or the vc has already fetched since viewDidLoad().
    var isFetchingForFirstTime = true
    
    private let lastUpdateRowHeight: CGFloat = 46.45
    
    
    // MARK: -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        weekMenu = fetcher.savedMenu ?? []
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(appDidBecomeActive), name: UIApplicationDidBecomeActiveNotification, object: nil)
                
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 150
        
        if weekMenu.isEmpty == false {
            tableView.contentOffset.y = lastUpdateRowHeight   // Hides "last update" row
            isFetchingForFirstTime = false
        }
        
        refreshControl = UIRefreshControl()
        refreshControl!.addTarget(self, action: #selector(fetchData), forControlEvents: .ValueChanged)
        
        updateSeparatorsInset(forSize: tableView.frame.size)
        
        if fetcher.needsToUpdateMenu {
            if isFetchingForFirstTime {
                refreshControl!.beginRefreshing()
                tableView.contentOffset.y = -tableView.contentInset.top
            }
            fetchData()
        }
    }
    
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    
    func appDidBecomeActive(notification: NSNotification) {
        // Menu was updated externally and changes need to be reflected in UI
        if let savedMenu = fetcher.savedMenu where savedMenu != weekMenu {
            self.error = nil
            weekMenu = savedMenu
            tableView.reloadData()
        } else {
            // This makes sure that only the date for today's menu is highlighted
            if let lastReload = lastTimeTableViewReloaded
                where NSCalendar.currentCalendar().isDateInToday(lastReload) == false {
                tableView.reloadData()
            }
            // Menu needs to be updated
            if fetcher.needsToUpdateMenu {
                fetchData()
            }
        }
    }
    
    
    func fetchData() {
        if fetcher.isFetching == false {
            fetcher.fetchMenu(completionHandler: { menu in
                self.error = nil
                let menuChanged = self.weekMenu != menu
                self.weekMenu = menu
                self.lastTimeTableViewReloaded = NSDate()
                self.isFetchingForFirstTime = false
                mainQueue {
                    if menuChanged {
                        self.tableView.reloadData()
                    } else {
                        self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 0)], withRowAnimation: UITableViewRowAnimation.None)   // Updates "last updated" row
                    }
                    UIView.animateWithDuration(0.5) {
                        if self.refreshControl!.refreshing {
                            self.refreshControl!.endRefreshing()
                        }
                    }
                }
            }, errorHandler: { error in
                self.error = error
                self.lastTimeTableViewReloaded = NSDate()
                self.isFetchingForFirstTime = false
                mainQueue {
                    if self.weekMenu.isEmpty {
                        self.tableView.reloadData()
                    } else {
                        self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 0)], withRowAnimation: UITableViewRowAnimation.None)   // Updates "last updated" row showing error message temporarily
                        delay(1) {
                            self.error = nil    // Next time first cell is loaded it will show last update date instead of error message
                        }
                    }
                    UIView.animateWithDuration(0.5) {
                        if self.refreshControl!.refreshing {
                            self.refreshControl!.endRefreshing()
                        }
                    }
                }
            })
        }
    }
    
    
    @IBAction func prepareForUnwind(segue: UIStoryboardSegue) {
        
    }
    
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        updateSeparatorsInset(forSize: size)
    }
    
    
    // MARK: - UITableViewDataSource
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if weekMenu.isEmpty {
            return isFetchingForFirstTime ? 0 : 1
        }
        return weekMenu.count + 1
    }
    

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if weekMenu.isEmpty == false {
            // First row shows error message if any (eventually dismissed, see fetchData()), or last update date
            if indexPath.row == 0 {
                if let error = error {
                    let cell = tableView.dequeueReusableCellWithIdentifier("ErrorCell", forIndexPath: indexPath) as! ErrorTableViewCell
                    cell.configure(error: error)
                    return cell
                } else {
                    let cell = tableView.dequeueReusableCellWithIdentifier("LastUpdateCell", forIndexPath: indexPath) as! LastUpdateTableViewCell
                    cell.configure(date: fetcher.lastUpdate)
                    return cell
                }
            } else {
                let cell = tableView.dequeueReusableCellWithIdentifier("MenuCell", forIndexPath: indexPath) as! MenuTableViewCell
                cell.configure(menu: weekMenu[indexPath.row - 1])
                return cell
            }
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("ErrorCell", forIndexPath: indexPath) as! ErrorTableViewCell
            cell.configure(error: error)
            return cell
        }
    }
    
    
    // MARK: - UITableViewDelegate
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        
        if weekMenu.isEmpty || indexPath.row == 0 {
            return nil
        }
        
        let rowAction = UITableViewRowAction(style: .Normal, title: NSLocalizedString("Add to Calendar"), handler: { action, indexPath in
            
            let menu = self.weekMenu[indexPath.row - 1]
            
            switch EventManager.authorizationStatus {
            case .Authorized: self.presentEventEditViewController(menu: menu)
            case .Denied: self.presentAlertController(title: NSLocalizedString("Access Denied"), message: NSLocalizedString("Please go to the app's settings and allow us to access your calendars."), showsGoToSettings: true)
            case .NotDetermined: self.requestEventAccessPermission(menu: menu)
            case .Restricted: self.presentAlertController(title: NSLocalizedString("Access Restricted"), message: NSLocalizedString("Access to calendars is restricted, possibly due to parental controls being in place."), showsGoToSettings: false)
            }
        })
        
        rowAction.backgroundColor = UIColor.customAlternateRedColor()
        
        return [rowAction]
    }
    
    
    // MARK: - UIScrollViewDelegate
    
    // Avoids "last update" row scrolling down to first dish row
    override func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if lastUpdateRowIsVisible {
            self.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 0), atScrollPosition: .Top, animated: true)
        }
    }
}


// MARK: Helpers

private extension MenuTableViewController {
    
    func presentEventEditViewController(menu menu: DayMenu) {
        let eventVC = EKEventEditViewController()
        let eventStore = EKEventStore()
        eventVC.eventStore = eventStore
        eventVC.editViewDelegate = self
        eventVC.event = EventManager.createEvent(inEventStore: eventStore, forMenu: menu)
        self.presentViewController(eventVC, animated: true, completion: nil)
    }
    
    
    func presentAlertController(title title: String, message: String, showsGoToSettings: Bool) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel"), style: .Cancel, handler: { action in
            self.dismissViewControllerAnimated(true, completion: nil)
            self.tableView.editing = false
        })
        alertController.addAction(cancelAction)
        
        if showsGoToSettings {
            let settingsAction = UIAlertAction(title: NSLocalizedString("Go to Settings"), style: .Default, handler: { action in
                UIApplication.sharedApplication().openURL(NSURL(string:  UIApplicationOpenSettingsURLString)!)
            })
            alertController.addAction(settingsAction)
            alertController.preferredAction = settingsAction
        }
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    
    func requestEventAccessPermission(menu menu: DayMenu) {
        EventManager.requestAccessPermission { granted in
            mainQueue {
                if granted {
                    self.presentEventEditViewController(menu: menu)
                } else {
                    self.tableView.editing = false
                }
            }
        }
    }
    
    
    var lastUpdateRowIsVisible: Bool {
        let offset = navigationController!.navigationBar.frame.height + UIApplication.sharedApplication().statusBarFrame.height
        return weekMenu.isEmpty == false && tableView.contentOffset.y < lastUpdateRowHeight - offset
    }
    
    
    /// Updates the table view's separators left inset according to the given size.
    func updateSeparatorsInset(forSize size: CGSize) {
        tableView.separatorInset.left = size.width * 0.2 - 60
    }
    
}


// MARK: - EKEventEditViewDelegate

extension MenuTableViewController: EKEventEditViewDelegate {
    
    func eventEditViewController(controller: EKEventEditViewController, didCompleteWithAction action: EKEventEditViewAction) {
        if let event = controller.event where action == .Saved {
            EventManager.saveDefaultInfoFromEvent(event: event)
        }
        dismissViewControllerAnimated(true, completion: nil)
        self.tableView.editing = false
    }
}

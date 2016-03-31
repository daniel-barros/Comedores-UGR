//
//  MenuTableViewController.swift
//  Comedores UGR
//
//  Created by Daniel Barros López on 3/9/16.
//  Copyright © 2016 Daniel Barros. All rights reserved.
//

import UIKit
import EventKitUI


class MenuTableViewController: UITableViewController {
    
    let fetcher = WeekMenuFetcher()
    
    var weekMenu: [DayMenu] = {
        return NSUserDefaults.standardUserDefaults().menuForKey(DefaultsWeekMenuKey) ?? [DayMenu]()
    }()

    var error: FetcherError?
    
    var lastTimeTableViewReloaded: NSDate?
    
    private let lastUpdateRowHeight: CGFloat = 46.45
    
    
    // MARK: -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(appDidBecomeActive), name: UIApplicationDidBecomeActiveNotification, object: nil)
                
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 150
        if weekMenu.isEmpty == false {
            tableView.contentOffset.y = lastUpdateRowHeight   // Hides "last update" row
        }
        
        refreshControl = UIRefreshControl()
        refreshControl!.addTarget(self, action: #selector(fetchData), forControlEvents: .ValueChanged)
        
        fetchData()
    }
    
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    
    func appDidBecomeActive(notification: NSNotification) {
        // This makes sure that only the date for today's menu is highlighted
        if let lastReload = lastTimeTableViewReloaded
            where NSCalendar.currentCalendar().isDateInToday(lastReload) == false {
            tableView.reloadData()
        }
    }
    
    
    func fetchData() {
        if fetcher.isFetching == false {
            fetcher.fetchMenu(completionHandler: { menu in
                self.error = nil
                let menuChanged = !self.weekMenu.containsSameWeekMenuAs(menu)
                self.weekMenu = menu
                self.lastTimeTableViewReloaded = NSDate()
                mainQueue {
                    self.refreshControl!.endRefreshing()
                    if menuChanged {
                        self.tableView.reloadData()
                    } else {
                        self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 0)], withRowAnimation: UITableViewRowAnimation.None)
                    }
                    if menu.isEmpty == false {
                        self.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 0), atScrollPosition: .Top, animated: !menuChanged)
                    }
                }
            }, errorHandler: { error in
                self.error = error
                self.lastTimeTableViewReloaded = NSDate()
                mainQueue {
                    self.refreshControl!.endRefreshing()
                    if self.weekMenu.isEmpty {
                        self.tableView.reloadData()
                    } else {
                        self.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 0), atScrollPosition: .Top, animated: true)
                    }
                }
            })
        }
    }
    
    
    @IBAction func prepareForUnwind(segue: UIStoryboardSegue) {
        
    }
    
    
    // MARK: - UITableViewDataSource
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if weekMenu.isEmpty {
            return 1
        }
        return weekMenu.count + 1
    }
    

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if weekMenu.isEmpty == false {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCellWithIdentifier("LastUpdateCell", forIndexPath: indexPath) as! LastUpdateTableViewCell
                cell.configure()
                return cell
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
            case .Denied: self.presentAlertController(NSLocalizedString("Access Denied"), message: NSLocalizedString("Please go to the app's settings and allow us to access your calendars."), showsGoToSettings: true)
            case .NotDetermined: self.requestEventAccessPermission(menu: menu)
            case .Restricted: self.presentAlertController(NSLocalizedString("Access Restricted"), message: NSLocalizedString("Access to calendars is restricted, possibly due to parental controls being in place."), showsGoToSettings: false)
            }
        })
        
        rowAction.backgroundColor = UIColor.customRedColor()
        
        return [rowAction]
    }
    
    
    // MARK: Helpers
    
    private func presentEventEditViewController(menu menu: DayMenu) {
        let eventVC = EKEventEditViewController()
        let eventStore = EKEventStore()
        eventVC.eventStore = eventStore
        eventVC.editViewDelegate = self
        eventVC.event = EventManager.createEvent(inEventStore: eventStore, forMenu: menu)
        self.presentViewController(eventVC, animated: true, completion: nil)
    }
    
    
    private func presentAlertController(title: String, message: String, showsGoToSettings: Bool) {
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
    
    
    private func requestEventAccessPermission(menu menu: DayMenu) {
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

    
    // MARK: - UIScrollViewDelegate
    // Avoids "last update" row scrolling down to first dish row
    
    override func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if lastUpdateRowIsVisible {
            self.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 0), atScrollPosition: .Top, animated: true)
        }
    }
    
    // MARK: Helpers
    
    private var lastUpdateRowIsVisible: Bool {
        let offset = navigationController!.navigationBar.frame.height + UIApplication.sharedApplication().statusBarFrame.height
        return weekMenu.isEmpty == false && tableView.contentOffset.y < lastUpdateRowHeight - offset
    }
}


// MARK: - EKEventEditViewDelegate

extension MenuTableViewController: EKEventEditViewDelegate {
    
    func eventEditViewController(controller: EKEventEditViewController, didCompleteWithAction action: EKEventEditViewAction) {
        dismissViewControllerAnimated(true, completion: nil)
        self.tableView.editing = false
    }
    
//    func eventEditViewControllerDefaultCalendarForNewEvents(controller: EKEventEditViewController) -> EKCalendar {
//        
//    }
}

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
import SafariServices


class MenuTableViewController: UITableViewController {
    
    let fetcher = WeekMenuFetcher()
    
    var weekMenu = [DayMenu]()

    var error: FetcherError?
    
    var lastTimeTableViewReloaded: Date?
    
    /// `false` when there's a saved menu or the vc has already fetched since viewDidLoad().
    var isFetchingForFirstTime = true
    
    fileprivate let lastUpdateRowHeight: CGFloat = 46.45
    
    
    // MARK: -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        weekMenu = fetcher.savedMenu ?? []
        
        NotificationCenter.default.addObserver(self, selector: #selector(appDidBecomeActive), name: Notification.Name.UIApplicationDidBecomeActive, object: nil)
                
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 150
        
        if weekMenu.isEmpty == false {
            tableView.contentOffset.y = lastUpdateRowHeight   // Hides "last update" row
            isFetchingForFirstTime = false
        }
        
        refreshControl = UIRefreshControl()
        refreshControl!.addTarget(self, action: #selector(fetchData), for: .valueChanged)
        
        updateSeparatorsInset(for: tableView.frame.size)
        
        if fetcher.needsToUpdateMenu {
            if isFetchingForFirstTime {
                refreshControl!.layoutIfNeeded()
                refreshControl!.beginRefreshing()
                tableView.contentOffset.y = -tableView.contentInset.top
            }
            fetchData()
        }
    }
    
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    func appDidBecomeActive(_ notification: Notification) {
        // Menu was updated externally and changes need to be reflected in UI
        if let savedMenu = fetcher.savedMenu, savedMenu != weekMenu {
            self.error = nil
            weekMenu = savedMenu
            tableView.reloadData()
        } else {
            // This makes sure that only the date for today's menu is highlighted
            if let lastReload = lastTimeTableViewReloaded, Calendar.current.isDateInToday(lastReload) == false {
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
                self.lastTimeTableViewReloaded = Date()
                self.isFetchingForFirstTime = false
                mainQueue {
                    if menuChanged {
                        self.tableView.reloadData()
                    } else {
                        self.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: UITableViewRowAnimation.none)   // Updates "last updated" row
                    }
                    UIView.animate(withDuration: 0.5) {
                        if self.refreshControl!.isRefreshing {
                            self.refreshControl!.endRefreshing()
                        }
                    }
                }
            }, errorHandler: { error in
                self.error = error
                self.lastTimeTableViewReloaded = Date()
                self.isFetchingForFirstTime = false
                mainQueue {
                    if self.weekMenu.isEmpty {
                        self.tableView.reloadData()
                    } else {
                        self.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: UITableViewRowAnimation.none)   // Updates "last updated" row showing error message temporarily
                        delay(1) {
                            self.error = nil    // Next time first cell is loaded it will show last update date instead of error message
                        }
                    }
                    UIView.animate(withDuration: 0.5) {
                        if self.refreshControl!.isRefreshing {
                            self.refreshControl!.endRefreshing()
                        }
                    }
                }
            })
        }
    }
    
    
    @IBAction func prepareForUnwind(_ segue: UIStoryboardSegue) {
        
    }
    
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        updateSeparatorsInset(for: size)
    }
    
    
    // MARK: - UITableViewDataSource
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if weekMenu.isEmpty {
            return isFetchingForFirstTime ? 0 : 1
        }
        return weekMenu.count + 1
    }
    

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if weekMenu.isEmpty == false {
            // First row shows error message if any (eventually dismissed, see fetchData()), or last update date
            if indexPath.row == 0 {
                if let error = error {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "ErrorCell", for: indexPath) as! ErrorTableViewCell
                    cell.configure(with: error)
                    return cell
                } else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "LastUpdateCell", for: indexPath) as! LastUpdateTableViewCell
                    cell.configure(with: fetcher.lastUpdate)
                    return cell
                }
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "MenuCell", for: indexPath) as! MenuTableViewCell
                cell.configure(with: weekMenu[indexPath.row - 1])
                return cell
            }
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ErrorCell", for: indexPath) as! ErrorTableViewCell
            cell.configure(with: error)
            return cell
        }
    }
    
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.row == 0 { return false }
        if self.weekMenu[indexPath.row - 1].isClosedMenu { return false }
        return true
    }
    
    
    // MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        if weekMenu.isEmpty || indexPath.row == 0 {
            return nil
        }
        
        let menu = self.weekMenu[indexPath.row - 1]
        let calendarAction = addToCalendarRowAction(for: menu)
        if let allergensRowAction = allergensInfoRowAction(for: menu) {
            return [calendarAction, allergensRowAction]
        } else {
            return [calendarAction]
        }
    }
    
    
    // MARK: - UIScrollViewDelegate
    
    // Avoids "last update" row scrolling down to first dish row
    override func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if lastUpdateRowIsVisible {
            self.tableView.scrollToRow(at: IndexPath(row: 1, section: 0), at: .top, animated: true)
        }
    }
}


// MARK: Helpers

private extension MenuTableViewController {
    
    func addToCalendarRowAction(for menu: DayMenu) -> UITableViewRowAction {
        let rowAction = UITableViewRowAction(style: .normal,
                                             title: NSLocalizedString("Add to\nCalendar"),
                                             handler: { action, indexPath in
            switch EventManager.authorizationStatus {
            case .authorized: self.presentEventEditViewController(for: menu)
            case .denied: self.presentAlertController(title: NSLocalizedString("Access Denied"), message: NSLocalizedString("Please go to the app's settings and allow us to access your calendars."), showsGoToSettings: true)
            case .notDetermined: self.requestEventAccessPermission(for: menu)
            case .restricted: self.presentAlertController(title: NSLocalizedString("Access Restricted"), message: NSLocalizedString("Access to calendars is restricted, possibly due to parental controls being in place."), showsGoToSettings: false)
            }
        })
        rowAction.backgroundColor = .customAlternateRedColor
        return rowAction
    }
    
    
    func allergensInfoRowAction(for menu: DayMenu) -> UITableViewRowAction? {
        if let _ = menu.allergens {
            // TODO: Implement
            return nil
        } else {
            return nil
        }
    }
    
    
    func presentEventEditViewController(for menu: DayMenu) {
        let eventVC = EKEventEditViewController()
        let eventStore = EKEventStore()
        eventVC.eventStore = eventStore
        eventVC.editViewDelegate = self
        eventVC.event = EventManager.createEvent(in: eventStore, for: menu)
        self.present(eventVC, animated: true, completion: nil)
    }
    
    
    func presentAlertController(title: String, message: String, showsGoToSettings: Bool) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel"), style: .cancel, handler: { action in
            self.dismiss(animated: true, completion: nil)
            self.tableView.isEditing = false
        })
        alertController.addAction(cancelAction)
        
        if showsGoToSettings {
            let settingsAction = UIAlertAction(title: NSLocalizedString("Go to Settings"), style: .default, handler: { action in
                UIApplication.shared.openURL(URL(string:  UIApplicationOpenSettingsURLString)!)
            })
            alertController.addAction(settingsAction)
            alertController.preferredAction = settingsAction
        }
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    func requestEventAccessPermission(for menu: DayMenu) {
        EventManager.requestAccessPermission { granted in
            mainQueue {
                if granted {
                    self.presentEventEditViewController(for: menu)
                } else {
                    self.tableView.isEditing = false
                }
            }
        }
    }
    
    
    var lastUpdateRowIsVisible: Bool {
        let offset = navigationController!.navigationBar.frame.height + UIApplication.shared.statusBarFrame.height
        return weekMenu.isEmpty == false && tableView.contentOffset.y < lastUpdateRowHeight - offset
    }
    
    
    /// Updates the table view's separators left inset according to the given size.
    func updateSeparatorsInset(for size: CGSize) {
        tableView.separatorInset.left = size.width * 0.2 - 60
    }
    
}


// MARK: - EKEventEditViewDelegate

extension MenuTableViewController: EKEventEditViewDelegate {
    
    func eventEditViewController(_ controller: EKEventEditViewController, didCompleteWith action: EKEventEditViewAction) {
        if let event = controller.event, action == .saved {
            EventManager.saveDefaultInfo(from: event)
        }
        dismiss(animated: true, completion: nil)
        self.tableView.isEditing = false
    }
}

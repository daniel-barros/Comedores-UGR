//
//  MenuTableViewController.swift
//  Comedores UGR
//
//  Created by Daniel Barros López on 3/9/16.
//  Copyright © 2016 Daniel Barros. All rights reserved.
//

import UIKit


class MenuTableViewController: UITableViewController {
    
    let fetcher = WeekMenuFetcher()
    
    var weekMenu: [DayMenu] = {
        return NSUserDefaults.standardUserDefaults().menuForKey(DefaultsWeekMenuKey) ?? [DayMenu]()
    }()

    var error: FetcherError?
    
    private let lastUpdateRowHeight: CGFloat = 46.45
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 150
        if weekMenu.isEmpty == false {
            tableView.contentOffset.y = lastUpdateRowHeight   // Hides "last update" row
        }
        
        refreshControl = UIRefreshControl()
        refreshControl!.addTarget(self, action: #selector(fetchData), forControlEvents: .ValueChanged)
        
        fetchData()
    }
    
    
    func fetchData() {
        if fetcher.isFetching == false {
            fetcher.fetchMenu(completionHandler: { menu in
                self.error = nil
                let menuChanged = !self.weekMenu.containsSameWeekMenuAs(menu)
                self.weekMenu = menu
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
    
    
    // MARK: UITableViewDataSource
    
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
    
    
    // MARK: UIScrollViewDelegate
    
    // Avoids "last update" row scrolling down to first dish row
    override func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        let offset = navigationController!.navigationBar.frame.height + UIApplication.sharedApplication().statusBarFrame.height
        
        if weekMenu.isEmpty == false && tableView.contentOffset.y < lastUpdateRowHeight - offset {
            self.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 0), atScrollPosition: .Top, animated: true)
        }
    }
}


//
//  ViewController.swift
//  Comedores UGR
//
//  Created by Daniel Barros López on 3/9/16.
//  Copyright © 2016 Daniel Barros. All rights reserved.
//

import UIKit

// TODO: Watch glance
// TODO: Add info and contact screen
// TODO: Scroll to make today's menu visible on tableView reload
class MenuTableViewController: UITableViewController {
    
    let fetcher = WeekMenuFetcher()
    
    var weekMenu: [DayMenu] = {
        return NSUserDefaults.standardUserDefaults().menuForKey(DefaultsWeekMenuKey) ?? [DayMenu]()
    }() {
        didSet {
            guard weekMenu.isEmpty == false else {
                return
            }
            NSUserDefaults.standardUserDefaults().setMenu(weekMenu, forKey: DefaultsWeekMenuKey)
            NSUserDefaults.standardUserDefaults().setObject(NSDate(), forKey: DefaultsLastUpdatedKey)
        }
    }

    var error: FetcherError?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 150
        
        refreshControl = UIRefreshControl()
        refreshControl!.addTarget(self, action: #selector(fetchData), forControlEvents: .ValueChanged)
        
        fetchData()
    }
    
    
    func fetchData() {
        if fetcher.isFetching == false {
            fetcher.fetchMenuAsync(completionHandler: { menu in
                self.error = nil
                self.weekMenu = menu
                mainQueue {
                    self.refreshControl?.endRefreshing()
                    self.tableView.reloadData()
                }
            }, errorHandler: { error in
                self.error = error
                mainQueue {
                    self.refreshControl?.endRefreshing()
                    self.tableView.reloadData()
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
        return weekMenu.count
    }
    

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if weekMenu.isEmpty == false {
            let cell = tableView.dequeueReusableCellWithIdentifier("MenuCell", forIndexPath: indexPath) as! MenuTableViewCell
            cell.configure(menu: weekMenu[indexPath.row])
            return cell
        } else {
            let identifier: String
            if let error = error {
                switch error {
                case .NoInternetConnection:
                    identifier = "NoConnectionCell"
                case .Other:
                    identifier = "UnknownErrorCell"
                }
            } else {
                identifier = "NoDataCell"
            }
            return tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath)
        }
        
        
        
        
    }
}


//
//  ViewController.swift
//  Comedores UGR
//
//  Created by Daniel Barros López on 3/9/16.
//  Copyright © 2016 Daniel Barros. All rights reserved.
//

import UIKit

// TODO: Watch glance
// TODO: Localization (including app name)
// TODO: Add info and contact screen
// TODO: Scroll to make today's menu visible on tableView reload
class MenuTableViewController: UITableViewController {
    
    let fetcher = WeekMenuFetcher()
    
    var weekMenu: [DayMenu] = {
        if let archivedMenu = NSUserDefaults.standardUserDefaults().dataForKey(DefaultsWeekMenuKey),
            menu = NSKeyedUnarchiver.unarchiveObjectWithData(archivedMenu) as? [DayMenu] {
            return menu
        } else {
            return [DayMenu]()
        }
    }() {
        didSet {
            guard weekMenu.isEmpty == false else {
                return
            }
            let archivedMenu = NSKeyedArchiver.archivedDataWithRootObject(weekMenu)
            NSUserDefaults.standardUserDefaults().setObject(archivedMenu, forKey: DefaultsWeekMenuKey)
            NSUserDefaults.standardUserDefaults().setObject(NSDate(), forKey: DefaultsLastUpdatedKey)
        }
    }

    
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
                self.weekMenu = menu
                mainQueue {
                    self.refreshControl?.endRefreshing()
                    self.tableView.reloadData()
                }
            }, errorHandler: { error in
                mainQueue {
                    self.refreshControl?.endRefreshing()
                }
                // TODO: Handle error
                print(error)
            })
        }
    }
    
    
    @IBAction func prepareForUnwind(segue: UIStoryboardSegue) {
        
    }
    
    
    // MARK: UITableViewDelegate and UITableViewDataSource
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return weekMenu.count
    }
    

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MenuCell", forIndexPath: indexPath) as! MenuTableViewCell
        cell.configure(menu: weekMenu[indexPath.row])
        return cell
    }
}


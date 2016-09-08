//
//  MotionActivityTableViewController.swift
//  Drive
//
//  Created by Martin Normark on 08/09/16.
//  Copyright © 2016 Milkshake Software. All rights reserved.
//

import UIKit
import RealmSwift

class MotionActivityTableViewController: UITableViewController {
    
    private var activities: [MotionActivity] = [MotionActivity]()
    private let formatter = NSDateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        formatter.dateStyle = .MediumStyle
        formatter.timeStyle = .ShortStyle
        
        navigationItem.title = "Motion Activity"
        
        refreshControl = UIRefreshControl()
        refreshControl?.backgroundColor = UIColor.brownColor()
        refreshControl?.tintColor = UIColor.lightTextColor()
        refreshControl?.addTarget(self, action: #selector(handleRefresh(_:)), forControlEvents: .ValueChanged)
        
        reloadData()
    }
    
    func handleRefresh(refreshControl: UIRefreshControl) {
        reloadData()
        refreshControl.endRefreshing()
    }
    
    func reloadData() {
        activities = Array(DataStore.sharedInstance.objects(MotionActivity.self).sorted("date", ascending: false))
        tableView.reloadData()
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return activities.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell
        let activity = activities[indexPath.row]
        
        cell.textLabel!.text = activity.name
        cell.detailTextLabel?.text = formatter.stringFromDate(activity.date)
        
        return cell
    }
}
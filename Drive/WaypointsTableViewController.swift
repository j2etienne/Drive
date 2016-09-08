//
//  WaypointsTableViewController.swift
//  Drive
//
//  Created by Martin Normark on 08/09/16.
//  Copyright © 2016 Milkshake Software. All rights reserved.
//

import UIKit
import RealmSwift

class WaypointsViewController: UITableViewController {
    
    private var waypoints: [LocationWayPoint] = [LocationWayPoint]()
    private let formatter = NSDateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        formatter.dateStyle = .MediumStyle
        formatter.timeStyle = .ShortStyle
        
        navigationItem.title = "Waypoints"
        
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
        waypoints = Array(DataStore.sharedInstance.objects(LocationWayPoint.self).sorted("date", ascending: false))
        tableView.reloadData()
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return waypoints.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell
        let wp = waypoints[indexPath.row]
        
        cell.textLabel!.text = formatter.stringFromDate(wp.date)
        cell.detailTextLabel?.text = "lat: \(wp.lat), lon: \(wp.lon)"
        
        return cell
    }
}
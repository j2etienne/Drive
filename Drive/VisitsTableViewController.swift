//
//  VisitsTableViewController.swift
//  Drive
//
//  Created by Martin Normark on 08/09/16.
//  Copyright © 2016 Milkshake Software. All rights reserved.
//

import UIKit
import RealmSwift

class VisitsTableViewController: UITableViewController {
    private var visits: [LocationVisit] = [LocationVisit]()
    private let formatter = NSDateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        formatter.dateStyle = .MediumStyle
        formatter.timeStyle = .ShortStyle
        
        navigationItem.title = "Visits"
        
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
        visits = Array(DataStore.sharedInstance.objects(LocationVisit.self).sorted("date", ascending: false))
        tableView.reloadData()
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return visits.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell
        let visit = visits[indexPath.row]
        
        cell.textLabel!.text = visit.name
        cell.detailTextLabel?.text = "\(formatter.stringFromDate(visit.date)) - lat: \(visit.lat), lon: \(visit.lon)"
        
        return cell
    }
}
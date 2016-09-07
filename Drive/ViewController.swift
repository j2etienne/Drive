//
//  ViewController.swift
//  Drive
//
//  Created by Martin Normark on 05/09/16.
//  Copyright © 2016 Milkshake Software. All rights reserved.
//

import UIKit
import CoreMotion
import CoreLocation
import RealmSwift

class ViewController: UITableViewController {

    typealias Activity = (date: NSDate, activity: String, place: String?)

    private var isTrackingLocation = false
    private let locationManger = CLLocationManager()
    private let geoCoder = CLGeocoder()
    private let motionSensor: CMMotionActivityManager = CMMotionActivityManager()
    private var data: [Activity] = [Activity]()
    private let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
    private let formatter = NSDateFormatter()
    private var latestActivityType: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(Realm.Configuration.defaultConfiguration.fileURL!)
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 64
        
        formatter.dateStyle = .MediumStyle
        formatter.timeStyle = .MediumStyle
        
        navigationItem.title = "Activity"
        navigationItem.leftBarButtonItems = [UIBarButtonItem(title: "Begin", style: .Plain, target: self, action: #selector(ViewController.toggleLocationUpdates(_:)))]
        
        locationManger.activityType = .AutomotiveNavigation
        locationManger.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManger.distanceFilter = kCLDistanceFilterNone
        locationManger.delegate = self
        
        let motionActivities = DataStore.sharedInstance.objects(MotionActivity.self)
        
        self.data.appendContentsOf(motionActivities.map { (act) -> Activity in
            return (date: act.date, activity: act.name, place: nil)
        })
        
        let locationVisits = DataStore.sharedInstance.objects(LocationVisit.self)
        
        self.data.appendContentsOf(locationVisits.map { (act) -> Activity in
            var arriveOrDepart = ""
            
            if let arrivalDate = act.arrivalDate {
                arriveOrDepart += "Arrived: \(formatter.stringFromDate(arrivalDate)), "
            }
            
            if let departureDate = act.departureDate {
                arriveOrDepart += "Departed: \(formatter.stringFromDate(departureDate))"
            }
            
            return (date: act.date, activity: arriveOrDepart, place: act.name)
        })
        
        if CLLocationManager.locationServicesEnabled() {
            if CLLocationManager.authorizationStatus() == .NotDetermined {
                locationManger.requestAlwaysAuthorization()
            }
            else if CLLocationManager.authorizationStatus() == .AuthorizedAlways {
                toggleLocationUpdates()
            }
        }
        
        if CMMotionActivityManager.isActivityAvailable() {

            motionSensor.startActivityUpdatesToQueue(NSOperationQueue.mainQueue()) { data in
                
                self.navigationItem.leftBarButtonItems = [(self.navigationItem.leftBarButtonItems?.first)!, UIBarButtonItem(barButtonSystemItem: .Trash, target: self, action: #selector(ViewController.clearActivityUpdates(_:)))]
                self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: self.activityIndicator)
                self.activityIndicator.startAnimating()
                
                if let data = data {
                    dispatch_async(dispatch_get_main_queue()) {
                        var activityType: String?;
                        
                        if(data.stationary == true){
                            activityType = "Stationary"
                        } else if (data.walking == true){
                            activityType = "Walking"
                        } else if (data.running == true){
                            activityType = "Running"
                        } else if (data.automotive == true){
                            activityType = "Automotive"
                        }
                        
                        if let activityType = activityType where self.latestActivityType != activityType {
                            self.latestActivityType = activityType
                            
                            self.data.insert((date: NSDate(), activity: activityType, place: nil), atIndex: 0)
                            
                            self.tableView.reloadData()
                            
                            let act = MotionActivity()
                            act.date = NSDate()
                            act.name = activityType
                            
                            try! DataStore.sharedInstance.write({
                                DataStore.sharedInstance.add(act)
                            })
                        }
                    }
                }
                
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let activity: Activity = self.data[indexPath.row]
        var cellIdentifier = "Cell"
        var detailText = self.formatter.stringFromDate(activity.date)
        
        if let place = activity.place {
            cellIdentifier = "CellVisit"
            detailText = "\(self.formatter.stringFromDate(activity.date)): \(place)"
        }
        
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as UITableViewCell
        
        cell.textLabel!.text = activity.activity
        cell.detailTextLabel?.text = detailText
        
        return cell
    }
    
    func clearActivityUpdates(sender: UIBarButtonItem) {
        self.data.removeAll()
        self.tableView.reloadData()
    }
    
    func toggleLocationUpdates(sender: UIBarButtonItem? = nil) {
        if isTrackingLocation {
            self.locationManger.stopMonitoringVisits()
            self.locationManger.stopUpdatingLocation()
            
            isTrackingLocation = false
            self.navigationItem.leftBarButtonItems?.first?.title = "Start"
        }
        else {
            self.locationManger.startMonitoringVisits()
            self.locationManger.startUpdatingLocation()
            
            isTrackingLocation = true
            self.navigationItem.leftBarButtonItems?.first?.title = "Stop"
        }
    }
}

extension ViewController : CLLocationManagerDelegate {
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
    }
    
    func locationManager(manager: CLLocationManager, didVisit visit: CLVisit) {
        geoCoder.reverseGeocodeLocation(CLLocation(latitude: visit.coordinate.latitude, longitude: visit.coordinate.longitude), completionHandler: { (places, error) in
            
            if let place = places?.first {
                dispatch_async(dispatch_get_main_queue()) {
                    guard let placeName = place.name else { return }
                    
                    self.data.insert((date: NSDate(), activity: "Arrived: \(visit.arrivalDate), departure: \(visit.departureDate)", place: "\(placeName)"), atIndex: 0)
                
                    self.tableView.reloadData()
                    
                    let vst = LocationVisit()
                    vst.date = NSDate()
                    vst.name = placeName
                    vst.lat = visit.coordinate.latitude
                    vst.lon = visit.coordinate.longitude
                    
                    if visit.arrivalDate != NSDate.distantPast() {
                        vst.arrivalDate = visit.arrivalDate
                    }
                    
                    if visit.departureDate != NSDate.distantFuture() {
                        vst.departureDate = visit.departureDate
                    }
                    
                    try! DataStore.sharedInstance.write({
                        DataStore.sharedInstance.add(vst)
                    })
                    
                    let n = UILocalNotification()
                    n.soundName = UILocalNotificationDefaultSoundName
                    
                    if visit.departureDate == NSDate.distantFuture() {
                        n.alertTitle = "Welcome to \(placeName) 👽"
                        n.alertBody = "You arrived here: \(placeName)"
                    }
                    else {
                        n.alertTitle = "Adios from \(placeName) 😎"
                        n.alertBody = "Goodbye from: \(placeName) 👹"
                    }
                    
                    UIApplication.sharedApplication().presentLocalNotificationNow(n)
                }
            }
        })
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let waypoints = locations.map { (location) -> LocationWayPoint in
            let wp = LocationWayPoint()
            wp.date = location.timestamp
            wp.lat = location.coordinate.latitude
            wp.lon = location.coordinate.longitude
            wp.course = location.course
            wp.speed = location.speed
            
            print("logged location: \(wp.speed)")
            
            return wp
        }
        
        try! DataStore.sharedInstance.write({
            DataStore.sharedInstance.add(waypoints)
        })
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        let gpsError = GPSError()
        gpsError.date = NSDate()
        gpsError.title = error.localizedDescription
        gpsError.message = error.localizedFailureReason
        
        try! DataStore.sharedInstance.write({
            DataStore.sharedInstance.add(gpsError)
        })
    }
}